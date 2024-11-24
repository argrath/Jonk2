use strict;
use warnings;
use Test::More;
use Test::SharedFork;
use Jonk2;

use lib '.';
use t::Utils;

my $dbh = t::Utils->setup;

    {   # insert test job
        my $jonk = Jonk2->new($dbh);
        ok $jonk->insert('MyWorker', 'arg1');
        ok $jonk->insert('MyWorker', 'arg2');
    }

    if ( fork ) {
        my $dbh = t::Utils->setup;

        my $jonk = Jonk2->new($dbh, {functions => [qw/MyWorker/]});
        my $job = $jonk->find_job();
        is $job->arg, 'arg1';

        wait;

        $job->completed;

        done_testing;
    }
    else {
        # child
        my $dbh = t::Utils->setup;

        sleep 1;

        my $jonk = Jonk2->new($dbh, {functions => [qw/MyWorker/]});
        my $job = $jonk->find_job();

        is $job->arg, 'arg2';
        $job->completed;
    }

