# DoChineseModels_FAccT26

Code repository for FAccT 2026 publication "[Do Chinese Models Speak Chinese Languages](https://dl.acm.org/doi/pdf/10.1145/3805689.3812333)" by Andrea Wen-Yi Wang, Unso Jo, David Mimno.


## Environment
```
conda create -n {env_name} python=3.11
conda activate {env_name}
pip install -r requirements.txt
```

## Scripts
### Experiment 1: Information Parity on the [Flores+](https://huggingface.co/datasets/openlanguagedata/flores_plus) dataset
0. Download Flores+ dataset

1. Calculate perplexity
```sh
python3 exp_1_calc_ppl_on_floresp.py --model-path ${model_path} --lang ${lang} --input-file ${input-file}
```
`lang`: values in the "lang_code_floresp" column of `langs.csv`, e.g. `ace_Arab`, `eng_Latn`. 
`input_file`: filepath of the floresp dataset, e.g. `./floresp-v2.0-rc.2/dev/dev.eng_Latn`
`model_path`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`
optional: `--output-dir`. Default to `results/`

2. Combine individual files from step 1
```sh
python3 combine_exp_1_result.py
```

### Experiment 2: Zero-shot multiple choice reading comprehension on [Belebele](https://github.com/facebookresearch/belebele) dataset

0. Download Belebele data
1. Run zero-shot inference
```sh
python3 exp_2_bele_multiple_choice.py --model-path ${model_path} --lang-id ${lang_id} --input-file ${input-file}
```

`lang-id`: values in the "lang_code_bele" column of `langs.csv`, such as "zho_Hans". 
`input-file`: filepath of the Belebele data for that language, e.g. `./Belebele/zho_Hans.jsonl`
`model_path`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`

2. Combine individual files from step 1
```sh
python3 combine_exp_2_result.py
```

### Experiment 3: 
1. Run language prediction 
```sh
python3 exp_3_predict_mc2_languages.py --model-path ${model_path} --lang ${lang}
```
`lang`: one of: `kazakh`, `uyghur`, `mongolian`, `tibetan`
`model_path`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`

2. Combine individual files from step 1
```sh
python3 combine_exp_3_results.py
```

### Make figures
1. Experiment 1 
```sh
Rscript plot_floresp.R
```

2. Experiment 2
```sh
Rscript plot_bele.R
```

3. Experiment 3
```sh
Rscript plot_mc2.R
```

4. Figure x,y,z [todo]: in `analyze_result.ipynb`

5. Figure a,b,c [todo]
```sh
python pearson_correlation.py
```

