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
1. Calculate perplexity
```sh
python3 calc_ppl_on_floresp.py --model-name ${model_name} --output-dir ${output_dir} --lang ${lang}
```
`lang`: values in the "lang_code_floresp" column of `langs.csv`, e.g. `ace_Arab`, `eng_Latn`. 
`model_name`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`

(#todo: output_dir)

2. Combine individual files from step 1
```sh
python3 combine_floresp_ppl_result.py
```

### Experiment 2: Zero-shot multiple choice reading comprehension on [Belebele](https://github.com/facebookresearch/belebele) dataset

1. Run zero-shot inference
```sh
python3 bele_multiple_choice.py --model-path ${model_path} --output-dir ${output_dir} --lang-id ${lang_id}
```
`lang-id`: values in the "lang_code_bele" column of `langs.csv`
`model_path`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`
(#todo: output_dir)

2. Combine individual files from step 1
```sh
python3 combine_bele_result.py
```

### Experiment 3: 
```sh
python3 predict_mc2_languages.py --model-path ${model_path} --output-dir ${output_dir} --lang ${lang}
```
`lang`: one of: `kazakh`, `uyghur`, `mongolian`, `tibetan`
`model_path`: huggingface model name, e.g. `mistralai/Mistral-7B-v0.3`
(#todo: output_dir)

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

