View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports.QuestionsMainView = class QuestionsMainView extends View
	autoRender: true
	template: require 'views/admin/questions-main'
	# idName: 'realm-select'
	events:
	# 	'click #single-player': 'singlePlayer'
		'submit form#create-question': 'createQuestion'

	regions:
		'questions': '#questions'
		'answers': '#answers'

	# singlePlayer: (event) =>
	# 	event.preventDefault()
	# 	@trigger 'single-player'

	createQuestion: (event) =>
		event.preventDefault()
		@trigger 'create-question', @$('#create-question #question-wording').val()
		@$('#create-question #question-wording').val('')
		return false

class QuestionItemView extends View
	template: require 'views/admin/question-item'
	tagName: 'tr'

	events:
		'click': 'click'

	click: =>
		@publishEvent 'select-realm', @model

module.exports.QuestionsView = class QuestionsView extends CollectionView
	autoRender: true
	tagName: 'table'
	className: 'table table-hover table-striped table-bordered'
	template: require 'views/admin/questions-collection'
	itemView: QuestionItemView
	listSelector: 'tbody'


module.exports.AnswersView = class AnswersView extends CollectionView
	autoRender: true
	tagName: 'table'
	className: 'table table-hover table-striped table-bordered'
	template: require 'views/admin/answers-collection'
	itemView: QuestionItemView
	listSelector: 'tbody'
