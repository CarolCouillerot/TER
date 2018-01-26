
traitement_paires("paires_tout.txt", "res_paires_tout.txt")


#---------------------------------------- 
# IN : fichier TRACE nettoyé
# Role : chercher les "  ==> English Vietnamese"
sub traitement_paires {
  $fic_in = $_[0];
  $nb_textes = 0;
  $fic_res = $_[1];
  $line = "";
  $fic = "";
  $texte = "";
  open(RES, ">$fic_res ");
  print STDOUT ("ouverture $fic_res ");
  open(IN, "<$fic_in ")|| die "Je ne peux ouvrir le fichier $fic $!";
  while ($line = <IN>) { 
    chop($line);
	if ($line =~m /^----------------------------- (.+)$/) {
		print RES ("\n$texte");
		$nb_textes++;
		$fic = $1;
		$texte = "";
	}
	elsif ($line =~m /^  ==> (.+)$/) {
		$paire = $1;
		$texte = $texte . "($paire)";
		}
	}
  close(IN);
  close(RES);
}


