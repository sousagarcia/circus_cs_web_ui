<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis" />
<meta http-equiv="content-style-type" content="text/css" />
<meta http-equiv="content-script-type" content="text/javascript" />
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />

<title>CIRCUS CS {$smarty.session.circusVersion}</title>

<link href="../css/import.css" rel="stylesheet" type="text/css" media="all" />
<script language="javascript" type="text/javascript" src="../jq/jquery-1.3.2.min.js"></script>
<script language="javascript" type="text/javascript" src="../jq/ui/jquery-ui-1.7.3.min.js"></script>
<script language="javascript" type="text/javascript" src="../jq/jq-btn.js"></script>
<script language="javascript" type="text/javascript" src="../js/hover.js"></script>
<script language="javascript" type="text/javascript" src="../js/viewControl.js"></script>
<script language="javascript" type="text/javascript" src="../js/edit_tag.js"></script>
<script language="javascript" type="text/javascript" src="../js/sprintf-0.7-beta1.js"></script>


{literal}
<script language="Javascript">
<!--

function Plus()
{
	var value = $("#slider").slider("value");

	if(value < $("#slider").slider("option", "max"))
	{
		value++;
		$("#sliderValue").html(value);
		$("#slider").slider("value", value);
	}
}

function Minus()
{
	var value = $("#slider").slider("value");

	if($("#slider").slider("option", "min") <= value)
	{
		value--;
		$("#sliderValue").html(value);
		$("#slider").slider("value", value);
	}
}

function ChangeSlice(imgNum)
{

	var orgImgFname = $("#orgImg").attr("src");
	var resImgFname = $("#resImg").attr("src");

	orgImgFname = sprintf("%s%03d.png", orgImgFname.substr(0, orgImgFname.length-7), imgNum);
	resImgFname = sprintf("%s%03d.png", resImgFname.substr(0, resImgFname.length-7), imgNum);

	$("#sliceNumber").html(imgNum);
	$("#orgImg").attr("src", orgImgFname);
	$("#resImg").attr("src", resImgFname);
}
{/literal}

$(function() {ldelim}
	$("#slider").slider({ldelim}
		value:{$imgNum},
		min: 1,
		max: {$maxImgNum},
		step: 1,
		slide: function(event, ui) {ldelim}
			$("#sliderValue").html(ui.value);
		{rdelim},
		change: function(event, ui) {ldelim}
			$("#sliderValue").html(ui.value);
			ChangeSlice(ui.value);
		{rdelim}
	{rdelim});
	$("#slider").css("width", "220px");
	$("#sliderValue").html(jQuery("#slider").slider("value"));	

{rdelim});


-->
</script>

<link rel="shortcut icon" href="favicon.ico" />

<link href="../jq/ui/css/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/mode.{$smarty.session.colorSet}.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/popup.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/darkroom.css" rel="stylesheet" type="text/css" media="all" />
<script language="javascript" type="text/javascript" src="../js/radio-to-button.js"></script>
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

			<!-- ***** TAB ***** -->
			{include file='cad_results/cad_result_tab_area.tpl'}
			
			<div class="tab-content">
				<form id="form1" name="form1">
				<input type="hidden" id="execID"            name="execID"            value="{$params.execID}">
				<input type="hidden" id="studyInstanceUID"  name="studyInstanceUID"  value="{$params.studyInstanceUID}">
				<input type="hidden" id="seriesInstanceUID" name="seriesInstanceUID" value="{$params.seriesInstanceUID}">
				<input type="hidden" id="colorSet"          name="colorSet"          value="{$smarty.session.colorSet}">
				<input type="hidden" id="srcList"           name="srcList"           value="{$params.srcList}">
				<input type="hidden" id="tagStr"            name="tagStr"            value="{$params.tagStr}">
				<input type="hidden" id="tagEnteredBy"      name="tagEnteredBy"      value="{$params.tagEnteredBy}">

				<div id="cadResult">

					<h2>CAD Result&nbsp;&nbsp;[{$params.cadName} v.{$params.version} ID:{$params.execID}]</h2>

					<div class="headerArea">
						<div class="fl-l"><a href="../study_list.php?mode=patient&encryptedPtID={$params.encryptedPtID}">{$params.patientName}&nbsp;({$params.patientID})&nbsp;{$params.age}{$params.sex}</a></div>
						<div class="fl-l"><img src="../img_common/share/path.gif" /><a href="../series_list.php?mode=study&studyInstanceUID={$params.studyInstanceUID}">{$params.studyDate}&nbsp;({$params.studyID})</a></div>
						<div class="fl-l"><img src="../img_common/share/path.gif" />{$params.modality},&nbsp;{$params.seriesDescription}&nbsp;({$params.seriesID})</div>
					</div>
			
					<div class="detailArea fl-clr">
						<div class="series-detail-img" style="width:{if $dispWidth>=300}{$dispWidth}{else}300{/if}px;">
							<table>
								<tr>
									<td valign=top width="{if $dispWidth>=300}{$dispWidth}{else}300{/if}" height="{$dispHeight}">
										<img id="orgImg" src="../{$b0Img}" width="{$dispWidth}" height="{$dispHeight}" />
									</td>
								</tr>
								<tr>
									<td class="pt10" valign=top width="{if $dispWidth>=300}{$dispWidth}{else}300{/if}" height="{$dispHeight}">
										<img id="resImg" src="../{$resImg}" width="{$dispWidth}" height="{$dispHeight}" />
									</td>
								<tr>
									<td valign=top align=center>
										<table cellpadding=0 cellspacing=0>
											<tr>
												<td align="right" width="{if $dispWidth>=300}{math equation="(x-256)/2" x=$dispWidth}{else}22{/if}">
	 												<input type="button" value="-" onClick="Minus();" />
												</td>
												<td align="center" width="256"><div id="slider"></div></td>
												<td align="left" width="{if $dispWidth>=300}{math equation="(x-256)/2" x=$dispWidth}{else}22{/if}">
		 											<input type="button" value="+" onClick="Plus();" />
												</td>
											</tr>
											<tr>
												<td align=center colspan=3>
													<span style="font-weight:bold;">Image number: <span id="sliderValue">1</span></span>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</div>

						<div class="mt20">
							<table id="posTable" class="col-tbl mb10">
								<tr>
									<th rowspan="2" style="width: 3em;">ch.</th>
									<th rowspan="2" style="width: 4em;">b0</th>
									<th colspan="3">Direction of MPG</th>
								</tr>
								<tr>
									<th style="width: 4em;">x</th>
									<th style="width: 4em;">y</th>
									<th style="width: 4em;">z</th>
								</tr>

								{foreach from=$data item=item}
									<tr>
										<td>{$item[1]|escape|string_format:"%d"}</td>
										<td class="al-r">{$item[2]|escape|string_format:"%.1f"}</td>
										<td class="al-r">{$item[3]|escape|string_format:"%.3f"}</td>
										<td class="al-r">{$item[4]|escape|string_format:"%.3f"}</td>
										<td class="al-r">{$item[5]|escape|string_format:"%.3f"}</td>
									</tr>
								{/foreach}
							</table>
						</div><!-- / .detail-panel END -->
					</div><!-- / .detailArea END -->
				</div>
				<div class="fl-clr"></div>
				<!-- / CAD detail END -->

				<!-- Tag area -->
				{include file='cad_results/plugin_tag_area.tpl'}

				</form>

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
