<?php

/**
 * CADResult represents result set for one CAD process.
 *
 * @author Soichiro Miki <smiki-tky@umin.ac.jp>
 */
class CADResult extends Model
{
	protected static $_table = 'executed_plugin_list';
	protected static $_primaryKey = 'job_id';
	protected static $_belongsTo = array(
		'Plugin' => array('key' => 'plugin_id'),
		'Storage' => array('key' => 'storage_id')
	);
	protected static $_hasMany = array(
		'Feedback' => array('key' => 'job_id'),
		'PluginAttribute' => array('key' => 'job_id')
	);
	protected static $_hasAndBelongsToMany = array(
		'Series' => array(
			'joinTable' => 'executed_series_list',
			'foreignKey' => 'job_id',
			'associationForeignKey' => 'series_sid',
			'foreignPrimaryKey' => 'sid'
		)
	);

	protected $_attributes;
	protected $_displayPresenter;
	protected $_feedbackListener;
	protected $_cadResult;

	/**
	 * Retrieves the list of feedback data associated with this CAD Result.
	 * @param string $feedbackMode 'personal', 'consensual', or 'all'
	 * @return array Array of Feedback objects
	 */
	public function getFeedback($feedbackMode = 'personal')
	{
		// TODO: Replace SQL
		$dummy = new Feedback();
		$arr = array(0,0,0,1,1,1,-1,-1,-1);
		shuffle($arr);
		$dummy->blockFeedback = $arr;
		return $dummy;
	}

	/**
	 * Returns the feedback visiblity/availability
	 * associated with this CAD Result.
	 * This is based on the user group settings and the feedback policy.
	 *
	 * @param string $feedbackMode 'consensual' or 'personal'
	 * @return string 'normal', 'disabled', 'locked', or 'hidden'.
	 * The 'normal' status means the login user can input or see his feedback.
	 * The 'disabled' status means the user can inspect the feedback
	 * result, but you cannot enter or modify it. (But he may go back
	 * to 'normal' status for personal feedback by unregistering)
	 * The 'locked' status applies only for consensual feedback and
	 * means that the user cannot enter the consensual mode.
	 * The 'hidden' status means the feedback information is completely hidden
	 * (typically for guest users).
	 */
	public function feedbackAvailability($feedbackMode = 'personal')
	{
		// TODO: implemente the feedbackAvailability

		// The availability is 'hidden' when the user has such privilege
		if (false) {
			return 'hidden';
		}

		// The availability is 'locked' when the user has not yet entered
		// his personal feedback.
		if ($feedbackMode == 'consensual' && false) {
			return 'locked';
		}

		// The availability is 'disabled' when:
		// (1) The user has no privileges to give personal/consensual feedback
		//     at all.
		// (2) The user has already entered the feedback.
		// (3) Consensual feedback is already registered by someone.
		if (false) {
			return 'disabled';
		}
		return 'normal';
	}

	/**
	 * Returns whether the user can unregister the feedback.
	 * @param string $feedbackMode 'personal' or 'consensual'.
	 * Please note there is no plant to unregister consensual feedback,
	 * so this method always return false for consensual feedback.
	 * @return bool $feedbackMode True if the user can unregister this
	 * CAD result.
	 */
	public function feedbackUnregisterable($feedbackMode = 'personal')
	{
		if ($feedbackMode != 'personal')
			return false;
		return false; // TODO: implement feedbackUnregisterable
	}

	/**
	 * Returns the CAD result visibility for the user currently logged in.
	 * @return bool True if the user can view this CAD result.
	 */
	public function checkCADResultAvailability()
	{
		// TODO: implement checkCADResultAavailability
		return true;
	}

	/**
	 * Retrieves the list of displays (such as lesion candidates).
	 * @return array Array of CAD dispalys
	 */
	public function getDisplays()
	{
		return $this->displayPresenter()->extractDisplays($this->_cadResult);
	}

	/**
	 * Retrieves the list of attributes associated with this CAD Result.
	 */
	public function getAttributes()
	{
		if (is_array($this->_attributes))
			return $this->_attributes;
		$tmp = $this->PluginAttribute;
		$result = array();
		foreach ($tmp as $attribute)
		{
			$result[$attribute->key] = $attribute->value;
		}
		$this->_attributes = $result;
		return $result;
	}

