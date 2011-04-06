<?php
	session_cache_limiter('none');
	session_start();

	include_once("../common.php");

	//-----------------------------------------------------------------------------------------------------------------
	// Import $_POST variables and validation
	//-----------------------------------------------------------------------------------------------------------------
	$dstData = array();
	$validator = new FormValidator();


	$validator->addRules(array(
		"modality" => array(
			"type" => "select",
			"options" => $modalityList,
			"default" => "CT",
			"otherwise" => "CT"),
		));

	if($validator->validate($_POST))
	{
		$dstData = $validator->output;
		$dstData['errorMessage'] = "&nbsp;";
	}
	else
	{
		$dstData = $validator->output;
		$dstData['errorMessage'] = implode('<br/>', $validator->errors);
	}
	//-----------------------------------------------------------------------------------------------------------------

	try
	{
		// Connect to SQL Server
		$pdo = DBConnector::getConnection();

		$dstData['executableList'] = array();
		$dstData['hiddenList']      = array();

		$sqlStr = "SELECT pm.plugin_name, pm.version, pm.exec_enabled"
				. " FROM plugin_master pm, cad_master cm, cad_series cs"
				. " WHERE cm.plugin_name=pm.plugin_name AND cs.plugin_name = cm.plugin_name"
				. " AND cm.version=pm.version AND cs.version=cm.version AND cs.series_id=0"
				. " AND cs.modality=? ORDER BY cm.label_order ASC";

		$stmt = $pdo->prepare($sqlStr);
		$stmt->bindValue(1, $dstData['modality']);
		$stmt->execute();

		while($result = $stmt->fetch(PDO::FETCH_NUM))
		{
			$tmp = $result[0] . "_v." . $result[1];

			if($result[2] == 't')  $dstData['executableList'][] = $tmp;
			else                   $dstData['hiddenList'][] =$tmp;
		}
		echo json_encode($dstData);

	}
	catch (PDOException $e)
	{
		var_dump($e->getMessage());
	}

?>