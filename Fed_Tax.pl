use strict; use warnings;
my ($type, $exception, $salary) = @ARGV;
my $tax;
if ($type eq "single")
     { $tax = single_fwh($exception, $salary); }
elsif ($type eq "married")
     { $tax = married_fwh($exception, $salary); }
else { die "Something went wrong ggwp gl bro\n" }
print "$tax\n";

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
#### EX DATA ##############################################
# low_salary upper_salary (exceptions) 0 1 2 3 4 5 6 7 8 9 10
# 2,220 2,240 250 226 203 179 156 133 109 86 66 50 34
# 2,240 2,260 253 229 206 182 159 136 112 89 68 52 36
# 2,260 2,280 256 232 209 185 162 139 115 92 70 54 38
