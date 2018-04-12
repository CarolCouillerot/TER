# Comvertit tous les pdfs de tous les dossiers en txt.
# Modifiable pour le rendre moins bourrin...


for d in ./*/;
do
	cd $d
	for f in ./*pdf
	do
		pdftotext $f
		pdftohtml -xml -i -s $f
	done
	cd ..
done
