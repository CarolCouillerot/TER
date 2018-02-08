# Comvertit tous les pdfs de tous les dossiers en txt.
# Modifiable pour le rendre moins bourrin...


for D in ./*/;
do
	cd $D
	for d in ./*/;
	do
		cd $d
		for f in ./*pdf
		do
			echo $D$d$f >> ../../../textes_adresses.txt
			pdftotext $f
		done
		cd ..
	done
	cd ..
done


#for d in ./*/;
#do
#	cd $d
#	for f in ./*pdf
#	do
#		echo "F/"$d$f >> ../../../textes_ACL.txt
#		pdftotext $f
#	done
#	cd ..
#done
