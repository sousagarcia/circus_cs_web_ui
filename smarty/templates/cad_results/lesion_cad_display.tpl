<?xml version="1.0" encoding="shift_jis"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><!-- InstanceBegin template="/Templates/base.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis" />
<meta http-equiv="content-style-type" content="text/css" />
<meta http-equiv="content-script-type" content="text/javascript" />
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
<!-- InstanceBeginEditable name="doctitle" -->
<title>CIRCUS CS {$smarty.session.circusVersion}</title>
<!-- InstanceEndEditable -->

<link href="../css/import.css" rel="stylesheet" type="text/css" media="all" />
<script language="javascript" type="text/javascript" src="../jq/jquery-1.3.2.min.js"></script>
<script language="javascript" type="text/javascript" src="../jq/ui/jquery-ui-1.7.3.min.js"></script>
<script language="javascript" type="text/javascript" src="../jq/jq-btn.js"></script>
<script language="javascript" type="text/javascript" src="../js/hover.js"></script>
<script language="javascript" type="text/javascript" src="../js/viewControl.js"></script>

{literal}

<!--[if lte IE 6]>
<script language="javascript" type="text/javascript" src="../js/DD_belatedPNG_0.0.8a-min.js"></script>
<script language="javascript">
	DD_belatedPNG.fix('.transparent');
</script>
<![endif]-->


<script language="Javascript">
<!--

function CreateEvalStr(lesionArr)
{
	var evalArr = new Array();

	for(var j=0; j<lesionArr.length; j++)
	{
		if($("#lesionBlock" + lesionArr[j] + " input[name:'radioCand" + lesionArr[j] + "']:checked").val() == undefined)
		{
			evalArr.push(99);
		}
		else 
		{
			evalArr.push($("#lesionBlock" + lesionArr[j] + " input[name:'radioCand" + lesionArr[j] + "']:checked").val());
		}
	}
	return evalArr.join("^");
}

function RegistFeedback(feedbackMode, interruptFlg, candStr, evalStr, dstAddress)
{
	$.post("feedback_registration.php",
			{ execID:  $("#execID").val(),
	  		  cadName: $("#cadName").val(),
	          version: $("#version").val(),
	          interruptFlg: interruptFlg,
			  fnFoundFlg: $('input[name="fnFoundFlg"]:checked').val(),
	          feedbackMode: feedbackMode,
	  		  candStr: candStr,
	          evalStr: evalStr},
			  function(data){

				if(interruptFlg == 0)	alert(data.message);

				if(dstAddress != "")
				{
					if(dstAddress == "historyBack")  history.back();
					else						   	 location.replace(dstAddress);
				}
		  }, "json");
}

function MovePageWithTempRegistration(address)
{
	if($("#registTime").val() == "" && $("#interruptFlg").val() == 1)
	{
		var candStr = $("#candStr").val();
		var lesionArr = candStr.split("^");
		var evalStr = CreateEvalStr(lesionArr);

		RegistFeedback($("#feedbackMode").val(), 1, candStr, evalStr, address);
	}
	else
	{
		if(address == "historyBack")	history.back();
		else							location.href=address;
	}
}


function ShowFNinput()
{
	var address = 'fn_input.php'
				+ '?execID=' + $("#execID").val()
                + '&feedbackMode=' + $("#feedbackMode").val();
	
	MovePageWithTempRegistration(address);
}

function ChangeCondition(mode, feedbackMode)
{
	var address = 'show_cad_results.php?execID=' + $("#execID").val()
			    + '&feedbackMode=' + feedbackMode
				+ '&sortKey=' + $("#sortKey").val()
				+ '&sortOrder=' + $(".sort-by input[name='sortOrder']:checked").val();

	if($("#remarkCand").val() > 0)  address += '&remarkCand=' + $("#remarkCand").val();

	if((feedbackMode == "personal" || feedbackMode == "consensual") && $("#registTime").val() == "")
	{
		var candStr = $("#candStr").val();
		var lesionArr = candStr.split("^");
		var evalStr = CreateEvalStr(lesionArr);

		if(mode == 'registration')
		{
			evalArr = evalStr.split("^");
			RegistFeedback(feedbackMode, 0, candStr, evalStr, address);
		}
		else if(mode == 'changeSort' && $("#interruptFlg").val()==1)
		{
			RegistFeedback(feedbackMode, 1, candStr, evalStr, address);
		}
		else  location.replace(address);
	}
	else	location.replace(address);
}

