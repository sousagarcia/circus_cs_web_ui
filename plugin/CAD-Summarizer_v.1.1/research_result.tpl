<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="content-style-type" content="text/css" />
<meta http-equiv="content-script-type" content="text/javascript" />
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
<title>CIRCUS CS {$smarty.session.circusVersion}</title>

<link href="../css/import.css" rel="stylesheet" type="text/css" media="all" />
<script language="javascript" type="text/javascript" src="../jq/jquery.min.js"></script>
<script language="javascript" type="text/javascript" src="../jq/ui/jquery-ui.min.js"></script>
<script language="javascript" type="text/javascript" src="../js/circus-common.js"></script>
<script language="javascript" type="text/javascript" src="../js/edit_tags.js"></script>
<script language="javascript" type="text/javascript" src="../jq/jquery.blockUI.js"></script>
<script language="javascript" type="text/javascript" src="../js/research_result.js"></script>
<script language="javascript" type="text/javascript" src="../js/viewControl.js"></script>

<script language="Javascript">
<!--
circus.jobID = {$params.jobID};
circus.userID = "{$smarty.session.userID|escape:javascript}";

{literal}

	function RedrawRocCurve(jobID, inputPath)
	{
		$.post("../plugin/CAD-Summarizer_v.1.1/redraw_roc_curve_v1.1.php",
			 	{ jobID: jobID,
			 	  curveType: $(".tab-content input[name='curveType']:checked").val()},
			   	function(data){
			 		$("#rocGraph").attr("src", data.imgFname);
				}, "json");
	}

	function ChangeDispTpNum()
	{
		$("#dispSensitivity").html($("#dispTpMenu").val() + '&nbsp;%');
	}

-->
</script>
{/literal}

<link rel="shortcut icon" href="../favicon.ico" />
<link href="../jq/ui/theme/jquery-ui.custom.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/mode.{$smarty.session.colorSet}.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/darkroom.css" rel="stylesheet" type="text/css" media="all" />

{literal}
<style type="text/css">
div.imgArea {
  background-color:#888888;
  border-width:2px; 
  border-style:solid;
  overflow:hidden;
}
{/literal}
</style>

</head>

<body class="lesion_cad_display">
<div id="page">
	<div id="container" class="menu-back">
		<!-- ***** #leftside ***** -->
		<div id="leftside">
			{include file='menu.tpl'}
		</div>
		<!-- / #leftside END -->
		
		<div id="content">

			<!-- ***** .tabArea ***** -->
			<div class="tabArea">
				<ul>
					<li><a href="{if $params.srcList!="" && $smarty.session.listAddress!=""}{$smarty.session.listAddress}{else}research_list.php{/if}" class="btn-tab" title="Research list">Research list</a></li>
					<li><a href="#" class="btn-tab" title="list" style="background-image: url(../img_common/btn/{$smarty.session.colorSet}/tab0.gif); color:#fff">Research result</a></li>
				</ul>
				<p class="add-favorite"><a href="#" title="favorite"><img src="../img_common/btn/favorite.jpg" width="100" height="22" alt="favorite"></a></p>
			</div>
			<!-- / .tabArea END -->

			<div class="tab-content">
				<h2>Research result&nbsp;&nbsp;[{$params.pluginName} v.{$params.version} ID:{$params.jobID}]</h2>
				<div class="headerArea">Executed at: {$params.executedAt}</div>

				<table>
					<tr>
						<td>
				 			<table>
								<tr>
									<td width="360" height="320"><img id="rocGraph" src="{$curveFnameWeb}" width="360" height="320" /></td>
							 	</tr>
							 </table>
						</td>
						<td>
							<table>
								<tr><td></td></tr>
								<tr>
									<td class="detail-panel">
										<table class="detail-tbl">
											<tr>
												<th style="width:11em;"><span class="trim01">Total cases</span></th>
												<td class="al-r">{$data.caseNum}</td>
							 				</tr>
										 	<tr>
												<th><span class="trim01">Detected lesions</span></th>
												<td class="al-r"><span id="dispTpNum">{$data.totalTpNum}</span></td>
				 							</tr>
										 	<tr>
												<th><span class="trim01">False positives</span></th>
												<td class="al-r"><span id="dispFpNum">{$data.totalFpNum}</span></td>
				 							</tr>
				 							<tr>
				 								<th><span class="trim01">Missed lesions</span></th>
				 								<td class="al-r"><span id="fnNum">{$data.fnNum}</span></td>
				 							</tr>
				 							<tr>
				 								<th><span class="trim01">Az</span></th>
				 								<td><span id="underRocArea">{$data.underRocArea}</span></td>
											</tr>
										</table>
				 					</td>
								</tr>
				 				<tr>
									<td height=10></td>
								</tr>
								{*<tr>
									<td class="detail-panel">
										<table class="detail-tbl">
											<tr>
				 								<th>
													<span class="trim01">
														Sensitivity (displaying <select id="dispTpMenu" onchange="ChangeDispTpNum();">
														{foreach from=$sensitivityArr item=item}<option value="{$item[1]}">{$item[0]}</option>{/foreach}
														</select> candidates)</span>
												</th>
												<td class="al-r" style="width:5em;"><span id="dispSensitivity">{$sensitivityArr[0][1]} %</span></td>
				 							</tr>
										</table>
				 					</td>
								</tr>
				 				<tr>
									<td height=10></td>
								</tr>*}
								<tr>
									<td class="detail-panel">
										<table class="detail-tbl">
											<tr>
				 								<th style="width: 6.0em;"><span class="trim01">Curve</span></th>
												<td>
													<label><input name="curveType" type="radio" value="0" checked="checked" />ROC</label>
													<label><input name="curveType" type="radio" value="1" />FROC</label>
												</td>
				 							</tr>
										</table>
										<div class="al-l mt10 ml20" style="width: 100%;">
					 						<input type="button" value="Redraw" class="w100 form-btn" onclick="RedrawRocCurve({$params.jobID},'{$params.resPath}');" />
				 						</div>
				 					</td>
								</tr>
				 			</table>
				 		</td>
					</tr>
				 </table>

				<h3 class="mt20">Example of true positive</h3>
				{$tpListHtml}

				<h3 class="mt20">Example of false positive</h3>
				{$fpListHtml}

				<h3 class="mt20">Example of pending</h3>
				{$pendingListHtml}

				<h3 class="mt20">Example of false negative</h3>
				{$fnListHtml}

				<!-- Tag area -->
				<p id="tagArea">Tags: <span id="research-tags">Loading Tags...</span> <a id="edit-research-tags">(Edit)</a></p>

				<div class="al-r">
					<p class="pagetop"><a href="#page">page top</a></p>
				</div>

			</div><!-- / .tab-content END -->

			<!-- darkroom button -->
			{include file='darkroom_button.tpl'}

		</div><!-- / #content END -->
	</div><!-- / #container END -->
</div><!-- / #page END -->
</body>
</html>