_ = require('underscore')

course = (course) ->
  title: course.title
  description: course.description
  app: course.audience?.application

lesson = (lesson) ->
  title: lesson.title
  description: lesson.description
  app: lesson.audience?.application

slideText = (slide) ->
  separator = "\n"
  mediaRegex = /\.(png|jpg|jpgeg|avi|mp3|mp4)$/i
  if _.isArray(slide)
    return slide.map(slideText).join(separator)
  else if _.isObject(slide)
    _.values(slide).map(slideText).join(separator)
  else if _.isString(slide) and not(slide.match(mediaRegex))
    slide
  else
    ""

slide = (slide) ->
  name: slide.name
  data: slide.data
  app: slide.lesson.audience?.application
  lesson: slide.lesson._id.toString()
  text: slideText(slide.data)

module.exports = { course, lesson, slide }

