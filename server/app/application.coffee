log4js = require 'log4js'
logger = log4js.getLogger 'cfd'
logger.setLevel if process.isTest then 'FATAL' else 'INFO'

path = require 'path'
fs = require 'fs'


clientPublic = path.normalize __dirname + '/../../client/public'

express = require 'express'

# config = require '../server_config'
mediator = require './mediator'

app = module.exports = express()

# Load db stuff

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/chaosfamilienduell'
global.mongoose = mongoose

Project = mongoose.model 'Game', require('./schemas/Game'), 'games'


# Server config

app.configure ->
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser 'ponies'
	app.use express.session()
	# app.use log4js.connectLogger log4js.getLogger 'my-project-access'
	app.use express.static clientPublic
	app.use app.router

app.configure 'development', ->
	app.use express.errorHandler {dumpExceptions: true, showStack:true }

app.configure 'production', ->
	app.use express.errorHandler()

# admin routers
# ModelRouter = require './routers/Model'


# cheap user list
users =
	root:
		username: 'root'
		password: 'password'

app.post '/authenticate', (req, res) ->
	if req.body.user?
		user = users[req.body.user.username]
		if user? and user.password = req.body.user.password
			return res.json user
		res.send 404
	else
		if req.session?.user?
			return req.session.user
		res.send 401

# Catch all other requests and deliver client files.
app.get '*', (req, res) ->
	res.sendfile path.join clientPublic, 'index.html'

server = app.listen 9000, ->
	logger.info "Express server listening on port %d in %s mode", 9000, app.settings.env

io = require('socket.io').listen server
mediator.init io

game = new (require './controllers/Game')

# io.sockets.on 'message', (msg) ->
# 	console.log 'message', msg

# io.sockets.on 'connection', (socket) ->
# 	# inject mediator
# 	$emit = socket.$emit
# 	socket.$emit = ->
# 		#args = Array.prototype.slice.call arguments
# 		mediator.emit.apply mediator, arguments
# 		$emit.apply socket, arguments
# # 	new IoRouter socket