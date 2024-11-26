# NAME

Jonk2 - simple job tank manager.

# SYNOPSIS

    use DBI; 
    use Jonk2;
    my $dbh = DBI->connect(...);
    my $jonk = Jonk2->new($dbh, {functions => [qw/MyWorker/]});
    # insert job
    {
        $jonk->insert('MyWorker', 'arg');
    }

    # execute job
    {
        my $job = $jonk->find_job;
        print $job->func; # MyWorker
        print $job->arg;  # arg
        $job->completed;
    }

# DESCRIPTION

Jonk2 is simple job queue manager system

Job is saved and taken out. Besides, nothing is done.

You may use Jonk2 to make original Job Queuing System.

# METHODS

## my $jonk = Jonk2::Worker->new($dbh, \[\\%options\]);

Creates a new Jonk2 object, and returns the object.

$options is an optional settings.

- $dbh

    $dbh is database handle.

- $options->{functions}

    Key word of job which this Jonk2 instance looks for.

    - $options->{functions} = \[qw/worker\_key worker\_key2/\]

        can set \*worker\_key\* at arrayref.

    - $options->{functions} = \['worker\_key' => {grab\_for => 5}\],

        can set worker\_key's grab\_for setting by hash-ref.

    - $options->{functions} = \['worker\_key' => {serializer => \\&serialize\_code, deserializer => \\&deserialize\_code}\],

        can set worker\_key's (de)serializer code setting by hash-ref.

    - $options->{functions} = \['worker\_key' => {serializer => \\&serialize\_code, deserializer => \\&deserialize\_code}, 'worker\_key2'\],

        can mix worker settings.

- $options->{table\_name}

    specific job table name.

    Default job table name is \`job\`.

- $options->{job\_find\_size}

    specific lookup job record size.

    Default 50.

- $options->{default\_serializer}

    global serializer setting.

- $options->{default\_deserializer}

    global deserializer setting.

- $options->{default\_grab\_for}

    global grab\_for setting.

## my $job\_id = $jonk->insert($func, $arg);

enqueue a job to a database.
returns job.id.

- $func

    specific your worker funcname.

- $arg

    job argument data.

## my $job = $jonk->lookup\_job($job\_id);

lookup a job from a database.

returns Jonk2::Job object.

- $job\_id

    lookup specific $job\_id's job.

## my $job = $jonk->find\_job();

get job from database by sorted priority descending order.

## $jonk->errstr;

get most recent error infomation.

# ERROR HANDLING

    my $job = $jonk->lookup;
    if ($jonk->errstr) {
        die $jonk->errstr;
    }

# SCHEMA

## MySQL

    CREATE TABLE job (
        id            int(10) UNSIGNED NOT NULL auto_increment,
        func          varchar(255)     NOT NULL,
        arg           MEDIUMBLOB,
        enqueue_time  INTEGER UNSIGNED,
        grabbed_until int(10) UNSIGNED NOT NULL,
        run_after     int(10) UNSIGNED NOT NULL DEFAULT 0,
        retry_cnt     int(10) UNSIGNED NOT NULL DEFAULT 0,
        priority      int(10) UNSIGNED NOT NULL DEFAULT 0,
        primary key ( id )
    ) ENGINE=InnoDB

## SQLite

    CREATE TABLE job (
        id            INTEGER PRIMARY KEY ,
        func          text,
        arg           text,
        enqueue_time  INTEGER UNSIGNED,
        grabbed_until INTEGER UNSIGNED NOT NULL,
        run_after     INTEGER UNSIGNED NOT NULL DEFAULT 0,
        retry_cnt     INTEGER UNSIGNED NOT NULL DEFAULT 0,
        priority      INTEGER UNSIGNED NOT NULL DEFAULT 0
    )

## PostgreSQL

    CREATE TABLE job (
        id            SERIAL PRIMARY KEY,
        func          TEXT NOT NULL,
        arg           BYTEA,
        enqueue_time  INTEGER,
        grabbed_until INTEGER NOT NULL,
        run_after     INTEGER NOT NULL DEFAULT 0,
        retry_cnt     INTEGER NOT NULL DEFAULT 0,
        priority      INTEGER NOT NULL DEFAULT 0
    )

# SEE ALSO

[Qudo](https://metacpan.org/pod/Qudo)

[TheSchwartz](https://metacpan.org/pod/TheSchwartz)

# REPOSITORY

    git clone https://github.com/argrath/Jonk2.git

# CONTRIBUTORS

tokuhirom

kan\_fushihara

fujiwara

# AUTHOR

SHIRAKATA Kentaro &lt;argrath@ub32.org&gt;

Jonk, by Atsushi Kobayashi &lt;nekokak \_at\_ gmail \_dot\_ com>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
