couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost', 'admin', 'admin')
db = client.db('gunning-hansard')
fs = require('fs')
_ = require('underscore')

html = ['<html><body><table>']

last = ''

db.view('gunning-hansard', 'blocks', include_docs: true, (err, r) ->
  _.each(r.rows, (row) ->
    debugger
    doc = row.doc
    if last isnt "#{doc.speaker} (#{doc.subject})"
      if last
        html.push("</ul>")
      last = "#{doc.speaker} (#{doc.subject})"
      html.push("""
        <ul>
          <li><h3>#{last}</h3></li>
      """)
    html.push("""
      <li>
        <b>#{doc.date[2]}-#{doc.date[1]}-#{doc.date[0]}</b>
        Gunning-Fog: #{doc.gunningFog} SMOG: #{doc.smogIndex}
      </li>
    """)
  )
  html.push('</ul></body></html>')
  fs.writeFileSync('result.html', html.join(''), 'utf8')
)

