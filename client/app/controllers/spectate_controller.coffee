mediator = require 'mediator'
Controller = require 'controllers/base/controller'
{Game, Games} = require 'models/game'
State = require 'models/state'
{Round} = require 'models/round'
{Team} = require 'models/team'
{Question, Questions, Answer, Answers} = require 'models/question'
{MainView, AdminGameView, TeamView, MembersView} = require 'views/spectate/main-views'
NewGameView = require 'views/admin/new-game-view'


module.exports = class AdminController extends Controller
	beforeAction: -> null
	index: ->
		@subscribeEvent '!io:game:started-new', () =>
			@redirectTo 'spectate#index', {}, 
				forceStartup: true
		@publishEvent '!io:emit', '!game:get-running', (err, game) =>
			if not game?
				@view = new MainView
			else
				@game = new Game game

				@state = new State
					game: @game
					phase: 'start'


				@game.set 'team1', new Team
					name: game.teams[0].name
					points: 0
				@game.set 'team2', new Team
					name: game.teams[1].name
					points: 0
				

				team1 = @game.get 'team1'
				team2 = @game.get 'team2'

				# build some dicts to find shit faster
				teams = []
				teams[1] = team1
				teams[2] = team2

				@state.on 'change:team', (state, team, options) =>
					# flip turn flag
					team.set 'turn', true

					if team is team1
						team2.unset 'turn'
					else
						team1.unset 'turn'

				switchTeams = =>
					roundPoints = @state.get('round').get 'points'
					team = @state.get('team')
					team.set('points', team.get('points') - roundPoints)
					@state.get('team').get('points')
					if @state.get('team') is team1
						team = team2
						@state.set 'team', team2
					else
						team = team1
						@state.set 'team', team1
					team.set('points', team.get('points') + roundPoints)

				@view = new MainView
					model: @state


				# @view.subview 'round', gameView


				for team in ['team1', 'team2']
					do (team) =>
						@view.subview team, new TeamView
							region: team
							model: @game.get(team)

				@subscribeEvent '!io:game:changed-team-name', (data) =>
					@game.get('team'+data.team).set 'name', data.name

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
								points: 0
							@state.set 'strikes', 0
							team1.unset 'turn'
							team2.unset 'turn'
						
						when 'face-off'
							@state.set 'phase', 'face-off'
						when 'buzz'
							@state.set 'team', teams[action.team]

						when 'switch-team'
							switchTeams()
							@state.set 'strikes', 0
						when 'answer'
							@state.set 'answerCount', @state.get('answerCount') + 1


							# do some calculating of the current state of answers
							answers = @state.get('round').get 'answers'
							topNop = 0
							highestAnswered = 0
							actionAnswer = null
							unanswered = answers.length
							calculateState = =>
								answers.each (answer) =>
									# remember top answer
									nop = answer.get('numberOfPeople')
									topNop = nop if nop > topNop
									
									if answer.get('answer') is action.answer
										actionAnswer = answer
										answer.set 'answered', true
										@state.get('round').set('points', @state.get('round').get('points') + answer.get 'numberOfPeople')
										@state.get('team').set('points', @state.get('team').get('points') + answer.get 'numberOfPeople')
									if answer.has 'answered'
										unanswered--
										highestAnswered = nop if nop > highestAnswered

							console.log 'phase', @state.get 'phase'
							switch @state.get 'phase'

								# answering while FACE OFF
								when 'face-off'
									console.log 'this is a face off!'
									calculateState()

									# if action.answer is 'wrong'
									# 		numAnswered++

									if actionAnswer? and (actionAnswer.get('numberOfPeople') is topNop or (@state.get('answerCount') > 1 and actionAnswer.get('numberOfPeople') is highestAnswered))
										console.log 'answered! Team phase now!'
										@state.set 'phase', 'team'
									else
										console.log 'answer not good enough, switch teams'
										switchTeams()
										# autophase the previous team
										if highestAnswered isnt 0 and (@state.get('answerCount') > 1 or not actionAnswer?)
											console.log 'previous team was better'
											@state.set 'phase', 'team'

								#answering when team
								when 'team'
									calculateState()
									if unanswered <= 0
										# WIN ROUND
										@state.set 'phase', 'round-won'
									if action.answer is '_wrong'
										strikes = @state.get('strikes') + 1
										@state.set 'strikes', strikes
										if strikes >= 3
											console.log 'team lost'