	/**
	 * Retrieves the Plugin object which produced this CAD result.
	 * @return Plugin
	 */
	public function getExecutedPlugin()
	{
		return null; // not implemented
	}

	public function load($id)
	{
		//
		// STEP: Load using inheriting load method
		//
		parent::load($id);

		//
		// STEP: Get the table name which actually holds the result data
		//
		$pid = $this->Plugin->plugin_id;
		$sqlStr = "SELECT * FROM plugin_cad_master WHERE plugin_id = ?";
		$cad_master = DBConnector::query($sqlStr, $pid, 'ARRAY_ASSOC');
		$result_table = $cad_master['result_table'];

		//
		// STEP: Get the actual CAD results from the result table
		//
		$sqlStr = "SELECT * FROM $result_table WHERE job_id=?";
		$this->_cadResult = DBConnector::query($sqlStr, $this->job_id, 'ALL_ASSOC');
	}

	protected function defaultPresentation()
	{
		return array(
			'displayPresenter' => array(
				'type' => 'LesionCADDisplayPresenter'
			),
			'feedbackListener' => array(
				'type' => 'SelectionFeedbackListener'
			)
		);
	}

	protected function loadPresentationConfiguration()
	{
		global $WEB_UI_ROOT;
		if (is_array($this->_presentation))
			return;
		$result = $this->defaultPresentation();
		$plugin_name = $this->Plugin->plugin_name . "_v" . $this->Plugin->version;
		try {
			$json = file_get_contents(
				"$WEB_UI_ROOT/plugin/$plugin_name/presentation.json" );
			$tmp = json_decode($json, true);
			$result = array_merge($result, $tmp);
		} catch (Exception $e) {
			print ($e->getMessage());
		}
		$this->_presentation = $result;
	}

	/**
	 * Returns DisplayPresenter associated with this cad result.
	 * @return DisplayPresenter The DisplayPresenter instance
	 */
	public function displayPresenter()
	{
		if ($this->_displayPresenter)
			return $this->_displayPresenter;
		$this->loadPresentationConfiguration();
		$presenter = new $this->_presentation['displayPresenter']['type']($this);
		$presenter->setParameter($this->_presentation['displayPresenter']['params']);
		$this->_displayPresenter = $presenter;
		return $presenter;
	}

	/**
	 * Returns FeedbackListener associated with this cad result.
	 * @return FeedbackListener The FeedbackListener instance
	 */
	public function feedbackListener()
	{
		if ($this->_feedbackListener)
			return $this->_feedbackListener;
		$this->loadPresentationConfiguration();
		$listener = new $this->_presentation['feedbackListener']['type']($this);
		$listener->setParameter($this->_presentation['feedbackListener']['params']);
		$this->_feedbackListener = $listener;
		return $listener;
	}

	/**
	 * Returns CAD result directory web path.
	 * @return string CAD result directory web path.
	 */
	public function webPathOfCADResult()
	{
		global $DIR_SEPARATOR_WEB, $SUBDIR_CAD_RESULT;
		$webPath = $this->Storage->apache_alias;
		$series = $this->Series[0];
		// TODO: This should be replaced when WEB_BASE or something is implemented
		$seriesDirWeb = '../' . $webPath .
			$series->Study->Patient->patient_id . $DIR_SEPARATOR_WEB .
			$series->Study->study_instance_uid . $DIR_SEPARATOR_WEB .
			$series->series_instance_uid;
		$result =  $seriesDirWeb . $DIR_SEPARATOR_WEB .
			$SUBDIR_CAD_RESULT . $DIR_SEPARATOR_WEB . $this->Plugin->fullName();
		return $result;
	}

	/**
	 * Returns CAD result directory path.
	 * @return string CAD result directory path.
	 */
	public function pathOfCADResult()
	{
		global $DIR_SEPARATOR, $SUBDIR_CAD_RESULT;
		$path = $this->Storage->path;
		$series = $this->Series[0];
		$seriesDir = $path . $DIR_SEPARATOR .
			$series->Study->Patient->patient_id . $DIR_SEPARATOR .
			$series->Study->study_instance_uid . $DIR_SEPARATOR .
			$series->series_instance_uid;
		$result =  $seriesDir . $DIR_SEPARATOR .
			$SUBDIR_CAD_RESULT . $DIR_SEPARATOR . $this->Plugin->fullName();
		return $result;
	}
}

?>