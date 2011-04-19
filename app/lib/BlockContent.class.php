<?php

/**
 * BlockContent renders the main part of the CAD result.
 * Typically, this outputs a lesion candidate as a static image with a
 * circle marker, with some additional information (such as confidence).
 *
 * @author Soichiro Miki <smiki-tky@umin.ac.jp>
 */
abstract class BlockContent extends BlockElement
{
	/*
	 * Returns the HTML of the element.
	 */
	public function display($smarty)
	{
		$smarty->assign('blockContentParams', $this->params);
	}
}

?>