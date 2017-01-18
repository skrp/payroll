use strict; use warnings;
#################################
# Fed - tax witholding calculator
#                 ---skrp of MKRX
my ($type, $exception, $salary) = @ARGV;
my $f_tax; my $s_tax;
if ($type eq "single") { 
     $f_tax = single_fwh($exception, $salary);
     $s_tax = single_swh($exception, $salary); 
}
elsif ($type eq "married") { 
     $f_tax = married_fwh($exception, $salary); 
     $s_tax = married_swh($exception, $salary);
}
else { die "Something went wrong ggwp gl bro\n" }
print "Federal Witholding Amount: $f_tax\nState Withholding: $s_tax\n";
# SUBS ############################
sub single_fwh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $Fed_table = "SingleFWH.txt";
    open(my $ffp, '<', $Fed_table) or die "can't open SingleFWH.txt";
    my @Fed;
    while (my $line = readline $sfp) {
        my @tmp = split ' ', $line;
        foreach my $item (@tmp)
            { $item =~ s/,//; }
        push @Fed, [ @tmp ];
    }
    my $i = 0;
    foreach (@Single) {
        if (($salary > $Single[$i][0]) and ($salary < $Single[$i][1]))
            { return $Single[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub single_swh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $State_table = "SingleSWH.txt";
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
        if (($salary > $Single[$i][0]) and ($salary < $Single[$i][1]))
            { return $Single[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub married_fwh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $Fed_table = "MarriedFWH.txt";
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
        if (($salary > $Fed[$i][0]) and ($salary < $Fed[$i][1]))
            { return $Fed[$i][$xcept]; }
        else { $i++; next; }
    }
}
sub married_fwh { # ARGV1 EXCEPTION  ARGV2 GROSS
    my $xcept = shift @_; $xcept+=2; # adjust $xcept for table format
    my $gross = shift @_;
    my $State_table = "MarriedSWH.txt";
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
        if (($salary > $State[$i][0]) and ($salary < $State[$i][1]))
            { return $State[$i][$xcept]; }
        else { $i++; next; }
    }
}
