library(tidyverse)
library(rstudioapi)
library(skimr)
library(data.table)
library(inspectdf)


df <- fread("bank-full.csv")

df %>% inspect_na()

df %>% glimpse()

df$day %>% unique()
df$day <- df$day %>% as.factor()


df %>% dim()


df$campaign %>% unique()
df$pdays %>% unique()
df$previous %>% unique()


#df %>% View()

df$y %>% table() %>% prop.table()
#Imbalance is required
#Unfortunately it gives an error:(

df$y <- df$y %>% factor(levels = c("yes","no"),
                        labels = c(1,0))


#Splitting into Train and Test set
library(caTools)
set.seed(123)
split <- df$y %>% sample.split(SplitRatio = 0.8)
train <- df %>% subset(split == TRUE)
test <- df %>% subset(split == FALSE)


#Fitting XGBoost
library(xgboost)
library(parsnip)
set.seed(123)

df %>% glimpse()

classification <- boost_tree(mode = "classification",
                             mtry = 30,
                             learn_rate = 0.35,
                             tree_depth = 6) %>% set_engine(engine = "xgboost") %>% 
                                                 fit(y ~ .,data=train)
              

#Predicting
y_pred <- classification %>% predict(new_data = test %>% select(-y))

y_pred

y_pred %>% table()
