Model = require 'models/base/model'
Collection = require 'models/base/collection'


module.exports.Question = class Question extends Model
	urlRoot: 'question'

module.exports.Questions= class Questions extends Collection
	model: Question
	url: 'question'