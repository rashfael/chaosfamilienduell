util = require 'util'
log4js = require 'log4js'
log = log4js.getLogger 'game'

mediator = require '../mediator'
mongoose = require 'mongoose'
Game = mongoose.model 'Game'

Crud = require './Crud'

# load questions

module.exports = class GameController
	constructor: (@game) ->
		@state = {}
		@questions = require '../../../questions'
		#TODO remove old questions?

		mediator.on '!game:get-running', (cb) =>
			cb null, @game
		mediator.on '!game:perform-action', (action, cb) =>
			log.info 'action:', action
			switch action.action
				when 'new-round'
					action.question = @drawQuestion()
					for team of @state.teams
						team.activeMember = undefined
				when 'activate-member' # a player steps to the buzzer
					@state.teams[action.team].activeMember = action.member
				when 'buzz'
					activeMember = @state.teams[action.team].activeMember
					return unless activeMember?
					# and now what (we dont really have to set the member, follows from the game state)
			@game.actions.push action
			mediator.emit 'game:action-performed', action


		mediator.on '!game:new', (teams, cb) =>
			log.info 'attempting to create new game with teams:', teams
			@game = new Game
				teams: teams
				actions: []

			@state.teams = {}
			for team in teams
				@state.teams[team.name] = team


			@game.save (err) =>
				log.info 'created new game', util.inspect @game.toObject(), {depth: null}
				cb err, @game

		# mediator.on '!game:start', =>

		mediator.on '!game:new-round', =>
			question = drawQuestion()


	drawQuestion: =>
		[question] = @questions.splice Math.floor(Math.random() * @questions.length), 1
		console.log @questions.length
		if @questions.length is 0
			delete require.cache[require.resolve '../../../questions']
			@questions = require '../../../questions'
		return question
