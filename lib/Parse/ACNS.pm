use 5.008;
use strict;
use warnings;


package Parse::ACNS;
our $VERSION = '0.01';

use File::ShareDir ();
use File::Spec ();
use Scalar::Util qw(blessed);
use XML::LibXML;
use XML::Compile::Schema;

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

    my $path = File::ShareDir::class_file(
        File::Spec->catfile( 'schema', $self->{'version'}, 'infringement.xsd' )
    );

    $self->{'reader'} = $CACHE{$path}{'reader'};
    unless ( $self->{'reader'} ) {
        my $schema = XML::Compile::Schema( [$path] );
        $self->{'reader'} = $schema->compile( READER => 'Infringement' );
    }
    return $self;
}

sub parse {
    my $self = shift;
    return $self->{'reader'}->( shift );
}

sub parse_any {
    my $self = shift;
    my $source = shift;
    if ( blessed($source) ) {
        if ( $source->isa('XML::LibXML') ) {
            return $self->parse( $source );
        }
        else {
            require Carp;
            Carp::croak('Parsing from object of type '. ref($source) . ' is not supported');
        }
    }
    elsif ( ref $source ) {
        return $self->parse_fh( $source );
    }
    else {
        if ( -e $source ) {
            return $self->parse_file( $source );
        }
        else {
            return $self->parse_string( $source );
        }
    }
}

sub parse_string {
    my $self = shift;
    return $self->parse( XML::LibXML->new->parse_string(shift) );
}

sub parse_file {
    my $self = shift;
    return $self->parse( XML::LibXML->new->parse_file(shift) );
}

sub parse_fh {
    my $self = shift;
    return $self->parse( XML::LibXML->new->parse_fh(shift) );
}

=head1 AUTHOR

Ruslan Zakirov E<lt>ruz@bestpractical.comE<gt>

=head1 LICENSE

Under the same terms as perl itself.

=cut

1;
