# récupère les liens menant aux listes de pdf

mv EACL/ E/
curl "https://aclweb.org/anthology/" > base
grep -e "E/[A-Z0-9]\{3\}/" ./base -o > result # suffixes des liens
rm base

while read line; do
    curl "https://aclweb.org/anthology/"$line > fic #télécharge la page contenant les pdf
    grep -e "href=.\{,10\}\.pdf" ./fic -o > hrefs_ends #récupère les suffixes des liens des pdfs
    cut -d '=' -f "2" hrefs_ends > clean1_ends # nettoyage des suffixes
    cut -d '"' -f "1,2" clean1_ends --output-delimiter='' > clean2_ends
    while read end; do #va créer un fichier de liens dans de nombreux sous-dossiers
		mkdir -p $line
		cd $line
		echo "https://aclweb.org/anthology/"$line$end >> links #envoie les liens dans links
		cd "../.."
    done < clean2_ends
done < result #la boucle s'exécute pour chaque ligne de ce fichier

#supprime les fichiers inutiles
rm fic
rm hrefs_ends
rm clean1_ends
rm clean2_ends
rm result

mv E/ EACL/

