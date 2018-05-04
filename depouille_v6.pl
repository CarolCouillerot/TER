#----------------------------------------
# ROLE : lit les textes txt et cherche les langues
#----------------------------------------
# Active les avertissements de l'interpréteur
use warnings;
use POSIX;

# Variables globales, jamais déclarées nulle-part ailleurs
@tab_langues = ();
@tab_fausses_langues = ();
@tab_pays = ();
@tab_paires = ();
my %res_langues;

#concordance("corpus_ACL.txt");
#traitement_paires("res_paires_complement.txt", "res_paires_complement2.txt");
pretraitements("textes_adresses_echantillon.txt", "resultats_lecture.csv", "erreurs_lecture.txt", "corpus_lecture");
#etude_comparative("textes_adresses.txt", "textes_adresses_entier.txt", "erreurs_lecture.txt");
# analyse_diachronique("textes_adresses.txt", 5, "counter_diachronique_10_ans.csv");
# corpus_corpora("textes_adresses.txt", "corpora_occurrences.txt");
# clearCorporaOccurences("textes_adresses.txt","liste4.txt","corpora_occurrences.txt");

#----------------------------------------
sub concordance {
  my $texte = $_[0];
  my $line;
  my $conc;
  my $long = 60;
  my $affiche = "";
  #........................................... droite
  open(IN, "<$texte ")|| die "Je ne peux ouvrir le fichier $fic $!";
  open(OUT, ">$texte"."_droite ");
  while ($line = <IN>) {
    chop($line);
	print STDOUT (".");
	while ($line =~m /^(.+) (language|dictionnary|dictionnaries|corpus|corpora|text)(.+)$/) {
		$line = $1;
		$conc = substr($3, 0, $long);
		print OUT ("\n$2 - $conc");
	}
  }
  close(IN);
  close(OUT);
  #........................................... gauche
  open(IN, "<$texte ")|| die "Je ne peux ouvrir le fichier $fic $!";
  open(OUT, ">$texte"."_gauche ");
  while ($line = <IN>) {
    chop($line);
	print STDOUT (".");
	while ($line =~m /^(.+?) (language|dictionnary|dictionnaries|corpus|corpora|text)(.+)$/) {
		$line = $3;
		$conc = $1;
		$nb = length($conc);
		if ($nb - $long < 0) {
			$conc = substr($1, 0, $long);
		}
		else {
			$conc = substr($1, $nb-$long, $nb);
		}
		$affiche = "$conc - $2";
		$affiche =~s /;//g;
		print OUT ("\n$affiche");
		$affiche = reverse($affiche);
		print OUT (";$affiche");
	}
  }
  close(IN);
  close(OUT);
}


#--------------------------------------------------------
sub pretraitements {
  my $liste_fichiers = $_[0];
  my $fic_res = $_[1];
  my $fic_err = $_[2];
  my $fic_corpus = $_[3];
  open(TRACE, ">trace.txt ");
  open(RES, ">$fic_res ");
  open(ERR, ">$fic_err ");
  open(CORPUS, ">$fic_corpus ");
  lecture($liste_fichiers);
  close(CORPUS);
  close(TRACE);
  close(RES);
  close(ERR);
}

#--------------------------------------------------------
sub etude_comparative {
  my $liste_1 = $_[0];
  my $liste_2 = $_[1];
  my $fic_err = $_[2];
  open(TRACE, ">trace_comparatif.txt ");
  open(ERR, ">$fic_err ");
  lecture_comparative($liste_1, $liste_2);
  close(TRACE);
  close(ERR);
}


