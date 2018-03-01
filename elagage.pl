#############################
# Crée des copies des documents txt débarassés de leurs Introductions (et prochainement peut être de leurs bibliographies)
##
# Vous trouverez plusieurs variables ayant le même nom, au suffixe "Name" près.
# Ces variables sont les variables de dossiers et fichiers à lire ou écrire,
#	ou leur nom de fichier lorsqu'il y a le suffixe "Name".

# variables de navigation dans les dossiers et sous-dossiers
my $dirName = './pdfs/LREC/';
my $dir;
my $subDirName;
my $subDir;

# Fichiers lus
my $fileName;
my $xmlFileName;
my $xmlFile;
# Fichier écrit
my $createdFileName;
my $createdFile;

# Variables booléennes
my $matchIntro;
my $matchLine;
my $matchRef;
# Variables incrémentées
my $nbTreatedFiles = 0;
my $nbMatchIntro = 0;

# Variable textuelle
my $fontStruct;
my $fontLine;

opendir(DIR, $dirName) or die "Could not open !! $dir\n";

while (my $subDirName = readdir(DIR)) { #pour chaque sous-dossier
	if ($subDirName =~m /.[0-9][0-9]/){
		opendir($subDir, "$dirName$subDirName") or die "Could not open ! $subDir\n";
		
		while (my $fileName = readdir($subDir)) {
			if ($fileName =~m /(^.*).xml$/) {
				my $goodLine;
				my $lineSave;
				my $content = "";
				
				$xmlFileName = $fileName;
				$createdFileName = "$1_traite.txt";
				
				open($xmlFile, "<$dirName$subDirName/$xmlFileName") or die "Could not open : $xmlFileName\n";
				
				$nbTreatedFiles++;
				
				$matchIntro = 0;
				$matchTitle = 0;
				$matchRef = 0;
				while (my $line = <$xmlFile>) {
					# 1- On cherche la ligne Introduction et on enregistre son format d'écriture
					# 2- On cherche la prochaine ligne possédant ce format d'écriture
					# 3- Une fois le second titre trouvé, on nettoie toutes les lignes suivantes de leur balisage et on les concatène dans le nouveau fichier
					if(!$matchIntro and $line =~m /(font="[0-9]+").*>?([0-9]|[0-9] *|[0-9]. *)?(Introduction|INTRODUCTION)\.? *<\//){
						# 1- Introduction trouvée, démarrage du #2
						++$matchIntro;
						++$nbMatchIntro;
						$fontStruct = $1;
						$fontLine = $line;
					}elsif($matchIntro and !$matchTitle and $line =~m /$fontStruct/){
						# 2- Prochaine ligne de même format trouvée, démarrage du #3
						++$matchTitle;
					}
					if($matchTitle and !$matchRef) {		
						# 3- On enlève pour chaque ligne leur balisage, on concatène et on s'arrête une fois la Bibliographie trouvée
						while($line =~m /(^.*?)<(.+?)>(.*$)/){
							$line = $1.$3;
						}
						if ($line =~m /^([0-9]+(\.)*[  \t]+R[eé]f[eé]rences?|R[eé]f[eé]rences?|[0-9]+\.[  \t]+Bibliography|Bibliography|[0-9]+(\.)*[  \t]+Bibliographical References|Bibliographical References|5HIHUHQFHV)/i) {
							$matchRef++;
						}else{
							$content .= "$line\n";
						} 
					}
				}
				if($matchTitle){
					open($createdFile, ">$dirName$subDirName/$createdFileName") or die "Could not open : $createdFileName\n";
					print $createdFile  "$content";
					close($createdFile);
				}
				
				close($xmlFile);
			}
			
		}
	
		closedir($subDir);
	}
}

print "Nombre de fichiers traités : $nbTreatedFiles.\n";
print "Nombre d'Intro trouvés : $nbMatchIntro.\n";

closedir(DIR);
