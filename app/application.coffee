mediator = require 'mediator'
AuthenticationController = require 'controllers/authentication_controller'
HeaderController = require 'controllers/header_controller'
FooterController = require 'controllers/footer_controller'

require 'lib/iosync'


# The application object.
module.exports = class Application extends Chaplin.Application
	serverUrl: location.protocol + "//" + location.host + "/web"
	start: =>
		# You can fetch some data here and start app
		# (by calling `super`) after that.
		# @initSocket ->
		super
		@initControllers()
		

	# Instantiate common controllers
	# ------------------------------
	initControllers: ->
		# These controllers are active during the whole application runtime.
		# You don’t need to instantiate all controllers here, only special
		# controllers which do not to respond to routes. They may govern models
		# and views which are needed the whole time, for example header, footer
		# or navigation views.
		# e.g. new NavigationController()
		new HeaderController()
		new FooterController()

	# Create additional mediator properties
	# -------------------------------------
	# initMediator: ->
	# 	# Create a user property
	# 	# Chaplin.mediator.user = null
	# 	# Add additional application-specific properties and methods
	# 	# Seal the mediator
	# 	# Chaplin.mediator.seal()

	initSocket: (cb) =>
		socket = io.connect @serverUrl
		# Backbone.socket = socket
		# emit = socket.emit
		# socket.emit = function() {
		# 	args = Array.prototype.slice.call arguments
		# 	console.log('***','emit', Array.prototype.slice.call(arguments));
		# 	emit.apply socket, arguments
		# };
		$emit = socket.$emit
		socket.$emit = () ->
			args = Array.prototype.slice.call arguments
			mediator.publish "!io:#{args[0]}", args[1..]...
			$emit.apply socket, arguments

		mediator.subscribe '!io:emit', () ->
			args = Array.prototype.slice.call arguments
			console.info 'Server call: ' + args[0], (arg for arg in args[1..] when typeof arg isnt 'function')...
			socket.emit.apply socket, args, args

		socket.on 'connect', cb

		socket.on 'error', (err) ->
			console.error 'SocketIO error', err
