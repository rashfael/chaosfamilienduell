Model = require 'models/base/model'
Collection = require 'models/base/collection'

module.exports.Team = class Team extends Model


module.exports.Member = class Member extends Model

module.exports.Members = class Members extends Collection
	model: Member

	initialize: () ->
		@on 'change:active', this.ensureSingleActive

	ensureSingleActive: (changed, active) =>
		return unless active
		@each (model) ->
			return if model is changed
			model.unset 'active'