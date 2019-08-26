open(MYINPUTFILE, "<dirList.csv"); # open for input
my(@lines) = <MYINPUTFILE>; # read file into list
@lines = sort(@lines); # sort the list
my($line);
foreach $line (@lines) # loop thru list 
{ 
  print "$line"; # print in sort order 
}
close(MYINPUTFILE);
