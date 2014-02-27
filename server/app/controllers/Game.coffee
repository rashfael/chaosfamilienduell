mediator = require '../mediator'
mongoose = require 'mongoose'
Game = mongoose.model 'Game'

Crud = require './Crud'

# load questions
questions = require '../../../questions'

module.exports = class GameController
	constructor: (@game) ->
		mediator.on '!game:get-running', (cb) =>
			cb null, @game
		mediator.on '!game:perform-action', (action, cb) =>
			@game.actions.push action
			mediator.emit 'game:action-performed', action


		mediator.on '!game:new-game', (teams, cb) =>
			@game = new Game
				teams: teams
				actions: []

			@game.save (err) =>
				cb err, @game