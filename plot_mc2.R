library(dplyr)
library(ggplot2)
library(tidytext)
library(ggforce)
df <- read.csv("mc2_langpred_output.csv")

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

height <- 4
aspect_ratio <-1.2
df %>% 
filter(instruction_tuned == 1) %>%
ggplot(aes(x = accuracy, y = lang_name)) +
  geom_point(size = 3, aes(colour = model_name_abrev, shape=model_name_abrev), position=position_dodge(width = .2)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  scale_y_reordered() +
  scale_shape_manual(values = shape_values, breaks=names(shape_values)) +
  scale_color_manual(values = color_values, breaks=names(shape_values)) +
  labs(y="Languages", colour="Models", shape="Models", x="Language Identification Accuracy (%)", size=10, fill='Model Source')

ggsave("figures/mc2_langpred_boxplot_full_chat_models.pdf", height = height , width = height * aspect_ratio)


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

height <- 4
aspect_ratio <-1.2
df %>% 
filter(instruction_tuned == 0) %>%
ggplot(aes(x = accuracy, y = lang_name)) +
  geom_point(size = 3, aes(colour = model_name_abrev, shape=model_name_abrev), position=position_dodge(width = .2)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), axis.title=element_text(size=10), legend.text = element_text(size=8)) +
  scale_y_reordered() +
  scale_shape_manual(values = shape_values, breaks=names(shape_values)) +
  scale_color_manual(values = color_values, breaks=names(shape_values)) +
  labs(y="Languages", colour="Models", shape="Models", x="Language Identification Accuracy (%)", size=10, fill='Model Source')

ggsave("figures/mc2_langpred_boxplot_full_base_models.pdf", height = height , width = height * aspect_ratio)