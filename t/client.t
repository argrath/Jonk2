use t::Utils;
use Test::More;
use DBI;
use Jonk2;

my $dbh = t::Utils->setup;

subtest 'insert' => sub {
    my $jonk = Jonk2->new($dbh);

    my $job_id = $jonk->insert('MyWorker', 'arg');
    ok $job_id;

    my $sth = $dbh->prepare('SELECT * FROM job WHERE id = ?');
    $sth->execute($job_id);
    my $row = $sth->fetchrow_hashref;

    is $row->{arg}, 'arg';
    is $row->{func}, 'MyWorker';
    is $row->{grabbed_until}, 0;
    is $row->{run_after}, 0;
    is $row->{retry_cnt}, 0;
    is $row->{priority}, 0;

    ok not $jonk->errstr;
};

subtest 'error handling' => sub {
    my $jonk = Jonk2->new($dbh, +{table_name => 'jonk_job'});

    my $job_id = $jonk->insert('MyWorker', 'arg');
    ok not $job_id;
    like $jonk->errstr, qr/can't insert for job queue database:/;
};

subtest 'insert / set priority' => sub {
    my $jonk = Jonk2->new($dbh);

    my $job_id = $jonk->insert('MyWorker', 'arg', { priority => 10 });
    ok $job_id;

    my $sth = $dbh->prepare('SELECT * FROM job WHERE id = ?');
    $sth->execute($job_id);
    my $row = $sth->fetchrow_hashref;

    is $row->{arg}, 'arg';
    is $row->{func}, 'MyWorker';
    is $row->{priority}, 10;
    ok not $jonk->errstr;
};

t::Utils->cleanup($dbh);

subtest 'insert / flexible job table name' => sub {
    my $dbh = t::Utils->setup("my_job");
    my $jonk = Jonk2->new($dbh, +{table_name => "my_job"});

    my $job_id = $jonk->insert('MyWorker', 'arg');
    ok $job_id;

    my $sth = $dbh->prepare('SELECT * FROM my_job WHERE id = ?');
    $sth->execute($job_id);
    my $row = $sth->fetchrow_hashref;

    is $row->{arg}, 'arg';
    is $row->{func}, 'MyWorker';
    ok not $jonk->errstr;

    t::Utils->cleanup($dbh, "my_job");
};

done_testing;