function ChangeFeedbackMode(feedbackMode)
{
	var address = 'show_cad_results.php?execID=' + $("#execID").val()
                + '&feedbackMode=' + feedbackMode;

	if($("#remarkCand").val() > 0)  address += '&remarkCand=' + $("#remarkCand").val();

	MovePageWithTempRegistration(address);
}

function ChangeRegistCondition()
{
	var checkCnt = $("input[name^='radioCand']:checked").length;

	var tmpStr = 'Lesion classification: <span style="color:' 
               + (($("#candNum").val()==checkCnt) ? 'blue;">complete' : 'red;">incomplete') + '</span><br/>'
	           + 'FN input: <span style="color:'
		       + (($("#fnInputFlg").val()==1) ? 'blue;">complete' : 'red;">incomplete') + '</span>';

	if($("#registTime").val() =="" && $("#candNum").val()==checkCnt && $("#fnInputFlg").val()==1)
	{
		$("#registBtn").removeAttr("disabled").removeClass('form-btn-disabled').addClass('form-btn-normal');
		$("#interruptFlg").val(0);
	}
	else
	{
		$("#registBtn").attr("disabled", "disabled").removeClass('form-btn-normal').addClass('form-btn-disabled');
		$("#interruptFlg").val(1);
	}

	if($("#groupID").val() != 'demo')
	{
		$("#registCaution").html(tmpStr);
		$("#interruptFlg").val(1);

		// 候補分類入力中にメニューバーを押された場合の対策
		$("#linkAbout, #menu a").click(
			function(event){ 

				if(!event.isDefaultPrevented())
				{
					event.preventDefault();  // prevent link action
					
					if(confirm("Do you want to save the changes?"))
					{
						MovePageWithTempRegistration(event.currentTarget.href);
					}
				}
			});
	}
}

function ShowCADDetail(imgNum)
{
	$("#slider").slider("value", imgNum);

	if($("#registTime").val() == "" && $("#interruptFlg").val() == 1)
	{
		var candStr = $("#candStr").val();
		var lesionArr = candStr.split("^");
		var evalStr = CreateEvalStr(lesionArr);

		RegistFeedback($("#feedbackMode").val(), 1, candStr, evalStr, "");
	}

	$("#cadResult, #cadResultTab").hide();
	$("#cadDetailTab, #cadDetail").show();
	$('#container').height( $(document).height() - 10 );

}

function ShowCADResult()
{
	$("#cadDetailTab, #cadDetail").hide();
	$("#cadResult, #cadResultTab").show();
	$('#container').height( $(document).height() - 10 );
}

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

function ChangePresetMenu()
{
	var tmpStr = $("#presetMenu").val().split("^");
	var presetName = $("#presetMenu option:selected").text();
	$("#windowLevel").val(tmpStr[0]);
	$("#windowWidth").val(tmpStr[1]);
	$("#presetName").val(presetName);

	JumpImgNumber($("#slider").slider("value"), tmpStr[0], tmpStr[1], presetName);
}

function JumpImgNumber(imgNum, windowLevel, windowWidth, presetName)
{
	$.post("../jump_image.php",
			{ studyInstanceUID: $("#studyInstanceUID").val(),
			  seriesInstanceUID: $("#seriesInstanceUID").val(),
			  imgNum: imgNum,
			  windowLevel: windowLevel,
			  windowWidth: windowWidth,
			  presetName:  presetName },
  			  function(data){

				if(data.imgFname != "")
				{
					$("#imgBox img").attr("src", '../' + data.imgFname);
					$("#imgBox span").html(data.imgNumStr);
					$("#sliceNumber").html(data.sliceNumber);
					$("#sliceLocation").html(data.sliceLocation + ' [mm]');
				}
			}, "json");
}


function EditCandidateTag(execID, candID, feedbackMode, userID)
{
	var dstAddress = "../cad_results/edit_candidate_tag.php?execID=" + execID + "&candID=" + candID
                   + "&feedbackMode=" + feedbackMode + "&userID=" + userID;
	window.open(dstAddress,"Edit lesion candidate tag", "width=400,height=250,location=no,resizable=no,scrollbars=1");
}


