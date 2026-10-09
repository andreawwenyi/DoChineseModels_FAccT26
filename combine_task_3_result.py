import pandas as pd

models = pd.read_csv("models.csv")
models["model_name"] = models["model_path_hf"].apply(lambda t: t.split("/")[-1])
model_order = models["model_name"]

metrics = list()
for lang in ["tibetan", "uyghur", "mongolian", "kazakh"]:
    for model_obj in models.to_dict(orient='records'):
        model_name = model_obj['model_name']
        is_instruction_tuned = model_obj['instruction_tuned']
        if is_instruction_tuned:
            answer_file = f"./mc2_langpred_results/{lang}/{model_name}_chat_template/answers.jsonl"
        else:
            answer_file = f"./mc2_langpred_results/{lang}/{model_name}/answers.jsonl"
        correct_answer = 0
        # df = pd.read_json(answer_file, lines=True)

        try:
            df = pd.read_json(answer_file, lines=True)
        except ValueError:
            print(model_name, lang, "ValueError")
            continue
        else:
            if len(df) < 101:
                print(model_name, lang, f"Only has {len(df)} rows")
                continue

            for ans_str in df['answer'].tolist():
                ans_str = ans_str.lower()
                if lang in ans_str:
                    correct_answer += 1
            
            print(model_name, lang)
            metrics.append({"model_name": model_name, 
                            "lang_name": lang.capitalize(),
                            "accuracy": 100 * (correct_answer / len(df))})

df = pd.DataFrame(metrics)
df = df.join(models.set_index(["model_name"]), on='model_name', how='left')
df.to_csv("mc2_langpred_output.csv", index=False)
