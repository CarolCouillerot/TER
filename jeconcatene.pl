#############################
# Crée des copies des documents txt débarassés de leurs Introductions (et prochainement peut être de leurs bibliographies)
##
# Vous trouverez plusieurs variables ayant le même nom, au suffixe "Name" près.
# Ces variables sont les variables de dossiers et fichiers à lire ou écrire,
#	ou leur nom de fichier lorsqu'il y a le suffixe "Name".

# variables de navigation dans les dossiers et sous-dossiers
my $dirName = './pdfs/ACL/';
my $dir;
my $subDirName;
my $subDir;

# Fichiers lus
my $fileName;
my $fileName;
my $txtFile;
my $xmlFileName;
my $xmlFile;
# Fichier écrit
my $createdFileName;
my $createdFile;
my $filesList;

# Variables booléennes
my $matchIntro;
my $matchLine;
# Variables incrémentées
my $nbTreatedFiles = 0;
my $nbMatchIntro = 0;

# Variable textuelle
my $fontStruct;
my $fontLine;

open($filesList, ">textes_adresses.txt") or die "Could not create textes_adresses";
opendir(DIR, $dirName) or die "Could not open !! $dir\n";

while (my $subDirName = readdir(DIR)) { #pour chaque sous-dossier
	if ($subDirName =~m /P[0-9][0-9]/){
		opendir($subDir, "$dirName$subDirName") or die "Could not open ! $subDir\n";
		
		while (my $fileName = readdir($subDir)) {
			if ($fileName =~m /(^.*)traite.txt$/) {
				
				print $filesList $dirName.$subDirName."/".$fileName."\n";
				
				open($txtFile, "<$dirName$subDirName/$fileName") or die "Could not open : $fileName\n";
				
				$nbTreatedFiles++;
				my $content = "";
				while (my $line = <$txtFile>) {
					chomp($line);
					if($line =~m /(.*)-$/) { $content .= "$1"; }
					else { $content .= "$line "; }

				}

				close($txtFile);			
				open($txtFile, ">$dirName$subDirName/$fileName") or die "Could not open : $fileName\n";
				print $txtFile $content;
				close($txtFile);
			}
			
		}
	
		closedir($subDir);
	}
}

print "Nombre de fichiers traités : $nbTreatedFiles.\n";
print "Nombre d'Intro trouvés : $nbMatchIntro.\n";

close($filesList);
closedir(DIR);
