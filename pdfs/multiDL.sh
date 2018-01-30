# Based on this topic's answers :
# https://www.linuxquestions.org/questions/programming-9/download-consecutively-numbered-files-470298/

# Cette manière de faire est encore trop peu automatisée.
# On en a pour des J allant de 80 à 99, puis de 00 à 17.
# The way to do :
# Télécharger pour une séquence de 1 au premier fichier non trouvé,
#  le fichier 0 pouvant ne pas exister (essayer de le télécharger séparément à la séquence),
#  et pour de 1000 au premier millier non trouvé.
#  Et ce pour J allant de 80 à 99 puis de 00 à 17
#
# NOPE! Y'a mieux :
#
# On part de https://aclweb.org/anthology/
# On y ajoute <a href="?/???/">
# Et on y télécharge tous les <a href="*.pdf">

# récupère les liens menant aux listes de pdf
curl "https://aclweb.org/anthology/" > base
grep -e "[A-Z0-9]/[A-Z0-9]\{3\}/" ./base -o > result # suffixes des liens
awk '{print "https://aclweb.org/anthology/" $0}' result > result2 # liens entiers

#note, ne prend pas les liens de la ligne SIGs, ou de la line Donors Needed,
# mais ces liens semblent renvoyer vers des documents doublons

echo > links # initialise un fichier

while read line; do
    curl $line > fic #télécharge la page contenant les pdf
    grep -e "href=.\{,20\}\.pdf" ./fic -o > hrefs_ends #récupère les suffixes des liens des pdfs
    cut -d '=' -f "2" hrefs_ends > clean1_ends # nettoyage des suffixes
    cut -d '"' -f "1,2" clean1_ends --output-delimiter='' > clean2_ends
    #awk '{print "https://aclweb.org/anthology/" $0}' clean2_ends > links
    while read end; do
		echo $line$end >> links #envoie les liens dans links
    done < clean2_ends
done < result2 #la boucle s'exécute pour chaque ligne de ce fichier


#grep -e "href=.*\.pdf" ./text -o > result2

#

#for a in `seq -w `; do
#wget "${a}.pdf"
#done



