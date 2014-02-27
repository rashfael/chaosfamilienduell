View = require 'views/base/view'


module.exports = class NewGameView extends View
	autoRender: true
	template: require 'views/admin/new-game'
	id: 'new-game'

	events:
		'click button': 'newGame'

	newGame: (events) =>
		events.preventDefault();
		@trigger 'new-game', 
			team1:
				name: @$('#team-one .name').val()
				players: @$('#team-one .players').val()
			team2:
				name: @$('#team-two .name').val()
				players: @$('#team-two .players').val()
		return
