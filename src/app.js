/**
 * Main application code.
 */

// TODO: Support location setting
var LOCATION = "Melbourne";

var ajax = require('ajax');
var UI = require('ui');

Pebble.timelineSubscriptions(
  function(topics) {
    if (topics.length === 0) {
      Pebble.timelineSubscribe(LOCATION);
    }
  }
);

var main = new UI.Card({
  title: 'UV Alert',
  subtitle: 'Useless screen',
  body: 'Press any button.'
});

main.show();
