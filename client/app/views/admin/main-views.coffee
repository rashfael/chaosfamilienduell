View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'
{Question, Questions, Answer, Answers} = require 'models/question'


module.exports.AdminMainView = class AdminMainView extends View
	autoRender: true
	template: require 'views/admin/main'
	regions:
		team1: '#team-one'
		team2: '#team-two'
		answers: '#answers'

	events:
		'click #new-game': 'requestNewGame'
		'click #new-round': 'requestNewRound'
		'click #face-off': 'requestFaceOff'

	listen:
		'change:round model': 'displayNewRound'
		'change:strikes model': 'displayStrikes'
		'change:phase model': 'phaseChanged'

	requestNewGame: (event) =>
		event.preventDefault()
		@trigger 'new-game'

	requestNewRound: (event) =>
		event.preventDefault()
		@trigger 'new-round'

	requestFaceOff: (event) =>
		event.preventDefault()
		@trigger 'face-off'

	displayNewRound: (game, round) =>
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
		@$('#phase').text phase
		# if phase is 'round-won'
		# 	@$('')


module.exports.AdminGameView = class AdminGameView extends View
	autoRender: true
	template: require 'views/admin/game'


module.exports.TeamView = class TeamView extends View
	autoRender: true
	template: require 'views/admin/team'

	events:
		'submit form': 'changeName'
		'click .fake-buzz': 'fakeBuzz'

	listen:
		'change:name model': 'nameChanged'	
		'change:points model': 'pointsChanged'	

	# listen:
	# 	'change:turn model': 'turn'

	fakeBuzz: (event) ->
		event.preventDefault()
		@trigger 'fake-buzz'

	changeName: (event) =>
		event.preventDefault()
		@trigger 'changeName', @$('.name-field').val()

	nameChanged: (team, name) =>
		@$('.name').text name
		
	pointsChanged: (team, points) =>
		console.log points
		@$('.points').text points

class MemberItemView extends View
	template: require 'views/admin/member-item'
	tagName: 'tr'

	events:
		'click': 'click'

	listen:
		'change:active model': 'activeChanged'

	click: =>
		@publishEvent 'select-member', @model

	activeChanged: (member, active) =>
		if active
			@$el.addClass 'active'
		else
			@$el.removeClass 'active'




module.exports.MembersView = class MembersView extends CollectionView
	autoRender: true
	# tagName: 'table'
	# className: 'table'
	template: require 'views/admin/members-collection'
	itemView: MemberItemView
	listSelector: 'tbody'

	events:
		'click .fake-buzz': 'fakeBuzz'

	listen:
		'change:turn model': 'turn'

	fakeBuzz: (event) ->
		event.preventDefault()
		console.log @$el
		@trigger 'fake-buzz'

	turn: (team, turn) =>
		console.log turn
		if turn
			@$el.parent().addClass 'turn'
		else
			@$el.parent().removeClass 'turn'


class AnswerItemView extends View
	template: require 'views/admin/answer-item'
	tagName: 'tr'

	events:
		'click': 'click'

	listen:
		'change:answered model': 'answered'

	click: =>
		@publishEvent 'select-answer', @model

	answered: (answer, answered) =>
		if answered
			@$el.addClass 'answered'
		else
			@$el.removeClass 'answered'

module.exports.AnswersView = class AnswersView extends CollectionView
	autoRender: true
	template: require 'views/admin/answers-collection'
	itemView: AnswerItemView
	listSelector: 'tbody'

	events:
		'click #wrongAnswer': 'wrongAnswer'
		'click #switchTeam': 'switchTeam'

	wrongAnswer: (event) =>
		event.preventDefault()
		@publishEvent 'select-answer', new Answer
			answer: '_wrong'
			numberOfPeople: 0

	switchTeam: (event) =>
		event.preventDefault()
		@publishEvent 'switch-team'