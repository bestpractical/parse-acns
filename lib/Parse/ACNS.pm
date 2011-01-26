use 5.008;
use strict;
use warnings;


package Parse::ACNS;
our $VERSION = '0.01';

=head1 NAME

Parse::ACNS - parser for Automated Copyright Notice System (ACNS) XML

=head1 SYNOPSIS
    
    use Parse::ACNS;
    my $parser = Parse::ACNS->new(
        version => 'compat',
    );
    $parser->parse( );

=head1 DESCRIPTION

=cut

use File::ShareDir ();
use File::Spec ();
use Scalar::Util qw(blessed);
use XML::LibXML;
use XML::Compile::Schema;

our %CACHE = (
);

sub new {
    my $proto = shift;
    return (bless { @_ }, ref($proto) || $proto)->init;
}

sub init {
    my $self = shift;

    $self->{'version'} ||= 'compat';
    unless ( $self->{'version'} =~ /^(compat|0\.[67])$/ ) {
        require Carp;
        Carp::croak(
            "Only compat, 0.7 and 0.6 versions are supported"
            .", not '". $self->{'version'} ."'"
        );
    }

    my $path = File::ShareDir::dist_file(
        'Parse-ACNS',
        File::Spec->catfile( 'schema', $self->{'version'}, 'infringement.xsd' )
    );

    $self->{'reader'} = $CACHE{$path}{'reader'};
    unless ( $self->{'reader'} ) {
        my $schema = XML::Compile::Schema->new( [$path] );
        $self->{'reader'} = $schema->compile( READER => 'Infringement' );
    }
    return $self;
}

sub parse {
    my $self = shift;
    return $self->{'reader'}->( shift );
}

=head1 AUTHOR

Ruslan Zakirov E<lt>ruz@bestpractical.comE<gt>

=head1 LICENSE

Under the same terms as perl itself.

=cut

1;
