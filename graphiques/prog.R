
db = read.csv("counter_diachronique_5_ans_head.csv", sep=";", header=TRUE)
db = db[,1:4]
db = db[order(db$periode1,decreasing=TRUE),]
db = db[1:20,]
db = t(db)

# The palette with grey:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#E69F00")
# To use for fills, add

library(ggplot2)

db = read.csv("counter_diachronique_5_ans_test.csv", sep=",", header=TRUE)
ggplot(db, aes(x=periode, y=valeur, group=Langue, fill=Langue)) + geom_area(position="fill", size=1, colour="black") + scale_fill_manual(values=cbPalette)

#palette()[sample(1:8)]
