couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost', 'admin', 'admin')
db = client.db('gunning-hansard')
request = require('request')
cheerio = require('cheerio')
_ = require('underscore')
_s = require('underscore.string')
async = require('async')
moment = require('moment')
stats = require('text-statistics')()

db.exists((err, exists) ->
  if exists
    scrape()
  else
    db.create(scrape)
)

fixUrl = (url) ->
  if url.indexOf('http://') is 0
    url
  else
    url = "http://www.parliament.nz#{url}"

scrape = (url = 'http://www.parliament.nz/en-NZ/PB/Business/QOA/') ->
  url = fixUrl(url)

  request.get(url, (err, res, body) ->
    $ = cheerio.load(body)
    results = $('.listing tbody a')
    end = false

    async.forEach(results, (result, cb) ->
      href = $(result).attr('href')
      db.view('gunning-hansard', 'pages', key: href, limit: 1, (err, r) ->
        if err
          cb(err)
        else
          if r.rows.length > 0
            end = true
            console.log("already have #{href}")
            cb()
          else
            db.saveDoc(
              href: href
              type: 'page'
            , (err) ->
              console.log("Saved document for href #{href}") unless err
              cb()
            )
      )
    , (err) ->
      next = $('.nextPage').attr('href')
      if !end and next
        scrape(next)
      else
        scrapePages()
    )
  )

scrapePages = ->
  re = /(.+):(.+)/
  db.view('gunning-hansard', 'unscraped_pages', limit: 10, include_docs: true, (err, r) ->
    if r.rows.length > 0
      async.forEach(r.rows, (row, cb) ->
        url = fixUrl(row.doc.href)
        request.get(url, (err, res, body) ->
          $ = cheerio.load(body)
          date = $('.information dd').text()
          d = moment(date)
          subject = $($('p.SubsQuestion strong')[2]).text()
          subject = subject.replace(/.*Minister (of|for) /, '')
          subs = $('p.SubsQuestion, p.SubsAnswer, p.SupQuestion, p.SupAnswer', '.copy .section')
          blocks = _.map(subs, (sub) ->
            speaker = $(sub).find('strong').text().toUpperCase()
            text = _s.lines($(sub).text()).join('').replace(/\r/g, ' ').trim()
            [ all, header, text ] = text.match(re)
            speaker = speaker.replace(/(\(.+\).*$)|:|(^\d+\.)/g, '').trim()
            speaker: speaker, subject: subject, text: text
          )
          row.doc.scraped = true
          db.saveDoc(row.doc, (err) ->
            if err
              cb(err)
            else
              db.saveDoc(
                date: [ d.date(), d.month() + 1, d.year() ]
                type: 'question'
                blocks: blocks
                url: url
              , (err) ->
                if err
                  cb(err)
                else
                  console.log("Saved a question with subject #{subject} and #{blocks.length} blocks")
                  cb()
              )
          )
        )
      , (err) ->
        if err
          console.log(err.message)
          process.exit(1)
        else
          scrapePages()
      )
    else
      rateQuestions()
  )

rateQuestions = ->
  db.view('gunning-hansard', 'unrated_questions', include_docs: true, limit: 10, (err, r) ->
    if r.rows.length > 0
      async.forEach(r.rows, (row, cb) ->
        doc = row.doc
        subject = undefined

        blocks = _.reduce(doc.blocks, (memo, block) ->
          memo[block.speaker] ?= ''
          memo[block.speaker] += block.text
          memo[block.speaker] = memo[block.speaker].trim()
          subject = block.subject
          memo
        , {})
        async.forEach(_.keys(blocks), (key, cb2) ->
          text = blocks[key]
          db.saveDoc(
            date: doc.date
            type: 'block'
            text: blocks[key]
            speaker: key
            subject: subject
            gunningFog: stats.gunningFogScore(text)
            smogIndex: stats.smogIndex(text)
            fleschKincaidReadingEase: stats.fleschKincaidReadingEase(text)
          , (err) ->
            cb2(err)
          )
        , (err) ->
          doc.rated = true
          db.saveDoc(doc, (err) ->
            cb(err)
          )
        )
      , (err) ->
        if err
          console.log(err.message)
          process.exit(1)
        else
          rateQuestions()
      )
    else
      console.log('done')
  )