$(function() {
{/literal}

	$("#slider").slider({ldelim}
		value:{$detailData.imgNum},
		min: 1,
		max: {$detailData.fNum},
		step: 1,
		slide: function(event, ui) {ldelim}
			$("#sliderValue").html(ui.value);
		{rdelim},
		change: function(event, ui) {ldelim}
			$("#sliderValue").html(ui.value);
			JumpImgNumber(ui.value, $("#windowLevel").val(), $("#windowWidth").val(), $("#presetName").val());
		{rdelim}
	{rdelim});
	$("#slider").css("width", "220px");
	$("#sliderValue").html(jQuery("#slider").slider("value"));	

{literal}

	$("input[name='fnFoundFlg']").change(function() {

		if($(this).val() == 0)
		{
			if(confirm('Is there no false negative?'))
			{
				$("#fnInputFlg").val(1);
				$("#fnInputBtn").attr("disabled", "disabled").removeClass('form-btn-normal').addClass('form-btn-disabled');
				
			}
		}
		else
		{
			$("#fnInputBtn").removeAttr("disabled").removeClass('form-btn-disabled').addClass('form-btn-normal');
		    $("#fnInputFlg").val(($("#fnNum").val() > 0) ? 1 : 0);
		}

		ChangeRegistCondition();
	});
});
{/literal}


-->
</script>

<link rel="shortcut icon" href="favicon.ico" />

<!-- InstanceBeginEditable name="head" -->
<link href="../jq/ui/css/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/mode.{$smarty.session.colorSet}.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/popup.css" rel="stylesheet" type="text/css" media="all" />
<link href="../css/darkroom.css" rel="stylesheet" type="text/css" media="all" />
<script language="javascript" type="text/javascript" src="../js/radio-to-button.js"></script>

<!-- InstanceEndEditable -->
</head>

<!-- InstanceParam name="class" type="text" value="home" -->
<body class="lesion_cad_display">
<div id="page">
	<div id="container" class="menu-back">
		<div id="leftside">
			{include file='menu.tpl'}
		</div><!-- / #leftside END -->
		<div id="content">
