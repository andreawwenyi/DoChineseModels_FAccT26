import jsonlines
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
)
import torch
import pandas as pd
from pathlib import Path
from prompt_chat_models import load_model
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--lang-id", type=str)
parser.add_argument("--model-path", type=str)
args = parser.parse_args()

## read models.csv
models = pd.read_csv("models.csv")
models['system_prompt'] = models['system_prompt'].fillna("")

is_instruct_model = models[models['model_path_hf'] == args.model_path]["instruction_tuned"].values[0]
print("is_instruct_model: ", is_instruct_model)
if is_instruct_model:
    instruct_model = load_model(args.model_path)
if not is_instruct_model:
    tokenizer = AutoTokenizer.from_pretrained(args.model_path, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(args.model_path, torch_dtype=torch.float16, device_map="auto", trust_remote_code=True)

# make output_dir
model_subname=args.model_name.split("/")[-1]
if is_instruct_model:
    output_dir = f'./bele_results/{args.lang_id}/{model_subname}_chat_template/answers.jsonl'
else:
    output_dir = f"./bele_results/{args.lang_id}/{model_subname}/answers.jsonl"
output_dir = Path(args.output_dir)
output_dir.mkdir(exist_ok=True, parents=True)

def make_prompt(obj):
    instruction = "Given the following passage, query, and answer choices, output the letter corresponding to the correct answer."
    passage = obj['flores_passage']
    query = obj['question']
    A = obj['mc_answer1']
    B = obj['mc_answer2']
    C = obj['mc_answer3']
    D = obj['mc_answer4']
    prompt = f"{instruction}\n###\nPassage:\n{passage}\n###\nQuery:\n{query}\n###\nChoices:\n(A) {A}\n(B) {B}\n(C) {C}\n(D) {D}\n###\nAnswer:\n"
    return prompt
    
def prompt_model(obj):
    if is_instruct_model:
        system_prompt = models[models['model_path_hf'] == args.model_path]['system_prompt'].values[0]
        user_prompt = make_prompt(obj)
        response = instruct_model.prompt_chat_model(system_prompt, user_prompt)
        return response
    else:
        response = run_base_model(obj)
        return response

def run_base_model(obj):    
    prompt = make_prompt(obj)
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    outputs = model.generate(**inputs, max_new_tokens=200)
    outputs_decoded = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return outputs_decoded

with jsonlines.open(output_dir / "answers.jsonl", "w", flush=True) as writer:
    with jsonlines.open(f"data/Belebele/{args.lang_id}.jsonl") as reader:
        for obj in reader:
            zero_shot_answer = prompt_model(obj)
            writer.write({"link": obj["link"],
                          "question_number": obj["question_number"],
                          "correct_answer": obj["correct_answer_num"], 
                          "answer":zero_shot_answer})