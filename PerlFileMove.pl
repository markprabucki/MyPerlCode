
use File::Copy;
use File::Path qw( rmtree );
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);

my $debug = 0;
my $scrub_files = 1;

 my $logger = get_logger();

# SOURCE of Files 
#---------------------------------------
my $source = "\\\\SambaFileServer1\\Files\\Source";

print "source arg is:  $source\n";
my $swatchfolder = "$source\/Upload\/Upload\/files";

# Destination of Files
#---------------------------------------
my $dest = "\\\\SambaFileServer2\\Files\\Destination";
 
 
$logger->info( "dest arg is:  $dest \n");

if($debug > 0) {
  check_source_dir();
  }
  
  
($deltasec,$deltamin,$deltahour,$deltamday,$deltamon,$deltayear,$deltawday,$deltayday,$deltaisdst) = localtime(time);
$deltayear -= 100;
$deltamon +=1;
$deltadatefilename = sprintf("%02s%02s%02s", $deltamon,$deltamday,$deltayear);
$deltadir = "$source\/delta";

 
if ($scrub_files > 0) {
     process_file_dir();
}

sub process_file_dir
{
	$dirtoget="$source\\Upload\\files";
	print "Checking source directory: $dirtoget \n";
	opendir(IMD, $dirtoget) || die("Cannot open directory");
	@thefiles= readdir(IMD);
	closedir(IMD);
#	$logger->info( "-------------------- checking dir ------------------------\n");
	foreach $f (@thefiles)
	{
	 unless ( ($f eq ".") || ($f eq "..") || (substr($f,1,1) eq "_" ))
	 {
	    $logger->info( "(reading source) file:$f size:$filesize owner:$fileowner \n" );
	    my $newfile = $f;
	    $newfile =~ s/files\///;
	    if ($newfile !~ /\_xfer/) {   
	    	$newfile !~ s/\./\_xfer\./;
	    }  
	    if(($f =~ /\.dat$/i) || ($f =~ /\.idx$/i))
	    {
	       $logger->info(print "file:$newfile \n");
	       my $from = "$dirtoget//$f";
	       my $to = "$dirtoget//$newfile";
	       if (rename $from, $to) {
	     	   ## success, do nothing
	       } else {
	  	   warn "rename $f to $newfile failed: $! \n";
	       }
	    }
	 }
	}
	$logger->info("----------------------------------------------------------\n");
}


###################################
#   MAIN Procedure
###################################
my $now = time();
make_directory();

$delta_name="delta";
open(DELTA_LOG,">>$deltadir\\${delta_name}_${deltadatefilename}.dat") || die("Delta Log file will not open!");

# process all files and directories

$source = "$source\\Upload";

logDir($source);

recurse($source);

cleanFile($source);

logDir($source);

close(DELTA_LOG);

sleep(7);

###################################
# routine for validation only
###################################
sub check_source_dir
{
	$dirtoget="$source\\Upload";
	$logger->info("Checking source directory: $dirtoget \n");
	opendir(IMD, $dirtoget) || die("Cannot open directory");
	@thefiles= readdir(IMD);
	closedir(IMD);
	$logger->info("-------------------- checking dir ------------------------\n");
	foreach $f (@thefiles)
	{
	 unless ( ($f eq ".") || ($f eq "..") || (substr($f,1,1) eq "_" ))
	 {
	    $filesize = -s "$dirtoget//$f";
	    $fileowner = -o "$dirtoget//$f";
	    $logger->info("(reading source) file:$f size:$filesize owner:$fileowner \n");  
	 }
	}
	$logger->info("----------------------------------------------------------\n");
}

###################################
# routine for validation only
###################################
sub check_destination_dir
{
	$dirtoget=$dest;
	opendir(IMD, $dirtoget) || die("Cannot open directory");
	@thefiles= readdir(IMD);
	closedir(IMD);
	$logger->info("-------------------- checking dir ------------------------\n");
	foreach $f (@thefiles)
	{
	 unless ( ($f eq ".") || ($f eq "..") || (substr($f,1,1) eq "_" ))
	 {
	 $filesize = -s "$dirtoget//$f";
	 $fileowner = -o "$dirtoget//$f";
	 $logger->info("(reading dest directory after move to verify files) file:$f size:$filesize owner:$fileowner \n");  
	 }
	}
	$logger->info("----------------------------------------------------------\n");
}

###################################
# archive directory
###################################
sub make_directory
{
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

	$month = (January,February,March,April,May,June,
	    July,August,September,October,November,December)[$mon];

	$year -= 100;
	$mon +=1;
	$dayfoldername = sprintf("%02s%02s%02s", $mon,$mday,$year);
	$dayyrfoldername = sprintf("%02s_%02s_%02s", $mon,$month,$year);

	$dir = "$source\/Done";

	$dir = sprintf("%s\/%s", $dir, $dayyrfoldername);
	
	$logger->info( "* backup day-year folder: $dir \n");
	if (! -d "$dir") {
		mkdir $dir, 0755 or warn "Cannot make $dir directory: $! \n"; 
	}

	$dir = sprintf("%s\/%s", $dir, $dayfoldername);
	$logger->info( "* backup day folder: $dir \n");
	if (! -d "$dir") {
		mkdir $dir, 0755 or warn "Cannot make $dir directory: $! \n";
	}
}

