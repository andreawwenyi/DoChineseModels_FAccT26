import pandas as pd
import numpy as np
import random
from scipy import stats
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("floresp_nll_output_v2.csv")
df = df[df['lang_name'] != "English"].copy()
df = df.groupby(['lang_code', 'lang_name', 'lang_category', "model_name", "model_name_abrev", "model_source", "instruction_tuned"])["ip"].mean().reset_index(name='mean_ip')
df_base = df[df['instruction_tuned'] == 0]
df_base = df_base.groupby(['lang_code', 'lang_name', 'lang_category', "model_source", "instruction_tuned"])["mean_ip"].mean().reset_index(name='mean_ip')
df_base = df_base.pivot(index=['lang_name', 'lang_category'], columns='model_source', values='mean_ip').reset_index()
corrcoef, p_val = stats.pearsonr(df_base['China'], df_base['Western'])
sm_corr, sm_p_val = stats.spearmanr(df_base['China'], df_base['Western'])
print("[Base models | FLORES] Pearson Corr:", corrcoef, "P value: ", p_val)
print("[Base models | FLORES] Spearman Corr:", sm_corr, "P value: ", sm_p_val)
df_no_cmn_hans = df_base[df_base['lang_name'] != "Mandarin (Simplified)"]
print("[Base models | FLORES] Pearson Corr w/o Simplified Chinese: ", stats.pearsonr(df_no_cmn_hans['China'], df_no_cmn_hans['Western']))

