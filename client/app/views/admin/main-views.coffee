View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports.AdminMainView = class AdminMainView extends View
	autoRender: true
	template: require 'views/admin/main'