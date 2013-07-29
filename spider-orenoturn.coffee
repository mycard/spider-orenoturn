jsdom = require 'jsdom'
request = require 'request'
Iconv = require 'iconv'
fs = require 'graceful-fs'

iconv = new Iconv.Iconv('EUC-JP', 'UTF-8//TRANSLIT//IGNORE')
fs.exists 'images', (exists)->
  fs.mkdir('images') unless exists

request 'http://code.jquery.com/jquery-2.0.3.min.js', (error, response, body)->
  jquery = body
  console.log 'jquery loaded'
  jsdom.env
    url: 'http://kaibaland.shop-pro.jp/?mode=srh&cid=&keyword='
    src: jquery
    done: (errors, window)->
      count = parseInt window.$(".txt-hitNum strong").text()
      pages = Math.ceil(count / 500)
      console.log "#{count} items, #{pages} pages"
      window.$.each [1..pages], (index, page)->
        request
          uri: 'http://kaibaland.shop-pro.jp/?mode=srh&cid=&keyword=&page=' + page,
          encoding: 'binary',
          (error, response, body)->
            body = new Buffer(body, 'binary');
            body = iconv.convert(body).toString();
            jsdom.env
              html: body
              src: jquery
              done: (errors, window)->
                console.log "page #{page} loaded"
                window.$(".product_item").each (index, element)->
                  ele = window.$(element)
                  img = ele.find('a img').attr('src').replace('_th', '')
                  name = ele.find('.name a').text()
                  file = "images/#{name.replace('/', '_')}.jpg"
                  fs.stat file, (error, data)->
                    if data and data.size
                      console.log "#{name} skipped"
                    else
                      request(img).pipe(fs.createWriteStream("images/#{name.replace('/', '_')}.jpg"))