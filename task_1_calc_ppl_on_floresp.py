from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
)
import torch
from pathlib import Path
from utils.ppl import eval_ppl
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--input_file", type=str)
parser.add_argument("--lang", type=str)
parser.add_argument("--model-path", type=str)
args = parser.parse_args()

## make dir
model_subname=args.model_path.split("/")[-1]
output_dir = f'./results/floresp_results_v2/dev_${args.lang}/${model_subname}'
output_dir = Path(args.output_dir)
output_dir.mkdir(exist_ok=True, parents=True)

## device
if torch.cuda.is_available():
    device = 'cuda'
else:
    device = 'cpu'

## load model
tokenizer = AutoTokenizer.from_pretrained(args.model_path, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(args.model_path, torch_dtype=torch.float16, trust_remote_code=True, device_map=device)
model.eval()

with open(args.input_file, "r") as f: 
    texts = f.readlines()

f = open(output_dir / "logs_2.txt", "w")
f.write("n_toks\tnll_sum\tppl\n")

for i, t in enumerate(texts):
    encodings = tokenizer(t, return_tensors="pt")
    n_toks = encodings.input_ids.size(1)
    nll_sum, ppl = eval_ppl(model, encodings)
    print(f"{n_toks}\t{nll_sum}\t{ppl}", file=f, flush=True)
f.close()