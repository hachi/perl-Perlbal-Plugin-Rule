package Perlbal::Plugin::Rule::Exception;

use strict;
use warnings;

sub new {
    my $class = shift;
    return bless {}, (ref $class || $class);
}

sub succeed {
    my $class = shift;
    my $exception = $class->new;
    $exception->{success} = 1;
    die $exception;
}

sub fail {
    my $class = shift;
    my $message = shift;
    my $exception = $class->new;
    $exception->{failure} = 1;
    $exception->{message} = $message;
    die $exception;
}

sub success {
    my $self = shift;
    return $self->{success};
}

sub failure {
    my $self = shift;
    return $self->{failure};
}

sub failure_message {
    my $self = shift;
    return $self->{message};
}
