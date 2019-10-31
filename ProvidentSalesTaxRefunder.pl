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

print AM_OUTPUT_FILE "REF NUMBER,VIN NUMBER,ACOUNT CLOSED DATE,SALES DATE,REPO DATE,STOCK NUMBER,CUSTOMER NAME,RETAIL SALES PRICE,TAXABLE FEES (DOC SMOG),TOTAL AMOUNT SUBJECT TO TAX,";
print AM_OUTPUT_FILE "SALES TAX,TAX RATE,OTHER NON-TAXABLE CHARGES,TOTAL SELLING PRICE,DOWN PAYMENT,BALANCE ON CONTRACT,FINANCE CHARGES,TOTAL CONTRACT VALUE,";
print AM_OUTPUT_FILE "PAYMENTS RECEIVED ON CONTRACT,BALANCE ON DATE OF REPO,UNEARNED FINANCE CHARGES,NET CONTRACT BALANCE,";

print AM_OUTPUT_FILE "TAXPAYER REPO VALUE,TAX PAYER TOTAL PRINCIPAL PAID,TAX PAYER GAP+WARRANTY REFUND, TAX PAYER PRINCIPAL PAYMENTS,WHOLESALE VALUE,";
print AM_OUTPUT_FILE "RECONDITION COST,REPOSSESSION LOSS PER RECORDS,TAXABLE % OF LOSS,ALLOWABLE DEDUCTION,ALLOWABLE TAX CREDIT,TAX PAYER COMMENT\n";


## Read the AutoManager input file 
while (<AM_INPUT_FILE>) {
 chomp;
 my($closedate,$saledate,$fullvin,$stockno,$lastname,$firstname,$saleprice,$salestax,$docfee,$smogfee,$gapwarranty,$registration,$license,$smogcert,$downpayment,$financecharge,$intrcvd,$prinrcvd,$latercvd,$totalpayments,$taxrate,$repostatus,$unwind,$year,$principalrx,$city) = split(",");

 
 
 my $taxablefees = sprintf("%.2f",$docfee + $smogfee); 
 my $nontaxablecharges = sprintf("%.2f",$gapwarranty + $registration + $license + $smogcert);
 my $paymentsrecvd = sprintf("%.2f",$intrcvd + $prinrcvd + $latercvd);
 my $unearnedfinancecharge = sprintf("%.2f", $financecharge - $intrcvd); 
 my $amtsubjecttotax = sprintf("%.2f",$saleprice + $taxablefees);
 my $totalsellingprice = sprintf("%.2f",$amtsubjecttotax + $salestax + $nontaxablecharges);
 my $balanceoncontract = sprintf("%.2f",$totalsellingprice - $downpayment);
 my $totalcontratvalue = sprintf("%.2f",$balanceoncontract + $financecharge);
 my $unearnedint = sprintf("%.2f",$financecharge - $intrcvd);
 my $balanceonrepodate = sprintf("%.2f", $totalcontratvalue - $paymentsrecvd);
 
# print $count," [",$smogcert,"]", $smogfee," ",$gapwarranty," ",$registration," ",$license," = ",$nontaxablecharges,"\n"; 

 
 if ($unearnedfinancecharge < 0 )
 {
	$unearnedfinancecharge = 0;
 }
 
 my $netcontractbalance = sprintf("%.2f", $balanceonrepodate - $unearnedfinancecharge);
 
 $downpayment = sprintf("%.2f",$downpayment);
 $financecharge = sprintf("%.2f",$financecharge);
 $saleprice = sprintf("%.2f",$saleprice); 
 
 
 
 if ( ($unwind eq "U") || ($repostatus eq "Write Off") )
 {
	print AM_OUTPUT_FILE $count,$COMMA,$fullvin,$COMMA,$closedate,$COMMA,$saledate,$COMMAx2,$stockno,$COMMA,$firstname," ",$lastname,$COMMA,$taxrate/100,$COMMA,$saleprice,$COMMA,$taxablefees,$COMMA,$amtsubjecttotax,$COMMA;
	print AM_OUTPUT_FILE $salestax,$COMMA,$nontaxablecharges,$COMMA,$totalsellingprice,$COMMA,$downpayment,$COMMA,$balanceoncontract,$COMMA,$financecharge,$COMMA,$totalcontratvalue,$COMMA;
	print AM_OUTPUT_FILE $paymentsrecvd,$COMMA,$balanceonrepodate,$COMMA,$unearnedfinancecharge,$COMMA,$netcontractbalance,$COMMA,$city,"\n";
	
	print $count++," [",$stockno,"]", $firstname," ",$lastname,"\n"; 
 }
  	 
 
 
}

close(AM_INPUT_FILE);
close(AM_OUTPUT_FILE); 
