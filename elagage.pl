#############################
# Crée des copies des documents txt débarassés de leurs Introductions (et prochainement peut être de leurs bibliographies)
##
# Vous trouverez plusieurs variables ayant le même nom, au suffixe "Name" près.
# Ces variables sont les variables de dossiers et fichiers à lire ou écrire,
#  ou leur nom de fichier lorsqu'il y a le suffixe "Name".

# variables de navigation dans les dossiers et sous-dossiers
my $dirName = './pdfs/ACL/';
my $dir;
my $subDirName;
my $subDir;

# Fichiers lus
my $fileName;
my $txtFileName;
my $txtFile;
my $xmlFileName;
my $xmlFile;
# Fichier écrit
my $createdFileName;
my $createdFile;

# Variables booléennes
my $matchIntro;
my $matchLine;
# Variables incrémentées
my $nbTreatedFiles = 0;
my $nbMatchIntro = 0;

# Variable textuelle
my $fontStruct;
my $fontLine;

opendir(DIR, $dirName) or die "Could not open !! $dir\n";

while (my $subDirName = readdir(DIR)) { #pour chaque sous-dossier
  #if ($subDirName =~m /P[0|1][0-9]/){
	  opendir($subDir, "$dirName$subDirName") or die "Could not open ! $subDir\n";
	  
	  while (my $fileName = readdir($subDir)) {
		  if ($fileName =~m /(^.*).xml$/) { # Si un fichier .xml existe, alors son équivalent .txt existe aussi forcément
			  my $goodLine;
			  my $lineSave;
			  
			  $xmlFileName = $fileName;
			  $txtFileName = $1.".txt";
			  $createdFileName = "$1_traite.txt";
			  
			  open($xmlFile, "<$dirName$subDirName/$xmlFileName") or die "Could not open : $xmlFileName\n";
			  open($txtFile, "<$dirName$subDirName/$txtFileName") or die "Could not open : $txtFileName\n";
			  
			  $nbTreatedFiles++;
			  
			  $matchIntro = 0;
			  $matchTitle = 0;
			  while (my $line = <$xmlFile> and (!$matchIntro or !$matchTitle)) {
				  # 1- On cherche la ligne Introduction et on enregistre sa taille d'écriture
				  # 2- On cherche la prochaine ligne possédant cette taille d'écriture
				  # 3- On enregistre la première ligne d'une longueur suffisante après la ligne trouvée en 2-
				  # 4- (en dehors de ce while) On cherche la première ligne du fichier txt matchant avec la ligne trouvée en 3-
				  # Explication rapide : les lignes du fichier xml (débarassées de leurs balises) sont nêtement plus petites et fractionnées que celles du fichier txt, et parfois pas dans le même ordre (je pense aux titres et à leurs numéros, par exemple)
				  
				  if(!$matchIntro and $line =~m /(height="[0-9]+").*>?([0-9]|[0-9] |[0-9]. )?(Introduction|INTRODUCTION)\.?<\//){
					  # 1- Introduction trouvée
					  ++$matchIntro;
					  ++$nbMatchIntro;
					  $fontStruct = $1;
					  $fontLine = $line;
				  }elsif($matchIntro and !$matchTitle and $line =~m /$fontStruct/){
					  # 2- Prochaine ligne de même taille de police trouvée
					  $matchTitle++;
					  
					  do{
						  while($line =~m />(.+)</){ # On se débarasse (maladroitement) des balises
							  $line = $1;
						  }
						  
						  $goodLine = $line;
						  
						  $line = <$xmlFile>;
					  }while(length($goodLine) < 4); # 3- On prend la prochaine ligne de taille suffisante
				  }
			  }
			  
			  # Passage de la lecture du .xml à la lecture du .txt (si tous les éléments voulus ont été trouvés)
			  
			  if($matchIntro and $matchTitle){
				  open($createdFile, ">$dirName$subDirName/$createdFileName") or die "Could not open : $createdFileName\n";
				  print "Created $createdFileName\n";
				  
				  $matchLine = 0;
				  
				  while (my $line = <$txtFile>){
					  
					  if(!$matchLine and $line =~m \$goodLine\){
						  ++$matchLine;
					  }
					  
					  # 4- Une fois goodLine trouvée, on récupère tout le .txt restant
					  
					  if($matchLine){
						  print $createdFile $line;
					  }
				  }
				  
				  if(!$matchLine){
					  print "Did not match ; good line : $goodLine\n";
				  }
				  
				  close($createdFile);
			  }elsif($matchIntro and !$matchTitle){
				  print "Lost title : $xmlFileName ; $fontLine";
			  }elsif(!$matchIntro and !$matchTitle){
				  print "No Intro : $xmlFileName\n";
			  }elsif(!$matchIntro and $matchTitle){
				  print "What the fuck ? $xmlFileName\n";
			  }
			  
			  close($xmlFile);
			  close($txtFile);
		  }
		  
	  }
	  
	  closedir($subDir);
  #}
}

print "Nombre de fichiers traités : $nbTreatedFiles.\n";
print "Nombre d'Intro trouvés : $nbMatchIntro.\n";

closedir(DIR);
