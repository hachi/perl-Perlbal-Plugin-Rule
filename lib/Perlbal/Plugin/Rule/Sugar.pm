package Perlbal::Plugin::Rule::Sugar;

use strict;
use warnings;

use CGI::Cookie;

use Perlbal;
use Perlbal::ClientHTTPBase;
use Perlbal::HTTPHeaders;

our Perlbal::ClientHTTPBase $CB;
our Perlbal::HTTPHeaders $HD;
our $COOKIES;

our $RULE;

sub rule (&) {
    my $coderef = shift;
    $RULE = sub {
        my $cb = shift;
        return invoke_code($coderef, $cb);
    };
}

# This magic is for if we need to pass a closure outside of a rule, to be executed at an arbitrary
# point in time, we can't assume that our dynamic variables will still be set correctly at that
# time. Nor could we use our exceptions in a standard closure. Invoking again like the rule initially
# was will take care of both parts of this.
sub Closure (&) {
    my $coderef = shift;
    my $cb = $CB;
    my $hd = $HD;
    my $cookies = $COOKIES;
    return sub {
        return invoke_code($coderef, $cb, $hd, $cookies);
    };
}

sub Header ($) {
    my $headername = shift;
    $HD ||= $CB->{req_headers};
    return $HD->header($headername);
}

sub Cookie ($) {
    my $cookiename = shift;
    $COOKIES ||= { CGI::Cookie->parse(Header('Cookie')) };
    return $COOKIES->{$cookiename};
}

sub RemoteIP {
    return $CB->observed_ip_string || $CB->peer_ip_string;
}

sub Service ($) {
    my $servicename = shift;
    my $svc = Perlbal->service($servicename);
    if ($svc) {
        $svc->adopt_base_client($CB);
        Perlbal::Plugin::Rule::Exception->succeed;
    } else {
        $CB->_simple_response('503', 'Service unknown');
        Perlbal::Plugin::Rule::Exception->fail("Service unknown '$servicename'");
    }
}

sub Close ($) {
    my $message = shift;
    $CB->close($message);
    Perlbal::Plugin::Rule::Exception->succeed;
}

sub Response {
    $HD ||= $CB->{req_headers};

}

sub SetHeader {
    $HD ||= $CB->{req_headers};
    $HD->header(@_);
}

sub SetURI {
    my $uri = shift;
    $HD ||= $CB->{req_headers};
    $HD->set_request_uri($uri);
}

sub invoke_code {
    my $coderef = shift;

    local $CB = shift;
    local $HD = shift;
    local $COOKIES = shift;

    eval { $coderef->() };

    my $trapped = $@;

    if (eval { $trapped->isa('Perlbal::Plugin::Rule::Exception') } ) {
        return if $trapped->success;
        warn "Rule failed: " . $trapped->failure_message . "\n";
        return;
    }

    die $@;
}

1;
