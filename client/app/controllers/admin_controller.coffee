mediator = require 'mediator'
Controller = require 'controllers/base/controller'
Header = require 'models/header'
HeaderView = require 'views/header_view'
{Game, Games} = require 'models/game'
State = require 'models/state'
{Round} = require 'models/round'
{Team} = require 'models/team'
{Question, Questions, Answer, Answers} = require 'models/question'
{QuestionsMainView, QuestionsView, AnswersView} = require 'views/admin/question_views'
{AdminMainView, AdminGameView, TeamView} = require 'views/admin/main-views'
NewGameView = require 'views/admin/new-game-view'


module.exports = class AdminController extends Controller

	index: ->
		@subscribeEvent '!io:game:started-new', () =>
			@redirectTo 'admin#index', {}, 
				forceStartup: true
		@publishEvent '!io:emit', '!game:get-running', (err, game) =>
			if not game?
				@view = new AdminMainView
					region: 'main'

				@listenTo @view, 'new-game', =>
					console.log 'herp'
					@publishEvent '!io:emit', '!game:new'
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
					if team?
						# flip turn flag
						team.set 'turn', true
					if not team?
						team1.unset 'turn'
						team2.unset 'turn'
					else if team is team1
							team2.unset 'turn'
						else
							team1.unset 'turn'

				# autocomplete
				commands = [
					'new round'
					'face off'
					'fail'
					'switch team'
				]

				commandHound = new Bloodhound
					datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
					queryTokenizer: Bloodhound.tokenizers.whitespace
					local: $.map commands, (command) -> { value: command }

				answerHound = new Bloodhound
					datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
					queryTokenizer: Bloodhound.tokenizers.whitespace
					local: []

 				commandHound.initialize()
				answerHound.initialize()

				@view = new AdminMainView
					region: 'main'
					model: @state
					commandHound: commandHound
					answerHound: answerHound

				@state.on 'change:round', (state, round) =>
					answerHound.clear()
					answers = []
					round.get('answers').forEach (answer) ->
						answers.push
							value: 'answer ' + answer.get 'answer'
					console.log answers
					answerHound.add answers

				for team, i in ['team1', 'team2']
					do (team, i) =>
						@view.subview team, new TeamView
							region: team
							model: @game.get(team)

						@listenTo @view.subview(team), 'changeName', (name) =>
							@publishEvent '!io:emit', '!game:change-team-name',
								name: name
								team: i+1

						@listenTo @view.subview(team), 'fake-buzz', =>
							@publishEvent '!io:emit', '!game:perform-action',
								action: 'buzz'
								team: i+1

				@listenTo @view, 'command', (command) =>
					switch command
						when 'new round'
							event = 'new-round'
						when 'face off'
							event = 'face-off'
						when 'fail'
							@publishEvent '!io:emit', '!game:perform-action',
									action: 'answer'
									answer: '_wrong'
						when 'switch team'
							@publishEvent 'switch-team'
						else
							answerMatch = command.match /answer (.*)/
							if answerMatch
								@publishEvent '!io:emit', '!game:perform-action',
									action: 'answer'
									answer: answerMatch[1]


					@view.trigger event if event?

				@listenTo @view, 'new-game', =>
					console.log 'herp'
					@publishEvent '!io:emit', '!game:new'

				@listenTo @view, 'new-round', =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'new-round'

				@listenTo @view, 'face-off', =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'face-off'


				@subscribeEvent 'select-answer', (answer) =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'answer'
						answer: answer.get 'answer'

				@subscribeEvent 'switch-team', =>
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'switch-team'

				@subscribeEvent '!io:game:changed-team-name', (data) =>
					@game.get('team'+data.team).set 'name', data.name

				@subscribeEvent '!io:game:action-performed', (action) =>
					console.log 'Incoming action:', action
					@state.performAction action
										
				
				# replay actions
				for action in game.actions
					@state.performAction action