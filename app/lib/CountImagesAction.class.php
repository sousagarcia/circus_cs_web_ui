<?php

class CountImagesAction extends ApiAction
{
	function execute($api_request)
	{
		$params = $api_request['params'];
		$action = $api_request['action'];
		
		$seriesUIDs = $params['seriesInstanceUID'];
		$studyUIDs = $params['studyInstanceUID'];
		
		if(self::check_params($params) == FALSE)
		{
			throw new ApiException("Invalid parameter.", ApiResponse::STATUS_ERR_OPE);
		}
		
		$result = array();
		if(isset($seriesUIDs))
		{
			$result = self::get_series_counts($seriesUIDs);
		}
		else if(isset($studyUIDs))
		{
			$result = self::get_study_counts($studyUIDs);
		}
		
		$res = new ApiResponse();
		$res->setResult($action, $result);
		return $res;
	}
	
	private function check_params($params)
	{
		$seriesUIDs = $params['seriesInstanceUID'];
		$studyUIDs = $params['studyInstanceUID'];
		
		if((isset($seriesUIDs) && isset($studyUIDs))
			|| (!isset($seriesUIDs) && !isset($studyUIDs)))
		{
			return FALSE;
		}
		return TRUE;
	}
	
	private function get_series_counts($UIDs)
	{
		$result = array();
		foreach ($UIDs as $id)
		{
			$series = new Series($id);
			array_push(
				$result,
				array(
					"studyInstanceUID" => $series->study_instance_uid,
					"seriesInstanceUID" => $id,
					"number" => $series->image_number
				)
			);
		}
		
		return $result;
	}
	
	private function get_study_counts($UIDs)
	{
		$result = array();
		foreach ($UIDs as $id)
		{
			$series = new Series();
			$studies = $series->find(array('study_instance_uid' => $id));
			foreach ($studies as $s)
			{
				array_push(
					$result,
					array(
						"studyInstanceUID" => $s,
						"seriesInstanceUID" => $s->series_instance_uid,
						"number" => $s->image_number
					)
				);
			}
		}
		
		return $result;
	}
}
