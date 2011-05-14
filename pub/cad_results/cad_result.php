<?php

session_cache_limiter('none');
session_start();

include("../common.php");

//------------------------------------------------------------------------------
// Import and validate $_POST data
//------------------------------------------------------------------------------

$validator = new FormValidator();
$validator->addRules(array(
	'jobID' => array(
		"type" => "int",
		"required" => false, // true, // transient
		"min" => 1,
		"errorMes" => "[ERROR] CAD ID is invalid."
	),
	'feedbackMode' => array(
		"type" => "select",
		"required" => false, // true, // transient
		"options" => array("personal", "consensual"),
		"errorMes" => "[ERROR] 'Feedback mode' is invalid."
	)
));
if ($validator->validate($_REQUEST))
{
	$params = $validator->output;
}

show_cad_results($params['jobID'], $params['feedbackMode']);


/**
 * Displays CAD Result
 */
function show_cad_results($jobID, $feedbackMode) {
	global $DIR_SEPARATOR;

	// Retrieve the CAD Result
	$cadResult = new CadResult($jobID);

	// Assigning the result to Smarty
	$smarty = new SmartyEx();

	$params['toTopDir'] = '../';
	$sort = $cadResult->sorter();
	$user = $_SESSION['userID'];
	$feedback = $cadResult->queryFeedback('user', $_SESSION['userID']);
	if (is_array($feedback) && count($feedback) > 0)
	{
		$feedback = array_shift($feedback);
		$feedback->loadFeedback();
	}
	else
	{
		$feedback = null;
	}

	// Enabling plugin-specific template directory
	$td = $smarty->template_dir;
	$smarty->template_dir = array(
		$cadResult->pathOfPluginWeb(),
		$td . $DIR_SEPARATOR . 'cad_results',
		$td
	);

	$smarty->assign(array(
		'feedbackMode' => $feedbackMode,
		'cadResult' => $cadResult,
		'displays' => $cadResult->getDisplays(),
		'attr' => $cadResult->getAttributes(),
		'series' => $cadResult->Series[0],
		'displayPresenter' => $cadResult->displayPresenter(),
		'feedbackListener' => $cadResult->feedbackListener(),
		'feedbacks' => $feedback,
		'params' => $params,
		'sorter' => $sort,
		'sort' => array('key' => $sort['defaultKey'], 'order' => $sort['defaultOrder'])
	));

	// Render using Smarty
	$smarty->display('cad_results/cad_result.tpl');
}

?>