package SOAP::Autounload;


BEGIN:
{

use strict;
use vars qw($VERSION);

$VERSION = '0.10';

require 5.000;

use Data::Dumper;

}



sub handle_request
{
my ($self, $headers, $body, $envelopeMaker) = @_;
my (@ARGV, $arg);


	my $method_name = $body->{soap_typename};

	#
	# Unload Arguments into an array to pass to our method
	#
	$arg = 0;
	while ( $_ = $body->{"ARG$arg"} ) {
	 	if ( /^array::/ ) {
	 		s/^array:://;
	 		$_ = eval ( $_ );
	 	}
	 	push ( @ARGV, $_ );
		delete ( $body->{"ARG$arg"} );
		$arg++;
	}


	#
	# Recycle @ARGV with result of our method call.
	#
	@ARGV = $self->$method_name ( @ARGV );

	#
	# Reload Arguments into an array to return to our caller
	#
	$arg = 0;
	foreach (@ARGV) {
		if ( ref ($_) eq "ARRAY" ) {
			$_ = Dumper ( $_ );
			s/^\$VAR = /array::/g;
		}
		$body->{"ARG$arg"} = $_;
		$arg++;
	}

	#
	# For some reason I feel compelled to do this..
	#
	$body->{ARGC} = scalar @ARGV;


	$envelopeMaker->set_body(undef, "$method_name.response", 0, $body);
}


1;
__END__


=head1 NAME

SOAP::Autounload - Unmarshall data sent by SOAP::Autoload.

=head1 SYNOPSIS

  #
  #  Server example that goes with client example in SOAP::Autoload
  #

  package Calculator;
  use base qw( SOAP::Autounload );

  sub new {
    bless {}, shift;
  }

  sub add
  {
  my $self = shift;
  my $sum  = 0;

       foreach (@_) {
            $sum += $_;
       }

       $sum;
  }

=head1 DESCRIPTION

A package derived from from SOAP::Autounload will be able to receive data
via HTTP server sent by a client using SOAP::Autoload.  SOAP::Autounload
provides methods to extract arguments from a SOAP compliant XML structure
thus allowing the client to use the class as if it were local.

=head1 DEPENDENCIES

Data::Dumper

=head1 AUTHOR

Daniel Yacob, L<yacob@rcn.com|mailto:yacob@rcn.com>

=head1 SEE ALSO

S<perl(1). SOAP(3). SOAP::Autoload(3).>
