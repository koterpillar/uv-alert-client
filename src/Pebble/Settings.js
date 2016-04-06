"use strict";

// module Pebble.Settings

var Settings = require('settings');

exports._getOption = function (name) {
  return Settings.option(name);
};

exports._setOption = function (name, value) {
  return Settings.option(name, value);
};
