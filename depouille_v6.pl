#----------------------------------------
# ROLE : lit les textes txt et cherche les langues
 # modif apres proposition JE
#----------------------------------------
# Ces variables globales sont utilisées dans parcours et traite_texte,
#  elles sont aussi redéclarées dans lecture
  my $nb_langues = 0;
  my $nb_fausses_langues = 0;
  my $nb_pays = 0;
  my $nb_textes = 0;



# @tab_ancien_ve = ();
# @tab_ve = ();
# %tab_mediane = ();
#@tab_dpt = ();
#@tab_debut = ();
#@tab_fin = ();
@tab_langues = ();
@tab_fausses_langues = ();
@tab_pays = ();
@tab_paires = ();
my %res_langues;
#lance("test.txt", "resultats_test.csv", "erreurs_test.txt");
#lance("textes_ACL.txt", "resultats_ACL.csv", "erreurs_ACL.txt", "corpus_ACL.txt");
#lance("textes_LREC.txt", "resultats_LREC.csv", "erreurs_LREC.txt", "corpus_LREC.txt");
#concordance("corpus_ACL.txt");
#repertorie_langues("corpus_lecture", "langues3.csv", "resultats_tout_v4.csv", "erreurs_tout.txt");
#repertorie_langues("corpus_test.txt", "resultats_test.csv", "erreurs_test.txt");
#traitement_paires("res_paires_complement.txt", "res_paires_complement2.txt");
pretraitements("textes_adresses.txt", "resultats_lecture.csv", "erreurs_lecture.txt", "corpus_lecture");

#----------------------------------------
# IN : fichier TRACE nettoyé
# Role : rassembler les "  ==> English Vietnamese" derrière les noms de fichiers
sub traitement_paires {
  my $fic_in = $_[0];
  my $fic_res = $_[1];
  my $line;
  my $fic;
  my $texte = "";
  my $paire = "";
  my $paire_trouvee = 'false';
  open(RES, ">$fic_res ");
  print STDOUT ("ouverture $fic_res ");
  open(IN, "<$fic_in ")|| die "Je ne peux ouvrir le fichier $fic $!";
  while ($line = <IN>) {
    chop($line);
	if ($line =~m /^----------------------------- (.+)$/) {
		$nb_textes++;
		$fic = $1;
	}
	elsif ($line =~m /^  ==> (.+)$/) {
		print RES ("\n$fic;($paire)");
		$paire = $1;
		}
	}
	close(IN);
	close(RES);
}

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

#----------------------------------------
# recherche des langues et couples de langues
sub repertorie_langues {
  my $fic_corpus = $_[0];
  my $fic_langues = $_[1];
  my $fic_res = $_[2];
  my $fic_err = $_[3];
  open(TRACE, ">trace.txt ");
  open(RES, ">$fic_res ");
  open(ERR, ">$fic_err ");
  parcours($fic_corpus, $fic_langues);
  close(TRACE);
  close(RES);
  close(ERR);
}
#-------------------------------------------
#recherche des langues
#variables globales utilisées :
# - nb_fausses_langues, incrémenté dans parcours
# - nb_langues, incrémenté dans parcours
sub traite_texte {
	my $texte = $_[0];
	my $i;
	my $j;
	my $langue;
	my $langue2;
	my $pays;
	my $couples;
	my $fic;
	my $test_langue = 'false';
	my $len_langue;
	my $debut_texte = 'false';

	#................ destruction d'expressions generatrices de bruit (fausses langues)
	$i = 0;
	$marque = "";
	#print TRACE ("\n   APRES traite_texte($texte)");
	while ($i < $nb_fausses_langues) {
		#print TRACE ("\n*** cherche $i '$tab_fausses_langues[$i]' \n dans : '$texte'");
		$langue = $tab_fausses_langues[$i];
		while ($texte =~m /(.*) $langue([ ,;?!].*)/i) {
			$texte = $1." ".$2;
			print TRACE ("\n  <= $langue");
			#print RES ("\n  <= $langue");
		}
		$i++;
	}
	#............................................................recherche des langues
	$i = 0;
	while ($i < $nb_langues) {
		$test_langue = 'false';
		$langue = $tab_langues[$i];
		$len_langue = length($langue);
		if ($len_langue le 4) {
			if ($texte =~m / $langue[ ,;:?!~.!)-]/) {
				$test_langue = 'true';
			}
		}
		else {
			if ($texte =~m / $langue[ ,;:?!~.!)<>\/-]/i) {
				$test_langue = 'true';
			}
		}

		if ($test_langue eq 'true') {
			$res_langues[$langue]++;
			print TRACE ("\n  => $i $langue");
			#print TRACE ("\n  $texte");
			$marque = $i;
			#print RES ("\n  => $langue");
			$j = 0;
			while ($j < $nb_langues) {
				$langue2 = $tab_langues[$j];
				#print TRACE ("\n    cherche couple $i $j $tab_langues[$i] $tab_langues[$j]");  close TRACE; open(TRACE, ">>trace.txt ");
				if (($texte =~m / $langue2 *[!?-] *$langue[ ,;:?!~.!)-]/i) or ($texte =~m / $langue *[!?-] *$langue2[ ,;:?!~.!)-]/i)) {
					print TRACE ("\n  ==> $langue $langue2");
					#print RES ("\n  => $langue");
					$couples = $couples. ", ($langue $langue2), ($langue2 $langue)";
				}
				$j++;
			}
		}
		elsif ($texte =~m / $langue/i) {
			print TRACE ("\n  Langue non reconnue : $i $langue");
		}

		if ($marque ne "") {
			print RES (";1");
			$marque = "";
			}
		else {
			print RES (";");
			}
		$i++;
	}
}

