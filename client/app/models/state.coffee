Model = require 'models/base/model'

{Round} = require 'models/round'
{Question, Questions, Answer, Answers} = require 'models/question'

module.exports = class State extends Model
	# phase:
	#		start
	#		new-round
	#		face-off
	#		team
	#		round-won

	# round

	# roundCount:
	#		round count

	# answerCount

	# team:
	# 	the controlling team

	# strikes:
	# 	count of strikes (0..2)

	initialize: =>
		super
		@game = @get 'game'


	switchTeams: =>
		team1 = @game.get 'team1'
		team2 = @game.get 'team2'
		roundPoints = @get('round').get 'points'
		team = @get('team')
		team.set('points', team.get('points') - roundPoints)
		@get('team').get('points')
		if @get('team') is team1
			team = team2
			@set 'team', team2
		else
			team = team1
			@set 'team', team1
		team.set('points', team.get('points') + roundPoints)


	performAction: (action) =>
		console.log @get('phase')
		team1 = @game.get 'team1'
		team2 = @game.get 'team2'
		switch action.action
			when 'new-round'
				@set 'phase', 'new-round'
				@set 'answerCount', 0
				@set 'roundCount', @get('roundCount') + 1
				@set 'round', new Round
					question: action.question
					answers: new Answers action.question.answers
					points: 0
				@set 'strikes', 0
				@unset 'team'
				team1.unset 'turn'
				team2.unset 'turn'
			when 'face-off'
				@set 'phase', 'face-off'
			when 'buzz'
				if not @has('team') or action.force or @get('phase') is 'start'
					@set 'team', @game.get 'team' + action.team
				else
					console.log 'already buzzed'
			when 'switch-team'
				@set 'phase', 'team-steal'
				@switchTeams()
				@set 'strikes', 0

			when 'answer'
				@set 'answerCount', @get('answerCount') + 1

				# do some calculating of the current state of answers
				answers = @get('round').get 'answers'
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
							console.log answer.get 'numberOfPeople'
							console.log @get 'round'
							@get('round').set('points', @get('round').get('points') + answer.get('numberOfPeople')*@get('round').get('question').multiplier)
							@get('team').set('points', @get('team').get('points') + answer.get('numberOfPeople')*@get('round').get('question').multiplier)
						if answer.has 'answered'
							unanswered--
							highestAnswered = nop if nop > highestAnswered

				console.log 'phase', @get 'phase'
				switch @get 'phase'

					# answering while FACE OFF
					when 'face-off'
						console.log 'this is a face off!'
						calculateState()

						# if action.answer is 'wrong'
						# 		numAnswered++

						if actionAnswer? and (actionAnswer.get('numberOfPeople') is topNop or (@get('answerCount') > 1 and actionAnswer.get('numberOfPeople') is highestAnswered))
							console.log 'answered! Team phase now!'
							@set 'phase', 'team'
						else
							console.log 'answer not good enough, switch teams'
							@switchTeams()
							# autophase the previous team
							if highestAnswered isnt 0 and (@get('answerCount') > 1 or not actionAnswer?)
								console.log 'previous team was better'
								@set 'phase', 'team'

					#answering when team
					when 'team'
						calculateState()
						if unanswered <= 0
							# WIN ROUND
							@set 'phase', 'round-won'
						if action.answer is '_wrong'
							strikes = @get('strikes') + 1
							@set 'strikes', strikes
							if strikes >= 3
								console.log 'team lost'

					when 'team-steal'
						answers.each (answer) =>
							if answer.get('answer') is action.answer
								answer.set 'answered', true
						