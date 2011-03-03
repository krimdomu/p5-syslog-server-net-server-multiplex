package Syslog::Server::Net::Server::Multiplex;

use strict;
use warnings;

our $VERSION = '0.1.0';

use Net::Server::Multiplex;
use base qw(Net::Server::Multiplex);

#                          1      2       3      4     5     6      7     8
my $SYSLOG_REGEXP = qr{^<(\d+)>(\S{3})\s+(\d+)\s(\d+):(\d+):(\d+)\s(\S+)\s(.*)$};
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
      port              => $opt{'port'}    || 514,
      listen            => $opt{'backlog'} || 1024,
      host              => $opt{'host'}    || '',
      proto             => $opt{'proto'}   || 'tcp',

      no_client_stdout  => 1,
      serialize         => 'flock',

      %opt,
   );
}

sub mux_input {
   my ($self, $mux, $fh, $in_ref) = @_;

   while( $$in_ref =~ s/^(.*?)\r?\n// ) {
      next unless $1;
      my $line = $1;

      if($line =~ m/$SYSLOG_REGEXP/) {

         my $msg = {
            time  => $self->parsedate($2, $3, $4, $5, $6),
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

sub parsedate {
	my $self = shift;
	my ($mon, $day, $hour, $min, $sec) = @_;

	my %month = ('Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
			'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12');
	
	my $year = $self->_get_year;
	return "$year-" . $month{$mon} . "-$day $hour:$min:$sec";
}

sub _get_year {
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year+=1900;
	return $year;

}

1;
