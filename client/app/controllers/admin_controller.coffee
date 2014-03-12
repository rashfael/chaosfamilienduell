mediator = require 'mediator'
Controller = require 'controllers/base/controller'
Header = require 'models/header'
HeaderView = require 'views/header_view'
{Game, games} = require 'models/game'
{Round} = require 'models/round'
{Team, Member, Members} = require 'models/team'
{Question, Questions, Answer, Answers} = require 'models/question'
{QuestionsMainView, QuestionsView, AnswersView} = require 'views/admin/question_views'
{AdminMainView, AdminGameView, MembersView} = require 'views/admin/main-views'
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
		@publishEvent '!io:emit', '!game:get-running', (err, game) =>
			if not game?
				@view = new AdminMainView
					region: 'main'
			else
				@game = new Game(game)
				@game.set 'team1', new Team
					name: game.teams[0].name
					members: new Members()
				@game.set 'team2', new Team
					name: game.teams[1].name
					members: new Members()
				

				team1 = @game.get 'team1'
				team2 = @game.get 'team2'

				# build some dicts to find shit faster
				teams = {}
				teams[team1.get('name')] = team1
				teams[team2.get('name')] = team2

				members = {}

				for name in game.teams[0].members
					member = new Member
						name: name
						team: team1
					team1.get('members').add member
					members[name] = member

				for name in game.teams[1].members
					member = new Member
						name: name
						team: team2
					team2.get('members').add member
					members[name] = member

				

				@view = new AdminMainView
					region: 'main'
					model: @game

				gameView = new AdminGameView
					region: 'game'
					model: @game

				@view.subview 'round', gameView


				for team in ['team1', 'team2']
					do (team) =>
						@view.subview team, new MembersView
							region: team
							model: @game.get(team)
							collection: @game.get(team).get 'members'

						@listenTo @view.subview(team), 'fake-buzz', =>
							@publishEvent '!io:emit', '!game:perform-action',
								action: 'buzz'
								team: @game.get(team).get 'name'
						# activeMember = @game.get(team).get('members').find (member) -> member.has 'active'



				@listenTo @view, 'new-round', =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'new-round'

				@subscribeEvent 'select-member', (member) =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'activate-member'
						member: member.get 'name'
						team: member.get('team').get 'name'

				@subscribeEvent '!io:game:action-performed', (action) =>
					console.log action
					switch action.action
						when 'new-round'
							@game.set 'round', new Round
								question: action.question
								answers: new Answers action.question.answers
						when 'activate-member'
							members[action.member].set 'active', true
						when 'buzz'
							teams[action.team].set 'turn', true
							console.log teams[action.team]




	newGame: ->
		@view = new NewGameView
			region: 'main'

		@listenTo @view, 'new-game', (teams) =>

			
			teams.team1.members = teams.team1.members.split /\s*,\s*/
			teams.team2.members = teams.team2.members.split /\s*,\s*/
			@publishEvent '!io:emit', '!game:new', [teams.team1, teams.team2], (err, game) =>
				@redirectTo 'admin#index'

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
		