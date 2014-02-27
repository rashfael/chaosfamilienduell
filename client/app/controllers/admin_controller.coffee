mediator = require 'mediator'
Controller = require 'controllers/base/controller'
Header = require 'models/header'
HeaderView = require 'views/header_view'
{Game, games} = require 'models/game'
{Question, Questions} = require 'models/question'
{QuestionsMainView, QuestionsView, AnswersView} = require 'views/admin/question_views'
{AdminMainView} = require 'views/admin/main-views'
NewGameView = require 'views/admin/new-game-view'
module.exports = class AdminController extends Controller
	beforeAction: ->
		super
		headerModel = new Header()
		@reuse 'header', HeaderView,
			region: 'header'
			model: headerModel

	# historyURL: 'users'
	# index: ->
		# questions = new Questions()
		# questions.fetch
		# 	data:
		# 		options:
		# 			sort:
		# 				status: 1
		# 				'activity.date': -1
		# 				_id: 1
		# 		projection:
		# 			activity:
		# 				$slice: -1
		# @view = new UsersView
		# 	collection: users


	index: ->
		mediator.publish '!io:emit', '!game:getRunning', (err, game) =>
			if game?
				console.info 'game is running'
			else
				console.info 'no running game'

			@view = new AdminMainView
				model: {game: game} if game?
				region: 'main'


	newGame: ->
		@view = new NewGameView
			region: 'main'

		@listenTo @view, 'new-game', (teams) =>

			
			teams.team1.players = teams.team1.players.split /\s*,\s*/
			teams.team2.players = teams.team2.players.split /\s*,\s*/
			mediator.publish '!io:emit', '!game:new', [teams.team1, teams.team2], (err, game) =>
				console.log game

	questions: ->
		questions = new Questions()
		questions.fetch()

		@view = new QuestionsMainView region: 'main'
		@view.subview 'questions', new QuestionsView
			collection: questions
			region: 'questions'

		@view.subview 'answers', new AnswersView
			collection: questions
			region: 'answers'

		@listenTo @view, 'create-question', (questionWording) ->
			question = new Question
				question: questionWording
				answers: []

			questions.add question
		