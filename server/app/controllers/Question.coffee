mongoose = require 'mongoose'
Question = mongoose.model 'Question'

Crud = require './Crud'

module.exports = class QuestionController extends Crud
	model: Question
	prefix: 'question'