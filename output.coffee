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
    { gunningFog, speaker, subject, date, gunningFog } = row.doc

    speaker = _s.lines(speaker).join(' ').replace(/\r/, '').replace(/\s*\(.+$/, '')
    debugger if speaker.indexOf('(') > 0

    data[speaker] ?= { fog: [], subjects: {} }
    data[speaker].subjects[subject] ?= []
    data[speaker].fog.push(gunningFog)
    data[speaker].subjects[subject].push(
      date: moment(date.reverse().join(' ')).format('DD MMM YYYY')
      fog: gunningFog
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
      <table>
        <thead>
          <th class="name">#{name}</th>
    """
    if stdDevFog < 0.1
      html += """<th class="fog" colspan="2">#{fix(meanFog)}</th>"""
    else
      html += """<th class="fog" colspan="2">#{fix(meanFog - stdDevFog)} &mdash; #{fix(meanFog + stdDevFog)}</th>"""
    html += """
        </thead>
    """
    _.each(speaker.subjects, (talks, title) ->
      { meanFog, stdDevFog } = talks
      html += """
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
        { date, fog } = talk
        html += """
          <tr>
            <td></td>
            <td>#{date}</td>
            <td>#{fog}</td>
          </tr>
        """
      )
      html += """
        </tbody>
      """
    )
    html += """
      </table>
    """
    html
  )
  fs.writeFileSync('result.html', result.join(' '))
)
