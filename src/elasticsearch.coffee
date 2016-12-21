queries = require './queries'

esc = (esClient, indexName) ->
  _removeAllSlidesForLessons = (lessonIds, done) ->
    esClient.deleteByQuery
      index: indexName
      type: 'slide'
      body:
        query:
          terms: lesson: lessonIds
    , done

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

  search = ({ type, query, app }, done) ->
    dict = { "courseOrLesson": "course,lesson", "slides": "slide" }
    esClient.search
      index: indexName
      type: dict[type]
      body: query: queries[type](query, app)
    , (err, res) ->
      return done(err) if err?
      results = res.hits.hits or []
      done null, results

  {
    _removeAllSlidesForLessons
    _remove
    _addOrUpdate
    remove
    addOrUpdate
    search
  }

module.exports = esc
