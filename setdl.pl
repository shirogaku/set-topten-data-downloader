use LWP::UserAgent;
use File::Copy;
use Time::Piece;

RenameData(CategorizeCreateData(FilterDataFromSite(GetData())));

sub GetData{
	my $ua = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.65 Safari/537.36" #Your User-agent here
	);
	my $resp = $ua->get("http://marketdata.set.or.th/mkt/topten.do");
	return $resp->decoded_content;
}

sub FilterDataFromSite{
	@content;
	my $i=0;
	open(my $va , "<" , \@_[0]);
	while(<$va>){
		if($_ =~ /symbol=(\w{1,6})/){
			#Filter Stock Name
			@content[$i] = $1."\t";
		}
		elsif($_ =~ /\<td\salign\=\"right\"\>\s(\d{1,3}[,]?\d{1,3}[,]?\d{1,3}[,]?\d{1,3}|\d{1,3})\s\<\/td\>/){
			#Filter volume/value
			@content[$i] .= $1."\t";
		}
		elsif($_ =~ /\<td\salign\=\"right\"\>\s(\d{1,3}[.]\d{1,2})\s\<\/td\>/){
			#Filter last price
			@content[$i] .= $1."\t";
		}
		elsif($_ =~ /\<td\salign\=\"right\"\>\s\-\s\(\-\)\<\/td\>/){
			#Filter stock which doesn't have movement
			@content[$i] .= "- (-)";
			$i++;
		}
		elsif($_ =~ /\<td\salign\=\"right\"\>\s\<font\sstyle\=\"color\:\sgreen\;\"\>(\+\d{1,2}[.]\d{1,2})\<\/font\> \<font\sstyle\=\"color\:\sgreen\;\"\>(\(\+\d{1,3}[.]\d{1,2}\%\))\<\/font\>\<\/td\>/){
			#Filter stock which is gainer
			@content[$i] .= $1 . " " . $2;
			$i++;
		}
		elsif($_ =~ /\<td\salign\=\"right\"\>\s\<font\sstyle\=\"color\:\sred\;\"\>(\-\d{1,2}[.]\d{1,2})\<\/font\>\s\<font\sstyle\=\"color\:\sred\;\"\>(\(\-\d{1,2}[.]\d{1,2}\%\))\<\/font\>\<\/td\>/){
			#Filter stock which is loser
			@content[$i] .= $1 . " " . $2;
			$i++;
		}
	}
	return @content;
}

sub CategorizeCreateData{
	open("Data",">","Data.txt") or die "Could not create data file";
	print Data "Most Active Value ('000 Baht)\n";
	my $i;
	for($i=0 ; $i<10 ; $i++){
		print Data $_[$i]."\n";
	}
	print Data "\nMost Active Volume (Shares)\n";
	for($i=20 ; $i<30 ; $i++){
		print Data $_[$i]."\n";	
	}
	print Data "\nTop Gainer\n";
	for($i=10 ; $i<20 ; $i++){
		print Data $_[$i]."\n";
	}
	print Data "\nTop Loser\n";
	for($i=30 ; $i<40 ; $i++){
		print Data $_[$i]."\n";
	}
	close(Data);
}

sub RenameData{
	my $date = localtime->strftime('%d%m%Y');
	my $name = "Data". $date . ".txt";
	move("Data.txt",$name);
}
