use strict; use warnings;
#################################
# Fed - tax witholding calculator
#                 ---skrp of MKRX
my ($type, $exception, $salary) = @ARGV;
my $tax;
if ($type eq "single")
     { $tax = single_fwh($exception, $salary); }
elsif ($type eq "married")
     { $tax = married_fwh($exception, $salary); }
else { die "Something went wrong ggwp gl bro\n" }
print "Federal Witholding Amount: $tax\n";
# SUBS ############################
sub single_fwh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2;
    my $gross = shift @_;
    my $Single_table = "SingleFWH.txt";
    open(my $sfp, '<', $Single_table) or die "can't open SingleFWH.txt";
    my @Single;
    while (my $line = readline $sfp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @Single, [ @tmp ];
    }
    my $i = 0;
    foreach (@Single) {
        if (($salary > $Single[$i][0]) and ($salary < $Single[$i][1]))
            { return $Single[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub married_fwh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $Married_table = "MarriedFWH.txt";
    open(my $mfp, '<', $Married_table) or die "can't open MarriedFWH.txt";
    my @Married;
    while (my $line = readline $mfp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @Married, [ @tmp ];
    }
    my $xcept = shift @_; $xcept+=2;
    my $gross = shift @_;
    my $i = 0;
    foreach (@Married) {
        if (($salary > $Married[$i][0]) and ($salary < $Married[$i][1]))
            { return $Married[$i][$xcept]; }
        else { $i++; next; }
    }
}
