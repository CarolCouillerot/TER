import numpy
import pandas
import pylab
import matplotlib

db = pandas.read_csv("counter_diachronique_5_ans_head-tot.csv", index_col="Langue",sep=";")

db = db.sort_values(by=['Total'],ascending=False)
db = db.iloc[:,0:4]
dbf = db.iloc[10:,:].sum()
db = db.iloc[0:10,:]
db.loc["Else"] = dbf

tableau20 = [(31, 119, 180), (174, 199, 232), (255, 127, 14), (255, 187, 120), (44, 160, 44), (152, 223, 138), (214, 39, 40), (255, 152, 150), (148, 103, 189), (197, 176, 213), (140, 86, 75), (196, 156, 148), (227, 119, 194), (247, 182, 210), (127, 127, 127), (199, 199, 199), (188, 189, 34), (219, 219, 141), (23, 190, 207), (158, 218, 229)]

for i in range(len(tableau20)): 
	r, g, b = tableau20[i] 
	tableau20[i] = (r / 255., g / 255., b / 255.)

ax = db.transpose().plot(kind='area', color = tableau20, alpha=.7, title="Title Goes Here");

ax.set_xlabel("x axis units")
ax.set_ylabel("y axis units")

pylab.show()