#----------------------------------------
# traiter auteurs (avant Abstract) pour pays ;
# debut : Abstract ;
# erreurs (voir source) :
# - pas de "@"
# - "@" après "abstract"
# lecture des donnees
sub parcours {
  my $donnees = $_[0];
  my $fic_langues = $_[1];
  my $line;
  my $i;
  my $j;
  my $langue;
  my $langue2;
  my $pays;
  my $texte;
  my $couples;
  my $fic;
  my $test_langue = 'false';
  my $len_langue;
  my $debut_texte = 'false';
  my $nb_files = `wc -l $donnees`;
  my $counter;

  #............................................................liste de langues
  open(IN, "<langues3.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
  print TRACE ("\n$fic_langues");
  while (($line = <IN>) and (!($line =~m/FAMILLES/))) {
    chop($line);
    print TRACE ("\n$line");
	if ($line =~m /^([^ ]+) +([^()]*)( \(.*)?$/) {
		$langue = $2;
		$tab_langues[$nb_langues] = $langue;
		print TRACE ("\n  $nb_langues $langue");
		$nb_langues++;
		$res_langues[$langue] = 0;
	}
  }
  print STDOUT ("\nnb_langues = $nb_langues");
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
    chop($line);
	$pays = $line;
	$tab_pays[$nb_pays] = $pays;
	$nb_pays++;
	}
  close(IN);

  $i = 0;
  while ($i < $nb_langues) {
    print TRACE ("\n $i $tab_langues[$i]");
	print RES (";$tab_langues[$i]");
	$i++;
  }
  #$i = 0;
  #while ($i < $nb_pays) {
    #print TRACE ("\n $i $tab_pays[$i]");
	#print RES (";$tab_pays[$i]");
	#$i++;
  # }

  open(IN, "<$donnees ")|| die "Je ne peux ouvrir le fichier $fic $!";
 #  while ($line = <IN> and $debut_texte eq 'false') {
	# chop($line);
	# if ($line =~m /^  (.*)$/) {
	# 	$fic = $1;
	# 	$debut_texte = 'true';
	# 	print TRACE ("\n\n----------------------------- $fic"); close TRACE; open(TRACE, ">>trace.txt ");
	# 	print RES ("\n$fic;");
	# 	$texte = "";
	# }
 #  }

  while ($line = <IN>) {
 
	#print TRACE ("\n\n** $line");
	#................ identification texte
	# les textes sont sur une seule ligne, séparés par une ligne vide, le chemin, une nouvelle ligne vide
	if ($line !~m /^\n|\.\/pdfs\/.*\/.*traite.txt\n$/) {
		$texte = $line;
		traite_texte($texte);
		$fic = $1;
		print TRACE ("\n\n----------------------------- $fic"); close TRACE; open(TRACE, ">>trace.txt ");
	    $nb_textes++;
		$couples = "";
		$texte = "";
		print RES ("\n$fic;");
		$| = 1;
		my $tmp = scalar( ($nb_textes/$nb_files)*100);
		print STDOUT "\rProgression : $tmp%";
	}
  }
  print RES ("$couples");
  print STDOUT ("\n$nb_textes textes traites");
  print TRACE ("\n$nb_textes textes traites");

  open($counter, ">counter.txt") or die "impossible d'ouvrire le fichier counter.txt\n";

  foreach my $k (keys(%res_langues)) {
  	print $counter "$k : $res_langues{$k}\n";
  }

  close($counter);

}


#----------------------------------------
# traiter auteurs (avant Abstract) pour pays ;
# debut : Abstract ;
# erreurs (voir source) :
# - pas de "@"
# - "@" après "abstract"
# lecture des donnees
# sépare titre, auteurs, référence et enlève fausses langues et écrit les bonnes langues
# das resultat_lecture.csv
# TODO : virer les pays
sub lecture {
	my $donnees = $_[0];
	my $line;
	my $fic;
	my $i;
	my $langue;
	my $pays;
	my $nb_langues = 0;
	my $nb_fausses_langues = 0;
	my $nb_pays = 0;
	my $nb_textes = 0;
	my $nb_files = `wc -l $donnees`;
	my $texte;
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
	open(IN, "<langues3.csv ")|| die "Je ne peux ouvrir le fichier $fic $!";
	while ($line = <IN>) {
		if($line =~m /[a-z]/){ #élimine les lignes vides
			chomp($line);
			
			$langue = "";
			if($line =~m /(Ga language)/ or $line =~m /(Min Nan)/ or $line =~m / ([A-Z][a-z]+).*?/){ # Va chercher les noms de langue dans le fichier langues3.csv ; ajout d'exceptions pour les langues 
				$langue = $1;
			}
			
			#$langue = $line;
			$tab_langues[$nb_langues] = $langue;
			$langScore[$nb_langues] = 0;
			$nb_langues++;
			
			#initialisation du tableau de hashage de comptage des langues
			$res_langues[$langue] = 0;
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
		if($line =~m /([a-zA-Z ]+)/){ # Juste pour se débarasser une bonne fois pour toute du retour à la ligne
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
		my $tmp = scalar( ($nb_textes/$nb_files)*100);
		print STDOUT "\rProgression : $tmp%";

		#............................................................traitement d'un texte
		open(TEXT, "<$fic ")|| die "Je ne peux ouvrir le fichier $fic $!";
		$texte = "";
		$titre = "";
		$ref = "";
		$titre_trouve = 'false';
		$ref_trouvees = 'false';
		$nb_textes++;

		while ($line = <TEXT>) {
			$texte .= $line;
		}
		close(TEXT);
		#print("\n");
		#.....................................................references
		
		#print TRACE ("\n\n TEXTE : $texte");
		#............................................................recherche des langues
		#................ destruction d'expressions generatrices de bruit (fausses langues)
		$texte = $titre . "\n" . $texte; # TO-DO: récupérer le titre
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
	
		$i = 0;
		while ($i < $nb_langues) {
			#print TRACE ("\ncherche $i $tab_langues[$i] \n dans : '$texte'");
			$langue = $tab_langues[$i];
			if ($texte =~m / $langue/i) {
				print TRACE ("\n	=> $langue");
				$marque = $i;
				#print RES ("\n	=> $langue");
			}
			if ($marque ne "") {
				print RES (";1");
				$marque = "";
				
				# Incrémentation du score de la langue dans le tableau de hashage
				$res_langues[$langue]++;
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
	
	#foreach my $k (keys(%res_langues)) {
	#	print $counter "$k : $res_langues{$k}\n";
	#}

	close($counter);
}
