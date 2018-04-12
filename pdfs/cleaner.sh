############################
# Supprime tous les fichiers .txt, .xml et .back.
##
# Se lance depuis le dossier racine d'une conférence (/ACL, /LREC...),
#  quelque soit le répertoire où se trouve ce script (utilise un chemin relatif)
#

for d in ./*/; do
	cd $d;
	for f in ./*.txt; do
		rm $f
	done
	for f in ./*.xml; do
		rm $f
	done
	for f in ./*.back; do
		rm $f
	done
	cd ..
done
