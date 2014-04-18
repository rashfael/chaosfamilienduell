View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'
{Question, Questions, Answer, Answers} = require 'models/question'


module.exports.MainView = class AdminMainView extends View
	autoRender: true
	container: 'body'
	template: require 'views/spectate/main'
	id: 'spectate'
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
		@$el.removeClass 'phase-face-off phase-team phase-new-round'
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

	render: =>
		super
		@$el.hide()

	attach: =>
		super
		@$el.parent().addClass 'noTurn'

	nameChanged: (team, name) =>
		@$('.name').text name	
		@$el.show()

	turnChanged: (team, turn) =>
		if turn
			@$el.parent().addClass 'turn'
			@$el.parent().removeClass 'noTurn'
		else
			@$el.parent().removeClass 'turn'
			@$el.parent().addClass 'noTurn'

	pointsChanged: (team, points) =>
		@$('.points').text points

class AnswerItemView extends View
	template: require 'views/spectate/answer-item'
	tagName: 'tr'

	listen:
		'change:answered model': 'answered'

	answered: (answer, answered) =>
		if answered
			@$el.addClass 'answered'
		else
			@$el.removeClass 'answered'

module.exports.AnswersView = class AnswersView extends CollectionView
	autoRender: true
	template: require 'views/spectate/answers-collection'
	itemView: AnswerItemView
	listSelector: 'tbody'