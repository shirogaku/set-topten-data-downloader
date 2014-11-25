use Data::Dumper;
use LWP::UserAgent;
use File::Copy;
use Time::Piece;

GetData();
FilterDataFromSite();
CategorizeData();
RenameCatData();

sub GetData{
my $ua = LWP::UserAgent->new(
	agent => "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.65 Safari/537.36" #Your User-agent here
);
my $resp = $ua->get("http://marketdata.set.or.th/mkt/topten.do");
open("FILE",">","RawData.txt") or die "Could not create raw data file";
print FILE Dumper($resp);	
close FILE;
}

sub FilterDataFromSite{
	open("RawData","<","RawData.txt") or die "Could not open raw data file";
		open("Data",">","Data.txt") or die "Cound not create data file";
			foreach my $line (<RawData>){
				if($line =~ /symbol=(\w{1,6})/){
					#Filter stock name
					print Data $1."\t";
				}
				if($line =~ /\<td\salign\=\"right\"\>\s(\d{1,3}[,]?\d{1,3}[,]?\d{1,3}[,]?\d{1,3}|\d{1,3})\s\<\/td\>/){
					#Filter volume/value
					print Data $1."\t";
				}
				if($line =~ /\<td\salign\=\"right\"\>\s(\d{1,3}[.]\d{1,2})\s\<\/td\>/){
					#Filter last price
					print Data $1."\t";
				}
				if($line =~ /\<td\salign\=\"right\"\>\s\-\s\(\-\)\<\/td\>/){
					#Filter stock which doesn't have movement
					print Data "- (-)\n";
				}
				if($line =~ /\<td\salign\=\"right\"\>\s\<font\sstyle\=\"color\:\sgreen\;\"\>(\+\d{1,2}[.]\d{1,2})\<\/font\> \<font\sstyle\=\"color\:\sgreen\;\"\>(\(\+\d{1,2}[.]\d{1,2}\%\))\<\/font\>\<\/td\>/){
					#Filter stock which is gainer
					print Data $1 . " " . $2 . "\n";
				}
				if($line =~/\<td\salign\=\"right\"\>\s\<font\sstyle\=\"color\:\sred\;\"\>(\-\d{1,2}[.]\d{1,2})\<\/font\>\s\<font\sstyle\=\"color\:\sred\;\"\>(\(\-\d{1,2}[.]\d{1,2}\%\))\<\/font\>\<\/td\>/){
					#Filter stock which is loser
					print Data $1 . " " . $2 . "\n";
				}
			}
		close(Data);
	close(RawData);
	unlink("RawData.txt"); #Delete unused RawData.txt
}

sub CategorizeData{
	open("Data","<","Data.txt") or die "Data file not found";
	open("CatData",">","CatData.txt") or die "Could not create data file";
	print CatData "Most Active Value ('000 Baht)\n";
	my $i;
	@CONTENT = <Data>;
	for($i=0 ; $i<10 ; $i++){
		print CatData $CONTENT[$i];
	}
	print CatData "\nMost Active Volume (Shares)\n";
	for($i=20 ; $i<30 ; $i++){
		print CatData $CONTENT[$i];	
	}
	print CatData "\nTop Gainer\n";
	for($i=10 ; $i<20 ; $i++){
		print CatData $CONTENT[$i];
	}
	print CatData "\nTop Loser\n";
	for($i=30 ; $i<40 ; $i++){
		print CatData $CONTENT[$i];
	}
	close(CatData);
	close(Data);
	unlink("Data.txt"); #Delete unused Data.txt
}

sub RenameCatData{
	my $date = localtime->strftime('%d%m%Y');
	my $name = "Data". $date . ".txt";
	move("CatData.txt",$name);
}
