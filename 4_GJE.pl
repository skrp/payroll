use strict; use warnings;
use Spreadsheet::ParseXLSX;
#############################################
# GJE - General Journal Entry for Payroll
#############################################
# STRUCTURE #################################
# Workbook structure
# sheet 1   : GRAND
# sheet 2-5 : Quarterlies
# sheet 6-> : Stubs

# SETUP #####################################
my ($pr_row) = @ARGV;
die ("ARG1: pr_row") unless defined $pr_row;

my @sheets; my $book;
my ($ttl_deff, $ttl_garnish, $ttl_dental, $ttl_health, $ttl_hsa);
my ($ttl_fit, $ttl_sit, $ttl_ss, $ttl_med, $ttl_gross);
my ($add_med, $min_ss, $er, $fica); my $ttl_net = 0;
# OBTAIN VARIABLES FROM TXT FILE ############
open(my $vfh, '<', 'TABLES\VAR.txt') or die ("MISSING VAR.txt\n");
my @var = readline $vfh;
close $vfh; chomp @var;

my $year = $var[0]; my $lim_def = $var[1]; my $lim_odef = $var[2];
my $lim_shsa = $var[3]; my $lim_mhsa = $var[4]; my $lim_ohsa = $var[5];
my $lim_smed = $var[6]; my $lim_mmed = $var[7]; my $rate_addmed = $var[8]; my $lim_ss = $var[9];
#############################################
# VERIFY COLUMNS MATCH Spreadsheet (less 1) #
$book = glob("*.xlsm");
die ("No Payroll Spreadsheet book") unless defined $book;
open(my $bfh, '<', $book) or die ("FAIL OPEN $book\n");
my $parser = Spreadsheet::ParseXLSX->new;
my $wb = $parser->parse($book);
die ("parser error") unless defined $wb;

my $gross_col = 10; my $def_col = 12; my $garnish_col = 13; my $yob_col = 1;
my $dental_col = 14; my $health_col = 15; my $hsa_col = 16; my $start = 6;
my $fit_col = 20; my $sit_col = 21; my $net_col = 23; my $tag_col = 27;
my $stat_row = 72; my $stat_col = 9; my $ytd_row = 69; my $yob_row = 70;
#############################################
$pr_row--; # change for internal processing
my $name = dateup();
open(my $ofh, '>', "ITEMS\\journals\\$name.txt");
print $ofh "$name\n";
#############################################
foreach ($wb->worksheets())
    { push @sheets, $_->get_name(); }
