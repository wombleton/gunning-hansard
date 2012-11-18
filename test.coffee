_ = require('underscore')
stats = require('text-statistics')()

text = """
6. Schools, Canterbury—Criteria for Proposed Closures and Mergers

[Sitting date: 16 October 2012. Volume:684;Page:5803. Text is subject to correction.]

6. CHRIS HIPKINS (Labour—Rimutaka) to the Minister of Education: What specific criteria were used to determine whether a school in Christchurch was identified for restoration, consolidation or rejuvenation?

Hon HEKIA PARATA (Minister of Education) : Tēnā koe, Mr Speaker. The criteria for clusters were restore, mainly low-level change; consolidate, moderate-level change; and rejuvenate, major change across the cluster. However, it is important to note that those categories describe learning community clusters, and not individual schools.

Chris Hipkins: I raise a point of order, Mr Speaker. The Minister’s answer has given me an explanation of what each of the categories are. I have asked for what the criteria were in order to put schools within those categories.

Mr SPEAKER: I think the member has got a legitimate grievance because the member actually asked what specific criteria were used to determine whether a school was identified for restoration, consolidation, or rejuvenation. The Minister, in answering, gave criteria for clusters. If she could clarify for the House whether that applies to individual schools, that would be helpful because that is what the question asked.

Hon HEKIA PARATA: Those identifications—restore, consolidate, and rejuvenate—relate to learning community clusters, for which I have given you the criteria. They do not relate to individual schools.

Mr SPEAKER: I thank the Minister.

Chris Hipkins: I raise a point of order, Mr Speaker. Schools were specifically listed in her proposal under one of those headings, and I have asked the criteria on which they were listed under those headings. That is a primary question, and it is not an unreasonable question.

Mr SPEAKER: I accept absolutely that it is not an unreasonable question, and that is why I sought clarification from the Minister. What the Minister seems to be pointing out to the House is that those three classifications—restoration, consolidation, or rejuvenation—did not actually apply to individual schools. As to what the Minister has told the House, I have got to take the Minister’s answer at face value. I cannot second-guess that. The Minister has given an answer to that question.

Hon Trevor Mallard: I raise a point of order, Mr Speaker. I apologise to my colleague. The member asked for the criteria, and whether or not they were applied to a school or a cluster, I am not sure that any criteria were given.

Mr SPEAKER: The Minister did. The Minister in answering the question, if I heard her correctly, went through the three categories—restoration, what applied to that; consolidation, what applied to that; and, rejuvenation, what criteria applied to that. She went through each one. Admittedly she made it clear those did not apply to individual schools, and that is why I think there are some grounds for concern here. But just because the question asked that information does not mean to say the question was right in assuming that those categories applied to each school. The Minister is telling us that they do not, and I have got to take the Minister’s word at that. The member may dig further, because it seems the member may have information that disputes that.

Chris Hipkins: What specific criteria were used to identify whether a specific school was proposed for a merger or a closure?

Hon HEKIA PARATA: Sorry, could the member repeat the supplementary question?

Mr SPEAKER: I invite the member to repeat his question.

Chris Hipkins: I will try. What specific criteria were used to identify whether a specific school, an individual school, was proposed for a closure or a merger?

Hon HEKIA PARATA: I raise a point of order, Mr Speaker. The primary question actually refers quite specifically to the identification of restoration, consolidation, and rejuvenation, and I have answered what the criteria were for that and I have made it clear that they did not apply to individual schools. We are now on quite a completely different question.

Mr SPEAKER: Order! If I am going to help members on this matter, they should be a little silent. I think it is not unreasonable—the primary question asked what specific criteria were used to determine whether a school in Christchurch was identified for restoration, consolidation, or rejuvenation. The Minister in answering that question pointed out those three categories applied to clusters of schools, so the member has not unreasonably now dug further into that answer and asked then what criteria were used to identify schools for, I think his language was, merger, which is similar to consolidation, or closure, which is highly relevant to some schools in Christchurch. That is not an unreasonable supplementary question, and I am ruling that it is not an unreasonable supplementary question.

Hon HEKIA PARATA: There are 215 schools captured by the education renewal plan; 37 have specific proposals. However, all 215 are distributed across the three clusters, and each of them has different and specific criteria that relate to each of them. That is what—

Hon Members: What are they?

Hon HEKIA PARATA: For the 215 schools, each of them has a different status. For the proposals for the 37, the criteria relate to low, moderate, or high-level impact of the earthquake, to weathertightness integrity, to functionality of buildings, to rolls falling or growing, and to movement of population from one area to another. Those are some of the criteria.

Chris Hipkins: Were the assessment of earthquake damage and the likely cost of repair for each of the schools proposed for merger or closure based on a physical inspection of each site and building; if so, who conducted that assessment?

Hon HEKIA PARATA: The assessments were made in a range of ways. Some of them involved physical assessment by independently contracted engineers. Some of them involved book assessments. Some of them involved use of the property management information database from the schools themselves, and some of them involved permutations of all three.

Colin King: Was the change in demographics taken into account when developing the criteria?

Hon HEKIA PARATA: Yes, it is a people-related issue. Prior to the earthquake in 2010 there were 5,000 surplus places in the Greater Christchurch schools. The latest July roll data show that 4,300 children have left the area as a result of the earthquakes. So, obviously, those 9,300 empty places were one factor that had to be taken into account. In addition, a number of families that have stayed in Christchurch have moved, which has also impacted on school rolls.

Chris Hipkins: Was a physical assessment of the earthquake damage done on each of the schools that she proposed for merger or closure before she proposed that; if not, why not?

Hon HEKIA PARATA: I do not have the specific range of assessments that were used for each of the schools.

Mr SPEAKER: Tracy Watkins [Interruption]—Tracey Martin. I beg your pardon. My goodness.

Tracey Martin: Kia ora, Mr Speaker.

Mr SPEAKER: I beg your pardon.

Tracey Martin: Kia ora—

Mr SPEAKER: My apologies to the House.

Tracey Martin: Can the Minister assure the House that parental elections for boards of trustees will be held within 6 months of any consolidation or merger of schools in Christchurch as per the requirements of the Education Act 1989?

Hon HEKIA PARATA: We are currently in consultation with all of the schools that are affected in Christchurch. It is my expectation, if we get through the process in the time that has been outlined, that that will be the case. However, there is some flexibility in the time line depending on the consultation needs of the process.

Tracey Martin: I raise a point of order, Mr Speaker. I apologise. Perhaps I missed it. I understand the time line around mergers might not be quite clear at the moment, but my question was whether the elections for boards of trustees would be held within 6 months of any consolidation or merger as per the Education Act 1989.

Mr SPEAKER: I invite the Minister to actually answer that question.

Hon HEKIA PARATA: Yes.

Chris Hipkins: Did she review all of the information prepared by the Ministry of Education on the likely or estimated cost of repairing schools that she was intending to propose for merger or closure, before she made the decision to propose those schools for merger or closure; if not, why not?

Hon HEKIA PARATA: Yes.
"""

coleman = (sent) ->
  sent = sent.replace(/[?!.]$/, '')
			.replace(/[,:;()]/g, " ")				# Replace commans, hyphens etc (count them as spaces)
			.replace(/^\s+/,"")						# Strip leading whitespace
			.replace(/\s+/g," ")						# Remove multiple spaces
			.replace(/\s+$/,"");					# Strip trailing whitespace
  words = sent.split(/\s/)
  l = words.join('').length / words.length * 100
  s = 100 / words.length
  Math.floor(((0.0588 * l) - (0.296 * s) - 15.8) * 10) / 10

re = /(.+: )(.+)/

_.each(text.split('\n'), (line) ->
  if line and line.match(re)
    sentenceRe = /.+?[.?!]\s*?/g
    [ total, header, body ] = line.match(re)

    result = []

    while (match = sentenceRe.exec(body)) isnt null
      sentence = match[0]

      score = stats.smogIndex(sentence)
      if score > 15
        result.push(' AARGGGH!')
      else
        result.push("#{sentence} (#{score})")
    console.log("#{header}#{result.join(' ')}")
  else
    console.log(line)
)
