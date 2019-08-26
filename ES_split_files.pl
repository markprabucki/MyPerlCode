#!/usr/bin/perl

$fileName = shift || die "invalid args: <sourcefilename> <filenametag> <targetdirectory";
$tag = shift || die "invalid args: <sourcefilename> <filenametag> <targetdirectory";
$outDir = shift || die "invalid args:  <textfilename> <outdnafilename> ";

open (DATA,"$fileName") || die "cannot open $fileName";
print "\nparsing file: $fileName\n";
 
while (<DATA>)  {

	next if (/^\s*$/);
	if (/^$tag(.*)/) {
		chomp;
		close (NEWFILE) if $notFirst;
		$newName = $1;
		$newName =~ s/\s*//g;
		print "\tcreating file: $outDir/$newName\n";
		open (NEWFILE,">$outDir/$newName") || die "cannot open $outDir/$newName";
		$notFirst++;
	} else {
		print NEWFILE;
	}
		

}
close (NEWFILE) if $notFirst;
close (DATA);

			








