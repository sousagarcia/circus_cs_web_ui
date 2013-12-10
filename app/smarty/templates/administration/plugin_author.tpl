{capture name="require"}
jq/ui/jquery-ui.min.js
jq/ui/theme/jquery-ui.custom.css
js/jquery.ruleseteditor.js
css/jquery.ruleseteditor.css
{/capture}
{capture name="extra"}

<script type="text/javascript">
var keys = {$keys|@json_encode};
</script>

{literal}
<style>
#tbl { width: 100%; }
#tbl th { width: 150px; padding: 0.5em 0; }
#tbl td { text-align: left; padding: 0.5em; }
.desc { display: none; }
#filter { width: 700px; }
#help { margin: 1em 0; border: 1px solid silver; border-radius: 3px; padding: 5px 10px; }
#help .title { font-weight: bold; margin: 0.3em 0; }
#help em { font-style: italic; }
#column_list { border: 5px solid #ebbe8c; margin-bottom: 10px; }
#column_list li { margin-left: 5px; cursor: move; }
.column_size { display: none; margin-right: 10px; }
.column_size:after { content: ' bytes'; }

#volume_list { margin: 10px 0 0 5px; }
#volume_list li {
	display: inline-block;
	background-color: silver;
	border-bottom: 2px solid white;
	min-width: 50px;
	text-align: center;
	margin-left: 5px;
	padding: 3px;
	cursor: pointer;
}
#num_volumes { font-weight: bold; }
#volume_list li.active {
	background-color: #ebbe8c;
	border-bottom-color: #ebbe8c;
}
#volume_editor {
	padding: 10px;
	border: 5px solid #ebbe8c;
}
#volume_editor > div {
	margin: 5px 0;
}
dt { font-weight: bold; }
dd { margin-left: 2em; }
#finish { padding: 0.5em 2em; }
#output { display: none; }
#generated_file { display: block; width: 100%; height: 15em; font-family: monospace; }
</style>
<script>
$(function() {

	// FOR TABLE DEFINITION
	var default_columns = [
		{ name: "location_x", type: "smallint", size: 0 },
		{ name: "location_y", type: "smallint", size: 0 },
		{ name: "location_z", type: "smallint", size: 0 },
		{ name: "slice_location", type: "real", size: 0 },
		{ name: "volume_size", type: "real", size: 0 },
		{ name: "confidence", type: "real", size: 0 }
	];

	var column_type = $('<select>').addClass('column_type');
	$.each(['int', 'smallint', 'real', 'boolean', 'text'], function(i, t) {
		$('<option>').attr('value', t).text(t).appendTo(column_type);
	});
	var column_list = $('#column_list').sortable({
		axis: 'y'
	});

	function createColumn(name, type, size) {
		var li = $('<li>');
		$('<input>').attr('type', 'text').addClass('column_name').val(name).appendTo(li);
		column_type.clone().val(type).appendTo(li);
		$('<span>').addClass('column_size').text(size).appendTo(li);
		$('<button>').addClass('form-btn column_delete').text('delete').appendTo(li);
		return li;
	}

	function resetColumns(data) {
		column_list.empty();
		$.each(data, function(i, col) {
			var li = createColumn(col.name, col.type, col.size);
			li.appendTo(column_list);
		});
	}
	resetColumns(default_columns);

	$('#column_add').on('click', function() {
		var li = createColumn('new_field', 'smallint', 0);
		li.appendTo(column_list);
	});

	column_list.on('click', '.column_delete', function(event) {
		if (column_list.find('li').length <= 1) return;
		$(event.currentTarget).closest('li').remove();
	});

	column_list.on('change', '.column_type', function() {
		var t = $(event.target);
		var size = t.siblings('.column_size');
		console.log(size);
		if (t.val() == 'text') {
			var bytes = parseInt(size.text());
			if (bytes == 0) bytes = 128;
			do {
				bytes = parseInt(prompt('Column size?', bytes));
			} while (bytes <= 0);
			size.text(bytes).show();
		} else {
			size.text('0').hide();
		}
	});

	$('#column_default').click(function() { resetColumns(default_columns); });

	// FOR SERIES DEFINITION
	var new_volume = {
		label: 'Untitled',
		ruleset: [
			{
				filter: { group: 'and', members: [{ key: 'modality', condition: '=', value: 'CT'}] },
				rule: { continuous: false }
			}
		]
	};
	var volume_info = [];
	var volume_list = $('#volume_list');
	var active_index = 0;

	var filter = $('#filter').filtereditor({
		keys: keys
	});

	function seriesUpdate() {
		volume_list.empty();
		$.each(volume_info, function(idx, vol) {
			var txt = '#' + idx + ': ' + vol.label;
			$('<li>').text(txt).appendTo(volume_list);
		});
		$('#num_volumes').text(volume_info.length);
		seriesActivate(Math.min(active_index, volume_info.length - 1));
	}

	function seriesActivate(index) {
		volume_list.find('li').removeClass('active');
		volume_list.find('li').eq(index).addClass('active');
		var vol = volume_info[index];
		active_index = index;
		$('#label').val(vol.label);
		filter.filtereditor('option', 'filter', vol.ruleset[0].filter);
		$('#continuous').prop('checked', !!vol.ruleset[0].rule.continuous);
	}

	function addVolume() {
		var vol = $.extend(true, {}, new_volume);
		vol.volumeID = volume_info.length;
		volume_info.push(vol);
		seriesUpdate();
		seriesActivate(volume_info.length - 1);
	}

	addVolume(); // for the first volume (id = 0)

	volume_list.on('click', 'li', function(event) {
		var index = volume_list.find('li').index($(event.currentTarget));
		seriesActivate(index);
	});

	$('#volume_add').on('click', addVolume);

	$('#volume_delete').on('click', function() {
		if (volume_info.length <= 1) return;
		volume_info.pop();
		seriesUpdate();
	});

	filter.on('filterchange', function() {
		volume_info[active_index].ruleset[0].filter = filter.filtereditor('option', 'filter');
	});
	$('#label').on('keyup input', function() {
		volume_info[active_index].label = $('#label').val();
		seriesUpdate();
	});
	$('#continuous').on('change', function() {
		var rule = { continuous: $('#continuous').prop('checked') };
		volume_info[active_index].rule = rule;
	});

	// HELP
	$('table').on('focusin mousedown', 'td', function(event) {
		var td = $(event.currentTarget);
		var desc = $('.desc', td);
		var title = td.prev('th').text();
		var help = $('#help');
		help.empty();
		$('<div>').addClass('title themeColor').text(title).appendTo(help);
		desc.clone().show().appendTo(help);
	});

	// FINISH
	$('#finish').on('click', function() {
		var result = {
			pluginName: $('#pluginName').val(),
			version: $('#version').val(),
			pluginType: $('input[name="pluginType"]:checked').val(),
			architecture: $('input[name="architecture"]:checked').val(),
			desctiption: $('#description').val(),
			cadDefinition: {
				inputType: $('input[name="inputType"]:checked').val(),
				resultType: $('input[name="resultType"]:checked').val(),
				timeLimit: parseInt($('#timeLimit').val())
			}
		};

		result.seriesDefinition = volume_info;

		result.resultTable = $.map(column_list.find('li').get(), function(col) {
			return {
				name: $('.column_name', col).val(),
				type: $('.column_type', col).val(),
				size: parseInt($('.column_size', col).text())
			};
		});

		var txt = JSON.stringify(result, null, "\t");
		$('#generated_file').val(txt);
		$('#output').dialog({
			width: 800,
			modal: true,
			autoOpen: true,
			open: function() { $('#generated_file').select(); }
		});
	});
});
</script>
{/literal}
{/capture}
{include file="header.tpl"
	require=$smarty.capture.require
	head_extra=$smarty.capture.extra body_class="spot"}

