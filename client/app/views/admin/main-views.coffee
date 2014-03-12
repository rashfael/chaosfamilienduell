View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports.AdminMainView = class AdminMainView extends View
	autoRender: true
	template: require 'views/admin/main'
	regions:
		game: '#game'
		team1: '#team-one'
		team2: '#team-two'
		answers: '#answers'

	events:
		'click #new-round': 'requestNewRound'

	listen:
		'change:round model': 'displayNewRound'

	requestNewRound: (event) =>
		event.preventDefault()
		@trigger 'new-round'

	displayNewRound: (game, round) =>
		@$('#question h1').text round.get('question').question
		console.log round.get 'answers'
		@subview 'answers', new AnswersView
			region: 'answers'
			collection: round.get 'answers'

module.exports.AdminGameView = class AdminGameView extends View
	autoRender: true
	template: require 'views/admin/game'

class MemberItemView extends View
	template: require 'views/admin/member-item'
	tagName: 'tr'

	events:
		'click': 'click'

	listen:
		'change:active model': 'active'

	click: =>
		@publishEvent 'select-member', @model

	active: (member, active) =>
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

	# events:
	# 	'click': 'click'

	# listen:
	# 	'change:active model': 'active'

	# click: =>
	# 	@publishEvent 'select-member', @model

	# active: (member, active) =>
	# 	if active
	# 		@$el.addClass 'active'
	# 	else
	# 		@$el.removeClass 'active'

module.exports.AnswersView = class AnswersView extends CollectionView
	autoRender: true
	tagName: 'table'
	className: 'table'
	template: require 'views/admin/answers-collection'
	itemView: AnswerItemView
	listSelector: 'tbody'