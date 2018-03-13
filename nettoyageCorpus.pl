# Role : détecte les fichiers mal transformés du format pdf au format xml
# 	compte le nb moyen de mot par balise <text>
# Entree : Le dossier indiqué à l'adresse $dirName. Doit contenir des sous-dossiers qui, eux, doivent contenir les fichiers xml à traiter.
# Sortie : un fichier contenant la liste des fichiers mal transformés
# 


my $dirName = './pdfs/ACL/';
my $dir;
my $subDirName;
my $subDir;

my $fileName;
my $file;
my $badFiles;
my $resTxt;

my $nbFile = 0;
my $nbBadFile = 0;

opendir(DIR, $dirName) or die "Could not open $dir\n";
open ($badFiles, ">badFiles.txt");
open($resTxt, ">corpus.res");

while (my $subDirName = readdir(DIR)) {
  if ($subDirName =~m /P[0-9][0-9]/){
	  opendir($subDir, "$dirName$subDirName") or die "Could not open $subDir\n";
	  
	  while (my $fileName = readdir($subDir)) {
		  if ($fileName =~m /(.*).xml$/) {
			my $nbLine = 0;
			my $nbWord = 0;
			my $contentFile = "";
			my $motTrouve = 0;
			  open($file, "<$dirName$subDirName/$fileName") or die "Could not open $file\n";
			  # print("\n\n$fileName ouvert : ");
			  $nbFile++;
			  
			  while (my $line = <$file>) {
			  	if( $line =~m />[0-9]*<\/text>/) {
			  		
			  	}
				elsif( $line =~m />(.*)<\/text>/) {
					my $content = $1;
					$nbLine++;
					$nbWord += scalar( () = $content =~ /\w+/g);
					if( $content =~m /(we)|(that)|(the)|(with)|(and)|(our)|(can)|(all)/i) { $motTrouve++; }			
				}
				if( $line =~m />(.*)-<\/text>/) { $contentFile .= $1; }
				elsif( $line =~m />(.*)<\/text>/) { $contentFile .= " $1"; } 
			  }
			  
			close($file);
			print $resTxt "=========== $fileName ===========\n$contentFile\n";
			my $res = ($nbLine > 0) ? $nbWord/$nbLine : 0;
		 	# print("nb Lignes : $nbLine, nb Mots : $nbWord -> $res\n");
		  	if( ($res < 3.5) and ($motTrouve < 5)) {
		  		$nbBadFile++;
		  		print $badFiles "$dirName$subDirName/$fileName\n";# => $res, mots reconnus $motTrouve\n";
		  	}
		  }
	  }
	  
	  closedir($subDir);
  }
}

print "Nombre de fichiers : $nbFile.\n";
print "Nombre de mauvais fichiers : $nbBadFile.\n";

close($resTxt);
close($badFiles);
closedir(DIR);

`sort badFiles.txt -o badFiles.txt`;
