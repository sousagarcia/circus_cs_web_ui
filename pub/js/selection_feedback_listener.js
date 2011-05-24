/**
 * Feedback Listener for selection.
 */

var circus = circus || {};

circus.evalListener = (function() {
	var global = {
		setup: function ()
		{
			$('.feedback-pane a.radio-to-button').click(function () {
				circus.feedback.change();
			});
		},
		set: function (target, value)
		{
			if (!value) value = {};
			$('.feedback-pane input[type=radio]', target).each(function() {
				if ($(this).val() == value.selection) {
					$(this).click().trigger('flush');
				}
			});
		},
		get: function (target)
		{
			return {
				selection: $('.feedback-pane input[type=radio]:checked', target).val()
			};
		},
		validate: function (target)
		{
			if ($('.feedback-pane input[type=radio]:checked', target).length > 0) {
				return { register_ok: true };
			} else {
				return {
					register_ok: false,
					message: 'Classification: <span class="register-not-ok">Incomplete</span>'
				};
			}
		},
		disable: function (target)
		{
			$('.feedback-pane input[type=radio]', target)
				.attr('disabled', 'disabled')
				.trigger('flush');
		},
		enable: function (target)
		{
			$('.feedback-pane input[type=radio]', target)
				.attr('disabled', '')
				.trigger('flush');
		}
	};
	return global;
})();