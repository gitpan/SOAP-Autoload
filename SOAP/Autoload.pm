package SOAP::Autoload;


BEGIN
{

use strict;
use vars qw ( $VERSION $AUTOLOAD $DEFAULT_HOST $DEFAULT_PORT $DEFAULT_ENDPOINT $DEFAULT_METHOD_URI  );

$VERSION = '0.10';

require 5.000;

use SOAP::EnvelopeMaker;
use SOAP::Struct;
use SOAP::Transport::HTTP::Client;
use SOAP::Parser;
use Data::Dumper;

$DEFAULT_HOST       = "localhost";
$DEFAULT_PORT       = 80;
$DEFAULT_ENDPOINT   = "/soap?class=";
$DEFAULT_METHOD_URI = "urn:com-name-your";

}



sub new
{
my $class = shift;
my $self  = {};

	my $blessing = bless ( $self, $class );

	$self->{host}       = $DEFAULT_HOST;
	$self->{port}       = $DEFAULT_PORT;
	$self->{endpoint}   = $DEFAULT_ENDPOINT.$class;
	$self->{method_uri} = $DEFAULT_METHOD_URI;

	#
	# override defaults if arguments passed.
	#
	if (@_) {
		my %args = @_;
		foreach my $key (keys %args) {
			if ( $key eq "host"
				 || $key eq "port"
			     || $key eq "endpoint"
				 || $key eq "method_uri" )
			{
				$self->{$key} = $args{$key};
			}
			else {
				warn ( "Skipping unknown paramter $key.\n" );
			}
		}
	}

	$blessing;
}



sub setHost
{
	$_[0]->{host} = $_[1];
}



sub setPort
{
	$_[0]->{port} = $_[1];
}



sub setEndPoint
{
	$_[0]->{endpoint} .= $_[1];
}



sub setMethodURI
{
	$_[0]->{method_uri} .= $_[1];
}



sub getHost
{
	$_[0]->{gethost};
}



sub getPort
{
	$_[0]->{getport};
}



sub getEndPoint
{
	$_[0]->{endpoint};
}



sub getMethodURI
{
	$_[0]->{method_uri};
}



sub deliverRequest
{
my ($self, $method_name) = (shift, shift);

	#
	# Convert any arguments into a hash for send SOAP::Struct.
	#
	my %ARGV;
	my $arg = 0;

	foreach (@_) {
		if ( ref ($_) eq "ARRAY" ) {
			$_ = Dumper ( $_ );
			s/^\$VAR1 = /array::/g;
		}
		$ARGV{"ARG$arg"} = $_;
		$arg++;	
	}

	#
	# For some reason I feel compelled to do this..
	#
	$ARGV{ARGC} = scalar @_;


	#
	# Now set and send our request to the server.
	#
	my $soap_request = '';
	my $output_fcn = sub { $soap_request .= shift; };
	my $em = SOAP::EnvelopeMaker->new ( $output_fcn );

	my $body = SOAP::Struct->new (
	           %ARGV
	);

	$em->set_body( $self->{method_uri}, $method_name, 0, $body );


	my $soap_on_http = SOAP::Transport::HTTP::Client->new();

	my $soap_response = $soap_on_http->send_receive (
                        $self->{host},
                        $self->{port},
                        $self->{endpoint},
                        $self->{method_uri},
                        $method_name,
                        $soap_request
	);

	my $soap_parser = SOAP::Parser->new();

	$soap_parser->parsestring($soap_response);

	$body = $soap_parser->get_body;

	#
	# Convert any return arguments into a return list. 
	#
	$arg = 0;
	@_ = ();
	while ( $_ = $body->{"ARG$arg"} ) {
		if ( /^array::/ ) {
			s/^array:://;
			$_ = eval ( $_ );
		}
		push ( @_, $_ );
		$arg++;
	}

	@_;
}



DESTROY
{
 	$_[0] = undef;
}



sub AUTOLOAD
{
        my($self) = shift;
        my($method) = ($AUTOLOAD =~ /::([^:]+)$/);
        return unless ($method);

        $self->deliverRequest ( $method, @_ );
}



1;
__END__


=head1 NAME

SOAP::Autoload - Automarshall methods for Perl SOAP

=head1 SYNOPSIS

  #!/usr/bin/perl -w

  #
  #  Client example that goes with server example in SOAP::Autounload
  #

  use strict;

  package Calculator;
  use base qw( SOAP::Autoload );


  package main;

  my $calc = new Calculator;


  print "sum = ", $calc->add ( 1, 2, 3 ), "\n";


=head1 DESCRIPTION

The intention of SOAP::Autoload is to allow a SOAP client to use a remote
class as if it were local.  The remote package is treated as local with
a declaration like:

  package MyClass;
  use base qw( SOAP::Autoload );

The SOAP::Autoload base class will "Autoload" methods called from an
instance of "MyClass", send it to the server side, and return the results
to the caller's space. 

=head2 Provided Methods

=item new

The 'new' method may be called with option arguments to reset variables
from the defaults.

  my $class = new MyClass (
                  host       => 'anywhere.com',
                  port       => 80,
                  endpoint   => 'soapx?class=OtherClass',
                  method_uri => 'urn:com-name-your'
              );

It is advisable to set the package defaults at installation time in the
SOAP/Autoload.pm (this) file.  The variables may also be reset after
instantiation with the 'set' methods.


=item getHost

returns the contents of $class->{host}.

=item setHost

sets the contents of $class->{host}.

=item getPort

returns the contents of $class->{port}.

=item setPort

sets the contents of $class->{port}.

=item getEndPoint

returns the contents of $class->{endpoint}.

=item setEndPoint

sets the contents of $class->{endpoint}.

=item getMethodURI

returns the contents of $class->{method_uri}.

=item setMethodURI

sets the contents of $class->{method_uri}.


=head1 DEPENDENCIES

SOAP-0.28
Data::Dumper

=head1 AUTHOR

Daniel Yacob, L<yacob@rcn.com|mailto:yacob@rcn.com>

=head1 SEE ALSO

S<perl(1). SOAP(3). SOAP::Autounload(3).>
