package MojoliciousTest::Bar;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub special {
    my $self = shift;
    my $res  = $self->res;

    $res->body('Yuupiii!');
    $res->code('200');

    $self->ctx->skip_renderer(1);

    return 1;
}

1;
