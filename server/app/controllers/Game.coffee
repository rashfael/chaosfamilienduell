util = require 'util'
log4js = require 'log4js'
log = log4js.getLogger 'game'

mediator = require '../mediator'


fs = require 'fs'
# load questions

module.exports = class GameController
	constructor: () ->
		@savegamename = 'savegame-' + Date.now() + '.json'
		@state = {}
		if process.argv.length is 3
			log.info 'load game'
			@game = require '../../../answers/' + process.argv[2]
		@questions = []
		fs.readdir __dirname + '/../../../answers/', (err,files) =>
			oldQuestions = []
			for file in files
				save = require('../../../answers/' + file)
				continue unless save?.actions?
				for action in save.actions
					continue if not action.question
					oldQuestions.push action.question.question
			log.info oldQuestions
			longestQuestion = ''
			longestAnswer = ''

			for i in [3..7]
				@questions[i] = []
				questions = require '../../../questions/questions_' + i
				for question in questions
					longestQuestion = question.question if question.question.length > longestQuestion.length
					for answer in question.answers
						longestAnswer = answer.answer if answer.answer.length > longestAnswer.length
					question.answers.sort (a, b) -> b.numberOfPeople - a.numberOfPeople
					if question.question in oldQuestions
						log.info 'dropped', question.question
					else
						@questions[i].push question

				if @questions[i].length is 0
					log.fatal 'OUT OF QUESTIONS'

			log.warn 'longestQuestion:', longestQuestion, longestQuestion.length
			log.warn 'longestAnswer:', longestAnswer, longestAnswer.length


			#TODO remove old questions?

			mediator.on '!game:get-running', (cb) =>
				cb null, @game
			mediator.on '!game:change-team-name', (data) =>
				mediator.emit 'game:changed-team-name', data
				@game.teams[data.team-1].name = data.name
				@save()

			mediator.on '!game:perform-action', (action, cb) =>
				log.info 'action:', action
				switch action.action
					when 'new-round'
						action.question = @drawQuestion()
						@game.round++
						for team of @state.teams
							team.activeMember = undefined
					# when 'buzz'
					# 	# and now what (we dont really have to set the member, follows from the game state)
				@game.actions.push action
				mediator.emit 'game:action-performed', action
				@save()

			mediator.on '!game:new', (cb) =>
				log.info 'attempting to create new game'
				@savegamename = 'savegame-' + Date.now() + '.json'
				teams = [
						name: ''
					,
						name: ''
					]
				@game =
					teams: teams
					actions: []

				@state.teams = {}
				@game.round = 0
				for team in teams
					@state.teams[team.name] = team

				@save()
				mediator.emit 'game:started-new'
				# @game.save (err) =>
				# 	log.info 'created new game', util.inspect @game.toObject(), {depth: null}
				cb? err, @game

				if @game?
					mediator.emit 'game:started-new'
				



		# mediator.on '!game:start', =>

	drawQuestion: =>
		console.log 'round:', @game.round
		roundTable = [
			{answers: 7, multiplier: 1}
			{answers: 6, multiplier: 1}
			{answers: 5, multiplier: 1}
			{answers: 4, multiplier: 2}
			{answers: 3, multiplier: 3}
		]
		# get one question with the correct amount of answers
		answers = roundTable[@game.round]?.answers
		if not answers?
			return {question: 'not a question', answers: [], multiplier: 0}
		[question] = @questions[answers].splice Math.floor(Math.random() * @questions[answers].length), 1
		if not question?
			log.fatal 'NO MORE QUESTIONS!'
			return {question: '!!OUT OF QUESTIONS!!',  answers: [], multiplier: 0}

		question.multiplier = roundTable[@game.round].multiplier
		# if @questions.length is 0
		# 	delete require.cache[require.resolve '../../../questions']
		# 	@questions = require '../../../questions'
		return question

	save: =>
		savegame = JSON.stringify @game, null, 4
		fs.writeFile __dirname + '/../../../answers/' + @savegamename, savegame, (err) ->
			log.error err if err?
			log.info 'wrote savegame'
