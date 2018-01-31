# récupère les liens menant aux listes de pdf

mv ACL/ P/
curl "https://aclweb.org/anthology/" > base
grep -e "P/[A-Z0-9]\{3\}/" ./base -o > result # suffixes des liens
rm base

while read line; do
    curl "https://aclweb.org/anthology/"$line > fic #télécharge la page contenant les pdf
    grep -e "P.\{7\}.pdf" ./fic -o > ends #récupère les suffixes des liens des pdfs
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

mv P/ ACL/

