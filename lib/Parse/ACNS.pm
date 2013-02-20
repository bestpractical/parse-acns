use 5.008;
use strict;
use warnings;


package Parse::ACNS;
our $VERSION = '0.03';

=head1 NAME

Parse::ACNS - parser for Automated Copyright Notice System (ACNS) XML

=head1 SYNOPSIS

    use Parse::ACNS;
    my $data = Parse::ACNS->new->parse( XML::LibXML->load_xml( string => $xml ) );

=head1 DESCRIPTION

ACNS stands for Automated Copyright Notice System. It's an open source,
royalty free system that universities, ISP's, or anyone that handles large
volumes of copyright notices can implement on their network to increase
the efficiency and reduce the costs of responding to the notices... 
See "http://mpto.unistudios.com/xml/" for more details.

This module parses ACNS XML into a perl data structure. Supports both 0.6 and
0.7 version. Parser strictly follows XML Schemas, so throws errors on malformed
data.

However, it B<doesn't> extract ACNS XML from email messages.

=cut

use File::ShareDir ();
use File::Spec ();
use Scalar::Util qw(blessed);
use XML::Compile::Schema;

our %CACHE = (
);

=head1 METHODS

=head2 new

Constructor, takes list of named arguments.

=over 4

=item version - version of the specification

=over 4

=item compat - default value, can parse both 0.7 and 0.6 XML by making
TimeStamp element in Infringement/Content/Item optional. This is the
only difference between the spec versions.

=item 0.7 or 0.6 - strict parsing of the specified version.

=back

=back

=cut

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
        $self->{'reader'} = $CACHE{$path}{'reader'}
            = $schema->compile( READER => 'Infringement' );
    }
    return $self;
}

=head2 parse

    my $data = Parse::ACNS->new->parse( XML::LibXML->load_xml(...) );

Takes L<XML::LibXML::Document> containing an ACNS XML and returns it as a perl
struture. Read L<XML::LibXML::Parser> on parsing from different sources.

Returned data structure follows XML and its Schema, for example:

    {
        'Case' => {
            'ID' => 'A1234567',
            'Status' => ...,
            ...
        },
        'Complainant' => {
            'Email' => 'antipiracy@contentowner.com',
            'Phone' => ...,
            ...
        },
        'Source' => {
            'TimeStamp' => '2003-08-30T12:34:53Z',
            'UserName' => 'guest',
            'Login' => { ... },
            'IP_Address' => ...,
            ...
        }
        'Service_Provider' => { ... }
        'Content' => {
            'Item' => [
                {
                    'TimeStamp' => '2003-08-30T12:34:53Z',
                    'FileName' => '8Mile.mpg',
                    'Hash' => {
                            'Type' => 'SHA1',
                            '_' => 'EKR94KF985873KD930ER4KD94'
                          },
                    ...
                },
                { ... },
                ...
            ]
        },
        'History' => {
            'Notice' => [
                {
                    'ID' => '12321',
                    'TimeStamp' => '2003-08-30T10:23:13Z',
                    '_' => 'freeform text area'
                },
                { ... },
                ...
            ]
        },
        'Notes' => '
            Open area for freeform text notes, filelists, etc...
        '
    }

=cut

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
