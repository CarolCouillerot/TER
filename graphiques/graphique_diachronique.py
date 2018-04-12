import pandas
from matplotlib import pyplot
import numpy as np
pyplot.rcParams["figure.figsize"] = [10,10]

# param df : dataframe à deux dimensions
#       indcol : colonne sur laquelle créer le piechart
#       threshold : seuil à partir duquel l'item est ajouté au piechart
def bake_pie(df,indcol,threshold):
    labels = db.iloc[:df.shape[0],indcol]
    name = 'autre : ' + str((db['periode1'] < threshold).sum())
    labels.loc[name] = np.sum([a for a in db['periode1'] if a < threshold])
    labels.plot.pie() 


db = pandas.read_csv("counter_diachronique_5_ans.csv", index_col="Langue",sep=";")
bake_pie(db,0,0.1)