#----------------------------------------
# traiter auteurs (avant Abstract) pour pays ;
# debut : Abstract ;
# erreurs (voir source) :
# - pas de "@"
# - "@" après "abstract"
# lecture des donnees
# enlève fausses langues
# écrit les occurences de langues ainsi que de mots en rapport avec les corpus parallèles
#  dans resultat_lecture.csv
# TODO : virer les pays
sub lecture {
	#
	my $donnees = $_[0];
	
	my $line;
	my $fic;
	
	my $i;
	
	my $texte;
	
	my $langue;
	my $pays;
	
	my $nb_langues = 0;
	my $nb_fausses_langues = 0;
	my $nb_pays = 0;
	my $nb_textes = 0;
	my $nb_files = `wc -l $donnees | grep -o "[0-9]*"`;
	my $car;
	my $n1;
	my $n2;
	my $n3;
	my $n4;
	my $titre_trouve = 'false';
	my $pays_trouve;
	my $abstract_trouve;

	my $titre;
	my $auteurs;
	my $ref;
	
	my @langScore; #compte le nombre d'occurence par langue

	print("nb de fichiers : $nb_files\n");

	#............................................................liste de langues
	open(IN, "<langues5.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		if($line =~m /[a-z]/){ #élimine les lignes vides
			chomp($line);
			
			$langue = "";
			if($line =~m /^(.*)(\r|\n)$/){ # Pour se débarasser du retour à la ligne...
				$tab_langues[$nb_langues] = $1;
				$nb_langues++;
				$res_langues{$1} = 0;
				$langScore[$nb_langues] = 0;
			}else{
				$tab_langues[$nb_langues] = $line;
				$nb_langues++;
				$res_langues{$line} = 0;
				$langScore[$nb_langues] = 0;
			}
			
			#initialisation du tableau de hashage de comptage des langues
		}
	}
	close(IN);
	for ($i = 0; $i < $nb_langues ; $i++){
		print TRACE ("$tab_langues[$i]\n");
	}
	print TRACE ("nombre de langues : $nb_langues\n");
	#............................................................liste de fausses langues
	open(IN, "<fausses_langues.txt ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		chop($line);
		$langue = $line;
		$tab_fausses_langues[$nb_fausses_langues] = $langue;
		$nb_fausses_langues++;
	}
	close(IN);
	#............................................................liste de pays
	open(IN, "<pays.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		chomp($line);
		if($line =~m /([a-zA-Z -]+)/){ # Juste pour se débarasser une bonne fois pour toute du retour à la ligne
			$pays = $1;
		}
		
		$tab_pays[$nb_pays] = $pays;
		$nb_pays++;
	}
	close(IN);

	$i = 0;
	while ($i < $nb_langues) {
		#print TRACE ("\n $i $tab_langues[$i]");
		print RES (";$tab_langues[$i]");
		$i++;
	}
	$i = 0;
	while ($i < $nb_pays) {
		#print TRACE ("\n $i $tab_pays[$i]");
		print RES (";$tab_pays[$i]");
		$i++;
	}

	open(IN, "<$donnees ")|| die "Je ne peux ouvrir le fichier $fic $!";

	while ($line = <IN>) {
		chop($line);
		$fic = $line;
		print TRACE ("\n\n-------------------------------------\n$fic");
		print RES ("\n$fic");
		my $tmp = scalar( ($nb_textes/$nb_files)*100); # nombre de fichiers traités / nombre total de fichier * 100, permet d'afficher une progression
		print STDOUT "\rProgression : $tmp%"; # l'option \r permet à la progression de rester sur la même ligne du terminal. Pour cela, aucun autre print STDOUT doit être fait dans la boucle.

		#............................................................traitement d'un texte
		open(TEXT, "<$fic ")|| die "Je ne peux ouvrir le fichier $fic $!";
		$texte = "";
		$ref = "";
		$ref_trouvees = 'false';
		$nb_textes++;

		while ($line = <TEXT>) {
			chomp $line;
			$texte .= " ".$line;
		}
		close(TEXT);
		#print("\n");
		
		#print TRACE ("\n\n TEXTE : $texte");
		#............................................................recherche des langues
		#................ destruction d'expressions generatrices de bruit (fausses langues)
		#$texte = $titre . "\n" . $texte; # TO-DO: récupérer le titre
		$texte = "\n" . $texte; # TO-DO: récupérer le titre
		print CORPUS ("\n\n$fic");
		print CORPUS ("\n$texte");
	
		$i = 0;
		$marque = "";
		# boucle qui remplace une fausse langue par un espace
		while ($i < $nb_fausses_langues) {
			#print TRACE ("\n*** cherche $i '$tab_fausses_langues[$i]' \n dans : '$texte'");
			$langue = $tab_fausses_langues[$i];
			while ($texte =~m /(.*) $langue([ ,;?!].*)/i) {
				$texte = $1." ".$2;
				print TRACE ("\n	<= $langue");
				#print RES ("\n	<= $langue");
			}
			$i++;
		}
		
		#...................................................................
		# Recherche de contexte concernant les corpus parallèles
		
		# Multilingual corpora
		# aligned parallel corpora
		# comparable corpus
		# corpus/corpora => corp\w+ (peu de mot commence par corp, surtout précédé des mots ci-dessus)
		
		# while ($texte =~ /(Multilingual corp\w*)|(aligned parallel)|(aligned corp\w*)|(parallel corp\w*)|(comparable corp\w*)/gi) {
		# 	print TRACE ("\n\t:::: $1$2$3$4$5");
		# }
		
		#...................................................................
		# Comptage des langues par texte
		$i = 0;
		while ($i < $nb_langues) {
			#print TRACE ("\ncherche $i $tab_langues[$i] \n dans : '$texte'");
			$langue = $tab_langues[$i];
			if ($texte =~m / $langue[ ,;:?!~.!)-\/]+/i) {
				print TRACE ("\n	=> $langue");
				$marque = $i;
				#print RES ("\n	=> $langue");
			}
			if ($marque ne "") {
				print RES (";1");
				$marque = "";
				
				# Incrémentation du score de la langue dans le tableau de hashage
				$res_langues{$langue}++;
				$langScore[$i]++; # autre essaie de liste de comptage
			}
			else {
				print RES (";");
				}
			$i++;
		}
		
		#............................................................recherche des pays
		# $i = 0;
		# $pays_trouve = 'false';
		# while ($i < $nb_pays) {
		#print TRACE ("\ncherche $i '$tab_pays[$i]' dans '$auteurs'");
		# $pays = $tab_pays[$i];
		# while ($auteurs =~m /(.*) $pays(.*)/i) {
		# $auteurs = $1." ".$2;
		# print TRACE ("\n	.=> $pays");
		# $marque = $i;
		# $pays_trouve = 'true';
		# }
		# if ($marque ne "") {
		# print RES (";1");
		# $marque = "";
		# }
		# else {
		# print RES (";");
		# }
		# $i++;
		# }
		# if ($pays_trouve eq 'false') {
		# print ERR ("\n\n$fic \nPas de pays pour '$auteurs'");
		# }

	}
	print STDOUT ("\n$nb_textes textes traités");
	print TRACE ("\n$nb_textes textes traités");
	
	open(my $counter, ">counter.csv") or die "impossible d'ouvrire le fichier counter.txt\n";

	for ($i = 0; $i < $nb_langues ; $i++){
		print $counter "$tab_langues[$i];$langScore[$i]\n";
	}

	close($counter);
}

