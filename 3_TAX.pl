use strict; use warnings;
use Spreadsheet::ParseXLSX;
#############################################
# TAX - Calculate tax witholding
#############################################
my ($pr_row) = @ARGV;
die "ARG1 pr_row" if (!defined $pr_row);
my ($pr, $wb, $book, $win);
my @sheets;
my $gross_col = 10; my $stat_col = 9; my $exception_col = 9;
my $stat_row = 72; my $exception_row = 73;
$pr_row--; # change for internal processing
#############################################
$book = glob("*.xlsm");
open(my $bfh, '<', $book) or die ("FAIL OPEN $book\n");
my $parser = Spreadsheet::ParseXLSX->new();
$wb = $parser->parse($book);
die ("parser error") unless defined $wb;
#############################################
$pr = dateup();
open(my $ofh, '>', "ITEMS\\tax\\$pr.txt");
print $ofh "$pr\n";
#############################################
foreach ($wb->worksheets())
    { push @sheets, $_->get_name(); }
print $ofh "##########################\n";
splice @sheets, 0, 5; # rm GRAND & Quarterlies & tmp
#############################################
for (@sheets)
{
    my ($ws, $name, $gross, $fit, $sit, $stat, $exception);

    $ws = $wb->worksheet($_);
    $name = $ws->get_name();

    $gross = sprintf("%.2f", val($ws, $pr_row, $gross_col));
    next if ($gross == 0); # skip blank entries
#############################################
    $stat = val($ws, $stat_row, $stat_col);
    $exception = val($ws, $exception_row, $exception_col);

    if ($stat =~ m/s/i)
    {
         $fit = single_fwh($exception, $gross);
         $sit = single_swh($exception, $gross);
    }
    elsif ($stat =~ m/m/i)
    {
         $fit = married_fwh($exception, $gross);
         $sit = married_swh($exception, $gross);
    }
#############################################
    print $ofh "$name: ";
    printf $ofh "FIT: %5s      ", $fit;
    printf $ofh "SIT: %5s\n", $sit;
#############################################

}
# SUB #######################################
sub val
{
    my ($ws, $row, $col) = @_;
    my $bcell; my $ival;

    $bcell = $ws->get_cell($row, $col);
    $ival = 0 unless eval { $ival = $bcell->unformatted; };
    $ival = 0 if ($ival eq '');

    return $ival;
}
sub single_fwh
{ # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $Fed_table = 'TABLES\SingleFWH.txt';
    open(my $ffp, '<', $Fed_table) or die "can't open SingleFWH.txt";
    my @Fed;
    while (my $line = readline $ffp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @Fed, [ @tmp ];
    }
    my $i = 0;
    foreach (@Fed) {
        if (($gross > $Fed[$i][0]) and ($gross <= $Fed[$i][1]))
            { return $Fed[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub single_swh
{ # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $State_table = 'TABLES\SingleSWH.txt';
    open(my $sfp, '<', $State_table) or die "can't open SingleSWH.txt";
    my @State;
    while (my $line = readline $sfp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @State, [ @tmp ];
    }
    my $i = 0;
    foreach (@State) {
        if (($gross > $State[$i][0]) and ($gross <= $State[$i][1]))
            { return $State[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub married_fwh
{ # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $Fed_table = 'TABLES\MarriedFWH.txt';
    open(my $ffp, '<', $Fed_table) or die "can't open MarriedFWH.txt";
    my @Fed;
    while (my $line = readline $ffp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @Fed, [ @tmp ];
    }
    my $i = 0;
    foreach (@Fed) {
        if (($gross > $Fed[$i][0]) and ($gross <= $Fed[$i][1]))
            { return $Fed[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub married_swh
{ # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $State_table = 'TABLES\MarriedSWH.txt';
    open(my $mfp, '<', $State_table) or die "can't open MarriedSWH.txt";
    my @State;
    while (my $line = readline $mfp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @State, [ @tmp ];
    }
    my $i = 0;
    foreach (@State) {
        if (($gross > $State[$i][0]) and ($gross <= $State[$i][1]))
            { return $State[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub dateup
{
    my $iws = $wb->worksheet('TTL');
    my ($ival, $icell);

    $icell = $iws->get_cell($pr_row, 1);
    $ival = 0 unless eval { $ival = $icell->value(); };

    return $ival;
}
#############################################

#############################################
sub new_fit
{

}
sub new_sit
{

}
sub ss
{
}
sub med
{
}
sub add_med
{
}
sub chk_ITEMS
{ # go thru all pr_rows chk journal & tax entry populate if needed

}
