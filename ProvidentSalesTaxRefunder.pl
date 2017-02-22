##
## Script to read AutoManager Closed Deals Report
##

my $COMMA = ",";
my $COMMAx2 = ",,";

my $numArgs = $#ARGV + 1;

## Make sure we have the right command line arguments
if ( $numArgs != 1 )
{
	print "ProvidentSalesTaxRefunder.pl <ClosedDeals-SalesTaxCalculation.csv>\n";
	exit 1;
}

## Open file and sure the file AutoManager file exists
if (open(AM_INPUT_FILE,$ARGV[0]) == 0) {
   print "Error opening: ",$ARGV[0];
   exit -1;  
}

## Open AutoManager output file 
if (open(AM_OUTPUT_FILE,'> SalesTaxCalculation_output.csv') == 0) {
   print "Error opening: SalesTaxCalculation_output.csv";
   exit -1;  
}

my $count=1;

## Read the AutoManager input file 
while (<AM_INPUT_FILE>) {
 chomp;
 my($closedate,$saledate,$fullvin,$stockno,$lastname,$firstname,$saleprice,$salestax,$docfee,$smogfee,$gapwarranty,$registration,$license,$smogcert,$downpayment,$financecharge,$intrcvd,$prinrcvd,$latercvd,$totalpayments,$taxrate,$repostatus,$unwind) = split(",");
 
 my $taxablefees = sprintf("%.2f",$docfee + $smogfee);
 my $nontaxablecharges = sprintf("%.2f",$gapwarranty + $registration + $license + $smogcert);
 my $paymentsrecvd = sprintf("%.2f",$intrcvd + $prinrcvd + $latercvd);
 my $unearnedfinancecharge = sprintf("%.2f", $financecharge - $intrcvd);
 
 $downpayment = sprintf("%.2f",$downpayment);
 $financecharge = sprintf("%.2f",$financecharge);
 $saleprice = sprintf("%.2f",$saleprice);
 
 if ($unwind eq "U" || $repostatus eq "Write Off")
 {
	print AM_OUTPUT_FILE $fullvin,$COMMA,$closedate,$COMMA,$saledate,$COMMAx2,$stockno,$COMMA,$firstname," ",$lastname,$COMMA,$saleprice,$COMMA;
	print AM_OUTPUT_FILE $taxablefees,$COMMAx2,$salestax,$COMMA,$nontaxablecharges,$COMMAx2,$downpayment,$COMMAx2,$financecharge,$COMMAx2;
	print AM_OUTPUT_FILE $paymentsrecvd,$COMMAx2,$unearnedfinancecharge,"\n";
	
	print $count++,"[",$stockno,"]", $firstname," ",$lastname, "\n"; 
 }
 
}

close(AM_INPUT_FILE);
close(AM_OUTPUT_FILE); 
