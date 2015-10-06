/**
 * Main application code.
 */

// TODO: Support location setting
var LOCATION = "Melbourne";

function pass() {}

function logError(where) {
  return function (errorString) {
    console.log("Error: " + where + ": " + errorString);
  };
}

function setLocationSubscription(loc) {
  Pebble.timelineSubscriptions(
    function (topics) {
      var haveSubscription = false;

      for (var i = 0; i < topics.length; i++) {
        if (topics[i] == loc) {
          haveSubscription = true;
        } else {
          Pebble.timelineUnsubscribe(
              topics[i], pass, logError('timelineUnsubscribe'));
        }

        if (!haveSubscription) {
          Pebble.timelineSubscribe(loc, pass, logError('timelineSubscribe'));
        }
      }
    },
    logError('timelineSubscriptions')
  );
}

var ajax = require('ajax');
var UI = require('ui');

var main = new UI.Card({
  title: 'UV Alert',
  subtitle: 'Useless screen',
  body: 'Press any button.'
});

main.show();

setLocationSubscription(LOCATION);
