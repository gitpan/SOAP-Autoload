package Calculator;
use base qw( SOAP::Autounload );

sub new {
    bless {}, shift;
}

sub add
{
shift;
my $sum = 0;

	if ( ref ($_[0]) ) {		# assume this HAS to be an ARRAY
		foreach (@{$_[0]}) {
			$sum += $_;
		}
	}
	else {
		foreach (@_) {
			$sum += $_;
		}
	}

	$sum;
}

1;
__END__



=head1 NAME

Calculator - Demo Package for SOAP::Autoload

=head1 SYNOPSIS

Install on system with Apache server that has been configured to
receive SOAP queries.  Be sure 'Calculator" has been added in a call
to your SOAP handler with SOAP::Transport::HTTP::Apache::handler.

=head1 DEPENDENCIES

SOAP-Autounload

=head1 AUTHOR

Daniel Yacob, L<yacob@rcn.com|mailto:yacob@rcn.com>

=head1 SEE ALSO

S<perl(1). SOAP(3). SOAP::Autounload(3).>
