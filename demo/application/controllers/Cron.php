<?php

use Medoo\Medoo;

class CronController extends MyCtr
{
    /**
     * 巨星活动定时任务 每月 1、11、21 执行
     */
    public function testAction ()
    {
$database = new Medoo([
	// required
	'database_type' => 'mysql',
	'database_name' => 'test',
	'server' => 'mysql',
	'username' => 'root',
	'password' => 'loveclub123',
 
	// [optional]
	'charset' => 'utf8',
	'port' => 3306,
 
	// [optional] Table prefix
	'prefix' => '',
 
	// [optional] Enable logging (Logging is disabled by default for better performance)
	'logging' => true,
 
	// [optional] Medoo will execute those commands after connected to the database for initialization
	'command' => [
		'SET SQL_MODE=ANSI_QUOTES'
	]
]);
 
$datas = $database->select("users", [
    "username",
    "age",
    "sex"
], []);
print_r($datas);
    }

}