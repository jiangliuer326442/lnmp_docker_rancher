<?php

if (!function_exists('exec')) {
    exit;
}


$json_string = file_get_contents('docker/pm2/jobs.json');
$jobs = json_decode($json_string, true);
if (!$jobs || !isset($jobs['apps'])) {
    exit;
}


$re = [];
foreach ($jobs['apps'] as $job) {
    if ($job && isset($job['name']) && $job['script'] == 'cli.php') {
        exec('pm2 reload ' . $job['name'], $re);
    }
}
print_r($re);
