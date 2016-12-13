es     = require('elasticsearch')
seneca = require('seneca')()

module.exports = (options) ->
 
  pluginName = 'search'
  indexName  = options.index
  esClient   = null

  @add { init: pluginName }, (args, done) ->
    console.log("Connecting to Elastic Search", options.host)
    esClient = new es.Client
      host: options.host

    esClient.ping { requestTimeout: Infinity }, (err) -> done(err)

  _remove = ({ type, id }, done) ->
    esClient.delete
      index: indexName
      type: type
      id: id
    , (err, resp) ->
      console.error(err, resp)
      done(err, {})

  _addOrUpdate = ({ type, id, doc }, done) ->
    esClient.update
      index: indexName
      type: type
      id: id
      body:
        doc: doc
        upsert: doc
    , (err, resp) ->
      console.error(err) if err?
      console.error(resp)
      done err, {}

  @add { cmd: 'update', type: 'course' }, (args, done) ->
    _addOrUpdate { type: 'course', id: args.id, doc: args.doc }, done

  @add { cmd: 'update', type: 'lesson' }, (args, done) ->
    _addOrUpdate { type: 'lesson', id: args.id, doc: args.doc }, done
    # We want to remove every existing slide for the lesson
    

  @add { cmd: 'delete' }, (args, done) ->
    _remove { type: args.type, id: args.id }, done

  return { name: pluginName }

