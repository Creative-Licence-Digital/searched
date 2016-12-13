es      = require('elasticsearch')
async   = require('async')
_       = require('underscore')
seneca  = require('seneca')()
queries = require('./queries')
format  = require('./format')

module.exports = (options) ->
 
  pluginName = 'search'
  indexName  = options.index
  esClient   = null # Direct reference to the Elastic Search Client
  esc        = null # Helper functions to interact with the ES instance

  # Available actions on the plugin 
  @add { init: pluginName }, (args, done) ->
    console.log("Connecting to Elastic Search", options.host)
    esClient = new es.Client host: options.host
    esc      = require('./elasticsearch')(esClient, indexName)
    esClient.ping { requestTimeout: Infinity }, (err) -> done(err)

  @add { cmd: 'update', type: 'course' }, (args, done) ->
    id  = args.doc._id.toString()
    doc = format.course(args.doc)
    esc.addOrUpdate { type: 'course', id, doc }, done

  @add { cmd: 'update', type: 'lesson' }, (args, done) =>
    id    = args.doc._id.toString()
    doc   = format.lesson(args.doc)
    tasks = []
    tasks.push (n) -> esc.addOrUpdate({ type: 'lesson', id, doc }, n)
    tasks.push (n) -> esc.removeAllSlidesForLesson(id, n)
    tasks = tasks.concat (args.doc.configuration?.slides or [])[0..0].map (slide) => (n) =>
      ndoc = _.extend slide, _id: (id + "-" + slide.name), lesson: args.doc.toJSON()
      @act { cmd: 'update', type: 'slide', doc: ndoc }, n
    async.series tasks, done
    
  @add { cmd: 'update', type: 'slide' }, (args, done) ->
    id   = args.doc._id.toString()
    ndoc = format.slide(args.doc)
    esc.addOrUpdate { type: 'slide', id, doc: ndoc }, done

  @add { cmd: 'delete' }, (args, done) ->
    esc.remove { type: args.type, id: args.id }, done

  @add { cmd: 'search' }, (args, done) ->
    esc.search { type: args.type, query: args.query }, done

  return { name: pluginName }