sns.scatterplot(data = df_base, x='Western', y='China', hue='lang_category')
print(df_base[df_base['lang_category'] ==  "Chinese Minorities"])
for i, lang_name in enumerate(df_base['lang_name']):
    if lang_name == 'Mandarin (Simplified)':
        annotate_x_offset = -0.05
        annotate_y_offset = -0.025
        plt.annotate(lang_name, (df_base['Western'].iloc[i]+annotate_x_offset,  df_base['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name == "Yue (Cantonese)":
        annotate_x_offset = -0.1
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_base ['Western'].iloc[i]+annotate_x_offset, df_base ['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name in ['Mandarin (Traditional)']:
        annotate_x_offset = -0.1
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_base['Western'].iloc[i]+annotate_x_offset, df_base ['China'].iloc[i] + annotate_y_offset), size=11)
    # elif lang_name == 'Uyghur':


# Add regression line
z = np.polyfit(df_base['Western'], df_base['China'], 1)
slope = z[0]
intercept = z[1]
print(f"[Base models | FLORES] slope={slope}, intercept={intercept}")
p = np.poly1d(z)
plt.plot(df_base['Western'], p(df_base['Western']), color='gray', linestyle='-', alpha=0.8)
x = np.linspace(0, 1, 100)
plt.plot(x, x, color='darkgrey', linestyle='dotted') # plot x=y
plt.xlabel('Average IP of Western base models')
plt.ylabel('Average IP of Chinese base models')
plt.title(f'Pearson $r$ = {corrcoef:.3f}; Spearman $r$ = {sm_corr:.3f}; Slope = {slope:.3f}')
#plt.grid(True, alpha=0.3)
plt.xlim(0.15, 0.92)
plt.ylim(0.15, 0.92)
plt.legend(title='Language Category', bbox_to_anchor=(0.97, 0.3), borderaxespad=0, fontsize=9)
plt.tight_layout()
plt.savefig("figures/floresp_ip_scatter_base_models.pdf")
plt.close()


df_chat = df[(df['instruction_tuned'] == 1) & (df['model_name_abrev'] != "DeepSeek-R1-Llama")]
df_chat = df_chat.groupby(['lang_code', 'lang_name', 'lang_category', "model_source", "instruction_tuned"])["mean_ip"].mean().reset_index(name='mean_ip')

df_chat = df_chat.pivot(index=['lang_name', 'lang_category'], columns='model_source', values='mean_ip').reset_index()
corrcoef, p_val = stats.pearsonr(df_chat['China'], df_chat['Western'])
sm_corr, sm_p_val = stats.spearmanr(df_chat['China'], df_chat['Western'])
print("[Chat models | FLORES] Pearson Corr:", corrcoef, "P value: ", p_val)
print("[Chat models | FLORES] Spearman Corr:", sm_corr, "P value: ", sm_p_val)
df_no_cmn_hans = df_chat[df_chat['lang_name'] != "Mandarin (Simplified)"]
print("[Chat models | FLORES] Pearson Corr w/o Simplified Chinese: ", stats.pearsonr(df_no_cmn_hans['China'], df_no_cmn_hans['Western']))

sns.scatterplot(data = df_chat, x='Western', y='China', hue='lang_category')
for i, lang_name in enumerate(df_chat['lang_name']):
    if lang_name == 'Mandarin (Simplified)':
        annotate_x_offset = -0.05
        annotate_y_offset = -0.025
        plt.annotate(lang_name, (df_chat['Western'].iloc[i]+annotate_x_offset, df_chat['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name == "Yue (Cantonese)":
        annotate_x_offset = -0.1
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_chat['Western'].iloc[i]+annotate_x_offset, df_chat['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name in ['Mandarin (Traditional)']:
        annotate_x_offset = -0.1
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_chat['Western'].iloc[i]+annotate_x_offset, df_chat['China'].iloc[i] + annotate_y_offset), size=11)

# Add regression line
z = np.polyfit(df_chat['Western'], df_chat['China'], 1)
p = np.poly1d(z)
slope = z[0]
intercept = z[1]
print(f"[Chat models | FLORES], slope={slope}, intercept={intercept}")

plt.plot(df_chat['Western'], p(df_chat['Western']), color='gray', linestyle='-', alpha=0.8)
x = np.linspace(0, 1, 100)
plt.plot(x, x, color='darkgrey', linestyle='dotted') # plot x=y
plt.xlabel('Average IP of Western instruction-tuned models')
plt.ylabel('Average IP of Chinese instruction-tuned models')
plt.title(f'Pearson $r$ = {corrcoef:.3f}; Spearman $r$ = {sm_corr:.3f}; Slope = {slope:.3f}')
#plt.grid(True, alpha=0.3)
plt.xlim(0.15, 0.92)
plt.ylim(0.15, 0.92)
plt.legend(title='Language Category', bbox_to_anchor=(0.95, 0.4), borderaxespad=0, fontsize=9)
plt.tight_layout()
plt.savefig("figures/floresp_ip_scatter_chat_models.pdf")
plt.close()


df = pd.read_csv("bele_output.csv")
df = df[df['chat_template'] == 0].copy()
df = df[(df['model_source'].isin(["China", "Western"])) & (df['model_name_abrev'] != "DeepSeek-R1-Llama")].copy()

df = df.groupby(['lang_code', 'lang_name', 'lang_category', "model_source", 'instruction_tuned'])["accuracy"].mean().reset_index(name='mean_accuracy')
df = df.pivot(index=['lang_name', 'lang_category','instruction_tuned'], columns='model_source', values='mean_accuracy').reset_index()
df_base = df[df['instruction_tuned'] == 0].copy()

corrcoef, p_val = stats.pearsonr(df_base['China'], df_base['Western'])
sm_corr, sm_p_val = stats.spearmanr(df_base['China'], df_base['Western'])
print("[Base Models / Belebele] Pearson Corr: ", corrcoef, "P value: ", p_val)
print("[Base Models / Belebele] Spearman Corr: ", sm_corr, "P value: ", sm_p_val)
df_no_cmn_hans = df_base[df_base['lang_name'] != "Mandarin (Simplified)"]
print("[Base Models / Belebele] Pearson Corr w/o Simplified Chinese: ", stats.pearsonr(df_no_cmn_hans['China'], df_no_cmn_hans['Western']))

sns.scatterplot(data = df_base, x='Western', y='China', hue='lang_category')

for i, lang_name in enumerate(df_base['lang_name']):
    if lang_name in 'Mandarin (Simplified)':
        annotate_x_offset = -0.03
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_base['Western'].iloc[i]+annotate_x_offset, df_base['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name == 'Mandarin (Traditional)':
        annotate_x_offset = -0.15
        annotate_y_offset = -0.03
        plt.annotate(lang_name, (df_base['Western'].iloc[i]+annotate_x_offset, df_base['China'].iloc[i] + annotate_y_offset), size=11)

# Add regression line
z = np.polyfit(df_base['Western'], df_base['China'], 1)
p = np.poly1d(z)
slope = z[0]
intercept = z[1]
print(f"[Base Models / Belebele] slope={slope}, intercept={intercept}")
plt.plot(df_base['Western'], p(df_base['Western']), color='gray', linestyle='-', alpha=0.8)
x = np.linspace(0, 1, 100)
plt.plot(x, x, color='darkgrey', linestyle='dotted') # plot x=y
plt.xlabel('Average MRC accuracy of Western base models')
plt.ylabel('Average MRC accuracy of Chinese base models')
plt.title(f'Pearson $r$ = {corrcoef:.3f}; Spearman $r$ = {sm_corr:.3f}; Slope = {slope:.3f}')
plt.grid(True, alpha=0.3)
plt.xlim(0.23, 0.95)
plt.ylim(0.23, 0.95)
plt.legend(title='Language Category', bbox_to_anchor=(0.97, 0.3), borderaxespad=0, fontsize=9)
plt.tight_layout()
plt.savefig("figures/bele_accuracy_scatter_base_models.pdf")
plt.close()

df_chat = df[df['instruction_tuned'] == 1].copy()
corrcoef, p_val = stats.pearsonr(df_chat['China'], df_chat['Western'])
sm_corr, sm_p_val = stats.spearmanr(df_chat['China'], df_chat['Western'])
print("[Chat Models / Belebele] Pearson Corr: ", corrcoef, "P value: ", p_val)
print("[Chat Models / Belebele] Spearman Corr: ", sm_corr, "P value: ", sm_p_val)

df_no_cmn_hans = df_chat[df_chat['lang_name'] != "Mandarin (Simplified)"]
print("[Chat Models / Belebele] Pearson Corr w/o Simplified Chinese: ", stats.pearsonr(df_no_cmn_hans['China'], df_no_cmn_hans['Western']))

sns.scatterplot(data = df_chat, x='Western', y='China', hue='lang_category')

for i, lang_name in enumerate(df_chat['lang_name']):
    if lang_name in 'Mandarin (Simplified)':
        annotate_x_offset = -0.15
        annotate_y_offset = random.uniform(0.01, 0.02)
        plt.annotate(lang_name, (df_chat['Western'].iloc[i]+annotate_x_offset, df_chat['China'].iloc[i] + annotate_y_offset), size=11)
    elif lang_name == 'Mandarin (Traditional)':
        annotate_x_offset = -0.15
        annotate_y_offset = -0.03
        plt.annotate(lang_name, (df_chat['Western'].iloc[i]+annotate_x_offset, df_chat['China'].iloc[i] + annotate_y_offset), size=11)

# Add regression line
z = np.polyfit(df_chat['Western'], df_chat['China'], 1)
p = np.poly1d(z)
slope = z[0]
intercept = z[1]
print(f"[Chat Models / Belebele], slope={slope}, intercept={intercept}")
plt.plot(df_chat['Western'], p(df_chat['Western']), color='gray', linestyle='-', alpha=0.8)
x = np.linspace(0, 1, 100)
plt.plot(x, x, color='darkgrey', linestyle='dotted') # plot x=y
plt.xlabel('Average MRC accuracy of Western instruction-tuned models')
plt.ylabel('Average MRC accuracy of Chinese instruction-tuned models')
plt.title(f'Pearson $r$ = {corrcoef:.3f}; Spearman $r$ = {sm_corr:.3f}; Slope = {slope:.3f}')
#plt.grid(True, alpha=0.3)
plt.xlim(0.23, 0.95)
plt.ylim(0.23, 0.95)
plt.legend(title='Language Category', bbox_to_anchor=(0.95, 0.4), borderaxespad=0, fontsize=9)
plt.tight_layout()
plt.savefig("figures/bele_accuracy_scatter_chat_models.pdf")
plt.close()
