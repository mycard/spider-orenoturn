jsdom = require 'jsdom'
request = require 'request'
Iconv = require 'iconv'
fs = require 'graceful-fs'
path = require 'path'
iconv = new Iconv.Iconv('EUC-JP', 'UTF-8//TRANSLIT//IGNORE')
fs.exists 'wikia-images', (exists)->
  fs.mkdir('wikia-images') unless exists

#MongoClient = require('mongodb').MongoClient
#MongoClient.connect 'mongodb://127.0.0.1:27017/mycard', (err, db)->
#  throw err if err
#  collection = db.collection('orenoturn')
#  collection.remove()
  data = []

  request 
    url:'http://yugioh.wikia.com/api.php?action=query&list=allimages&ailimit=500&aifrom=Legendary&format=json', (error, response, body)->
