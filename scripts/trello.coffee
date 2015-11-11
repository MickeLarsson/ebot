fs = require 'fs'
Trello = require('node-trello')
_ = require('lodash')
async = require 'async'

trelloBase = 'https://api.trello.com'
cardIds = []
config = {}

module.exports = (robot) ->
	
	fs.readFile 'config.json', 'utf-8', (err, data) ->
		config = JSON.parse(data)

	robot.respond /release/i, (msg) ->
		trello = new Trello(config.trelloKey, config.trelloToken)

		#Create Next release list on the release board
		trello.post('/1/lists', { name: 'Next release', idBoard: config.releaseBoardId, pos: 1 }, (err, data) ->
			#Locate cards in for release list in bug board
			newListId = data.id
			#Locate cards in for release list in development board
			trello.get('/1/lists/' + config.devReleaseListId + '/cards', (err, data) ->
				for card in data
					cardIds.push card.id
				
				trello.get('/1/lists/' + config.bugReleaseListId + '/cards', (err, data) ->
					for card in data
						cardIds.push card.id

					#Move found cards to Next release card on release board
					async.map(cardIds, (id, callback) ->
						trello.put('/1/cards/' + id, { idBoard: config.releaseBoardId, idList: newListId }, (err, data) ->
							callback(err, data)
						)
					, (err, data) ->
						msg.reply "Cards have been moved"
						cardIds = []
					)
				)
			)

		)
    
    robot.respons /bug me/i, (msg) ->
        trello = new Trello(config.trelloKey, config.trelloToken)

       trello.get("/1/boards/" + boardId + "/lists?cards=open", function(err, data) {
           var lists = _.filter(data, function(n){
               return n.name.toLowerCase() !== 'known issue';
           });

           var cardCount = _.sum(lists, function(l){
               return l.cards.length;
           });

           msg.reply('We have ' + cardCount + ' cards on the bug board (Known issue excluded)'); 
       });

