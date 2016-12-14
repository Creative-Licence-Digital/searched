

module.exports =
  courseOrLesson: (userInput, app) ->
    q = userInput
    bool:
      filter: [
        { term: app: app }
      ]
      should: [
        { match: title: q },
        { match: description: q }
        { match: text: q }
      ]


  slide: (userInput, app) ->
    q = userInput
    bool:
      filter: [
        { term: app: app }
      ]
      must: [
        { match: text: q },
      ]