#----------------------------------------
# Fonction de recherche de contextes sur les mentions de corpus
sub corpus_corpora {
	my $donnees = $_[0];
	my $fic_res = $_[1];
	open(TRACE, ">$fic_res");
	
	my $line;
	my $fic;
	
	my $i;
	
	my $texte;
	
	my $nb_textes = 0;
	my $nb_files = `wc -l $donnees | grep -o "[0-9]*"`;
	
	print("nb de fichiers : $nb_files\n");

	open(IN, "<$donnees ")|| die "Je ne peux ouvrir le fichier $donnees $!";

	while ($line = <IN>) {
		chomp($line);
		$fic = $line;
		print TRACE ("\n\n-------------------------------------\n$fic");
		my $tmp = scalar( ($nb_textes/$nb_files)*100); # nombre de fichiers traités / nombre total de fichier * 100, permet d'afficher une progression
		print STDOUT "\rProgression : $tmp%"; # l'option \r permet à la progression de rester sur la même ligne du terminal. Pour cela, aucun autre print STDOUT doit être fait dans la boucle.

		#............................................................traitement d'un texte
		open(TEXT, "<$fic ")|| die "Je ne peux ouvrir le fichier $fic $!";
		$texte = "";
		$nb_textes++;

		while ($line = <TEXT>) {
			chomp $line;
			$texte .= " ".$line;
		}
		close(TEXT);
		
		$i = 0;
		
		#.........................................................
		# Recherche de contexte concernant les corpus mentionnés
		
		# corpus/corpora
		
		while ($texte =~ /(.{30} corpus.{15})|(.{30} corpora .{15})/gi) {
			my $tmp = $1 . $2;
			if($tmp =~ /[^\.] [A-Z]/) {
				print TRACE ("\n$tmp");
			}
		}
	}
	print STDOUT ("\n$nb_textes textes traités");
	print TRACE ("\n$nb_textes textes traités");
	
	close(TRACE);
}

