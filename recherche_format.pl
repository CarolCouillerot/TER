
my $dirName = './pdfs/ACL/';
my $dir;
my $subDirName;
my $subDir;

my $fileName;
my $file;
my $matchIntro;
my $matchRef;
my $noMatchIntro;
my $noMatchRef;

my $nbFile = 0;
my $nbXml = 0;
my $nbIntro = 0;
my $nbIntroXml = 0;
my $nbRef = 0;


open ($noMatchIntro, ">noMatchIntro.txt");
open ($noMatchRef, ">noMatchRef.txt");
open ($matchSpec, ">matchSpec.txt");

opendir(DIR, $dirName) or die "Could not open !! $dir\n";

while (my $subDirName = readdir(DIR)) {
  if ($subDirName =~m /P[0|1][0-9]/){
	  opendir($subDir, "$dirName$subDirName") or die "Could not open ! $subDir\n";
	  
	  while (my $fileName = readdir($subDir)) {
		  if ($fileName =~m /(.*).txt$/) {
			  
			  open($file, "<$dirName$subDirName/$fileName") or die "Could not open... $fileName\n";
			  
			  $nbFile++;
			  
			  $matchIntro = 0;
			  $matchRef = 0;
			  while (my $line = <$file>) {
				  
				  if($line =~m /^?([0-9]?[0-9]|[0-9]?[0-9] |[0-9]?[0-9]. )?(R ?E ?F ?E ?R ?E ?N ?C ?E ?S?|B ?i ?b ?l ?i ?o ?g ?r ?a ?p ?h ?y|(o ?n ?l ?i ?n ?e )?r ?e ?s ?o ?u ?r ?c ?e ?s?)(\.| ?:| ?-| ?\/)?\.?\n$/i){
					  ++$matchRef;
				  }
				  
				  
				  if($line =~m /^?([0-9]|[0-9] |[0-9]. )?(Introduction|I ?N ?T ?R ?O ?D ?U ?C ?T ?I ?O ?N)\.?\n$/){
					  ++$matchIntro;
				  }
			  }
			  if($matchIntro){
				  $nbIntro++;
			  }else{
				  print $noMatchIntro "$fileName\n"
			  }
			  if($matchRef){
				  $nbRef++;
			  }else{
				  print $noMatchRef "$fileName\n"
			  }
			  
			  close($file);
		  }
		  elsif ($fileName =~m /(.*).xml$/) {
			  open($file, "<$dirName$subDirName/$fileName") or die "Could not open : $fileName\n";
			  
			  $nbXml++;
			  
			  $matchIntro = 0;
			  $matchRef = 0;
			  while (my $line = <$file>) {
				  
				  if(!$matchIntro and $line =~m />?([0-9]|[0-9] |[0-9]. )?(Introduction|I ?N ?T ?R ?O ?D ?U ?C ?T ?I ?O ?N)\.?<\//){
					  ++$matchIntro;
					  #print "$fileName : $line";
				  #}elsif(){
					#  ++$matchIntro;
					#  print "$fileName : $line";
				  }
			  }
			  if($matchIntro){
				  $nbIntroXml++;
			  }else{
				  print $noMatchIntro "Xml : $fileName\n"
			  }
			  
			  close($file);
		  }
	  }
	  
	  closedir($subDir);
  }
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
