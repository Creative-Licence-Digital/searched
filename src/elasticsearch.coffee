queries = require './queries'

module.exports = (esClient, indexName) ->
  removeAllSlidesForLesson: (lessonId, done) ->
    # TODO
    #console.error("Remove all slides for lesson", lessonId)
    done()

  remove: ({ type, id }, done) ->
    esClient.delete
      index: indexName
      type: type
      id: id
    , (err, resp) -> done(err, {})

  addOrUpdate: ({ type, id, doc }, done) ->
    esClient.update
      index: indexName
      type: type
      id: id
      body:
        doc: doc
        upsert: doc
    , (err, resp) -> done(err, {})

  search: ({ type, query }, done) ->
    dict = { "courseOrLesson": "course,lesson", "slide": "slide" }
    esClient.search
      index: indexName
      type: dict[type]
      body: query: queries[type](query)
    , (err, res) ->
      return done(err) if err?
      results = res.hits.hits or []
      done null, results