<!-- InstanceBeginEditable name="content" -->

		<!-- ***** TAB ***** -->
		<div id="cadResultTab" class="tabArea">
			<ul>
				{if $params.srcList!="" && $smarty.session.listAddress!=""}
					<li><a href="#" onclick="MovePageWithTempRegistration('../{$smarty.session.listAddress}');" class="btn-tab" title="{$params.listTabTitle}">{$params.listTabTitle}</a></li>
				{else}
					<li><a href="#" onclick="MovePageWithTempRegistration('../series_list.php?mode=study&studyInstanceUID={$params.studyInstanceUID}');" class="btn-tab" title="Series list">Series list</a></li>
				{/if}
				<li><a href="#" class="btn-tab" title="list" style="background-image: url(../img_common/btn/{$smarty.session.colorSet}/tab0.gif); color:#fff">CAD result</a></li>
			</ul>
			<p class="add-favorite"><a href="#" title="favorite"><img src="../img_common/btn/favorite.jpg" width="100" height="22" alt="favorite"></a></p>
		</div><!-- / .tabArea END -->

		<div id="cadDetailTab" class="tabArea" style="display:none;">
			<ul>
				{if $params.srcList!="" && $smarty.session.listAddress!=""}
					<li><a href="../{$smarty.session.listAddress}" class="btn-tab" title="{$params.listTabTitle}">{$params.listTabTitle}</a></li>
				{else}
					<li><a href="../series_list.php?mode=study&studyInstanceUID={$params.studyInstanceUID}" class="btn-tab" title="Series list">Series list</a></li>
				{/if}
				<li><a href="#" onclick="ShowCADResult();" class="btn-tab" title="CAD result">CAD result</a></li>
				<li><a href="#" class="btn-tab" title="list" style="background-image: url(../img_common/btn/{$smarty.session.colorSet}/tab0.gif); color:#fff">CAD detail</a></li>
			</ul>
			<p class="add-favorite"><a href="#" title="favorite"><img src="../img_common/btn/favorite.jpg" width="100" height="22" alt="favorite"></a></p>
		</div><!-- / .tabArea END -->

		
		<div class="tab-content">
		{if $data.errorMessage != ""}
			<div style="color:#f00;font-weight:bold;">{$data.errorMessage}</div>
		{else}
			<form id="form1" name="form1">
			<input type="hidden" id="feedbackMode"      name="feedbackMode"      value="{$params.feedbackMode}" />
			<input type="hidden" id="execID"            name="execID"            value="{$params.execID}" />
			<input type="hidden" id="groupID"           name="groupID"           value="{$smarty.session.groupID}" />
			<input type="hidden" id="studyInstanceUID"  name="studyInstanceUID"  value="{$params.studyInstanceUID}" />
			<input type="hidden" id="seriesInstanceUID" name="seriesInstanceUID" value="{$params.seriesInstanceUID}" />
			<input type="hidden" id="cadName"           name="cadName"           value="{$params.cadName}" />	
			<input type="hidden" id="version"           name="version"           value="{$params.version}" />
			<input type="hidden" id="ticket"            name="ticket"            value="{$ticket}" />
			<input type="hidden" id="registTime"        name="registTime"        value="{$params.registTime}" />
			<input type="hidden" id="srcList"           name="srcList"           value="{$params.srcList}" />
			<input type="hidden" id="remarkCand"        name="remarkCand"        value="{$params.remarkCand}" />

			<input type="hidden" id="candNum"        value="{$params.candNum}" />
			<input type="hidden" id="fnInputFlg"     value="{$params.fnInputFlg}" />
			<input type="hidden" id="fnPersonalCnt"  value="{$params.fnPersonalCnt}" />

			<div id="cadResult">

				<h2>CAD Result&nbsp;&nbsp;[{$params.cadName} v.{$params.version} ID:{$params.execID}]</h2>
				{* <h2>CAD Result&nbsp;&nbsp;[{$params.cadName} v.{$params.version}]<span class="ml10" style="font-size:12px;">(ID:{$params.execID})</span></h2> *}

			<div class="headerArea">
					<div class="fl-l"><a onclick="MovePageWithTempRegistration('../study_list.php?mode=patient&encryptedPtID={$params.encryptedPtID}');">{$params.patientName}&nbsp;({$params.patientID})&nbsp;{$params.age}{$params.sex}</a></div>
					<div class="fl-l"><img src="../img_common/share/path.gif" /><a onclick="MovePageWithTempRegistration('../series_list.php?mode=study&studyInstanceUID={$params.studyInstanceUID}');">{$params.studyDate}&nbsp;({$params.studyID})</a></div>
					<div class="fl-l"><img src="../img_common/share/path.gif" />{$params.modality},&nbsp;{$params.seriesDescription}&nbsp;({$params.seriesID})</div>
				</div>
		
				<div class="hide-on-guest">
					<input type="radio" name="change-mode1" value="Personal mode" class="radio-to-button-l" label="Personal mode"  onclick="ChangeFeedbackMode('personal');" {if $params.feedbackMode=='personal'}checked="checked"{/if} />
					<input type="radio" name="change-mode1" value="Consensual mode" class="radio-to-button-l" label="Consensual mode" onclick="ChangeFeedbackMode('consensual');" {if $params.feedbackMode=='consensual'}checked="checked"{/if}{if $smarty.session.consensualFBFlg==0 || ($params.feedbackMode == "personal" && $consensualFBFlg == 0)} disabled="disabled"{/if} />
					<div class="fl-l" style="margin-left:5px;font-size:80%;"><a href="#">about classification types</a></div>
				</div>
			
				<div class="fl-clr"></div>

				<div class="sort-by">
					<div class="total-cand">
						{if $smarty.session.researchFlg==1}<span style="font-weight:bold;">Total candidates:</span> {$params.totalCandNum}{else}&nbsp;{/if}
					</div>
					<div class="sort-btn">
						<input id="sortBtn" type="button" value="Sort" class="s-btn w50 form-btn" onclick="ChangeCondition('changeSort','{$params.feedbackMode}');" />
						by
						<select id="sortKey" name="sortKey">
							<option value="0" {if $params.sortKey==0}selected="selected"{/if}>Confidence</option>
							<option value="1" {if $params.sortKey==1}selected="selected"{/if}>Img. No.</option>
							<option value="2" {if $params.sortKey==2}selected="selected"{/if}>Volume</option>
						</select>
						<input name="sortOrder" type="radio" value="f" {if $params.sortOrder=='f'}checked="checked"{/if} />Asc.
						<input name="sortOrder" type="radio" value="t" {if $params.sortOrder=='t'}checked="checked"{/if} />Desc.
						</div>
				</div>

				<!-- CAD result (lesionBlock) -->
				{if $params.candNum==0}
					<div style="margin:10px;">&nbsp;</div>
				{else}
					{foreach from=$candHtml item=htmlStr}{$htmlStr}{/foreach}
				{/if}

				{*<div class="fl-clr mb10" style="margin-top:-50px; border-top: 1px solid #888;"></div>*}

				<!-- Input FN number -->
				{if $smarty.session.personalFBFlg == 1 || $smarty.session.consensualFBFlg == 1 || $smarty.session.groupID == 'demo'}

					<input type="hidden" id="candStr"      name="candStr"    value="{$candStr}">
					<input type="hidden" id="evalStr"      name="evalStr"      value="">
					<input type="hidden" id="interruptFlg" name="interruptFlg" value="{$params.interruptFlg}">
					<input type="hidden" id="registFlg"    name="registFlg"    value="{$params.registFlg}">

					<div class="hide-on-guest fl-clr" style="width: 820px;">
						<div class="fl-l" style="width:570px;">
							<input type="radio" name="fnFoundFlg" value="1"{if !$params.fnInputFlg ||$params.fnNum>0 || ($params.feedbackMode=="consensual" && $params.fnPersonalCnt>0)} checked="checked"{/if} {if $params.fnInputFlg} disabled="disabled"{/if}/> False negative found&nbsp;&nbsp;<input id="fnInputBtn" type="button" class="form-btn {if $params.fnInputFlg && $params.fnNum==0}form-btn-disabled{else}form-btn-normai{/if}" value="input" onclick="ShowFNinput();"{if $params.fnInputFlg && $params.fnNum==0} disabled="disabled"{/if} />&nbsp;&nbsp;(<span id="fnNum" style="font-weight:bold;color:red;">{$params.fnNum}</span> entered)<br/>
							<input type="radio" name="fnFoundFlg" value="0"{if $params.fnInputFlg && $params.fnNum==0} checked="checked"{/if}{if $params.fnInputFlg || ($params.feedbackMode=="consensual" && $params.fnPersonalCnt>0)} disabled="disabled"{/if} /> FN&nbsp;&nbsp;NOT&nbsp;&nbsp;found
						</div>
						<p class="fl-r" style="width:250px;">
							<input id="registBtn" type="button" value="Registration of feedback" class="fs-l form-btn registration form-btn-disabled" onclick="ChangeCondition('registration', '{$params.feedbackMode}');" {if $params.registTime!="" || !($params.candNum==$params.lesionCheckCnt && $params.fnInputFlg)} disabled="disabled"{/if} />
							<br />
							<span id="registCaution" style="font-weight:bold;">{if $params.registTime=="" || !$params.fnInputFlg}{$params.registStr}{else}{$registMsg}{/if}</span>
						</p>
					</div>
				{/if}
				<div class="fl-clr"></div>
				</div>
			<!-- / Result -->

			<!-- CAD detail -->
			<div id="cadDetail" style="display:none;">
				<input type="hidden" id="presetName"   name="presetName"   value="{$detailData.presetName}" />
				<input type="hidden" id="windowLevel"  name="windowLevel"  value="{$detailData.windowLevel}" />
				<input type="hidden" id="windowWidth"  name="windowWidth"  value="{$detailData.windowWidth}" />

				<h2>CAD Detail</h2>

				<div class="detailArea fl-clr">
					<div class="series-detail-img">
						<table>
							<tr>
								<td valign=top align=left width="320" height="{$detailData.dispHeight}">
									<div id="imgBox" style="width:{$detailData.dispWidth}; height:{$detailData.dispHeight}; position:relative;">
										<img src="../{$detailData.dstFnameWeb}" width="{$detailData.dispWidth}" height="{$detailData.dispHeight}" style="position:absolute; left:{$detailData.imgLeftPos}px; top:0px; z-index:1;" />
										<span style="color:#fff; font-weight:bold; position:absolute; left:{$detailData.imgNumStrLeftPos}px; top:0px; z-index:2;">Img. No. {$detailData.imgNum|string_format:"%04d"}</span>
									</div>
								</td>
							</tr>
							<tr>
								<td valign=top align=center>
									<table cellpadding=0 cellspacing=0>
										<tr>
											<td align="right" {if $detailData.dispWidth>=300}width={math equation="(x-256)/2" x=$detailData.dispWidth}"{/if}>
 												<input type="button" value="-" onClick="Minus();" />
											</td>
											<td align="center" width="256"><div id="slider"></div></td>
											<td align="left" {if $detailData.dispWidth>=300}width="{math equation="(x-256)/2" x=$detailData.dispWidth}"{/if}>
	 											<input type="button" value="+" onClick="Plus();" />
											</td>
										</tr>
										<tr>
											<td align=center colspan=3>
												<span style="font-weight:bold;">Image number: <span id="sliderValue">1</span></span>
											</td>
										</tr>
										{if $detailData.grayscaleStr != ""}
											<tr>
												<td align=center colspan=3>
													<span style="font-weight:bold;">Grayscale preset: </span>
													<select id="presetMenu" name="presetMenu" onchange="ChangePresetMenu();">
														{section name=i start=0 loop=$detailData.presetNum}
															{assign var="i" value=$smarty.section.i.index}
															{assign var="tmp0" value=$i*3}
															{assign var="tmp1" value=$i*3+1}
															{assign var="tmp2" value=$i*3+2}

															<option value="{$detailData.presetArr[$tmp1]}^{$detailData.presetArr[$tmp2]}" {if $detailData.presetName == $detailData.presetArr[$tmp0]}selected="selected"{/if}>{$detailData.presetArr[$tmp0]}</option>
														{/section}
													</select>
												</td>
											</tr>
										{/if}
									</table>
								</td>
							</tr>
						</table>
					</div>
					
					<div class="detail-panel">
						<table class="detail-tbl">
							<tr>
								<th style="width: 12em;"><span class="trim01">Patient ID</span></th>
								<td>{$params.patientID}</td>
							</tr>
							<tr>
								<th><span class="trim01">Patient name</span></th>
								<td>{$params.patientName}</td>
							</tr>
							<tr>
								<th><span class="trim01">Sex</span></th>
								<td>{$params.sex}</td>
							</tr>
							<tr>
								<th><span class="trim01">Age</span></th>
								<td>{$params.age}</td>
							</tr>
							<tr>
								<th><span class="trim01">Study ID</span></th>
								<td>{$params.studyID}</td>
							</tr>
							<tr>
								<th><span class="trim01">Series date</span></th>
								<td>{$params.seriesDate}</td>
							</tr>
							<tr>
								<th><span class="trim01">Series time</span></th>
								<td>{$params.seriesTime}</td>
							</tr>
							<tr>
								<th><span class="trim01">Modality</span></th>
								<td>{$params.modality}</td>
							</tr>
							<tr>
								<th><span class="trim01">Series description</span></th>
								<td>{$params.seriesDescription}</td>
							</tr>
							<tr>
								<th><span class="trim01">Body part</span></th>
								<td>{$params.bodyPart}</td>
							</tr>
							<tr>
								<th><span class="trim01">Image number</span></th>
								<td><span id="sliceNumber">{$detailData.imgNum}</span></td>
							</tr>
							<tr>
								<th><span class="trim01">Slice location</span></th>
								<td><span id="sliceLocation">{$detailData.sliceLocation}</span></td>
							</tr>
						</table>
					</div><!-- / .detail-panel END -->
				</div><!-- / .detailArea END -->
				<div class="fl-clr"></div>
			</div>
			<!-- / CAD detail END -->

			<!-- Tag area -->
			{include file='cad_results/plugin_tag_area.tpl'}

			</form>

			<div class="al-r">
				<p class="pagetop"><a href="#page">page top</a></p>
			</div>
		{/if}
		</div><!-- / .tab-content END -->

		<!-- darkroom button -->
		{include file='darkroom_button.tpl'}


<!-- InstanceEndEditable -->
		</div><!-- / #content END -->
	</div><!-- / #container END -->
</div><!-- / #page END -->

</body>
<!-- InstanceEnd --></html>