#----------------------------------------
# Détecte les occurences de langues dans deux corpus distincts (provenant des mêmes sources),
#  et note les différences de résultat dans le fichier trace_comparatif.txt
# Les deux corpus :
#  - Corpus issu de la conversion des documents pdf en format txt via l'outil pdftotxt
#  - Corpus issu de la conversion en xml (via pdftohtml -xml) puis du prétraitement par elagage.pl et jeconcatene.pl (nom à changer)
# Données en entrée :
#  - Liste des adresses des fichiers composants le second corpus cité ci-dessus.
#   Les noms des fichiers doivent se terminer par "_traite.txt", correspondant au noms donnés par le script de prétraitement elagage.pl.
#   Les fichiers de l'autre corpus ont le même nom, mais sans le suffixe "_traite".
# Données en sortie :
#  - Le fichier trace_comparatif donnant pour chaque document source la langue ne se trouvant que dans l'un ou l'autre du fichier correspondant.
#   Il est précisé dans lequel la langue est présente.
sub lecture_comparative {
	my $donnees1 = $_[0];
	my $donnees2 = $_[1];
	
	my $in1;
	my $in2;
	my $line;
	my $line1;
	my $line2;
	my $fic1;
	my $fic2;
	
	my $i;
	
	my $langue;
	my $pays;
	
	my $nb_langues = 0;
	my $nb_fausses_langues = 0;
	my $nb_pays = 0;
	my $nb_textes = 0;
	
	my $nb_files = `wc -l $donnees1 | grep -o "[0-9]*"`;
	# Faire de même avec $donnees2 et envoyer une erreur s'ils n'ont pas le même nombre de fichiers ?
	
	my $texte;
	
	my $titre;
	my $auteurs;
	my $ref;
	
	my @langScore; #compte le nombre d'occurence par langue
	my @langScore2;

	print("nb de fichiers : $nb_files\n");

	#............................................................liste de langues
	open(IN, "<langues5.csv ")|| die "Je ne peux ouvrir le fichier langues5.csv";
	while ($line = <IN>) {
		if($line =~m /[a-z]/){ #élimine les lignes vides
			chomp($line);
			
			$langue = "";
			if($line =~m /^(.*)(\r|\n)$/){ # Pour se débarasser du retour à la ligne...
				$langue = $1;
			}else{
				$langue = $line;
			}
			
			#$langue = $line;
			$tab_langues[$nb_langues] = $langue;
			$langScore[$nb_langues] = 0;
			$langScore2[$nb_langues] = 0;
			$nb_langues++;
		}
	}
	close(IN);
	#............................................................liste de fausses langues
	open(IN, "<fausses_langues.txt ")|| die "Je ne peux ouvrir le fichier fausses_langues";
	while ($line = <IN>) {
		chop($line);
		$langue = $line;
		$tab_fausses_langues[$nb_fausses_langues] = $langue;
		$nb_fausses_langues++;
	}
	close(IN);
	#............................................................liste de pays
	open(IN, "<pays.csv ")|| die "Je ne peux ouvrir le fichier pays.csv";
	while ($line = <IN>) {
		chomp($line);
		if($line =~m /([a-zA-Z -]+)/){ # Juste pour se débarasser une bonne fois pour toute du retour à la ligne
			$pays = $1;
		}
		
		$tab_pays[$nb_pays] = $pays;
		$nb_pays++;
	}
	close(IN);

	open(in1, "<$donnees1 ")|| die "Je ne peux ouvrir le fichier $donnees1";
	open(in2, "<$donnees2 ")|| die "Je ne peux ouvrir le fichier $donnees2";

	while ($line1 = <in1> and $line2 = <in2>) {
		chop($line1);
		chop($line2);
		$fic1 = $line1;
		$fic2 = $line2;
		
		print TRACE ("\n\n-------------------------------------\n$fic1");
		my $tmp = scalar( ($nb_textes/$nb_files)*100); # nombre de fichiers traités / nombre total de fichier * 100, permet d'afficher une progression
		print STDOUT "\rProgression : $tmp%"; # l'option \r permet à la progression de rester sur la même ligne du terminal. Pour cela, aucun autre print STDOUT doit être fait dans la boucle.

		#............................................................traitement d'un texte
		$texte = "";
		my $texte2 = "";
		
		$nb_textes++;
		
		open(TEXT, "<$fic1 ")|| die "Je ne peux ouvrir le fichier $fic1 $!";
		
		while ($line = <TEXT>) {
			chomp $line;
			$texte .= " ".$line;
		}
		close(TEXT);
		
		
		open(TEXT, "<$fic2 ")|| die "Je ne peux ouvrir le fichier $fic2 $!";
		
		while ($line = <TEXT>) {
			chomp $line;
			$texte2 .= " ".$line;
		}
		close(TEXT);
		
		#print("\n");
		
		#print TRACE ("\n\n TEXTE : $texte");
		#............................................................recherche des langues
		#................ destruction d'expressions generatrices de bruit (fausses langues)
		#$texte = $titre . "\n" . $texte; # TO-DO: récupérer le titre
		$texte = "\n" . $texte; # TO-DO: récupérer le titre
		
		$i = 0;
		$marque = "";
		# boucle qui remplace une fausse langue par un espace
		while ($i < $nb_fausses_langues) {
			#print TRACE ("\n*** cherche $i '$tab_fausses_langues[$i]' \n dans : '$texte'");
			$langue = $tab_fausses_langues[$i];
			
			while ($texte =~m /(.*) $langue([ ,;?!].*)/i) {
				$texte = $1." ".$2;
				#print TRACE ("\n	<= $langue");
			}
			
			while ($texte2 =~m /(.*) $langue([ ,;?!].*)/i) {
				$texte2 = $1." ".$2;
				#print TRACE ("\n	<= $langue");
			}
			
			$i++;
		}
		
		##############################################################
		# C'est là que ce fait la comparaison entre les deux textes
		#
		
		$i = 0;
		while ($i < $nb_langues) {
			my $found = 0;
			my $found2 = 0;
			
			#print TRACE ("\ncherche $i $tab_langues[$i] \n dans : '$texte'");
			$langue = $tab_langues[$i];
			if ($texte =~m / $langue[ ,;:?!~.!)-\/]+/i) {
				$found=1;
				
				# Incrémentation du score de la langue
				$langScore[$i]++;
			}
			if ($texte2 =~m / $langue[ ,;:?!~.!)-\/]+/i) {
				$found2=1;
				
				# Incrémentation du score de la langue
				$langScore2[$i]++;
			}
			
			if ($found != $found2) {
				print TRACE "\nLangue : $langue";
				
				if($found){
					print TRACE "\n  Present dans traite";
				}else{
					print TRACE "\n  Absent dans traite";
				}
			}
			$i++;
		}
	}
	print STDOUT ("\n$nb_textes textes traités");
	print TRACE ("\n$nb_textes textes traités");
	
	open(my $counter, ">counter_comparatif.csv") or die "impossible d'ouvrire le fichier counter.txt\n";

	for ($i = 0; $i < $nb_langues ; $i++){
		print $counter "$tab_langues[$i];$langScore[$i];$langScore2[$i]\n";
	}

	close($counter);
}

