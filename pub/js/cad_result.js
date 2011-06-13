/**
 * cad_result.js
 * Used in the cad_result.php page.
 */

var circus = circus || {};

circus.feedback = function() {
	var global = {
		initialize: function() {
			var idata = circus.feedback.initdata;
			$('.result-block').each(function() {
				var block = this;
				var id = $("input.display-id", block).val();
				$(block).data('displayid', id);
				if (idata && idata.blockFeedback instanceof Object)
					circus.evalListener.set(block, idata.blockFeedback[id]);
			});
			if (circus.feedback.additional instanceof Array)
			{
				$.each(circus.feedback.additional, function(key, additional) {
					if (idata && idata.additionalFeedback)
						data = idata.additionalFeedback[additional.name];
					else
						data = null;
					additional.initialize(data);
				});
			}
		},
		collect: function() {
			var blockFeedback = {};
			var additionalFeedback = {};
			$('.result-block').each(function() {
				var block = this;
				var id = $(block).data('displayid');
				blockFeedback[id] = circus.evalListener.get(block);
			});
			$.each(circus.feedback.additional, function (name, afb) {
				additionalFeedback[afb.name] = afb.collect();
			});
			return {
				blockFeedback: blockFeedback,
				additionalFeedback: additionalFeedback
			};
		},
		disable: function () {
			$('.result-block').each(function () {
				circus.evalListener.disable(this);
			});
		},
		enable: function () {
			$('.result-block').each(function () {
				circus.evalListener.enable(this);
			})
		},
		register_ok: function() {
			if (circus.feedback.feedbackStatus != 'normal')
				return { register_ok: false, messages: [] }
			var register_ok = true;
			var messages = [];
			var caption = circus.cadresult.presentation.displayPresenter.caption;
			$('.result-block').each(function() {
				var block = this;
				var id = $(block).data('displayid');
				var tmp = circus.evalListener.validate(block);
				if (!tmp.register_ok) {
					register_ok = false;
					if (tmp.message)
					{
						var mes = caption + ': <span class="register-not-ok">' + tmp.message + '</span>';
						if (messages.indexOf(mes) == -1)
						messages.push(mes);
					}
				}
			});
			if (register_ok)
				messages.push(caption + ': <span class="register-ok">Complete</span>');
			if (circus.feedback.additional instanceof Array) {
				var ad = circus.feedback.additional;
				for (var i = 0; i < ad.length; i++) {
					var tmp = ad[i].validate();
					if (!tmp.register_ok) {
						register_ok = false;
					}
					if (tmp.message && messages.indexOf(tmp.message) == -1)
						messages.push(tmp.message);
				}
			}
			return { register_ok: register_ok, messages: messages };
		},
		change: function() {
			var ok = circus.feedback.register_ok();
			if (ok.register_ok === true) {
				$('#register').attr('disabled', '').trigger('flush');
				var data = circus.feedback.collect();
				$('#result').val(JSON.stringify(data));
			} else {
				$('#register').attr('disabled', 'disabled').trigger('flush');
			}
			$('#register-error').empty();
			$.each(ok.messages, function (index, msg) {
				$('<li>').html(msg).appendTo('#register-error');
			})
		},
		register: function() {
			var feedback = circus.feedback.collect();
			if (console && console.log) console.log(feedback);
			$.post("register_feedback.php",
				{
					jobID: $("#job-id").val(),
					feedbackMode: circus.feedback.feedbackMode,
					feedback: JSON.stringify(feedback)
				},
				function (result)
				{
					var obj = JSON.parse(result)
					if (obj)
					{
						if (obj.status == 'OK')
							location.reload(true);
						else
							alert("Error while registering feedback:\n" + obj.error.message);
					}
					else
						alert("System Error:\n" + result);
				},
				"text"
			);
		}
	};
	return global;
}();

circus.cadresult = function() {
	var global = {
		sortBlocks: function(key, order) {
			var data = circus.cadresult.displays;
			var sorted = $('#result-blocks .result-block').sort(function(a,b){
				var aid = $(a).data('displayid');
				var bid = $(b).data('displayid');
				var tmp = data[aid][key] - data[bid][key];
				return order == 'desc' ? -tmp : tmp;
			});
			$.each(sorted, function(index, item){
				$('#result-blocks').append(item);
			});
		},
		showTab: function(index) {
			$('.tab-content > div').hide();
			$('.tab-content > div:nth-child(' + (index+1) + ')').show();
			$('.tabArea a').removeClass('btn-tab-active');
			$('.tabArea ul li:nth-child(' + (index+1) + ') a').addClass('btn-tab-active');
		},
		showTabLabel: function(label) {
			$('.tabArea a').each(function () {
				if ($(this).text() == label) {
					circus.cadresult.showTab($('.tabArea a').index($(this)));
				}
			});
		}
	};
	return global;
}();


$(function(){
	// Initialize the evaluator status.
	circus.feedback.initialize();
	circus.evalListener.setup();
	circus.feedback.change();
	if (circus.feedback.feedbackStatus == 'disabled')
	{
		circus.feedback.disable();
	}

	$('#register').click(circus.feedback.register);

	$('.tabArea a').click(function(event) {
		var target = $(event.target);
		var index = $('.tabArea a').index(target);
		circus.cadresult.showTab(index);
	});

	$('#mode-form input[name=feedbackMode]')
		.val([circus.feedback.feedbackMode])
		.trigger('flush');
	$('#mode-form a.radio-to-button-l').click(function() {
		var mode = $('#mode-form input[name=feedbackMode]:checked').val();
		if (mode != circus.feedback.feedbackMode)
			$('#mode-form').submit();
	});

	if (circus.feedback.consensualFeedbackAvail != 'locked')
	{
		$('#consensual-mode').removeAttr('disabled').trigger('flush');
	}

});