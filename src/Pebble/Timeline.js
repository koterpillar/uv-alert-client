"use strict";

// module Pebble.Timeline

exports._getSubscriptions = function (callback) {
  // TODO: error callback
  Pebble.timelineSubscriptions(callback);
};

exports._subscribe = function (topic, callback) {
  Pebble.timelineSubscribe(topic, callback);
};
exports._unsubscribe = function (topic, callback) {
  Pebble.timelineUnsubscribe(topic, callback);
};
