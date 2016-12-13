

module.exports =
  courseOrLesson: (userInput) ->
    q = userInput
    bool:
      should: [
        { match: title: q },
        { match: description: q }
      ]


  slide: (userInput) ->
    q = userInput
    bool:
      should: [
        { match: text: q },
      ]


