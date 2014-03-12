Model = require 'models/base/model'
Collection = require 'models/base/collection'


module.exports.Answer = class Answer extends Model

module.exports.Answers = class Answers extends Collection
	model: Answer

module.exports.Question = class Question extends Model
	urlRoot: 'question'

module.exports.Questions = class Questions extends Collection
	model: Question
	url: 'question'