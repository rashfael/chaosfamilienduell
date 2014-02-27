Model = require 'models/base/model'
Collection = require 'models/base/collection'


module.exports.Game = class Game extends Model
	urlRoot: 'game'
	idAttribute: '_id'

module.exports.Games= class Games extends Collection
	model: Game
	url: 'game'