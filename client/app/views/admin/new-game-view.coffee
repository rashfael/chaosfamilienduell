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
				members: @$('#team-one .members').val()
			team2:
				name: @$('#team-two .name').val()
				members: @$('#team-two .members').val()
		return
