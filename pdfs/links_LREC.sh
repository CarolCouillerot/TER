###############################################
# Récupère les liens menant aux listes de pdf,
##
# Utilise curl pour télécharger les pages html puis grep pour rechercher les liens correspondant aux motifs voulus.
# Les motifs sont simples à trouver car le site source formatise rigoureusement ses liens.

mv LREC/ L/
curl "https://aclweb.org/anthology/" > base
grep -e "L/[A-Z0-9]\{3\}/" ./base -o > result # suffixes des liens
rm base

while read line; do
    curl "https://aclweb.org/anthology/"$line > fic #télécharge la page contenant les pdf
    grep -e "href=.\{,60\}\.pdf" ./fic -o > hrefs_links #récupère les suffixes des liens des pdfs
    cut -d '=' -f "2" hrefs_links > clean1_links # nettoyage des suffixes
    cut -d '"' -f "1,2" clean1_links --output-delimiter='' > clean2_links
    while read link; do #va créer un fichier de liens dans de nombreux sous-dossiers
		mkdir -p $line
		cd $line
		echo $link >> links #envoie les liens dans links
		cd "../.."
    done < clean2_links
done < result #la boucle s'exécute pour chaque ligne de ce fichier

#supprime les fichiers inutiles
rm fic
rm hrefs_links
rm clean1_links
rm clean2_links
rm result

mv L/ LREC/

