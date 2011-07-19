{capture name="extra"}
<script type="text/javascript">;
var adminModeFlg = {$adminModeFlg};
{literal}
$(function() {
	if (adminModeFlg) {
		$('#administration').show();
		$('#smoke').hide();
	}
	else
	{
		$(window).load(function () {
			if (confirm('Do you want to enter administration mode?'))
			{
				$('#administration').show();
				$('#smoke').hide();
				$.get('administration.php', { open: 1 });
			}
			else
			{
				window.location = '../home.php';
			}
		});
	}
})
-->
</script>

<style type="text/css">
#content table td { padding: 0.5em; }
#content h3 { margin-top: 1em; }
.form-btn { width: 100px; }
</style>

{/literal}
{/capture}

{include file="header.tpl" head_extra=$smarty.capture.extra body_class="spot"}

<div id="smoke"></div>

<div id="administration" style="display: none">
<form onsubmit="return false;">
<input type="hidden" id="ticket" value="{$params.ticket|escape}" />

<h2>Administration</h2>

<h3>Server settings</h3>
<table>
	{if $smarty.session.serverSettingsFlg==1}
	<tr>
		<td>DICOM storage server</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='dicom_storage_server_config.php';" />
		</td>
	</tr>
	<tr>
		<td>Data storages</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='data_storage_config.php';"/>
		</td>
	</tr>
	<tr>
		<td>Add plug-in from packaged file</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='add_plugin.php';" />
		</td>
	</tr>

	<tr>
		<td>Basic configuration for plug-ins</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='plugin_basic_configuration.php';">
		</td>
	</tr>

	<tr>
		<td>Cofiguration for CAD result policies</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='result_policy_config.php';">
		</td>
	</tr>
	{/if}

	<tr>
		<td>Users</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='user_config.php';" />
		</td>
	</tr>

	{if $smarty.session.serverSettingsFlg==1}
	<tr>
		<td>Groups</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='group_config.php';" />
		</td>
	</tr>
	{/if}

	<tr>
		<td>Server service</td>
		<td>
			<input type="button" value="config" class="form-btn"
				onclick="location.href='server_service_config.php';" />
		</td>
	</tr>

	<tr>
		<td>Server logs</td>
		<td>
			<input type="button" value="show" class="form-btn"
				onclick="location.href='server_logs.php';" />
		</td>
	</tr>
</table>

<h3>Plug-in jobs</h3>
<table>
	<tr>
		<td>Show plug-in job queue</td>
		<td>
			<input type="button" value="show" class="form-btn"
				onclick="location.href='show_job_queue.php';" />
		</td>
	</tr>
</table>

</div>
</form>
<img class="loading" width="15" height="15" src="../images/busy.gif" style="display: none" />
{include file="footer.tpl"}
