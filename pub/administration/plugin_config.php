<?php

require_once('../common.php');
Auth::checkSession();
Auth::purgeUnlessGranted(Auth::SERVER_SETTINGS);

try {
	$pdo = DBConnector::getConnection();

	$validator = new FormValidator();
	$validator->addRules(array(
		'mode' => array(
			'type' => 'select',
			'options' => array('set', 'set_order')
		),
		'order' => array('type' => 'string'),
		'plugin_id' => array('type' => 'int'),
		'exec_enabled' => array('type' => 'bool', 'default' => false),
		'default_policy' => array('type' => 'int'),
		'ticket' => array ( 'type' => 'string' )
	));

	if ($validator->validate($_POST)) {
		$req = $validator->output;
	} else {
		throw new Exception(implode(" ", $validator->errors));
	}

	if ($req['mode'] && $req['ticket'] != $_SESSION['ticket']) {
		throw new Exception('Invalid page transition detected. Try again.');
	}

	if ($req['mode'] == 'set') {
		$plugin = new Plugin($req['plugin_id']);
		if (!$plugin->plugin_name) throw new Exception('Invalid plugin specified');
		$cadPlugin = $plugin->CadPlugin[0];
		$pol = new PluginResultPolicy($req['default_policy']);
		if (!$pol->policy_name) throw new Exception('Invalid policy specified');

		$plugin->save(array('Plugin' => array(
			'exec_enabled' => $req['exec_enabled'] ? 't' : 'f'
		)));
		$cadPlugin->save(array('CadPlugin' => array(
			'default_policy' => $pol->policy_id
		)));
		$message = "Plugin {$plugin->fullName()} was successfully updated.";
	}

	if ($req['mode'] == 'set_order') {
		$order = json_decode($req['order']);
		$i = 1;
		$pdo->beginTransaction();
		$transaction_started = true;
		foreach ($order as $pid) {
			$plugin = new CadPlugin($pid);
			if (!isset($plugin->plugin_id)) throw new Exception('Failed');
			$plugin->save(array('CadPlugin' => array(
				'label_order' => $i++
			)));
		}
		$pdo->commit();
		$message = "Plugin display order was successfully saved.";
	}

} catch (Exception $e) {
	if ($transaction_started) $pdo->rollBack();
	$message = $e->getMessage() . " at " . $e->getTraceAsString();
}
display($message);

function display($message)
{
	$smarty = new SmartyEx();
	$ticket = $_SESSION['ticket'] = md5(uniqid().mt_rand());

	$default_policy_id = null;
	$pol_map = array();

	$policies = array_map(
		function($item) use(&$default_policy_id, &$pol_map) {
			if ($item->policy_name == PluginResultPolicy::DEFAULT_POLICY) {
				$default_policy_id = $item->policy_id;
			}
			$arr = $item->getData();
			$pol_map[$item->policy_id] = $arr;
			return $arr;
		},
		PluginResultPolicy::select()
	);

	$plugin_list = Plugin::select(
		array('type' => Plugin::CAD_PLUGIN)
	);
	$plugins = array();
	foreach ($plugin_list as $item)
	{
		$tmp = $item->getData();
		$tmp['exec_enabled'] = $tmp['exec_enabled'] == 't' ? 1 : 0;

		$cadPlugin = $item->CadPlugin[0];
		$merged = $cadPlugin->getData();
		$tmp = array_merge($tmp, $merged);

		if (is_null($tmp['default_policy'])) {
			$tmp['default_policy'] = $default_policy_id;
		}
		$tmp['default_policy_name'] = $pol_map[$tmp['default_policy']]['policy_name'];
		$tmp['full_name'] = $item->fullName();
		$plugins[] = $tmp;
	}
	usort($plugins, function($a, $b) { return $a['label_order'] - $b['label_order']; });

	$smarty->assign(array(
		'message' => $message,
		'plugins' => $plugins,
		'policies' => $policies,
		'ticket' => $ticket
	));
	$smarty->display('administration/plugin_config.tpl');
}
