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


			$(document).keydown (event) =>
				if event.which is 70
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'buzz'
						team: 1
				if event.which is 74
					@publishEvent '!io:emit', '!game:perform-action',
						action: 'buzz'
						team: 2

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
					if team?
						# flip turn flag
						team.set 'turn', true
						if team is team1
							team2.unset 'turn'
						else
							team1.unset 'turn'
					else
						team1.unset 'turn'
						team2.unset 'turn'

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
					@state.performAction action

				# replay actions
				for action in game.actions
					@state.performAction action