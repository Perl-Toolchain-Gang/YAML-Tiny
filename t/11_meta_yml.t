# Testing of common META.yml examples
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;

use File::Spec::Functions ':ALL';
use YAML::Tiny;


#####################################################################
# Various files that fail for unknown reasons

SCOPE: {
    my $content = load_ok(
        'Template-Provider-Unicode-Japanese.yml',
        catfile( test_data_directory(), 'Template-Provider-Unicode-Japanese.yml' ),
        100
    );
    subtest 'Template-Provider-Unicode-Japanese', sub {
        yaml_ok(
            $content,
            [ {
                abstract => 'Decode all templates by Unicode::Japanese',
                author   => 'Hironori Yoshida C<< <yoshida@cpan.org> >>',
                distribution_type => 'module',
                generated_by => 'Module::Install version 0.65',
                license => 'perl',
                'meta-spec' => {
                    url => 'http://module-build.sourceforge.net/META-spec-v1.3.html',
                    version => '1.3',
                },
                name => 'Template-Provider-Unicode-Japanese',
                no_index => {
                    directory => [ qw{ inc t } ],
                },
                requires => {
                    'Template::Config' => 0,
                    'Unicode::Japanese' => 0,
                    perl => '5.6.0',
                    version => '0',
                },
                version => '1.2.1',
            } ],
            'Template-Provider-Unicode-Japanese',
        );
    };
}

SCOPE: {
    my $content = load_ok(
        'HTML-WebDAO.yml',
        catfile( test_data_directory(), 'HTML-WebDAO.yml' ),
        100
    );
    subtest 'HTML-WebDAO', sub {
        yaml_ok(
            $content,
            [ {
                abstract => 'Perl extension for create complex web application',
                author   => [
                    'Zahatski Aliaksandr, E<lt>zagap@users.sourceforge.netE<gt>',
                ],
                license  => 'perl',
                name     => 'HTML-WebDAO',
                version  => '0.04',
            } ],
            'HTML-WebDAO',
            nosyck => 1,
        );
    };
}

SCOPE: {
    my $content = load_ok(
        'Spreadsheet-Read.yml',
        catfile( test_data_directory(), 'Spreadsheet-Read.yml' ),
        100
    );
    subtest 'Spreadsheet-Read', sub {
        yaml_ok(
            $content,
            [ {
                'resources' => {
                    'license' => 'http://dev.perl.org/licenses/'
                },
                'meta-spec' => {
                    'version' => '1.4',
                    'url' => 'http://module-build.sourceforge.net/META-spec-v1.4.html'
                },
                'distribution_type' => 'module',
                'generated_by' => 'Author',
                'version' => 'VERSION',
                'name' => 'Read',
                'author' => [
                    'H.Merijn Brand <h.m.brand@xs4all.nl>'
                ],
                'license' => 'perl',
                'build_requires' => {
                    'Test::More' => '0',
                    'Test::Harness' => '0',
                    'perl' => '5.006'
                },
                'provides' => {
                    'Spreadsheet::Read' => {
                        'version' => 'VERSION',
                        'file' => 'Read.pm'
                    }
                },
                'optional_features' => [
                    {
                        'opt_csv' => {
                            'requires' => {
                                'Text::CSV_XS' => '0.23'
                            },
                            'recommends' => {
                                'Text::CSV_PP' => '1.10',
                                'Text::CSV_XS' => '0.58',
                                'Text::CSV' => '1.10'
                            },
                            'description' => 'Provides parsing of CSV streams'
                        }
                    },
                    {
                        'opt_excel' => {
                            'requires' => {
                                'Spreadsheet::ParseExcel' => '0.26',
                                'Spreadsheet::ParseExcel::FmtDefault' => '0'
                            },
                            'recommends' => {
                                'Spreadsheet::ParseExcel' => '0.42'
                            },
                            'description' => 'Provides parsing of Microsoft Excel files'
                        }
                    },
                    {
                        'opt_excelx' => {
                            'requires' => {
                                'Spreadsheet::XLSX' => '0.07'
                            },
                            'description' => 'Provides parsing of Microsoft Excel 2007 files'
                        }
                    },
                    {
                        'opt_oo' => {
                            'requires' => {
                                'Spreadsheet::ReadSXC' => '0.2'
                            },
                            'description' => 'Provides parsing of OpenOffice spreadsheets'
                        }
                    },
                    {
                        'opt_tools' => {
                            'recommends' => {
                                'Tk::TableMatrix::Spreadsheet' => '0',
                                'Tk::NoteBook' => '0',
                                'Tk' => '0'
                            },
                            'description' => 'Spreadsheet tools'
                        }
                    }
                ],
                'requires' => {
                    'perl' => '5.006',
                    'Data::Dumper' => '0',
                    'Exporter' => '0',
                    'Carp' => '0'
                },
                'recommends' => {
                    'perl' => '5.008005',
                    'IO::Scalar' => '0',
                    'File::Temp' => '0.14'
                },
                'abstract' => 'Meta-Wrapper for reading spreadsheet data'
            } ],
            'Spreadsheet-Read',
            noyamlpm   => 1,
        );
    };
}

done_testing;
