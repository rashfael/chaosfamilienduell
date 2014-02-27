# this module manages all the talky stuff between rest, ws, irc and db, and fires events
# it is a singelton, require will give you the global instance
{EventEmitter} = require 'events'


class Mediator extends EventEmitter
	constructor: ->
		#

	init: (io) =>
		
		@io = io
		io.sockets.on 'connection', (socket) =>
			# inject
			$emit = socket.$emit
			socket.$emit = =>
				#args = Array.prototype.slice.call arguments
				EventEmitter::emit.apply @, arguments
				$emit.apply socket, arguments

	emit: ->
		super
		@io.sockets.emit.apply @io.sockets, arguments

module.exports = new Mediator()