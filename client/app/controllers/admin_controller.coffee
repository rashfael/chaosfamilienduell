mediator = require 'mediator'
Controller = require 'controllers/base/controller'
Header = require 'models/header'
HeaderView = require 'views/header_view'
{Game, Games} = require 'models/game'
State = require 'models/state'
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
				@game = new Game game

				@state = new State
					game: @game
					phase: 'start'


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

				@state.on 'change:team', (state, team, options) =>
					# flip turn flag
					team.set 'turn', true

					if team is team1
						team2.unset 'turn'
					else
						team1.unset 'turn'

				switchTeams = ->
					if @state.get('team') is team1
						@state.set 'team', team2
					else
						@state.set 'team', team1

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
					model: @state

				gameView = new AdminGameView
					region: 'game'
					model: @state

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

				@subscribeEvent 'select-answer', (answer) =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'answer'
						answer: answer.get 'answer'

				@subscribeEvent '!io:game:action-performed', (action) =>
					console.log 'Incoming action:', action
					switch action.action
						when 'new-round'
							@state.set 'phase', 'new-round'
							@state.set 'answerCount', 0
							@state.set 'roundCount', @state.get('roundCount') + 1
							@state.set 'round', new Round
								question: action.question
								answers: new Answers action.question.answers
							@state.set 'strikes', 0
						when 'activate-member'
							members[action.member].set 'active', true
							# TODO: check that both teams have an active member
							@state.set 'phase', 'face-off'
						when 'buzz'
							@state.set 'team', teams[action.team]
							console.log teams[action.team]
						when 'answer'
							@state.set 'answerCount', @state.get('answerCount') + 1


							# do some calculating of the current state of answers
							answers = @state.get('round').get 'answers'
							topNop = 0
							highestAnswered = 0
							actionAnswer = null
							unanswered = answers.length
							calculateState = ->
								answers.each (answer) =>
									# remember top answer
									nop = answer.get('numberOfPeople')
									topNop = nop if nop > topNop
									
									if answer.get('answer') is action.answer
										actionAnswer = answer
										answer.set 'answered', true
									if answer.has 'answered'
										unanswered--
										highestAnswered = nop if nop > highestAnswered

							switch @state.get 'phase'

								# answering while FACE OFF
								when 'face-off'
									calculateState()

									# if action.answer is 'wrong'
									# 		numAnswered++

									if actionAnswer.get('numberOfPeople') is topNop or (@state.set('answerCount') > 1 and actionAnswer.get('numberOfPeople') is highestAnswered)
										console.log 'answered! Team phase now!'
										@state.set 'phase', 'team'
									else
										console.log 'answer not good enough, switch teams'
										switchTeams()
										# autophase the previous team
										if highestAnswered isnt 0
											@state.set 'phase', 'team'

								#answering when team
								when 'team'
									calculateState()
									if action.answer is '_wrong'
										strikes = @state.get('strikes') + 1
										@state.set 'strikes', strikes
										if strikes >= 3
											# THINGS
											console.log 'team lost'


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
		