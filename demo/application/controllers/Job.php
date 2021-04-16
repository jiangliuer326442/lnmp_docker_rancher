<?php

class JobController extends MyCtr
{
    public function TestAction ()
    {
        $redis_dsn = 'redis:6379';
        $server = 'test';
        $auth = "";	
        Resque::setBackend($redis_dsn);
        if(!empty($auth)) {
	Resque::auth($REDIS_PWD);
        }
        putenv("QUEUE=" . $server);
        putenv("LOGGING=1");
        putenv("INTERVAL=0.1");
	$worker = new Resque_Worker($server);
	$worker->work(1);
    }
}