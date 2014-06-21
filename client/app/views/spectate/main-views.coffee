View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'
{Question, Questions, Answer, Answers} = require 'models/question'


module.exports.MainView = class AdminMainView extends View
	autoRender: true
	container: 'body'
	template: require 'views/spectate/main'
	id: 'spectate'
	className: 'phase-splash'
	regions:
		game: '#game'
		team1: '#team-one'
		team2: '#team-two'
		answers: '#answers'

	listen:
		'change:round model': 'displayNewRound'
		'change:strikes model': 'displayStrikes'
		'change:phase model': 'phaseChanged'

	displayNewRound: (game, round) =>
		@$('#title').hide()
		@$('#question h1').text round.get('question').question
		console.log round.get 'answers'
		@subview 'answers', new AnswersView
			region: 'answers'
			collection: round.get 'answers'

	displayStrikes: (state, strikes) =>
		if strikes is 0
			@$('.strike').removeClass 'on'
			return
		for i in [1..strikes]
			@$(".strike:nth-child(#{i})").addClass 'on'
		if strikes < 3
			for i in [(strikes+1)..3] 
				@$(".strike:nth-child(#{i})").removeClass 'on'

	phaseChanged: (state, phase) =>
		# unset ALL
		@$el.removeClass 'phase-splash phase-face-off phase-team phase-new-round phase-team-steal phase-team-steal-attempt phase-team-steal-fail phase-team-steal-success phase-round-won'
		@$el.addClass 'phase-' + phase
		# if phase is 'round-won'
		# 	@$('')

module.exports.TeamView = class TeamView extends View
	autoRender: true
	template: require 'views/spectate/team'
	listen:
		'change:name model': 'nameChanged'
		'change:turn model': 'turnChanged'
		'change:points model': 'pointsChanged'
		'change:win model': 'winChanged'

	render: =>
		super
		# @$el.hide()

	attach: =>
		super

	nameChanged: (team, name) =>
		@$('.name').text name	
		# @$el.show()

	turnChanged: (team, turn) =>

		if turn
			@$el.parent().addClass 'turn'
			@$el.parent().removeClass 'noTurn'
		else if turn?
			@$el.parent().removeClass 'turn'
			@$el.parent().addClass 'noTurn'
		else
			@$el.parent().removeClass 'turn noTurn'

	winChanged: (team, win) =>
		console.log 'winwin'
		if win
			@$el.parent().addClass 'win'

	pointsChanged: (team, points) =>
		@$('.points').text points

class AnswerItemView extends View
	answerMaxLength = 27
	template: require 'views/spectate/answer-item'
	tagName: 'tr'

	listen:
		'change:answered model': 'answered'

	initialize: ->
		super
		@text = Array(answerMaxLength).join 'X'

	render: =>
		super
		@$('.text').html @text

	answered: (answer, answered) =>
		return unless @$el?
		answerText = @model.get 'answer'
		if answered
			@$el.addClass 'answered'
			char = 0
			interval = setInterval =>
				return unless @$el?
				if char < answerMaxLength-1
					if char < answerText.length
						@$('.text').html answerText[0..char] + @text[char+1..answerMaxLength-2]
					else
						spaces = ''
						spaces += '&nbsp;' for i in [answerText.length..char]
						@$('.text').html answerText + spaces + @text[char+1..answerMaxLength-2]
					char++
				else
					clearInterval interval
					numText = ''+@model.get('numberOfPeople')
					num = 0
					
					numInterval = setInterval =>
						if num <= 1
							if num is 0
								@$('.numberOfPeople').html 'X' + numText[0]
							else
									@$('.numberOfPeople').html numText
						else
							clearInterval numInterval
						num++
					, 100
					

			, 55
		else
			@$el.removeClass 'answered'

module.exports.AnswersView = class AnswersView extends CollectionView
	autoRender: true
	template: require 'views/spectate/answers-collection'
	itemView: AnswerItemView
	listSelector: 'tbody'