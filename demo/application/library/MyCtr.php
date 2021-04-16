<?php

class MyCtr extends Yaf_Controller_Abstract
{

    private $xhprof_on = false;
    private $timer_start;
    private $timer_end;

    public function init()
    {
        // 监测全站所有方法
        if (false && !is_production() && function_exists('xhprof_enable')) {
            $this->timer_start = microtime(true);
            xhprof_enable(XHPROF_FLAGS_NO_BUILTINS | XHPROF_FLAGS_CPU | XHPROF_FLAGS_MEMORY);
            $this->xhprof_on = true;
        }
    }


    protected function xhprof () {
        if($this->xhprof_on){
            $this->timer_end = microtime(true);
            $xhprof_data = xhprof_disable();
            include_once APPLICATION_PATH . "/../lib/src/ThirdParty/xhprof_lib/utils/xhprof_lib.php";
            include_once APPLICATION_PATH . "/../lib/src/ThirdParty/xhprof_lib/utils/xhprof_runs.php";
            $xhprof_runs = new XHProfRuns_Default();
            $xhprof_runs->save_run($xhprof_data, '____{feed}____' . number_format($this->timer_end - $this->timer_start, 5, ',', '') . '____' . (isset($_GET['caller']) ? $_GET['caller'] : 'unknown'));
        }
    }

    public function __destruct() {
        $this->xhprof();
    }


}