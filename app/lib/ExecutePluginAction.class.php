<?php

class ExecutePluginAction extends ApiAction
{
	function execute($api_request)
	{
		$res = new ApiResponse();
		$res->setResult($action, $result);
		return $res;
	}
}

?>
