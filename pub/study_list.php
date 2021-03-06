<?php
	include_once('common.php');
	Auth::checkSession();
	Auth::purgeUnlessGranted(Auth::LIST_SEARCH);

	try
	{
		// Connect to SQL Server
		$pdo = DBConnector::getConnection();

		//--------------------------------------------------------------------------------------------------------------
		// Import $_GET variables and validation
		//--------------------------------------------------------------------------------------------------------------
		$mode = (isset($_GET['mode']) && $_GET['mode'] == 'patient') ? 'patient' : "";
		$params = array();

		$validator = new FormValidator();

		if($mode == 'patient')
		{
			$validator->addRules(array(
				"encryptedPtID" => array(
					"type" => "pgregex",
					"required" => true,
					"errorMes" => "URL is incorrect.")));
		}
		else
		{
			$validator->addRules(array(
				"filterPtID" => array(
					"type" => "pgregex",
					"errorMes" => "'Patient ID' is invalid."),
				"filterPtName" => array(
					"type" => "pgregex",
					"errorMes" => "'Patient name' is invalid."),
				"filterSex" => array(
					"type" => "select",
					"options" => array('M', 'F', 'all'),
					"default" => "all",
					"otherwise" => "all")
				));
		}

		$validator->addRules(array(
			"filterAgeMin" => array(
				'type' => 'int',
				'min' => '0',
				'label' => 'Age'),
			"filterAgeMax" => array(
				'type' => 'int',
				'min' => '0',
				'label' => 'Age'),
			"filterModality" => array(
				'type' => 'select',
				"options" => $modalityList,
				"default" => "all",
				"otherwise" => "all"),
			"stDateKind" => array(
				"type" => "str",
				"label" => 'Study date',
				"default" => 'all'),
			"stDateFrom" => array(
				"type" => "date",
				"label" => 'Study date'),
			"stDateTo" => array(
				"type" => "date",
				"label" => 'Study date'),
			"stTimeTo" => array(
				"type" => "time",
				"label" => 'Study time'),
			"orderCol" => array(
				"type" => "select",
				"options" => array('PatientID','Name','Age','Sex','Modality','StudyID','StudyDate'),
				"default" => 'StudyDate',
				"otherwise" => 'StudyDate'),
			"orderMode" => array(
				"type" => "select",
				"options" => array('DESC', 'ASC'),
				"default"=> 'DESC',
				"otherwise" => 'DESC'),
			"showing" => array(
				"type" => "select",
				"options" => array('10', '25', '50', 'all'),
				"default" => '10',
				"otherwise" => '10')
			));

		if($validator->validate($_GET))
		{
			$params = $validator->output;
			$params['errorMessage'] = "&nbsp;";

			$params['pageNum']  = (isset($_GET['pageNum']) && ctype_digit($_GET['pageNum'])) ? $_GET['pageNum'] : 1;
			$params['startNum'] = 0;
			$params['endNum'] = 0;
			$params['totalNum'] = 0;
			$params['maxPageNum'] = 1;

			if(isset($params['filterAgeMin']) && isset($params['filterAgeMax'])
			   && $params['filterAgeMin'] > $params['filterAgeMax'])
			{
				//$params['errorMessage'] = "Range of 'Age' is invalid.";
				$tmp = $params['filterAgeMin'];
				$params['filterAgeMin'] = $params['filterAgeMax'];
				$params['filterAgeMax'] = $tmp;
			}
		}
		else
		{
			$params = $validator->output;
			$params['errorMessage'] = implode('<br/>', $validator->errors);
		}
		$params['mode'] = $mode;
		//--------------------------------------------------------------------------------------------------------------

		$data = array();

		if($params['errorMessage'] == "&nbsp;")
		{
			//----------------------------------------------------------------------------------------------------------
			// Create WHERE statement of SQL
			//----------------------------------------------------------------------------------------------------------
			$sqlCondArray = array();
			$sqlParams = array();
			$sqlCond = "";
			$addressParams = array();

			$sqlCond = " WHERE ";

			if($params['mode'] == 'patient')
			{
				$patientID = PinfoScramble::decrypt($params['encryptedPtID'], $_SESSION['key']);
				$params['filterPtID'] = ($_SESSION['anonymizeFlg'] == 1) ? $params['encryptedPtID'] : $patientID;

				$sqlCondArray[] = "pt.patient_id=?";
				$sqlParams[]    = $patientID;
				$addressParams['mode'] = 'patient';
				$addressParams['encryptedPtID'] = $params['encryptedPtID'];

				$stmt = $pdo->prepare("SELECT pt.patient_name, pt.sex FROM patient_list pt WHERE patient_id=?");
				$stmt->bindParam(1, $patientID);
				$stmt->execute();

				$result = $stmt->fetch(PDO::FETCH_NUM);
				$params['filterPtName'] = $result[0];
				$params['filterSex'] = $result[1];

				if($params['filterSex'] != "M" && $params['filterSex'] != "F")  $params['filterSex'] = "all";
			}
			else
			{
				if($params['filterPtID'] != "")
				{
					$patientID = $params['filterPtID'];
					if($_SESSION['anonymizeFlg'] == 1)  $patientID = PinfoScramble::decrypt($params['filterPtID'], $_SESSION['key']);

					// Search by regular expression
					$sqlCondArray[] = "pt.patient_id~*?";
					$sqlParams[] = $patientID;
					$addressParams['filterPtID'] = $params['filterPtID'];
				}

				if($params['filterPtName'] != "")
				{
					// Search by regular expression
					$sqlCondArray[] = "pt.patient_name~*?";
					$sqlParams[] = $params['filterPtName'];
					$addressParams['filterPtName'] = $params['filterPtName'];
				}

				if($params['filterSex'] == "M" || $params['filterSex'] == "F")
				{
					$sqlCondArray[] = "pt.sex=?";
					$sqlParams[] = $params['filterSex'];
					$addressParams['filterSex'] = $params['filterSex'];
				}
			}

			if($params['stDateKind'] != 'all')  $addressParams['stDateKind'] = $params['stDateKind'];

			if($params['stDateFrom'] != "" && $params['stDateTo'] != "" && $params['stDateFrom'] == $params['stDateTo'])
			{
				$sqlCondArray[] = "st.study_date=?";
				$sqlParams[] = $params['stDateFrom'];
				$addressParams['stDateFrom'] = $params['stDateFrom'];
				$addressParams['stDateTo'] = $params['stDateTo'];
			}
			else
			{
				if($params['stDateFrom'] != "")
				{
		 			$sqlCondArray[] = "?<=st.study_date";
					$sqlParams[] = $params['stDateFrom'];
					$addressParams['stDateFrom'] = $params['stDateFrom'];
				}

				if($params['stDateTo'] != "")
				{
					$sqlParams[] = $params['stDateTo'];
					$addressParams['stDateTo'] = $params['stDateTo'];

					if($params['stTimeTo'] != "")
					{
						$sqlCondArray[] = "(st.study_date<? OR (st.study_date=? AND st.study_time<=?))";
						$sqlParams[] = $params['stDateTo'];
						$sqlParams[] = $params['stTimeTo'];
						$addressParams['stTimeTo'] = $params['stTimeTo'];
					}
					else
					{
						$sqlCondArray[] = "st.study_date<=?";
					}
				}
			}

			if($params['filterAgeMin'] != "" && $params['filterAgeMax'] != "" && $params['filterAgeMin'] == $params['filterAgeMax'])
			{
				$sqlCondArray[] = "st.age=?";
				$sqlParams[] = $params['filterAgeMin'];
				$addressParams['filterAgeMin'] = $params['filterAgeMin'];
				$addressParams['filterAgeMax'] = $params['filterAgeMax'];
			}
			else
			{
				if($params['filterAgeMin'] != "")
				{
					$sqlCondArray[] .= " ?<=st.age";
					$sqlParams[] = $params['filterAgeMin'];
					$addressParams['filterAgeMin'] = $params['filterAgeMin'];
				}

				if($params['filterAgeMax'] != "")
				{
					$sqlCondArray[] = "st.age<=?";
					$sqlParams[] = $params['filterAgeMax'];
					$addressParams['filterAgeMax'] = $params['filterAgeMax'];
				}
			}

			if($params['filterModality'] != "" && $params['filterModality'] != "all")
			{
				$sqlCondArray[] = "st.modality=?";
				$sqlParams[] = $params['filterModality'];
				$addressParams['filterModality'] = $params['filterModality'];
			}

			$sqlCondArray[] = "pt.patient_id=st.patient_id";
			$sqlCond = sprintf(" WHERE %s", implode(' AND ', $sqlCondArray));
			//----------------------------------------------------------------------------------------------------------

			//----------------------------------------------------------------------------------------------------------
			// Retrieve sort column and order (Default: ascending order of patient ID)
			//----------------------------------------------------------------------------------------------------------
			$orderColStr = "";

			switch($params['orderCol'])
			{
				case "PatientID":		$orderColStr = 'pt.patient_id '   . $params['orderMode'];  break;
				case "Name":			$orderColStr = 'pt.patient_name ' . $params['orderMode'];  break;
				case "Age":				$orderColStr = 'st.age '          . $params['orderMode'];  break;
				case "Sex":				$orderColStr = 'pt.sex '          . $params['orderMode'];  break;
				case "Modality":		$orderColStr = 'st.modality '     . $params['orderMode'];  break;
				case "StudyID":			$orderColStr = 'st.study_id '     . $params['orderMode'];  break;
				default:
					$orderColStr = 'st.study_date ' . $params['orderMode'] . ', st.study_time ' . $params['orderMode'];
					$params['orderCol']    = 'StudyDate';
					break;
			}

			$addressParams['orderCol']  = $paramss['orderCol'];
			$addressParams['orderMode'] = $paramss['orderMode'];
			$addressParams['showing']   = $paramss['showing'];
			//----------------------------------------------------------------------------------------------------------

			$params['pageAddress'] = sprintf('study_list.php?%s',
			                                 implode('&', array_map('UrlKeyValPair', array_keys($addressParams), array_values($addressParams))));

			//----------------------------------------------------------------------------------------------------------
			// count total number
			//----------------------------------------------------------------------------------------------------------
			$sqlStr = "SELECT COUNT(*) FROM patient_list pt, study_list st " . $sqlCond;
			$params['totalNum']     = DBConnector::query($sqlStr, $sqlParams, 'SCALAR');
			$params['maxPageNum']   = ($params['showing'] == "all") ? 1 : ceil($params['totalNum'] / $params['showing']);
			$params['startPageNum'] = max($params['pageNum'] - $PAGER_DELTA, 1);
			$params['endPageNum']   = min($params['pageNum'] + $PAGER_DELTA, $params['maxPageNum']);
			//----------------------------------------------------------------------------------------------------------

			//----------------------------------------------------------------------------------------------------------
			// Set $data array
			//----------------------------------------------------------------------------------------------------------
			$sqlStr = "SELECT st.sid, st.study_instance_uid, pt.patient_id, pt.patient_name, st.age, pt.sex,"
					. " st.study_id, st.study_date, st.study_time, st.modality, st.accession_number"
					. " FROM patient_list pt, study_list st" . $sqlCond . " ORDER BY " . $orderColStr;

			if($params['showing'] != "all")
			{
				$sqlStr .= " LIMIT ? OFFSET ?";
				$sqlParams[] = $params['showing'];
				$sqlParams[] = $params['showing'] * ($params['pageNum']-1);
			}

			$stmt = $pdo->prepare($sqlStr);
			$stmt->execute($sqlParams);

			$rowNum = $stmt->rowCount();
			$params['startNum'] = ($rowNum == 0) ? 0 : $params['showing'] * ($params['pageNum']-1) + 1;
			$params['endNum']   = ($rowNum == 0) ? 0 : $params['startNum'] + $rowNum - 1;

			$sqlStr = "SELECT tag FROM tag_list WHERE category=2 AND reference_id=?";
			$stmtTag = $pdo->prepare($sqlStr);

			while ($result = $stmt->fetch(PDO::FETCH_NUM))
			{
				if($_SESSION['anonymizeFlg'])
				{
					$result[2] = PinfoScramble::encrypt($result[2], $_SESSION['key']);
					$result[3] = PinfoScramble::scramblePtName();
				}

				$stmtTag->bindValue(1, $result[0]);
				$stmtTag->execute();
				$result[] = implode(',', $stmtTag->fetchAll(PDO::FETCH_COLUMN));

				$data[] = $result;
			}
			//----------------------------------------------------------------------------------------------------------

			//---------------------------------------------------------------------------------------------------------
			// Generate one-time ticket to delete selected studies
			//---------------------------------------------------------------------------------------------------------
			if($_SESSION['dataDeleteFlg'])
			{
				$_SESSION['ticket'] = md5(uniqid().mt_rand());
				$params['ticket'] = $_SESSION['ticket'];
			}
			//---------------------------------------------------------------------------------------------------------
		}

		//--------------------------------------------------------------------------------------------------------------
		// Settings for Smarty
		//--------------------------------------------------------------------------------------------------------------
		$smarty = new SmartyEx();

		$smarty->assign('params', $params);
		$smarty->assign('data',   $data);

		$smarty->assign('modalityList', $modalityList);

		$smarty->display('study_list.tpl');
		//--------------------------------------------------------------------------------------------------------------
	}
	catch (PDOException $e)
	{
		var_dump($e->getMessage());
	}

	$pdo = null;
