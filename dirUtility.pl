use File::Find;
use Data::Dumper;
$dir = "/logs/";
%files = ();  
$files_href = "";  
%Allfiles = ();
find(\&edits, $dir);
foreach $key (sort keys %files) {
  $name = $files{$key}{'name'};
  $month = $files{$key}{'month'};
  $day = $files{$key}{'day'};
  $year = $files{$key}{'year'};
  $hr = $files{$key}{'hr'};
  $min = $files{$key}{'min'};
  $sec = $files{$key}{'sec'};
  $job = $files{$key}{'job'};
  $startYear = $files{$key}{'startYear'}; 
  $startMonth = $files{$key}{'startMonth'}; 
  $startDay = $files{$key}{'startDay'}; 
  $startHour = $files{$key}{'startHour'};
  $startMinute = $files{$key}{'startMinute'}; 
  $startSecond = $files{$key}{'startSecond'}; 
  
   print "$year,$month,$day,$hr,$min,$sec,$startYear,$startMonth,$startDay,$startHour,$startMinute,$startSecond,$job,$name \n"; 
}
sub edits() {
   if (!-d $_)           
   {
     $prefix = substr $_,0,3;
     if($prefix eq "MYJOB-PREFIX-")
     {
        $job = substr $_,0,7;
        $mtime = (stat($_))[9]; 
        ($sec, $min, $hr, $day, $month, $year, $day_Of_Week, $julianDate, $dst) = localtime($mtime);
        $year=$year+1900;
        $month=$month+1;
        $length = length($_);
        $startYear = substr($_,$length - 19,2);        
        $startYear=$startYear+2000;
        $startMonth = substr($_,$length - 17,2);
        $startDay = substr($_,$length - 15,2);
        $startHour = substr($_,$length - 12,2);
        $startMinute = substr($_,$length - 9,2);
        $startSecond = substr($_,$length - 6,2);
        $files{$_}{'name'}      = $_;
        $files{$_}{'month'}     = $month;
        $files{$_}{'day'}       = $day;
        $files{$_}{'year'}      = $year;
        $files{$_}{'hr'}        = $hr;
        $files{$_}{'min'}       = $min;
        $files{$_}{'sec'}       = $sec;
        $files{$_}{'startYear'} = $startYear;
        $files{$_}{'startMonth'} = $startMonth;
        $files{$_}{'startDay'}  = $startDay;
        $files{$_}{'startHour'}   = $startHour;
        $files{$_}{'startMinute'} = $startMinute;
        $files{$_}{'startSecond'} = $startSecond;        
        $files{$_}{'job'}   = $job;
        # keep track of how many elements are in the parent hash
        my $file_no = scalar(keys(%files));
        # print Dumper(%files);
     }
   }
}
