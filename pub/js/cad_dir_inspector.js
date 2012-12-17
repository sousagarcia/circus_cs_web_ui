(function() {
	var self;
	var main;

	function listHandler(data)
	{
		main.empty();
		for (var i = 0; i < data.length; i++)
		{
			var entry = data[i];
			var div = $('<div>').addClass('job-file-entry');
			var a = $('<a>').text(entry.link).attr('href', entry.url);
			$('<span>').addClass('job-file-name').append(a).appendTo(div);
			$('<span>').addClass('job-file-size').text('(' + entry.size + ' bytes)').appendTo(div);
			div.appendTo(main);
		}
	}

	function errorHandler(message)
	{
		var p = $('<p>').addClass('error').text(message);
		main.empty().append(p);
	}

	function preview(row)
	{
		var url = $('.job-file-name a', row).attr('href');
		var div = $('<div>').addClass('job-file-preview').appendTo(row);
		var m;
		if (url.match(/\.(jpe?g|png|gif)$/i))
		{
			$('<img>').addClass('job-file-thumbnail').attr('src', url).appendTo(div);
		}
		else if (m = url.match(/\.(mp4|m4v|flv)$/i))
		{
			var ext = m[1].toLowerCase();
			if (ext == 'mp4') ext = 'm4v';
			var media = {};
			media[ext] = url;
			$('<div>').appendTo(div).jPlayer({
				swfPath: circus.toTop + 'jq',
				supplied: ext,
				width: '320px',
				nativeVideoControls: { all: /./ },
				ready: function() {
					$(this).jPlayer('setMedia', media).jPlayer('play');
				}
			});
		}
		else if (url.match(/\.(txt|csv)$/i))
		{
			var t = $('<textarea>').appendTo(div);
			$.ajax({
				url: url,
				dataType: 'text',
				type: 'GET',
				cache: false,
				success: function (data) { t.text(data); }
			});
		}
	}

	function clickHandler(event)
	{
		var target = $(event.target);
		if (!target.is('.job-file-entry,.job-file-preview')) return;
		var row = target.closest('.job-file-entry');
		if (row.is('.job-file-expanded'))
		{
			row.removeClass('job-file-expanded');
			row.find('.job-file-preview').remove();
		}
		else
		{
			row.addClass('job-file-expanded');
			preview(row);
		}
	}

	function init()
	{
		self.empty();
		main = $('<div>').addClass('job-file-list').appendTo(self);
		main.click(clickHandler);
	}

	var fn = function(filesMatch, substitutes) {
		self = this;
		init();
		if (!substitutes) substitutes = [];
		$.webapi({
			action: 'inspectJobDirectory',
			params: {
				jobID: circus.jobID,
				filesMatch: filesMatch,
				substitutes: substitutes
			},
			onSuccess: listHandler,
			onFail: errorHandler
		});
	};

	$.fn.cadDirInspector = fn;
})();