#----------------------------------------
# Effectue une analyse temporelle : les occurences des langues par période
# Entrée : corpus, langue.csv, pays.csv, fausses_langues.csv, taille de la période
# Sortie : 1 fichiers "analyse_dia.txt" avec le nombre d'occurences de langues par période
sub analyse_diachronique {
	my $donnees = $_[0];
	my $periode = $_[1];
	my $fichier_res = $_[2]; 
	my $line;
	my $fic;
	my $i;
	my $langue;
	my $pays;
	my $nb_langues = 0;
	my $nb_fausses_langues = 0;
	my $nb_pays = 0;
	my $nb_textes = 0;
	my $nb_files = `wc -l $donnees | grep -o "[0-9]*"`;
	my $texte;
	my $ind_periode = 0;
	my $date_prec = "00";
	my $num_periode = 1;
	my $numberOfYear = 18;
	my $numberOfPeriod = ceil($numberOfYear/$periode);
	my @nbTextesParPeriode;
	my @totalLang = 0;

	my $datePeriode = "00";
	my @langScore; #compte le nombre d'occurence par langue

	for $i (1 .. $numberOfPeriod) { 
		$nbTextesParPeriode[$i] = 0; 
		$totalLang[$i] = 0;
	}

	open(TRACE, ">trace_diachronique.txt") || die "Je ne peux ouvrir le fichier trace_diachronique.txt $!";
	open(RES, ">$fichier_res") || die "Je ne peux ouvrir le fichier $fichier_res $!";

	#............................................................liste de langues
	open(IN, "<langues5.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		if($line =~m /[a-z]/){ #élimine les lignes vides
			chomp($line);
			
			$langue = "";
			if($line =~m /^(.*)(\r|\n)$/){ # Pour se débarasser du retour à la ligne...
				$langue = $1;
			}
			$tab_langues[$nb_langues] = $langue;
			$langScore[$nb_langues] = [ initTab($numberOfPeriod,$langue) ];
			$nb_langues++;
		}
	}
	close(IN);
	#............................................................liste de fausses langues
	open(IN, "<fausses_langues.txt ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		chop($line);
		$langue = $line;
		$tab_fausses_langues[$nb_fausses_langues] = $langue;
		$nb_fausses_langues++;
	}
	close(IN);
	#............................................................liste de pays
	open(IN, "<pays.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		chomp($line);
		if($line =~m /([a-zA-Z -]+)/){ # Juste pour se débarasser une bonne fois pour toute du retour à la ligne
			$pays = $1;
		}
		
		$tab_pays[$nb_pays] = $pays;
		$nb_pays++;
	}
	close(IN);

	open(IN, "<$donnees ")|| die "Je ne peux ouvrir le fichier $fic $!";

	while ($line = <IN>) {
		chop($line);
		$fic = $line;
		my $date;
		if ($fic =~m /P([0-9][0-9])/) {
			$date = $1; 
		}
		if( $date > $date_prec) { 
			$ind_periode++;
			$date_prec = $date;

			if($ind_periode >= $periode) {
				$ind_periode = 0;
				$num_periode++;
				# $datePeriode .= "- $date_prec ; $date";
			}
		}
		# nombre de fichiers traités / nombre total de fichier * 100, permet d'afficher une progression
		my $tmp = sprintf "%.2f", scalar( ($nb_textes/$nb_files)*100); 
		print STDOUT "\rProgression : $tmp%"; # l'option \r permet à la progression de rester sur la même ligne du terminal. Pour cela, aucun autre print STDOUT doit être fait dans la boucle.

		#............................................................traitement d'un texte
		open(TEXT, "<$fic ")|| die "Je ne peux ouvrir le fichier $fic $!";
		$nb_textes++;
		$nbTextesParPeriode[$num_periode]++;
		$texte = "";

		while ($line = <TEXT>) {
			chomp $line;
			$texte .= " ".$line;
		}
		close(TEXT);
		
		$i = 0;
		$marque = "";
		# boucle qui remplace une fausse langue par un espace
		while ($i < $nb_fausses_langues) {
			$langue = $tab_fausses_langues[$i];
			while ($texte =~m /(.*) $langue([ ,;?!].*)/i) {
				$texte = $1." ".$2;
				print TRACE ("\n	<= $langue");
			}
			$i++;
		}
	
		#...................................................................
		# Comptage des langues par texte
		$i = 0;
		while ($i < $nb_langues) {
			$langue = $tab_langues[$i];
			if ($texte =~m / $langue[ ,;:?!~.!)-\/]+/i) {
				$marque = $i;
			}
			if ($marque ne "") {
				$marque = "";
				$totalLang[$num_periode]++;
				$langScore[$i][$num_periode]++; 
				print TRACE ("$tab_langues[$i] : $langScore[$i]\n-------------------------------------");
			}
			$i++;
		}

	}

	my $percent;
	for $i ( 0 .. $#langScore ) {		
   		for $j ( 0 .. $#{$langScore[$i]} ) {
   			if ($j > 0) {
   				$percent = sprintf "%.3f", scalar( $langScore[$i][$j] / $totalLang[$j]);
	   			print RES ("$percent;")
	   		}
	   		else {
   				print RES ("$langScore[$i][$j];");
   			}
    	}
   	print RES ("\n");
	}
	print TRACE ("\n$datePeriode \n");
	
	close(TRACE);
	close(RES);
}



