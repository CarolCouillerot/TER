# Le but ici est de télécharger tous les pdf du dossier LREC, dont les liens se trouvent dans des fichiers nommés link.
# wget permet de télécharger un fichier.
# wget -i récupère toutes les adresses contenus dans le fichier mis en paramètre.
# wget -nc ne télécharge pas le fichier s'il est déjà présent dans le dossier.
# wget -nc -i permet donc d'éviter de télécharger les doublons présents dans le fichier mis en paramètre.

cd LREC
for d in ./*/; #pour chaque dossier de LREC
do
	cd $d
	wget -nc -i links
	cd ..
done
cd ..
