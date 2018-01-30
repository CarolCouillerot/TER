# Le but ici est de télécharger tous les pdf dans leurs dossiers respectifs
# Les deux boucles for vont permettre de déplacer l'action dans ces dossiers et sous-dossiers
# wget permet de télécharger un fichier.
# wget -i récupère toutes les adresses contenus dans le fichier mis en paramètre.
# wget -nc ne télécharge pas le fichier s'il est déjà présent dans le dossier.
# wget -nc -i permet donc d'éviter de télécharger les doublons présents dans le fichier mis en paramètre.

for D in ./*/;
do
    cd $D
    for d in ./*/;
	do
		cd $d
		wget -nc -i links
		cd ..
	done
    cd ..
done

