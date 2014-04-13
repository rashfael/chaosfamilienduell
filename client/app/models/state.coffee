Model = require 'models/base/model'

module.exports = class State extends Model
	# phase:
	#		start
	#		new-round
	#		face-off
	#		team

	# round

	# roundCount:
	#		round count

	# answerCount

	# team:
	# 	the controlling team

	# strikes:
	# 	count of strikes (0..2)

