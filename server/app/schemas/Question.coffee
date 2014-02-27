mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
	question: String
	answers: [
		answer: String
		numberOfPeople: Number
	]

module.exports = schema