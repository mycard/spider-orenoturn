<<<<<<< HEAD
jsdom = require 'jsdom'
request = require 'request'
Iconv = require 'iconv'
fs = require 'graceful-fs'
path = require 'path'
iconv = new Iconv.Iconv('EUC-JP', 'UTF-8//TRANSLIT//IGNORE')
fs.exists 'images', (exists)->
  fs.mkdir('images') unless exists

#MongoClient = require('mongodb').MongoClient
#MongoClient.connect 'mongodb://127.0.0.1:27017/mycard', (err, db)->
#  throw err if err
#  collection = db.collection('orenoturn')
#  collection.remove()
  data = []

  request 'http://code.jquery.com/jquery-2.0.3.min.js', (error, response, body)->
    jquery = body
    console.log 'jquery loaded'
    request
      uri: 'http://orenoturn.com/'
      encoding: 'binary',
      (error, response, body)->
        body = new Buffer(body, 'binary');
        body = iconv.convert(body).toString();
        jsdom.env
          html: body
          src: jquery
          done: (errors, window)->
            console.log 'index loaded'
            pending = 0
            window.$('#slider p:first').nextUntil('div').filter('dt').each (index, category)->
              window.$(category).nextUntil('dt').find('li a').each (index, subcategory)->
                pending++
                request
                  uri: window.$(subcategory).attr('href'),
                  encoding: 'binary',
                  (error, response, body)->
                    body = new Buffer(body, 'binary');
                    body = iconv.convert(body).toString();
                    jsdom.env
                      html: body
                      src: jquery
                      done: (errors, window)->
                        console.log window.$(subcategory).text()
                        window.$(".product_item").each (index, element)->
                          ele = window.$(element)
                          orenoturn_id = parseInt(ele.find('a').attr('href').slice(5))
                          orenoturn_name = ele.find('.name a').text()
                          orenoturn_image = ele.find('a img').attr('src').replace('_th', '')
                          orenoturn_image_basename = path.basename(orenoturn_image)
                          file = "images/#{orenoturn_image_basename}"

                          data.push
                            orenoturn_id: orenoturn_id
                            orenoturn_name: orenoturn_name
                            orenoturn_image: orenoturn_image
                            orenoturn_image_basename: orenoturn_image_basename

                          console.log "#{data.length}: #{orenoturn_name}"

                          fs.stat file, (error, data)->
                            if data and data.size
                              console.log "#{orenoturn_name} skipped"
                            else
                              request(orenoturn_image).pipe(fs.createWriteStream(file))
                        pending--
                        if !pending
                          fs.writeFile('orenoturn.json', JSON.stringify(data, null, 2))
=======
jsdom = require 'jsdom'
request = require 'request'
Iconv = require 'iconv'
fs = require 'graceful-fs'
path = require 'path'
iconv = new Iconv.Iconv('EUC-JP', 'UTF-8//TRANSLIT//IGNORE')
fs.exists 'images', (exists)->
  fs.mkdir('images') unless exists

#MongoClient = require('mongodb').MongoClient
#MongoClient.connect 'mongodb://127.0.0.1:27017/mycard', (err, db)->
#  throw err if err
#  collection = db.collection('orenoturn')
#  collection.remove()
  data = []

  request 'http://code.jquery.com/jquery-2.0.3.min.js', (error, response, body)->
    jquery = body
    console.log 'jquery loaded'
    request
      uri: 'http://orenoturn.com/'
      encoding: 'binary',
      (error, response, body)->
        body = new Buffer(body, 'binary');
        body = iconv.convert(body).toString();
        jsdom.env
          html: body
          src: jquery
          done: (errors, window)->
            console.log 'index loaded'
            pending = 0
            window.$('#slider p:first').nextUntil('div').filter('dt').each (index, category)->
              window.$(category).nextUntil('dt').find('li a').each (index, subcategory)->
                pending++
                request
                  uri: window.$(subcategory).attr('href'),
                  encoding: 'binary',
                  (error, response, body)->
                    body = new Buffer(body, 'binary');
                    body = iconv.convert(body).toString();
                    jsdom.env
                      html: body
                      src: jquery
                      done: (errors, window)->
                        console.log window.$(subcategory).text()
                        window.$(".product_item").each (index, element)->
                          ele = window.$(element)
                          orenoturn_id = parseInt(ele.find('a').attr('href').slice(5))
                          orenoturn_name = ele.find('.name a').text()
                          orenoturn_image = ele.find('a img').attr('src').replace('_th', '')
                          orenoturn_image_basename = path.basename(orenoturn_image)
                          file = "images/#{orenoturn_image_basename}"

                          data.push
                            orenoturn_id: orenoturn_id
                            orenoturn_name: orenoturn_name
                            orenoturn_image: orenoturn_image
                            orenoturn_image_basename: orenoturn_image_basename

                          console.log "#{data.length}: #{orenoturn_name}"

                          fs.stat file, (error, data)->
                            if data and data.size
                              console.log "#{orenoturn_name} skipped"
                            else
                              request(orenoturn_image).pipe(fs.createWriteStream(file))
                        pending--
                        if !pending
                          fs.writeFile('orenoturn.json', JSON.stringify(data, null, 2))
>>>>>>> 24b9aaea320650ea29f4de2d1af224ee2896cff2
                          console.log "all pages loaded"
