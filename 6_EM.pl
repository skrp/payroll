use strict; use warnings;
use Email::Stuffer qw(send);
use Email::Sender::Transport::SMTP::TLS qw();
#################################
# EM - automated group password-protected-pdf attachments
# DESC ##########################
# prior steps:
# 1) PDF.vba - vba to pdf (if necessary)
# 2) ATT.pl - password protect attachment
# SETUP #########################
print "batch: ";
my $batch = <>; chomp $batch;

my %list; # key = email; value = attachment;
# LIST ##########################
print "Reading TABLES\\LIST.txt\n";
open(my $lifh, '<', 'TABLES\\LIST.txt');
my @set = readline $lifh; chomp @set;

my $i_sender = shift @set;
my @a_sender = split(" ", $i_sender, 2);
my $sender = @a_sender[0];
my $pass = @a_sender[1];

foreach my $line (@set) {
    my @i = split(" ", $line, 3);
    $list{$i[0]} = $i[1];
}
# SENDER #########################
my $trans = Email::Sender::Transport::SMTP::TLS->new(
    host => 'smtp.gmail.com',
    port => '587',
    username => $sender,
    password => $pass,
);
# LOOP ############################
foreach my $ee (keys %list) {
    my $att = "PDF\\ATT\\$list{$ee}";
    print "sending $ee : $att\n";
    my $body = "$msg\n$batch pay stub attached as a pdf\nUNLOCK WITH LAST 4 DIGITS OF SSN\n";
    my $email = Email::Stuffer
        ->from ($sender)
        ->to ($ee)
        ->subject($batch)
        ->text_body($body)
        ->attach_file($att)
        ->transport($trans)
        ->send or die "error in trans\n";
}
# NOTES ###########################
# GOOGLE
# If the sender is a google account change this setting
# https://www.google.com/settings/security/lesssecureapps
