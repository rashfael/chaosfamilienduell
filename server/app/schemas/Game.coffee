mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
	teams: [
		name: String
	]
	actions: [{}]

module.exports = schema