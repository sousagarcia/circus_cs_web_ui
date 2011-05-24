<div class="cad-detail-content">

<h2>CAD Detail [{$cadResult->Plugin->plugin_name|escape}&nbsp;
  v.{$cadResult->Plugin->version|escape} ID:{$cadResult->job_id}]</h2>
<div class="headerArea">
	{$series->Study->Patient->patient_name|escape} ({$series->Study->Patient->patient_id})
	{$series->Study->Patient->age()}{$series->Study->Patient->sex} /
	{$series->Study->study_date} ({$series->Study->study_id}) /
	{$series->Study->modality|escape}, {$series->series_description|escape} ({$series->series_number})
</div>

<div id="cad-detail-viewer-container">
  <div id="cad-detail-viewer"></div>
</div>
<div id="cad-detail-table">
	{* <p style="margin:0px 0px 3px 10px;">{$detailParams.sortStr}</p> *}
	<div style="overflow-y:scroll; overflow-x:hidden; width: 330px; height: 400px;">
		<table id="posTable" class="col-tbl">
			<thead>
				<tr>
					<th>ID</th>
					<th>Pos X</th>
					<th>Pos Y</th>
					<th>Pos Z</th>
					<th style="width:4em;">Volume [mm3]</th>
					<th>Confidence</th>
					<th>Tag</th>
				</tr>
			</thead>
			<tbody>
				{foreach from=$displays item=display name=detailData}
				<tr class="{if $smarty.foreach.detailData.index%2==1}column{/if}{$item[9]}">
					<td class="id">{$display.display_id|escape}</td>
					<td class="x">{$display.location_x|escape}</td>
					<td class="y">{$display.location_y|escape}</td>
					<td class="z">{$display.location_z|escape}</td>
					<td class="volume">{$display.volume_size|string_format:"%.1f"|escape}</td>
					<td class="confidence">{$display.confidence|string_format:"%.3f"|escape}</td>
					<td class="tagColumn">
						<input id="tagBtn{$display.display_id|escape}" type="button" value="tag" class="s-btn form-btn"
							    onclick="EditTag(5, '{$item[0]|escape}', '../')" title="{$item[8]|escape}" />
					</td>
				</tr>
				{/foreach}
			</tbody>
		</table>
	</div>
</div>
</div>