#--------------------------
# Fonction qui retourne un tableau de taille n+1(paramètre) 
# initialisé à 0 avec nom de langue en premiere case
sub initTab {
	my $size = $_[0];
	my $langue = $_[1];
	my @tableau;

	$tableau[0] = $langue;
	for $i (1 .. $size) {
		$tableau[$i] = 0;
	}

	return @tableau;
}

#--------------------------
# Fonction qui nettoie les résultats sortis par la fonction corpus-corpora
# en enlevant les lignes avec des noms de langues présent ou
# des corpus déjà connus
# params : fichier entrée : textes_adresses.txt
#							liste_corpus.txt
#		fichier sortie : corpora_occurrences.txt
sub clearCorporaOccurences {
	my $donnees = $_[0];
	my $fic_corpus = $_[1];
	my $fic_sortie = $_[2];
	my $sortie = $donnees; 

	my $nb_files = `wc -l $donnees | grep -o "[0-9]*"`;
	my $fic;
	my $texte = "";
	my $nb_langues = 0;
	my $nb_textes = 0;
	my @tab_corpus;
	my %corpusPerText;
	my $nb_corpus = 0;
	my $line;

	open(TRACE, ">trace.txt") || die "Je ne peux ouvrir le fichier trace.txt $!";

	#............................................................liste de langues
	open(IN, "<$fic_corpus")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		chomp($line);
		$tab_corpus[$nb_corpus] = $line;
		print TRACE ("$line\n");
		$nb_corpus++;
		$corpusPerText{$line} = 0;
	}
	close(IN);

	$nb_corpus--;
	# ................................................ traitement corpora_occurences
	open(IN, "<$donnees ")|| die "Je ne peux ouvrir le fichier $donnees $!";
	my $trouve = 0;
	my $newTexte = 0;
	while ($line = <IN>) {
		chop($line);
		$fic = $line;

		my $tmp = sprintf "%.2f", scalar( ($nb_textes/$nb_files)*100); 
		print STDOUT "\rProgression : $tmp%";

		open(TEXT, "<$fic ")|| die "Je ne peux ouvrir le fichier $fic $!";
		$nb_textes++;
		$texte = "";

		while ($line = <TEXT>) {
			chomp $line;
			$texte .= " ".$line;
		}
		close(TEXT);

		for $j (0 .. $nb_corpus) {
			if($texte =~m / $tab_corpus[$j]([ \.-]|[0-9])/i) {
				$corpusPerText{$tab_corpus[$j]}++;
			}
		}
		
	}
	close(IN);

	open(OUT, ">$fic_sortie") || die "Je ne peux ouvrir le fichier $sortie !";
	foreach  my $k (keys(%corpusPerText)) {
		print OUT ("$k : $corpusPerText{$k}\n");
	}

	
	close(TRACE);
}
