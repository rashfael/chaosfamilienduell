exports.config =
	# See http://brunch.readthedocs.org/en/latest/config.html for documentation.
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^(?!app)/


		stylesheets:
			joinTo:
				'stylesheets/app.css'

		templates:
			joinTo: 'javascripts/app.js'