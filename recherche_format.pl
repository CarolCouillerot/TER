################################
# Script de recherche de motifs et d'affichage des résultats
##
# Vous trouverez plusieurs variables ayant le même nom, au suffixe "Name" près.
# Ces variables sont les variables de dossiers et fichiers à lire ou écrire,
#  ou leur nom de fichier lorsqu'il y a le suffixe "Name".

# variables de navigation dans les dossiers et sous-dossiers
my $dirName = './pdfs/ACL/';
my $dir;
my $subDirName;
my $subDir;

# Fichier lu
my $fileName;
my $file;

# Variables booléennes
my $matchIntro;
my $matchRef;
my $matchTitle;
# Fichiers écrits
my $noMatchIntro; #Contient les noms de fichiers txt où aucune Introduction n'a été trouvé
my $noMatchRef; #Contient les noms de fichiers txt où aucune Bibliographie n'a été trouvé

# Variables incrémentées
my $nbFile = 0;
my $nbXml = 0;
my $nbIntro = 0;
my $nbIntroXml = 0;
my $nbRef = 0;

# Variable textuelle
my $fontStruct;

open ($noMatchIntro, ">noMatchIntro.txt");
open ($noMatchRef, ">noMatchRef.txt");
open ($matchSpec, ">matchSpec.txt");

opendir(DIR, $dirName) or die "Could not open !! $dir\n";

while (my $subDirName = readdir(DIR)) { #pour chaque sous-dossier
  #if ($subDirName =~m /P[0|1][0-9]/){
	  opendir($subDir, "$dirName$subDirName") or die "Could not open ! $subDir\n";
	  
	  while (my $fileName = readdir($subDir)) { #pour chaque fichier
		  if ($fileName =~m /(.*).txt$/) { # Fichier .txt
			  
			  open($file, "<$dirName$subDirName/$fileName") or die "Could not open... $fileName\n";
			  
			  $nbFile++;
			  
			  $matchIntro = 0; #initialisation à false
			  $matchRef = 0;
			  while (my $line = <$file>) {
				  
				  # Recherche de la bibliographie
				  if($line =~m /^?([0-9]?[0-9]|[0-9]?[0-9] |[0-9]?[0-9]. )?(R ?E ?F ?E ?R ?E ?N ?C ?E ?S?|B ?i ?b ?l ?i ?o ?g ?r ?a ?p ?h ?y|(o ?n ?l ?i ?n ?e )?r ?e ?s ?o ?u ?r ?c ?e ?s?)(\.| ?:| ?-| ?\/)?\.?\n$/i){
					  ++$matchRef;
				  }
				  
				  # Recherche de l'introduction
				  if($line =~m /^?([0-9]|[0-9] |[0-9]. )?(Introduction|INTRODUCTION|I ?N ?T ?R ?O ?D ?U ?C ?T ?I ?O ?N)\.?\n$/){
					  ++$matchIntro;
				  }
			  }
			  
			  # Incrémenter nbIntro et nbRef ici permet qu'ils ne soient pas incrémentés plus d'une seule fois par fichier
			  if($matchIntro){
				  $nbIntro++;
			  }else{
				  print $noMatchIntro "$fileName\n"; #écriture dans $noMatchIntro
			  }
			  if($matchRef){
				  $nbRef++;
			  }else{
				  print $noMatchRef "$fileName\n"; #écriture dans $noMatchRef
			  }
			  
			  close($file);
		  }
		  elsif ($fileName =~m /(.*).xml$/) { # Fichier .xml
			  open($file, "<$dirName$subDirName/$fileName") or die "Could not open : $fileName\n";
			  
			  $nbXml++;
			  
			  $fontStruct = "";
			  $matchIntro = 0;
			  $matchTitle = 0;
			  while (my $line = <$file>) {
				  
				  if(!$matchIntro and $line =~m /(height="[0-9]+").*>?([0-9]|[0-9] |[0-9]. )?(Introduction|I ?N ?T ?R ?O ?D ?U ?C ?T ?I ?O ?N)\.?<\//){
					  ++$matchIntro;
					  $fontStruct = $1; # correspond à height="...", soit la taille d'écriture
					  #print "$fileName : $fontStruct\n";
				  }elsif($matchIntro and !$matchTitle and $line =~m /$fontStruct/){
					  # On cherche ici la prochaine ligne ayant la même taille d'écriture que Introduction
					  # Ce qui suit est expérimental et pas forcément au point...
					  
					  my $wholeLine = "";
					  
					  $matchTitle++;
					  
					  do{ #permet de se débarasser des balises <...> (clairement pas la meilleure méthode)
						  while($line =~m />(.+)</){
							  $line = $1;
						  }
						  
						  $wholeLine = $line;
						  
						  $line = <$file>;
					  }while(length($wholeLine) < 4); #Sélectionne la prochaine "phrase" après le second titre, l'objectif étant d'avoir quelque chose de suffisamment unique à matcher dans le fichier .txt
					  
					  print "$fileName : $wholeLine\n";
				  }
			  }
			  if($matchIntro){
				  $nbIntroXml++;
			  }else{
				  print $noMatchIntro "Xml : $fileName\n"; # écriture dans $noMatchIntro
			  }
			  
			  close($file);
		  }
	  }
	  
	  closedir($subDir);
  #}
}

print "Nombre de fichiers : $nbFile.\n";
print "Nombre de fichiers xml : $nbXml.\n";
print "Nombre d'Introduction : $nbIntro.\n";
print "Nombre d'Introduction Xml : $nbIntroXml.\n";
print "Nombre de réferences : $nbRef.\n";

close($noMatchIntro);
close($noMatchRef);
close($matchSpec);
closedir(DIR);
