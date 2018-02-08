
my $dirName = './pdfs/EACL/';
my $dir;
my $subDirName;
my $subDir;

my $fileName;
my $file;
my $bigFile;

open ($bigFile, ">corpus_EACL.txt");

opendir(DIR, $dirName) or die "Could not open $dir\n";

while (my $subDirName = readdir(DIR)) {
  opendir($subDir, "$dirName$subDirName") or die "Could not open $subDir\n";
  
  while (my $fileName = readdir($subDir)) {
	  if ($fileName =~m /(.*).txt$/) {
		  
		  open($file, "<$dirName$subDirName/$fileName") or die "Could not open $file\n";
		  
		  print $bigFile "$dirName$subDirName/$fileName\n";
		  
		  while (my $line = <$file>) {
			  
			  chop $line;
			  print $bigFile $line." ";
			  
		  }
		  print $bigFile "\n  \n";
		  
		  close($file);
	  }
  }
  
  closedir($subDir);
}

close($bigFile);
closedir(DIR);