<h2><div class="breadcrumb"><a href="administration.php">Administration</a> &gt;</div>
Plugin definition file (plugin.json) builder</h2>

<table class="col-tbl" id="tbl">
	<tbody>
		<tr>
			<th>Plugin Name</th>
			<td>
				<input type="text" id="pluginName" value="My-CAD" />
				<div class="desc">
					Name of the plugin (eg. "MRA-CAD", "Pancreas-Extractor").
				</div>
			</td>
		</tr>
		<tr>
			<th>Plugin Version</th>
			<td>
				<input type="text" id="version" value="1.0" />
				<div class="desc">
					Version of the plugin (eg. "1.0", "2.1.1").
				</div>
			</td>
		</tr>
		<tr>
			<th>Plugin Type</th>
			<td>
				<label>
					<input type="radio" name="pluginType" value="1" checked="checked" />CAD
				</label>
				<div class="desc">Currently, only "CAD" type plug-in is supported.</div>
			</td>
		</tr>
		<tr>
			<th>Architecture</th>
			<td>
				<label>
					<input type="radio" name="architecture" value="x86" />x86
				</label>
				<label>
					<input type="radio" name="architecture" value="x64" checked="checked" />x64
				</label>
				<label>
					<input type="radio" name="architecture" value="x86/x64" />x86/x64
				</label>
				<div class="desc">
					Plug-in architecture.
				</div>
			</td>
		</tr>
		<tr>
			<th>Description</th>
			<td>
				<input type="text" id="description" style="width: 300px;" value="My CAD." />
				<div class="desc">
					Short description of this plug-in. (eg. "Detects lung nodules using FooBar method.")
				</div>
			</td>
		</tr>
		<tr>
			<th>Input Type</th>
			<td>
				<label>
					<input type="radio" name="inputType" value="1" checked="checked" />Single series
				</label>
				<label>
					<input type="radio" name="inputType" value="2" />Single study
				</label>
				<label>
					<input type="radio" name="inputType" value="3" />All study within patient
				</label>
				<div class="desc">
					Scope of the series which this plug-in can process.
				</div>
			</td>
		</tr>
		<tr>
			<th>Result Type</th>
			<td>
				<label>
					<input type="radio" name="resultType" value="1" checked="checked" />Lesion detection CAD
				</label>
				<label>
					<input type="radio" name="resultType" value="2" />Other CAD
				</label>
				<div class="desc">
					<p>Select the type of the CAD.</p>
					<p><em>This settings is deprecated and will be removed in the future release.</em></p>
				</div>
			</td>
		</tr>
		<tr>
			<th>Time Limit</th>
			<td>
				<label><input type="text" id="timeLimit" value="300" style="text-align: right; width: 100px" /> sec.</label>
				<div class="desc">
					CAD execution time limit, specified in seconds.
				</div>
			</td>
		</tr>
		<tr>
			<th>Table Definition</th>
			<td>
				<ol id="column_list">
				</ol>
				<div>
					<input type="button" class="form-btn" id="column_add" value="add column">
					<input type="button" class="form-btn" id="column_default" value="Call default for LesionCandDisplayPresenter">
				</div>
				<div class="desc">
					<p>This section defines how your CAD results are saved in the database.
					Some display presenters require specific combination of columns.</p>
					<p>The CAD executables must output the CAD results as a CSV file,
					in the order defined here.</p>
				</div>
			</td>
		</tr>
		<tr>
			<th>Input Volume Ruleset</th>
			<td>
				<div>
					Number of input volumes: <span id="num_volumes"></span>
					<input type="button" id="volume_add" class="form-btn" value="add" />
					<input type="button" id="volume_delete" class="form-btn" value="delete" />
				</div>
				<ul id="volume_list">
				</ul>
				<div id="volume_editor">
					<label>Volume label: <input type="text" id="label"></label>
					<div>Condition:</div>
					<div id="filter"></div>
					<label><input type="checkbox" id="continuous">Continuous</label>
				</div>
				<div class="desc">
					This section defines the number of input volumes (series),
					and minimum requirement of the series.
					<dl>
						<dt>Volume label</dt>
						<dd>Short description of each volume (eg. "arterial phase", "sagittal", "MRI")</dd>
						<dt>Condition</dt>
						<dd>Determine the minimum requirement each input volume must meet.</dd>
						<dt>Continuous</dt>
						<dd>If checked, </dd>
					</dl>
				</div>
			</td>
		</tr>
	<tbody>
</table>
<div style="margin: 10px; text-align: right">
	<input type="button" class="form-btn" id="finish" value="finish and show generated plug-in definition file" />
</div>

<div id="output" title="Result">
<p>Generated plug-in definition (plugin.json) file:</p>
<textarea id="generated_file" readonly="readonly"></textarea>
</div>

<div id="help">Help
</div>

{include file="footer.tpl"}