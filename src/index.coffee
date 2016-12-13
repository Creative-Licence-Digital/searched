es     = require('elasticsearch')
async  = require('async')
_      = require('underscore')
seneca = require('seneca')()

module.exports = (options) ->
 
  pluginName = 'search'
  indexName  = options.index
  esClient   = null

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

  _extractCourseData = (course) ->
    title: course.title
    description: course.description

  _extractLessonData = (lesson) ->
    title: lesson.title
    description: lesson.description

  _extractSlideText = (slide) ->
    separator = "\n"
    mediaRegex = /\.(png|jpg|jpgeg|avi|mp3|mp4)$/i
    if _.isArray(slide)
      return slide.map(_extractSlideText).join(separator)
    else if _.isObject(slide)
      _.values(slide).map(_extractSlideText).join(separator)
    else if _.isString(slide) and not(slide.match(mediaRegex))
      slide
    else
      ""

  _extractSlideData = (slide) ->
    data: slide
    text: extractSlideText(slide.data)

  # Available actions on the plugin 
  @add { init: pluginName }, (args, done) ->
    console.log("Connecting to Elastic Search", options.host)
    esClient = new es.Client
      host: options.host

    esClient.ping { requestTimeout: Infinity }, (err) -> done(err)

  @add { cmd: 'update', type: 'course' }, (args, done) ->
    id  = args.doc._id.toString()
    doc = _extractCourseData(args.doc)
    _addOrUpdate { type: 'course', id, doc }, done

  @add { cmd: 'update', type: 'lesson' }, (args, done) =>
    id    = args.doc._id.toString()
    doc   = _extractLessonData(args.doc)
    tasks = []
    tasks.push (n) -> _addOrUpdate({ type: 'lesson', id, doc }, n)
    tasks = tasks.concat (args.doc.configuration?.slides or []).map (slide) => (n) =>
      doc = _.extend slide, _id: id + "-" + slide.name
      @act { cmd: 'update', type: 'slide', doc }, n
    async.series tasks, done
    
  @add { cmd: 'update', type: 'slide' }, (args, done) ->
    id  = args.doc._id.toString()
    doc = _extractLessonData(args.doc)
    _addOrUpdate { type: 'slide', id, doc }, done

  @add { cmd: 'delete' }, (args, done) ->
    _remove { type: args.type, id: args.id }, done

  return { name: pluginName }

