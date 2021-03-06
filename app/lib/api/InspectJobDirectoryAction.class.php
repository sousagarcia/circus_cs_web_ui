<?php

/**
 * Internal API action class which lists downloadable files in plugin result
 * directories. Works with CadFileManagerExtension class.
 * @author Soichiro Miki <smiki-tky@umin.ac.jp>
 */
class InspectJobDirectoryAction extends ApiActionBase
{
	/**
	 * @var CadResult
	 */
	private $_cad_result = null;
	private $_options = null;
	private $_canDelete = null; // privilege defined by presentation.json

	protected static $rules = array(
		'jobID' => array('type' => 'int', 'required' => true),
		'delete' => array('type' => 'string')
	);

	protected function execute($params)
	{
		// check that current user has access to job directory
		$job_id = $params['jobID'];
		$this->_cad_result = new CadResult($job_id);

		$ext = $this->_cad_result->Plugin->presentation()->extensionByName('CadFileManagerExtension');
		if (!$ext)
			throw new ApiOperationException('This pluguin does not enable file downloads.');
		$groups = $this->currentUser->Group;
		if (!$this->_cad_result->checkCadResultAvailability($groups))
			throw new ApiOperationException('You do not have privilege to see this CAD result.');
		if (!$ext->checkVisibleGroups($groups))
			throw new ApiOperationException('You do not have acess to see the contents of this CAD result.');
		$this->_canDelete = $ext->checkDeletableGroups($groups);

		$this->_options = $ext->getParameter();

		if (strlen($params['delete']) > 0)
		{
			if (!$this->checkDeletable($params['delete']))
			{
				throw new ApiOperationException('You can not delete this file.');
			}
			$this->delete($params['delete']);
		}
		else
		{
			// recursively read the current directory.
			$result = $this->readJobDirContents();
			return $result;
		}
	}

	protected function delete($target_file)
	{
		$file = $this->_cad_result->pathOfCadResult() . DIRECTORY_SEPARATOR . $target_file;
		if (!unlink($file))
			throw new ApiSystemException('Failed to delete file.');
		return true;
	}

	/**
	 * Determines whether user can download the specified file.
	 * Subclasses can override this function and implement custom checking
	 * (for example, complicated user-based access control).
	 * @param string $entry The subpath (sub/path/to/file.ext) of the file.
	 * @return boolean True if user can download this file.
	 */
	protected function checkAccess($entry)
	{
		$pattern = $this->_options['filesMatch'];
		return strlen($pattern) == 0 || preg_match($pattern, $entry);
	}

	protected function checkDeletable($entry)
	{
		if (!$this->_canDelete) return false;
		$pattern = $this->_options['deleteFilesMatch'];
		return strlen($pattern) == 0 || preg_match($pattern, $entry);
	}

	protected function getKeywords()
	{
		$cr = $this->_cad_result;
		Patient::$anonymizeMode = $this->currentUser->needsAnonymization();
		$from = array('{$PATIENT_ID}', '{$JOB_ID}', '{$STUDY_DATE}', '{$JOB_DATE}', '{$TODAY}');
		$primary_series = $cr->Series[0];
		$sd = new DateTime($primary_series->Study->study_date);
		$ed = new DateTime($cr->executed_at);
		$to = array(
			$primary_series->Study->Patient->patient_id,
			$cr->job_id,
			$sd->format('Y-m-d'),
			$ed->format('Y-m-d'),
			date('Y-m-d')
		);
		return array('from' => $from, 'to' => $to);
	}

	protected function readJobDirContents()
	{
		$cr = $this->_cad_result;
		$path = $cr->pathOfCadResult();
		$wpath = $cr->webPathOfCadResult();
		$flags = FilesystemIterator::SKIP_DOTS |
			FilesystemIterator::UNIX_PATHS |
			FilesystemIterator::CURRENT_AS_FILEINFO;
		$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($path, $flags));
		$result = array();

		$keywords = $this->getKeywords();
		$from = $keywords['from'];
		$to = $keywords['to'];

		while ($it->valid())
		{
			if ($it->current()->isDir())
			{
				$it->next();
				continue;
			}
			$entry = $it->getSubPathname();

			if (!$this->checkAccess($entry))
			{
				$it->next();
				continue;
			}

			$link = $entry;
			if (is_array($this->_options['links']))
			{
				foreach ($this->_options['links'] as $sub)
				{
					$link = preg_replace($sub[0], $sub[1], $link, -1, $cnt);
					if ($cnt > 0)
					{
						$link = str_replace($from, $to, $link);
						break;
					}
				}
			}
			if (is_array($this->_options['fileNames']))
			{
				foreach ($this->_options['fileNames'] as $item)
				{
					$as = preg_replace($item[0], $item[1], $entry, -1, $cnt);
					if ($cnt > 0)
					{
						$as = str_replace($from, $to, $as);
						$as = urlencode($as);
						break;
					}
				}
			}
			$result[] = array(
				'file' => $entry,
				'url' => "$wpath/$entry",
				'download' => "$wpath/$entry?dl=1&as=$as",
				'size' => $it->getSize(),
				'link' => $link,
				'deletable' => $this->checkDeletable($entry)
			);
			$it->next();
		}
		return $result;
	}
}
