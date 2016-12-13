seneca = require('seneca')()
plugin = require './index'

seneca.use(plugin)
seneca.ready (err) ->
  if err?
    console.error(err)
    process.exit()
  else
    data =
      title: "test course"

    seneca.act { cmd: 'update', type: 'course', id: "kjfldksjfldskj", doc: data }, (err, res) ->
      console.error(err, res)
      seneca.act { cmd: 'delete', type: 'course', id: "kjfldksjfldskj" }, (err, res) ->
        console.error(err, res)
