"use strict";

// module Pebble.UI

var UI = require('ui');

exports._null = null;

exports._makeCard = function (options) {
  return function () {
    var options_ = {};
    for (var opt in options) {
        if (options.hasOwnProperty(opt)) {
            options_[opt] = options[opt];
        }
    }
    return new UI.Card(options_);
  };
};

exports._windowShow = function (wnd) {
  return function () {
    wnd.show();
    return {};
  };
};
