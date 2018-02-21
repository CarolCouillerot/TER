###############################################
# Récupère les liens menant aux listes de pdf,
##
# Utilise curl pour télécharger les pages html puis grep pour rechercher les liens correspondant aux motifs voulus.
# Les motifs sont simples à trouver car le site source formatise rigoureusement ses liens.

mv EACL/ E/
curl "https://aclweb.org/anthology/" > base
grep -e "E/[A-Z0-9]\{3\}/" ./base -o > result # suffixes des liens
rm base

while read line; do
    curl "https://aclweb.org/anthology/"$line > fic #télécharge la page contenant les pdf
    grep -e "E.\{7\}.pdf" ./fic -o > ends #récupère les suffixes des liens des pdfs
    while read end; do #va créer un fichier de liens dans de nombreux sous-dossiers
		mkdir -p $line
		cd $line
		echo "https://aclweb.org/anthology/"$line$end >> links #envoie les liens dans links
		cd "../.."
    done < ends
done < result #la boucle s'exécute pour chaque ligne de ce fichier

#supprime les fichiers inutiles
rm fic
rm ends
rm result

mv E/ EACL/

