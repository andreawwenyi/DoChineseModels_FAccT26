library(dplyr)
library(ggplot2)
library(tidytext)
library(ggforce)
df <- read.csv("floresp_nll_output_v2.csv") %>%
filter(lang_name!="English")

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

# shape_values <- c(
#   "Qwen2.5-Instruct" = 1, 
#   "Yi1.5-Chat" = 19, 
#   "DeepSeek-R1-Llama" = 19, 
#   "DeepSeek-R1-Qwen"= 19,
#   "InternLM3-Instruct" = 19, 
#   "Baichuan2-Chat" = 19, 
#   "Llama3-Instruct" = 2, 
#   "Mistral-Instruct" = 2, 
#   "Olmo2-Instruct" = 2, 
#   "Gemma2-Instruct" = 2
# )
# color_values <- c(
#   "Qwen2.5-Instruct" = "darkgreen", 
#   "Yi1.5-Chat" = "black", 
#   "DeepSeek-R1-Llama" = "green", 
#   "DeepSeek-R1-Qwen"= "darkgreen",
#   "InternLM3-Instruct" = "black", 
#   "Baichuan2-Chat" = "black", 
#   "Llama3-Instruct" = "green", 
#   "Mistral-Instruct" = "black", 
#   "Olmo2-Instruct" = "black", 
#   "Gemma2-Instruct"= "black"
# )

plot_whisker <- function(dataframe){
dataframe %>% group_by(model_name_abrev, model_source, lang_category, lang_code, lang_name) %>% 
summarise(mean_ip = mean(ip, na.rm = TRUE)) %>%
ungroup() %>%
mutate(lang_name=reorder_within(lang_name, mean_ip, lang_category, fun=mean)) %>%
ggplot(aes(x = mean_ip, y = lang_name, fill=model_source)) +
geom_boxplot(position=position_dodge(1))+
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  scale_y_reordered() +
  scale_x_continuous(breaks = c(0.2, 0.4, 0.6, 0.8), limits = c(0, 1)) + 
  facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
  scale_shape_manual(values = shape_values, breaks=names(shape_values)) +
  scale_color_manual(values = color_values, breaks=names(shape_values)) +
  scale_fill_discrete(breaks = c("Western", "China")) +
  labs(y="Languages", colour="Models", shape="Models", x="Mean IP Across Sentences", size=10, fill='Model Source')
}

plot_boxplot <- function(dataframe){
  dataframe %>%
group_by(model_name_abrev, lang_category, lang_code, lang_name) %>% 
summarise(mean_ip = mean(ip, na.rm = TRUE)) %>%
ungroup() %>%
mutate(lang_name=reorder_within(lang_name, mean_ip, lang_category, fun=mean)) %>%
ggplot(aes(x = mean_ip, y = lang_name)) +
  geom_point(size = 3, aes(colour = model_name_abrev, shape=model_name_abrev), position=position_dodge(width = .25)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  scale_y_reordered() +
  scale_x_continuous(breaks = c(0.2, 0.4, 0.6, 0.8), limits = c(0, 1)) + 
  facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "European", "Northeast Asian", "Southeast Asian", "Chinese Minorities")) ~ ., scales = "free_y", space = "free") +
  scale_shape_manual(values = shape_values, breaks=names(shape_values)) +
  scale_color_manual(values = color_values, breaks=names(shape_values)) +
  labs(y="Languages", colour="Models", shape="Models", x="Mean IP Across Sentences", size=10)
}

# df %>% 
# filter(lang_name!="English") %>%
# filter(instruction_tuned == 1) %>%
# group_by(model_name_abrev, lang_category, lang_code, lang_name) %>% 
# summarise(mean_ip = mean(ip, na.rm = TRUE)) %>%
# ungroup() %>%
# mutate(lang_name=reorder_within(lang_name, mean_ip, lang_category, fun=mean)) %>%
# mutate(alpha_value = ifelse(model_name_abrev %in% c("DeepSeek-R1-Llama", "DeepSeek-R1-Qwen", "Qwen2.5-Instruct", "Llama3-Instruct"), 1, 0.5)) %>%

# ggplot(aes(x = mean_ip, y = lang_name)) +
#   geom_point(size = 3, aes(
#     colour = model_name_abrev, 
#     shape=model_name_abrev, 
#     alpha = alpha_value)
#   ) +
#   guides(alpha = "none") +
#   theme_minimal() +
#   theme(
#     panel.grid.major.y = element_blank(), axis.title=element_text(size=10), 
#   legend.text = element_text(size=8)
#   ) +
#   scale_y_reordered() +
#   facet_col(factor(lang_category, levels = c("Mandarin Chinese", "Chinese Han Dialects (Other)", "US/European", "Northeast Asian", "Southeast Asian", "Chinese Ethnic Minorities")) ~ ., scales = "free_y", space = "free") +
#   scale_shape_manual(values = shape_values, breaks = c("Llama3-Instruct", "DeepSeek-R1-Llama", "Qwen2.5-Instruct", "DeepSeek-R1-Qwen")) +
#   scale_color_manual(values = color_values, breaks = c("Llama3-Instruct", "DeepSeek-R1-Llama", "Qwen2.5-Instruct", "DeepSeek-R1-Qwen")) +
#   labs(y="Languages", colour="Models", shape="Models", x="Mean IP Across Sentences", size=10)

# ggsave("figures/floresp_ip_boxplot_full_deepseek_chat_models.pdf", height = 7 , width = 7 * aspect_ratio)

# ---- boxplot chat few ---- #
height <- 5
aspect_ratio <- 1.2

df %>% 
filter(lang_name %in% c("Mandarin (Simplified)", "Yue (Cantonese)", "French", "Japanese", "Lhasa Tibetan", "Lao", "Vietnamese"))%>% 
filter(instruction_tuned == 1) %>%
plot_boxplot()

ggsave("figures/floresp_ip_boxplot_few_chat_models.pdf", height = height , width = height * aspect_ratio)

# ---- boxplot full chat ---- #
height <- 7
aspect_ratio <- 1
df %>% 
filter(instruction_tuned == 1) %>%
plot_boxplot()
ggsave("figures/floresp_ip_boxplot_full_chat_models.pdf", height = 7 , width = 7 * aspect_ratio)

# # ---- boxplot full base ---- #
# height <- 7
# aspect_ratio <- 1

# shape_values <- c(
#   "Qwen2.5" =16, 
#   "Yi-1.5" = 16,
#   "InternLM2.5" = 16, 
#   "Baichuan2" = 16, 
#   "Llama3" = 9, 
#   "Mistral" = 9, 
#   "Olmo2"= 9, 
#   "Gemma2"=9
# )

# color_values <- c("blue", "red", "darkgrey", "pink",  "darkgoldenrod1", "deeppink", "black", "cyan3")


df %>% 
filter(instruction_tuned == 0) %>%
plot_boxplot()
ggsave("figures/floresp_ip_boxplot_full_base_models.pdf", height = 7 , width = 7 * aspect_ratio)

# ---- whisker chat ---- #
aspect_ratio <- 1
height <- 7
df %>% 
filter(instruction_tuned == 1) %>%
filter(model_name_abrev != "DeepSeek-R1-Llama") %>%
plot_whisker()
ggsave("figures/floresp_ip_whisker_full_chat_models.pdf", height = height , width = height * aspect_ratio)

# ---- whisker base ---- #
aspect_ratio <- 1
height <- 7
df %>% 
filter(instruction_tuned == 0) %>%
plot_whisker()
ggsave("figures/floresp_ip_whisker_full_base_models.pdf", height = height , width = height * aspect_ratio)
