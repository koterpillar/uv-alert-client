/**
 * Main application code.
 */

var SERVER_URL = 'https://uvalert.koterpillar.com';

var ajax = require('ajax');
var Settings = require('settings');
var UI = require('ui');

function pass() {}

function logError(where) {
  return function () {
    var errorString = Array.prototype.slice.call(arguments).join(", ");
    console.log("Error: " + where + ": " + errorString);
  };
}

function getLocationList(callback) {
  if (Settings.option('locations')) {
    callback(Settings.option('locations'));
  } else {
    ajax(
      {
        url: SERVER_URL + '/locations',
        type: 'json'
      },
      function (locations, status_, request) {
        Settings.option('locations', locations);
        getLocationList(callback);
      },
      logError("getLocationList")
    );
  }
}

function getLocation() {
  return Settings.option('location');
}

function setLocation(value) {
  Settings.option('location', value);
  updateLocationSubscription();
  main.subtitle(value);
}

function updateLocationSubscription() {
  var loc = getLocation();
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

var main = new UI.Card({
  title: 'UV Alert',
  subtitle: getLocation(),
  body: 'Use the timeline to view alerts.',
  action: {
    select: 'images/select-location.png'
  }
});

main.on('click', 'select', function () {
  getLocationList(function (locations) {
    var locationSelect = new UI.Menu({
      sections: [{
        title: "Select Location",
        items: locations
      }]
    });
    locationSelect.on('select', function (e) {
      var loc = e.item.title;
      setLocation(loc);
      locationSelect.hide();
    });
    locationSelect.show();
  });
});

main.show();

// Default location
if (!getLocation()) {
  setLocation("Melbourne");
}
