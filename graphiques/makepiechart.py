# utilisation 

import sys, getopt
import pandas
from matplotlib import pyplot
import numpy as np
pyplot.rcParams["figure.figsize"] = [10,10]
from io import BytesIO



# param df : dataframe à deux dimensions
#       indcol : colonne sur laquelle créer le piechart
#       threshold : seuil à partir duquel l'item est ajouté au piechart
def bake_pie(df,indcol,threshold,outfile):
	periodName = "periode" + str(indcol+1)
	labels = df.iloc[:df.shape[0],indcol]
	name = 'autre : ' + str((df[periodName] < threshold).sum())
	labels.loc[name] = np.sum([a for a in df[periodName] if a < threshold])
	labels.plot.pie()
	pyplot.savefig(outfile + ".svg")
   

def main(argv):
	inputfile = ''
	outputfile = ''
	try:
		opts, args = getopt.getopt(argv,"hi:o:n:t:",["ifile=","ofile=","numc=","threshold="])
	except getopt.GetoptError:
		print('makepiechart.py -i <inputfile> -o <outputfile>\ninputfile -n <index of column>: csv, outputfile is the name of the image file')
		sys.exit(2)
	if len(sys.argv) < 2:
		print('makepiechart.py -i <inputfile> -o <outputfile>\ninputfile -n <index of column>: csv, outputfile is the name of the image file')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('makepiechart.py -i <inputfile> -o <outputfile>\ninputfile -n <index of column>: csv, outputfile is the name of the image file')
			sys.exit()
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg
		elif opt in ("-n", "--numc"):
			numcolumn = int(arg)
		elif opt in ("-t", "--threshold"):
			threshold = float(arg)
	
	db = pandas.read_csv(inputfile, index_col="Langue",sep=";")
	bake_pie(db,numcolumn,threshold,outputfile)

if __name__ == "__main__":
	main(sys.argv[1:])



