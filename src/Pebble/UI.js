"use strict";

// module Pebble.UI

var UI = require('ui');

exports._makeCard = function (options) {
  return function () {
    var options_ = {};
    for (var opt in options) {
        if (options.hasOwnProperty(opt)) {
            options_[opt] = options[opt];
        }
    }
    // FIXME: icon, subicon, banner, style, actions are wrong
    options_.icon = null;
    options_.subicon = null;
    options_.banner = null;
    options_.style = "small";
    options_.actions = {};
    return new UI.Card(options_);
  };
};

exports._windowShow = function (wnd) {
  return function () {
    wnd.show();
    return {};
  };
};