print $ofh "##########################\n";
# rm GRAND & Quarterlies & tmp
shift @sheets; pop @sheets; #splice @sheets, 0, 5;
#$pr_row--; # change for internal processing
#############################################
for (@sheets)
{
    # skip blank entries
    my $ws = $wb->worksheet($_);
    my $name = $ws->get_name;
    my $gross = sprintf("%.2f", val($ws, $pr_row, $gross_col));
    next if ($gross == 0);
    my $net = sprintf("%.2f", val($ws, $pr_row, $net_col));
    my $tag =  val($ws, $pr_row, $tag_col);
    my $gar = val($ws, $pr_row, $garnish_col);

    print $ofh "Gross $name: $gross\n";
    $ttl_gross += $gross;
    if ($tag eq 1)
      { print $ofh "   PR_Check $name: $net\n"; }
    else
      { $ttl_net += $net; }
    if ( $gar > 0)
        { print $ofh "   Garnish: $name: $gar\n"; }
#############################################
    deduct($ws);
    addmed_chk($ws, $name, $gross);
    ss($ws, $name, $gross);
#############################################
    chk_def($ws, $name);
    chk_hsa($ws, $name);
}
#############################################
$ttl_ss = $ttl_gross; $ttl_med = $ttl_gross;
$ttl_med -= $add_med if (defined $add_med && $add_med > 0);
$ttl_ss -= $min_ss if (defined $min_ss && $min_ss > 0);
#############################################
$ttl_ss = sprintf("%.2f", $ttl_ss*0.062);
$ttl_med = sprintf("%.2f", $ttl_med*0.0145);
$er = $ttl_ss+$ttl_med;
$fica = sprintf("%.2f", $er*2);
#############################################
print $ofh "\nDef:    $ttl_deff\n";
print $ofh "Dental: $ttl_dental\n";
print $ofh "Health: $ttl_health\n";
print $ofh "HSA:    $ttl_hsa\n";
print $ofh "FIT:    $ttl_fit\n";
print $ofh "SIT:    $ttl_sit\n";
print $ofh "FICA:    $fica\n";
print $ofh "   ER_Tax: $er\n";
print $ofh "\nNET: $ttl_net\n";
print $ofh "##########################\n";
# SUB #######################################
sub deduct
{
    my ($ws) = @_;
    $ttl_deff += val($ws, $pr_row, $def_col);
    $ttl_dental += val($ws, $pr_row, $dental_col);
    $ttl_health += val($ws, $pr_row, $health_col);
    $ttl_hsa += val($ws, $pr_row, $hsa_col);
    $ttl_fit += val($ws, $pr_row, $fit_col);
    $ttl_sit += val($ws, $pr_row, $sit_col);
}
sub addmed_chk
{
    my ($ws, $name, $gross) = @_;
    my ($app, $ptd, $ytd, $stat, $add_tax);

    $ytd = val($ws, $ytd_row, $gross_col);
    return if ($ytd < $lim_smed);

    $ptd = gross_ptd($ws);
    $stat = val($ws, $stat_row, $stat_col);

    if ($stat =~ m/m/i)
    {
        return if ($ptd < $lim_mmed);

        if (($ptd - $gross) >= $lim_mmed)
            { $app = $gross; }
        else
            { $app = $ptd - $lim_mmed; }

        $add_tax = $app*$rate_addmed;
        print $ofh "   ADDMED $name $add_tax\n";
        $add_med += $app;
    }
    if ($stat =~ m/s/i)
    {
        return if ($ptd < $lim_smed);

        if (($ptd - $gross) >= $lim_smed)
            { $app = $gross; }
        else
            { $app = $ptd - $lim_smed; }

        $add_tax = $app*$rate_addmed;
        print $ofh "   ADDMED $name $add_tax\n";
        $add_med += $app;
    }


    #if (($ptd - $gross) >= $lim_ss)
    #    { $app = $gross; }
    #else
    #        { $app = $ptd - $lim_ss; }
}
sub ss
{
    my ($ws, $name, $gross) = @_;
    my ($app, $ptd, $ytd);
    $ytd = val($ws, $ytd_row, $gross_col);
    return if ($ytd < $lim_ss);

    $ptd = gross_ptd($ws);
    return if ($ptd < $lim_ss);
    $app = $ptd - $lim_ss;

    if ($app > $gross)
    	{ $app = $gross; }
    else 
    	{ $app = $gross - $app; }
    $min_ss += $app;

    print $ofh "### INFO_ONLY SS_EXEMPT $name $app ###\n";
}
sub chk_def
{
    my ($ws, $name) = @_;
    my $max_def; my $age;

    my $aage = val($ws, $yob_row, $yob_col);
    print $ofh "### ERROR missing year of birth: $name ###\n" if $aage < 16;
    $age = $year -$aage;
    if ($age >= 50)
        { $max_def = $lim_def + $lim_odef; }
    else
        { $max_def = $lim_def; }

    print $ofh "### ERROR DEFFERAL EXCEEDED $name ###\n" if ($max_def < val($ws, $ytd_row, $def_col));
}
sub chk_hsa
{
    my ($ws, $name) = @_;
    my $max_hsa;
    my $stat = val($ws, $stat_row, $stat_col);
    my $age = $year - val($ws, $yob_row, $yob_col);

    if ($stat =~ m/s/i)
    {
        if ($age >= 55)
            { $max_hsa = $lim_shsa + $lim_ohsa; }
        else
            { $max_hsa = $lim_shsa; }
    }

    if ($stat =~ m/m/i)
    {
        if ($age >= 55)
            { $max_hsa = $lim_mhsa + $lim_ohsa; }
        else
            { $max_hsa = $lim_mhsa; }
    }

    print $ofh "### ERROR HSA EXCEEDED $name ###\n" if ($max_hsa < val($ws, $ytd_row, $hsa_col));
}
sub val
{
    my ($ws, $row, $col) = @_;
    my $bcell; my $ival;

    $bcell = $ws->get_cell($row, $col);
    $ival = 0 unless eval { $ival = $bcell->unformatted; };
    $ival = 0 if ($ival eq '');

    return $ival;
}
sub gross_ptd
{
    my ($ws) = @_;
    my $g; my $i = $start;

    while ($i <= $pr_row)
        { $g += val($ws, $i, $gross_col); $i++; }
    return $g;
}
sub dateup
{
    my $iws = $wb->worksheet('TTL');
    my ($ival, $icell);

    $icell = $iws->get_cell($pr_row, 1);
    $ival = 0 unless eval { $ival = $icell->value(); };

    return $ival;
}
