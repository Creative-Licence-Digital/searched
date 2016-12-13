queries = require './queries'

esc = (esClient, indexName) ->
  removeAllSlidesForLesson = (lessonId, done) ->
    # TODO
    #console.error("Remove all slides for lesson", lessonId)
    done()

  _remove = ({ type, id }) ->
    index: indexName
    type: type
    id: id

  _addOrUpdate = ({ type, id, doc }) ->
    index: indexName
    type: type
    id: id
    body:
      doc: doc
      upsert: doc

  remove = ({ type, id }, done) ->
    esClient.delete _remove({ type, id }), (err, resp) -> done(err, {})

  addOrUpdate = ({ type, id, doc }, done) ->
    esClient.update _addOrUpdate({ type, id, doc }), (err, resp) -> done(err, {})

  search = ({ type, query }, done) ->
    dict = { "courseOrLesson": "course,lesson", "slide": "slide" }
    esClient.search
      index: indexName
      type: dict[type]
      body: query: queries[type](query)
    , (err, res) ->
      return done(err) if err?
      results = res.hits.hits or []
      done null, results

  {
    removeAllSlidesForLesson
    _remove
    _addOrUpdate
    remove
    addOrUpdate
    search
  }

module.exports = esc
