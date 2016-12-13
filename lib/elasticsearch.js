// Generated by CoffeeScript 1.10.0
(function() {
  var queries;

  queries = require('./queries');

  module.exports = function(esClient, indexName) {
    return {
      removeAllSlidesForLesson: function(lessonId, done) {
        return done();
      },
      remove: function(arg, done) {
        var id, type;
        type = arg.type, id = arg.id;
        return esClient["delete"]({
          index: indexName,
          type: type,
          id: id
        }, function(err, resp) {
          return done(err, {});
        });
      },
      addOrUpdate: function(arg, done) {
        var doc, id, type;
        type = arg.type, id = arg.id, doc = arg.doc;
        return esClient.update({
          index: indexName,
          type: type,
          id: id,
          body: {
            doc: doc,
            upsert: doc
          }
        }, function(err, resp) {
          return done(err, {});
        });
      },
      search: function(arg, done) {
        var dict, query, type;
        type = arg.type, query = arg.query;
        dict = {
          "courseOrLesson": "course,lesson",
          "slide": "slide"
        };
        return esClient.search({
          index: indexName,
          type: dict[type],
          body: {
            query: queries[type](query)
          }
        }, function(err, res) {
          var results;
          if (err != null) {
            return done(err);
          }
          results = res.hits.hits || [];
          return done(null, results);
        });
      }
    };
  };

}).call(this);