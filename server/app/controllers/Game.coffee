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
		mediator.on '!game:change-team-name', (data) ->
			mediator.emit 'game:changed-team-name', data

		mediator.on '!game:perform-action', (action, cb) =>
			log.info 'action:', action
			switch action.action
				when 'new-round'
					action.question = @drawQuestion()
					for team of @state.teams
						team.activeMember = undefined
				# when 'buzz'
				# 	# and now what (we dont really have to set the member, follows from the game state)
			@game.actions.push action
			mediator.emit 'game:action-performed', action


		mediator.on '!game:new', (cb) =>
			log.info 'attempting to create new game'
			teams = [
					name: ''
				,
					name: ''
				]
			@game = new Game
				teams: teams
				actions: []

			@state.teams = {}
			@state.round = 0
			for team in teams
				@state.teams[team.name] = team


			@game.save (err) =>
				log.info 'created new game', util.inspect @game.toObject(), {depth: null}
				cb? err, @game
				mediator.emit 'game:started-new'

		# mediator.on '!game:start', =>

		mediator.on '!game:new-round', =>
			question = drawQuestion()
			@state.round++


	drawQuestion: =>
		roundTable = [
			{answers: 7, multiplier: 1}
			{answers: 6, multiplier: 1}
			{answers: 5, multiplier: 1}
			{answers: 4, multiplier: 2}
			{answers: 3, multiplier: 3}
		]
		# get one question with the correct amount of answers
		loopCount = 0
		while true
			i = Math.floor(Math.random() * @questions.length)
			loopCount++
			break if @questions[i].answers.length is roundTable[@state.round].answers or loopCount > 1000
		[question] = @questions.splice i, 1
		console.log @questions.length
		if @questions.length is 0
			delete require.cache[require.resolve '../../../questions']
			@questions = require '../../../questions'
		return question
