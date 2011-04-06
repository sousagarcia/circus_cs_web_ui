<script language="javascript" type="text/javascript" src="{$params.toTopDir}js/swfobject.js"></script>

<script type="text/javascript">
	swfobject.registerObject("today_{$smarty.session.colorSet}", "8.0.0");
</script>

<h1><a id="linkAbout" href="{$params.toTopDir}about.php"><img src="{$params.toTopDir}img_common/share/logo.jpg" width="208" height="63" alt="CIRCUS" /></a></h1>
<div id="menu">
	<ul>
		<li><a href="{$params.toTopDir}home.php" class="jq-btn jq-btn-home" title="home"></a></li>
		<li>
			<a id="linkTodayDisp" href="{$params.toTopDir}{if $smarty.session.todayDisp=='series'}series_list{else}cad_log{/if}.php?mode=today" class="jq-btn jq-btn-today" title="today">
				<!-- Calendar display -->
				<div class="calendar">
					<object id="today" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="32" height="32" id="" align="middle">
						<param name="allowScriptAccess" value="sameDomain" />
						<param name="movie" value="{$params.toTopDir}{$smarty.session.colorSet}.swf" />
						<param name="quality" value="high" />
						<param name="wmode" value="transparent" />
						<param name="bgcolor" value="#81392f" />
						<!--[if !IE]>-->
						<object type="application/x-shockwave-flash" data="{$params.toTopDir}{$smarty.session.colorSet}.swf" quality="high" wmode="transparent" bgcolor="#81392f" width="32" height="32" name="" align="middle" allowScriptAccess="sameDomain">
						<!--<![endif]-->
						<div>
							<img src="{$params.toTopDir}img_common/item/today_{$smarty.session.colorSet}.jpg" width="32" height="32" />
						</div>
						<!--[if !IE]>-->
						</object>
						<!--<![endif]-->
					</object>
				</div>
			</a>
		</li>
		<li><a href="{$params.toTopDir}search.php" class="jq-btn jq-btn-search" title="search"></a></li>
		<li class="hide-on-guest"><a id="linkStatistics" href="{$params.toTopDir}personal_statistics.php" class="jq-btn jq-btn-statistics" title="statistics"></a></li>

		{if $smarty.session.researchShowFlg==1 || $smarty.session.researchExecFlg==1}
			<li><a href="{$params.toTopDir}research/research_list.php" class="jq-btn jq-btn-research" title="research"></a></li>
		{/if}
	</ul>
	<p class="user">User: {$smarty.session.userID}</p>
	<ul>
		<li><a href="{$params.toTopDir}user_preference.php" class="jq-btn jq-btn-preference" title="preference"></a></li>
{*		<li><a href="#" class="jq-btn jq-btn-favorites" title="favorites"></a></li> *}
		{if $smarty.session.serverOperationFlg==1 || $smarty.session.serverSettingsFlg==1}
			<li><a href="{$params.toTopDir}administration/administration.php" class="jq-btn jq-btn-administration" title="administration"></a></li>
		{/if}
		<li><a href="{$params.toTopDir}index.php?mode=logout" class="jq-btn jq-btn-logout" title="logout"></a></li>
	</ul>

</div>
<!-- / #menu END -->
