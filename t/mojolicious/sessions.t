#!/usr/bin/env perl

# Copyright (C) 2008-2010, Sebastian Riedel.

use strict;
use warnings;

use utf8;

use Test::More;

# Make sure sockets are working
plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 16;

use Mojolicious::Lite;
use Test::Mojo;

# Silence
app->log->level('error');

# GET /session_cookie
get '/session_cookie' => sub {
    my $self = shift;
    $self->session->{foo} = '23';
    $self->render_text('Session set!');
};

# GET /session_cookie/2
get '/session_cookie/2' => sub {
    my $self    = shift;
    my $session = $self->session;
    my $value   = $session->{foo} ? $session->{foo} : "missing";
    $self->render_text("Session foo is $value!");
};

my $t      = Test::Mojo->new;

# GET /session_cookie
$t->get_ok('/session_cookie')->status_is(200)
  ->content_is('Session set!');

ok($t->tx->res->cookie('mojolicious'), 'got mojolicious cookie'); 

# GET /session_cookie/2
$t->get_ok('/session_cookie/2')->status_is(200)
  ->content_is('Session foo is 23!');

# GET /session_cookie/2 (retry)
$t->get_ok('/session_cookie/2')->status_is(200)
  ->content_is('Session foo is 23!');

ok(! $t->tx->res->cookie('mojolicious'), 'got mojolicious cookie (same data)'); 

# GET /session_cookie/2 (session reset)
$t->reset_session;
ok(!$t->tx);
$t->get_ok('/session_cookie/2')->status_is(200)
  ->content_is('Session foo is missing!');

ok(! $t->tx->res->cookie('mojolicious'), 'no mojolicious cookie'); 
