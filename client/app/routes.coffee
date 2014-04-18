module.exports = (match) ->
  match '', 'home#index'
  match 'admin', 'admin#index'
  match 'spectate', 'spectate#index'
  match 'admin/questions', 'admin#questions'
  match 'admin/new-game', 'admin#newGame'
