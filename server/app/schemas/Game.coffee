mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
	teams: [
		name: String
		members: [String]
	]
	actions: [
		# id: Number # explicit numbering should not be necessary when only appending to array
		team: String
		member: String
		action: String  #['buzz', 'answer', ...]
		question: String
		answer: String
		# (points: Number)
	]

module.exports = schema