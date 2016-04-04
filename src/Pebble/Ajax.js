"use strict";

// module Pebble.Ajax

var pebbleAjax = require('ajax');

exports.ajaxImpl = function (url, callback) {
  pebbleAjax(
    {
      url: url,
      type: 'json' // TODO: other types
    },
    function (data, status_, request) {
      callback(data);
    }
    // TODO: error callback
  );
};
