
# plot shapley values

library(httpgd)
hgd()
hgd_view()


library(readxl)
library(ggforce)
library(devtools)

#install_github("kassambara/easyGgplot2")
#devtools::install_github("kassambara/easyGgplot2")
#library(easyGgplot2)
#shpapley <- c(rnorm(200, 4, 1), rnorm(200, 5, 2), rnorm(400, 6, 1.5))
#group <- rep(c("Grp1", "Grp2", "Grp3", "Grp4", "Grp5"), c(100, 200, 300, 100, 100))
#cls <- rep(c("cls1", "cls2"), c(400, 400))

setwd(choose.dir())

lime <- read.csv("./Outcome/LIME_RD.csv")
shap <- read.csv("./Outcome/Shap_RD.csv")


# Create some data
p_shap <- ggplot(shap, aes(Feat,SHAP,color=Feat)) +  geom_violin(trim=FALSE) + coord_flip()
p_shap + geom_jitter(shape=16, position=position_jitter(0.1)) 


p_lime <- ggplot(lime, aes(Feat,LIME,color=Feat)) +  coord_flip() + geom_boxplot()
p_lime + geom_jitter(shape=16, position=position_jitter(0.2)) 


# scatter plot
library(ggpubr)
shap <- read.csv("./Outcome/Shap_RD.csv")
p <- ggscatter(shap, x = "Exp", y = "SHAP",
                add = "reg.line",
                conf.int = TRUE,
                color = "Feat")
p + stat_cor(aes(color = Feat))
p
