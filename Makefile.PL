#!/usr/bin/perl

use inc::Module::Install;

name        'Perlbal-Plugin-Rule';
all_from    'lib/Perlbal/Plugin/Rule.pm';

requires    'Perlbal'   => 0;

WriteAll;
