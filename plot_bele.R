library(dplyr)
library(ggplot2)
library(tidytext)
library(ggforce)
df <- read.csv("bele_output.csv") %>% mutate(accuracy = accuracy * 100)
color_values <- c("blue", "red", "darkgreen",  "green", "darkgrey", "pink",  "darkgoldenrod1", "deeppink", "black", "cyan3")

# Define shapes
shape_values <- c(
  "Qwen2.5-Instruct" =16, 
  "Yi-1.5-Chat" = 16, 
  "DeepSeek-R1-Llama" = 16, 
  "DeepSeek-R1-Qwen"= 16,
  "InternLM3-Instruct" = 16, 
  "Baichuan2-Chat" = 16, 
  "Llama3-Instruct" = 9, 
  "Mistral-Instruct" = 9, 
  "Olmo2-Instruct"= 9, 
  "Gemma2-Instruct"=9
)

plot_boxplot <- function(dataframe) {
    dataframe %>%
    mutate(lang_name=reorder_within(lang_name, accuracy, lang_category, fun=mean))%>% 
    ggplot(aes(x = accuracy, y = lang_name)) +
    geom_point(size = 3, aes(colour = model_name_abrev, shape=model_name_abrev), position=position_dodge(width = .2)) +
    theme_minimal() +
    theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
    geom_vline(xintercept = 25, linetype = "dashed", color = "black") +
    scale_y_reordered()+
    scale_x_continuous(breaks = c(20, 40, 60, 80), limits = c(0, 100)) + 
    facet_col(factor(lang_category, levels = c("Mandarin Chinese", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
    scale_shape_manual(values = shape_values, breaks=names(shape_values)) +
    scale_color_manual(values = color_values, breaks=names(shape_values)) +
    labs(y="Languages", colour="Models", shape="Models", x= "MRC Accuracy (%)", size=10) 
}

plot_whisker <- function(dataframe) {
    dataframe %>%
    group_by(model_name_abrev, model_source, lang_category, lang_code, lang_name) %>% 
    summarise(mean_accuracy = mean(accuracy, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(
      lang_name=reorder_within(lang_name, mean_accuracy, lang_category, fun=mean),
      ) %>%
    ggplot(aes(x = mean_accuracy, y = lang_name, fill=model_source)) +
    geom_boxplot(position=position_dodge(1))+
    theme_minimal() +
    theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
    geom_vline(xintercept = 25, linetype = "dashed", color = "black") +
    scale_y_reordered() +
    scale_fill_discrete(breaks = c("Western", "China")) +
    scale_x_continuous(breaks = c(20, 40, 60, 80), limits = c(0, 100)) + 
    facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
    labs(y="Languages", x= "MRC Accuracy (%)", size=10, fill='Model Source')
}

# ---- whisker chat ---- #
aspect_ratio <- 1
height <- 7

grouped_df <- df %>% 
filter(instruction_tuned == 1) %>%
filter(chat_template == 0) %>%
filter(model_name_abrev != "DeepSeek-R1-Llama") %>%
filter(model_name_abrev != "DeepSeek-R1-Qwen") %>%
    group_by(model_name_abrev, model_source, lang_category, lang_code, lang_name) %>% 
    summarise(mean_accuracy = mean(accuracy, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(lang_name=reorder_within(lang_name, mean_accuracy, lang_category, fun=mean))

qwen_df <- df %>% filter(chat_template == 1) %>% filter(model_name_abrev == "DeepSeek-R1-Qwen") %>%
    mutate(lang_name=reorder_within(lang_name, accuracy, lang_category, fun=mean))

ggplot() +
  geom_boxplot(data=grouped_df, position=position_dodge(1), aes(x = mean_accuracy, y = lang_name, fill=model_source))+
  geom_point(data=qwen_df, position = position_nudge(y = -0.25), size = 3, aes(colour = model_name_abrev, shape=model_name_abrev, x = accuracy, y = lang_name)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  geom_vline(xintercept = 25, linetype = "dashed", color = "black") +
  scale_y_reordered() +
  scale_x_continuous(breaks = c(20, 40, 60, 80), limits = c(0, 100)) + 
  facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
  scale_shape_manual(values = c(17), breaks=c("DeepSeek-R1-Qwen")) +
    scale_color_manual(values = c("#99be25"), breaks=c("DeepSeek-R1-Qwen")) +
    scale_fill_discrete(breaks = c("Western", "China")) +
  labs(y="Languages", x= "MRC Accuracy (%)", size=10, fill='Model Source', shape="Models", colour="Models")
 
ggsave("figures/bele_whisker_full_chat_models_deepseekQwen_as_green_triangle.pdf", height = height , width = height * aspect_ratio)


ggplot() +
  geom_boxplot(data=grouped_df, position=position_dodge(1), aes(x = mean_accuracy, y = lang_name, fill=model_source))+
  # geom_point(data=qwen_df, position = position_nudge(y = -0.25), size = 3, aes(colour = model_name_abrev, shape=model_name_abrev, x = accuracy, y = lang_name)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  geom_vline(xintercept = 25, linetype = "dashed", color = "black") +
  scale_y_reordered() +
  scale_x_continuous(breaks = c(20, 40, 60, 80), limits = c(0, 100)) + 
  facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
  scale_fill_discrete(breaks = c("Western", "China")) +
  labs(y="Languages", x= "MRC Accuracy (%)", size=10, fill='Model Source', shape="Models", colour="Models")
 
ggsave("figures/bele_whisker_full_chat_models_no_deepseekQwen.pdf", height = height , width = height * aspect_ratio)


aspect_ratio <- 1
height <- 7
df %>% 
filter(instruction_tuned == 1) %>%
filter(chat_template == 0) %>%
filter(model_name_abrev != "DeepSeek-R1-Llama") %>%
plot_whisker()
ggsave("figures/bele_whisker_full_chat_models.pdf", height = height , width = height * aspect_ratio)

aspect_ratio <- 1
height <- 7
df %>% 
filter(instruction_tuned == 1) %>%
filter(chat_template == 1) %>%
filter(model_name_abrev != "DeepSeek-R1-Llama") %>%
plot_whisker()
ggsave("figures/bele_whisker_full_chat_model_chat_template.pdf", height = height , width = height * aspect_ratio)

# ---- whisker base ---- #
aspect_ratio <- 1
height <- 7
df %>% 
filter(instruction_tuned == 0) %>%
plot_whisker()
ggsave("figures/bele_whisker_full_base_models.pdf", height = height , width = height * aspect_ratio)

# # ---- boxplot chat few ---- #
height <- 5
aspect_ratio <- 1.2

df %>% 
filter(lang_name %in% c("Mandarin (Simplified)", "Yue (Cantonese)", "English", "French", "Japanese", "Lhasa Tibetan", "Lao", "Vietnamese"))%>% 
filter(instruction_tuned == 1) %>%
filter(chat_template == 0) %>%
plot_boxplot()

ggsave("figures/bele_boxplot_few_chat_models.pdf", height = height , width = height * aspect_ratio)

# ---- boxplot chat all ---- #
height <- 7
aspect_ratio <- 1

df %>% 
filter(instruction_tuned == 1) %>%
filter(chat_template == 0) %>%
plot_boxplot()

ggsave("figures/bele_boxplot_full_chat_models.pdf", height = height , width = height * aspect_ratio)

# df %>% 
# filter(instruction_tuned == 1) %>%
# filter(chat_template == 1) %>%
# plot_boxplot()

# ggsave("figures/bele_boxplot_full_chat_models_chat_template.pdf", height = height , width = height * aspect_ratio)

# ---- boxplot base all ---- #
# Define shapes
shape_values <- c(
  "Qwen2.5" =16, 
  "Yi-1.5" = 16,
  "InternLM2.5" = 16, 
  "Baichuan2" = 16, 
  "Llama3" = 9, 
  "Mistral" = 9, 
  "Olmo2"= 9, 
  "Gemma2"=9
)

color_values <- c("blue", "red", "darkgrey", "pink",  "darkgoldenrod1", "deeppink", "black", "cyan3")

height <- 7
aspect_ratio <- 1

df %>% 
filter(instruction_tuned == 0) %>%
plot_boxplot()

ggsave("figures/bele_boxplot_full_base_models.pdf", height = height , width = height * aspect_ratio)