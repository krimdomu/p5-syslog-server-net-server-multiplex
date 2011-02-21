package Syslog::Server::Net::Server::Multiplex;

use strict;
use warnings;

our $VERSION = '0.1.0';

use Net::Server::Multiplex;
use base qw(Net::Server::Multiplex);

#                          1      2       3      4     5     6      7     8
my $SYSLOG_REGEXP = qr{^<(\d+)>(\S{3}\s+(\d+)\s(\d+):(\d+):(\d+)\s(\S+)\s(.*)$)};
#                         PRIO   MON     DAY    HOUR  MIN   SEC  SERVER  TEXT

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = { @_ };

   bless($self, $proto);

   return $self;
}

sub run {
   my ($self, %opt) = @_;

   $self->SUPER::run(
      port              => $opt{'port'} || 514,
      listen            => 1024,
      host              => '',
      no_client_stdout  => 1,
      proto             => 'tcp',
      serialize         => 'flock',
      %opt,
   );
}

sub mux_input {
   my ($self, $mux, $fh, $in_ref) = @_;

   my $input = ${$in_ref};

   if($input and length $input) {

      for my $line ( split(/\n/, $input) ){

         if($line =~ m/$SYSLOG_REGEXP/) {

            my $msg = {
               time  => "$2 $3 $4:$5:$6",
               msg   => $8,
               pri   => $1,
               host  => $7,
               facility => int($1/8),
               severity => int($1%8),
            };

            $self->input($msg);

         }

      }

   }

}

1;
