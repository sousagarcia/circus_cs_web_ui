{*
CIRCUS CS Template
Block layout template.

This template lays out the blocks of CAD results.
By default, each block is displayed as inline-block and
inserted into one div element.
Individual plugins can override this template for custom layouts.
*}
<div class="result-blocks" id="result-blocks">
{foreach from=$displays item=display}
{include file="block.tpl}
{/foreach}
</div>