use inc::Module::Install;
all_from 'lib/Parse/ACNS.pm';
readme_from 'lib/Parse/ACNS.pm';

install_share;

requires 'XML::Compile::Schema';
requires 'XML::LibXML';

requires 'Carp';
requires 'File::Spec';
requires 'Scalar::Util';
requires 'File::ShareDir';
requires 'File::Spec';

WriteAll;
