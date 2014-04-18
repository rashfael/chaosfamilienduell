mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
	teams: [
		name: String
	]
	actions: [
		# id: Number # explicit numbering should not be necessary when only appending to array
		team: String
		action: String  #['buzz', 'answer', ...]
		question: String
		answer: String
		# (points: Number)
	]

module.exports = schema