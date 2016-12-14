es      = require('elasticsearch')
async   = require('async')
_       = require('underscore')
seneca  = require('seneca')()
queries = require('./queries')
format  = require('./format')
nbCourses = 0
nbLessons = 0
nbSlides  = 0

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

  @add { cmd: 'index', type: 'course' }, (args, done) ->
    courses = args.docs
    tasks   = courses.map (course) ->
      id     = course._id.toString()
      doc    = format.course(course)
      update = esc._addOrUpdate({ type: "course", id, doc })
      [{ update: { _id: update.id, _type: update.type, _index: update.index }},
        update.body ]

    tasks = _.flatten(tasks)
  
    nbCourses += courses.length
    esClient.bulk body: tasks, (err, resp) ->
      console.error(err) if err?
      done err, {}

  @add { cmd: 'index', type: 'lesson' }, (args, done) ->
    lessons = args.docs
    ids     = lessons.map (l) -> l._id.toString()
    tasks   = lessons.map (lesson) ->
      id     = lesson._id.toString()
      doc    = format.lesson(lesson)
      slides = lesson.configuration.slides or []
      update = esc._addOrUpdate({ type: "lesson", id, doc })

      tasks  = [{ update: { _id: update.id, _type: update.type, _index: update.index }},
                  update.body ]

      tasks  = tasks.concat slides.map (s) ->
        sid = id + "-" + s.name
        s   = _.extend s, { _id: sid, lesson: lesson }
        d   = format.slide(s)
        upd = esc._addOrUpdate({ type: "slide", id: sid, doc: d })
        [{ update: { _id: upd.id, _type: upd.type, _index: upd.index }},
          upd.body ]
        
    nbLessons += lessons.length

    tasks = _.flatten(tasks)
    esc._removeAllSlidesForLessons ids, (err) ->
      console.error(err) if err?
      esClient.bulk body: tasks, (err, resp) ->
        console.error(err) if err?
        done err, {}
  
  # Takes 2 parameters, type of document, and id of the document
  @add { cmd: 'delete' }, (args, done) ->
    esc.remove { type: args.type, id: args.id }, done

  @add { cmd: 'search' }, (args, done) ->
    esc.search { type: args.type, query: args.query, app: args.app }, done

  # Remove all indexes
  @add { cmd: 'destroy' }, (args, done) ->
    esClient.indices.delete { index: '_all' }, (err, res) -> done(err)

  return { name: pluginName }
