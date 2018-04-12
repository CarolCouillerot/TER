############################
# Convertit les fichiers pdf en fichiers xml et txt
#  TODO: donner le choix de la conversion via un paramètre...
##
# Se lance depuis le dossier racine d'une conférence (/ACL, /LREC...),
#  quelque soit le répertoire où se trouve ce script (utilise un chemin relatif)
#

for d in ./*/;
do
	cd $d
	for f in ./*pdf
	do
		echo $f
		pdftotext $f
		pdftohtml -xml -i -s $f
	done
	cd ..
done
