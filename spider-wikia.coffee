request = require 'request'
fs = require 'graceful-fs'
path = require 'path'
util = require 'util'
_ = require 'underscore'

data = []
pending = 0

fetch = (cmcontinue='')->
  request
    url:"http://yugioh.wikia.com/api.php?action=query&list=categorymembers&cmtitle=Category:Card_Names&cmlimit=500&cmcontinue=#{cmcontinue}&format=json"
    json: true,
    (error, response, body)->
      fetch(body['query-continue'].categorymembers.cmcontinue) if body['query-continue']
      _.each body.query.categorymembers, (item)->
        card = item.title.slice(11) #Card Names:
        request
          url: "http://yugioh.wikia.com/api.php?action=parse&prop=wikitext&page=#{encodeURIComponent card}&format=json"
          json: true,
          (error, response, body)->
            body.parse.wikitext['*']
            matched = body.parse.wikitext['*'].match /\{\{CardTable2\n\|([\s\S]*)\n\}\}/
            card_info = {title: body.parse.title}
            for line in matched[1].split("\n|")
              lineitem = line.replace(/\<\!\-\-.*\-\-\>/g, '').split(/\ \=\s/, 2)
              card_info[lineitem[0]] = lineitem[1]
            if card_info.image
              pending++
              request
                url: "http://yugioh.wikia.com/api.php?action=query&prop=imageinfo&iiprop=url&titles=File:#{encodeURIComponent card_info.image}&format=json"
                json: true,
                  (error, response, body)->
                    card_info['image'] = _.values(body.query.pages)[0].imageinfo[0].url

                    card_info['image_basename'] = decodeURIComponent path.basename card_info['image']
                    data.push card_info

                    file = "images_wikia/#{card_info.image_basename}"
                    fs.stat file, (error, data)->
                      if data and data.size
                        console.log "[SKIPPED] #{card_info.title}"
                      else
                        console.log "[GET] #{card_info.title}"
                        request(card_info.image).pipe(fs.createWriteStream(file))

                    pending--
                    if !pending
                      fs.writeFile('wikia.json', JSON.stringify(data, null, 2))
                      wikia_image = {}
                      wikia_image[parseInt card.number] = card.image_basename for card in data when card.number
                      fs.writeFile('images_wikia.json', JSON.stringify(wikia_image, null, 2))
                      console.log "all cards loaded"






fs.exists 'images_wikia', (exists)->
  fs.mkdir('images_wikia') unless exists

#MongoClient = require('mongodb').MongoClient
#MongoClient.connect 'mongodb://127.0.0.1:27017/mycard', (err, db)->
#  throw err if err
#  collection = db.collection('orenoturn')
#  collection.remove()

  fetch()

