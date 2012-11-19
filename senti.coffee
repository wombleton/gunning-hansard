couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost', 'admin', 'admin')
db = client.db('gunning-hansard')
fs = require('fs')
_ = require('underscore')
async = require('async')
request = require('request')
qs = require('querystring')

count = 0

senti = ->
  db.view('gunning-hansard', 'unsenti_blocks', include_docs: true, (err, r) ->
    async.forEachLimit(r.rows, 10, (row, cb) ->
      doc = row.doc
      console.log("sending request##{++count}")
      params =
        app_key: process.env.APP_KEY
        phrase: row.doc.text
      request.post('http://api.sentirate.com/sentiment/request.do', form: params, (err, res, body) ->
        debugger
        result = JSON.parse(body)
        if result.error
          cb('wait')
        else
          summary = result.sentiment.summary
          _.extend(doc,
            sentiment: summary
          )
          db.saveDoc(doc, (err) ->
            cb(err)
          )
      )
    , (err) ->
      if err is 'wait'
        console.log('Trying again in an hour ...')
        setTimeout(senti, 60 * 60 * 1000)
      else if err
        console.log(err)
      else
        console.log('done!')
    )
  )

senti()
