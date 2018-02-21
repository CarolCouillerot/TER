# TER
Ce travail de recherche concerne l'étude de la diversité des langues étudiées en TALN.  
L'étude se concentre pour l'instant sur les travaux publiés sur le site de l'Association pour la Linguistique Computationnelle (aclweb.org/anthology/).

Ce github regroupe plusieurs scripts en Bash et Perl, dont que nous allons vous présenter :
- pdfs/ : links_ACL.sh, links_EACL.sh, ...  
- pdfs/ : dl_ACL.sh, dl_EACL.sh, ...  
- pdfs/converter.sh  
- depouille_v5.pl
- construit_corpus.pl
- recherche_format.pl

### pdfs/ links_ACL.sh, links_EACL.sh, ...
Ces scripts servent à récupérer les liens des documents pdf sur le site cité ci-dessus. Ces liens sont mis dans des dossiers organisés de la manière suivante :  
Les articles de recherche sont organisés sur le site de l'ACL par groupe : il y a les articles de l'ACL, ceux de EACL (le chapitre européen), etc. Chaque script link_... correspond à un groupe.  
Les articles sont en plus classés par années ; le script créera donc un sous-dossier par année. A noter que, sur le site, à chaque "groupe" est associé une lettre (tout du moins, dans les liens d'accès et de téléchargements). Les documents de 1984 et de 2001 de l'ACL se trouveront donc respectivement dans les dossiers ACL/P84/ et ACL/P01/ (P étant la lettre associée aux papiers de l'ACL).  
Pour rappel, le script dont nous parlions au départ ne va chercher que les liens de téléchargements des documents pdf. Ainsi, à l'issue de l'exécution du script links_ACL.sh ne se trouvera dans le dossier ACL/P84/ qu'un fichier links contenant une liste de liens, de même que dans le dossier ACL/01/.  

### pdfs/ dl_ACL.sh, dl_EACL.sh, ...
Ils sont à exécuter après les scripts links décrits plus haut.  
Par exemple, après avoir produit via links_ACL.sh tous les fichiers links dans les sous-dossiers ACL/**/, vous pouvez lancer le script dl_ACL.sh pour télécharger tous les documents  
Concrètement, ce script ne fait que lancer la commande suivante dans chaque sous-dossier :  
wget -nc -i links  
wget est une commande téléchargeant un fichier ciblé par un lien entré en paramètre.  
wget -i lance le téléchargement sur une liste de liens contenus dans le fichier entré en paramètre, en l'occurence dans notre cas : links.  
wget -nc, enfin, ne télécharge un fichier que s'il n'existe pas déjà de fichier du même nom sur l'ordinateur.  
Ce script va donc lancer le téléchargement des documents pdf correspondant aux liens. Il va les télécharger un par un, séquentiellement. Il est cependant possible, si vous souhaitez télécharger plusieurs fichiers en parallèle, de lancer plusieurs fois le même scripts. Grâce à l'option -nc, les scripts ne téléchargeront pas le même script.  

### pdfs/converter.sh
Ce script avait pour but de convertir tous les pdfs téléchargés dans le format voulu, en utilisant un outil de conversion en ligne de commande, comme pdftotxt ou pdftohtml. Ce script est voué à être modifié à nos guises, ou à ne pas être utilisé :  
Nous pouvons vouloir utiliser un autre outil de conversion, changer le format ou les options de conversion, ou encore modifier les dossiers sur lesquels appliquer la conversion.  


