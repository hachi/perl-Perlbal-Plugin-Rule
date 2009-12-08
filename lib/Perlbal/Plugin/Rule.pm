package Perlbal::Plugin::Rule;

use 5.006;

use strict;
use warnings;

use Perlbal;

our $VERSION = "0.00_01";
$VERSION = eval $VERSION;

sub load {
    my $class = shift;

    Perlbal::Service::add_tunable(
        rule_file => {
            des => "Perl script that returns a service selector.",
            check_role => "selector",
            setter => sub {
                my ($service, $value, $set, $mc) = @_;

                return $mc->err("'$value' is not a readable file") unless -r $value;

                my $selector = do $value;

                return $mc->err("Error while loading from '$value': $!") if $!;
                return $mc->err("Error while compiling from '$value': $@") if $@;
                return $mc->err("We didn't get a coderef from '$value'") if ref($selector) ne 'CODE';

                $service->selector($selector);
                $service->{extra_config}->{'rule_file'} = $value;
                return $mc->ok;
            },
            dumper => sub {
                my $service = shift;
                return $service->{extra_config}->{'rule_file'};
            },
        }
    );

    return 1;
}

sub unload {
    my $class = shift;
    return 1;
}

sub register {
    my ($class, $svc) = @_;
    die "You can't load the rule plugin on a non-selector service.\n"
        unless $svc && $svc->{role} eq "selector";
    return 1;
}

sub unregister {
    my ($class, $svc) = @_;
    $svc->selector(undef);
    return 1;
}

1;
