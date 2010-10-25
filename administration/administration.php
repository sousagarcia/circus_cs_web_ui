<?php

	session_start();
	include("../common.php");
	include("auto_logout_administration.php");
	include("server_status_private.php");

	$params = array('toTopDir' => "../");	
	$cadList = array();

	$userID = $_SESSION['userID'];

	$adminModeFlg = $mode = (isset($_REQUEST['adminModeFlg'])) ? $_REQUEST['adminModeFlg'] : 0;
	if($adminModeFlg == 1) $_SESSION['adminModeFlg'] = 1;

	// Connect to SQL Server
	$pdo = new PDO($connStrPDO);
		
	//-------------------------------------------------------------------------------------------------------------
	// Check server status
	//-------------------------------------------------------------------------------------------------------------
	$storageSvStatus  = ShowWindowsServiceStatus($DICOM_STORAGE_SERVICE);
	$jobManagerStatus = ShowWindowsServiceStatus($CAD_JOB_MANAGER_SERVICE);
	//-------------------------------------------------------------------------------------------------------------
		
	//-------------------------------------------------------------------------------------------------------------
	// Make one-time ticket
	//-------------------------------------------------------------------------------------------------------------
	$_SESSION['ticket'] = md5(uniqid().mt_rand());
	$params['ticket'] = htmlspecialchars($_SESSION['ticket'], ENT_QUOTES);
	//-------------------------------------------------------------------------------------------------------------
		
	//--------------------------------------------------------------------------------------------------------------
	// Settings for Smarty
	//--------------------------------------------------------------------------------------------------------------
	require_once('../smarty/SmartyEx.class.php');
	$smarty = new SmartyEx();
			
	$smarty->assign('params',           $params);
	$smarty->assign('storageSvStatus',  $storageSvStatus);
	$smarty->assign('jobManagerStatus', $jobManagerStatus);
	
	$smarty->display('administration/administration.tpl');
	//--------------------------------------------------------------------------------------------------------------
	
?>