sub cleanDirs
{
   ($cleanDir) = @_;
   $logger->info("cleaning $cleanDir \n");  

}

sub cleanFile
{
   ($cleanFile) = @_;
   $logger->info("cleaning $cleanFile \n");  

}

sub logDir
{
   ($logDir) = @_;
   $logger->info("Logging $logDir \n");  

}

sub logDataFile
{
  my $theDataFile;
  ($theDataFile) = @_;
  
  print DELTA_LOG "$theDataFile\n";

  close(PLOT);  
  
}

###################################
# 1 = locked 0 = not locked 
###################################
sub is_file_locked 
{   
  my $theFile;   
  my $theRC;    
  ($theFile) = @_;   
  $theRC = open(my $HANDLE, ">>", $theFile);   
  $logger->info(" checking that file is ok to move and copy and not locked... \n");
  
  $theRC = flock($HANDLE, LOCK_SH);   
  $logger->info(" file is ok to copy \n");
  close($HANDLE);   
  return !$theRC; 
}  

###################################
# Main Recurse Procedure
###################################
sub recurse
{
    print "Processing files... \n";
    my($path) = @_; 
    $logger->info( "working in: $path\n" );

    my ($file) = @_;
    if (! -l $file && -d _) {
        opendir DIR, $file or die "Unable to opendir $file: $^E";
        my @contents = readdir DIR;
        closedir DIR or die "Unable to closedir $file: $^E";
        foreach my $entry (@contents) {
            $entry eq '.' || $entry eq '..'
                and next;
            recurse (File::Spec->catfile ($file, $entry));
        }
    }
    processFile($file);
}

###################################
# Main Routine for processing files
###################################
sub processFile
{
   my($file) = @_;
   if($file =~ /\.(dat|xfer|idx|bin)$/i) {
        $logger->info( "processing file: $file \n");
         
	$age = (stat($file) ) [9];
	$owner = (stat($file) ) [4];

	$logger->info( "now is.: $now\n");
	$logger->info( "$file is age.: $age\n");
        my @fileAgeStats = stat($file); 
        $logger->info( "fileAge is: $fileAgeStats[9] \n");
  
        $fileAge = ($now - $fileAgeStats[9]);
        $logger->info( "age is $fileAge \n");

	$filesize = -s "$file";
	# in seconds
 	if ($fileAge > 60) {
	   if ($filesize <= 0) {
	       $logger->error( "skipping empty file: $file \n");
	       deleteFile($file);
	   } else {
	     if (($file =~ /'/) || ($ifile =~ /`/) || ($ifile =~ /"/)) {
	         $logger->error( "file name is bad skip file \n");
	     } else {
                if ( is_file_locked($file) )
                {     
                  $logger->info( "$file is NOT locked  \n");   
                } 
                else
                {
                  $logger->info( "$file is locked  \n");
                }
	     
                $logger->info( "Backing up to:$dir \n");
 		copy("$file", "$dir") || warn "Failed to copy files: $! \n";
                $logger->info( "moving to: $dest \n");
 		move("$file", "$dest") || warn "Failed to move files will try to move in next run: $! \n";
	        deleteFile($file);
	        if(($file =~ /_ALT.*(idx|xfer|dat|bin)$/i) || 
	           ($file =~ /_ALT.(idx|xfer|dat|bin)$/i))
	        {
	          my $idx = rindex($file, "\\");
	          my $deltaFileToLog = substr($file,$idx+1,length($file));
	          logImage($deltaFileToLog);
	        }
	     } 
	     # end brace for single quote check
	   }
	   # end brace for zero size check
        } else {
           $logger->info( "file: $file age is too recent - skipping in this run \n");	   
	}    
	# end brace for file timestamp check
   }
   # end brace for file type check 
}
# end brace for subroutine

###################################
# routine for deleting files
###################################
sub deleteFile
{
   $fileToUnlink = shift;
   $logger->info( "unlinking file: $fileToUnlink \n");
   $fileToUnlinkSize = -s $fileToUnlink;
   $logger->info( "file size before unlink: $fileToUnlinkSize \n");
   if (unlink ($fileToUnlink))
   {
       $logger->info( "The file $fileToUnlink has been deleted.\n");
   }
   else
   {
       $logger->info( "The file $fileToUnlink was not deleted - possibly already removed: $!\n");
       sleep(1);
   }   
      
   $status = -e $fileToUnlink;  
   $fileToAfterUnlinkSize = -s $fileToUnlink;
   $logger->info( "file size after unlink: $fileToAfterUnlinkSize \n");
   
   if ($status) {
 	  if (unlink ($fileToUnlink))
	   {	
   	    	$logger->info( "The file $fileToUnlink has been deleted.\n");
 	  }
	  else
   	  {
                $logger->info( "The file $fileToUnlink was not deleted - possibly already removed: $!\n");
   	  }   
   }   
}


#
# End of Perl Script
#