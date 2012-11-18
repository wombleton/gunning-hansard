couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost', 'admin', 'admin')
db = client.db('gunning-hansard')
fs = require('fs')
_ = require('underscore')
_s = require('underscore.string')
moment = require('moment')
stats = require('stats-array')

data = {}

fix = (n) ->
  n.toFixed(1)

db.view('gunning-hansard', 'blocks', include_docs: true, (err, r) ->
  _.each(r.rows, (row) ->
    { gunningFog, speaker, subject, date, gunningFog, url } = row.doc

    speaker = _s.lines(speaker).join(' ').replace(/\r/, '').replace(/\s*\(.+$/, '')
    debugger if speaker.indexOf('(') > 0

    data[speaker] ?= { fog: [], subjects: {} }
    data[speaker].subjects[subject] ?= []
    data[speaker].fog.push(gunningFog)
    data[speaker].subjects[subject].push(
      date: moment(date.reverse().join(' ')).format('DD MMM YYYY')
      fog: gunningFog
      url: url
    )
  )
  _.each(data, (speaker, name) ->
    speaker.stdDevFog = if speaker.fog.length is 1 then 0 else speaker.fog.stdDeviation()
    speaker.meanFog = speaker.fog.mean()
    _.each(speaker.subjects, (subject) ->
      fogs = _.pluck(subject, 'fog')
      subject.stdDevFog = if fogs.length is 1 then 0 else fogs.stdDeviation()
      subject.meanFog = fogs.mean()
    )
  )

  result = _.map(data, (speaker, name) ->
    { meanFog, stdDevFog } = speaker
    html = """
      <h2>
        #{name} <span class="fog" colspan="2">#{if stdDevFog < 0.1 then fix(meanFog) else "#{fix(meanFog - stdDevFog)} &mdash; #{fix(meanFog + stdDevFog)}"}</span>
      </h2>
    """

    _.each(speaker.subjects, (talks, title) ->
      { meanFog, stdDevFog } = talks
      html += """
        <table>
        <tbody>
          <tr>
            <th class="subject">#{name} speaking on ... #{_s.prune(title, 40)}</th>
      """
      if stdDevFog < 0.1
        html += """<th class="fog" colspan="2">#{fix(meanFog)}</th>"""
      else
        html += """<th class="fog" colspan="2">#{fix(meanFog - stdDevFog)} &mdash; #{fix(meanFog + stdDevFog)}</th>"""
      html += """</tr>"""
      _.each(talks, (talk) ->
        { date, fog, url } = talk
        html += """
          <tr>
            <td></td>
            <td class="date"><a href="#{url}">#{date}</a></td>
            <td class="fog">#{fog}</td>
          </tr>
        """
      )
      html += """
        </tbody></table>
      """
    )
    html
  )
  fs.writeFileSync('result.html', """<div class="results">#{result.join(' ')}</div>""")
)
