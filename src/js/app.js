/**
 * Main application code.
 */

var SERVER_URL = 'https://uvalert.koterpillar.com';

var BOM_INFO_URL = 'http://www.bom.gov.au/data-access/3rd-party-attribution.shtml';

var LOCATION_MAX_AGE = 60 * 60 * 24; // seconds

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
  var locations = Settings.option('locations');
  if (locations && locations.timestamp &&
      locations.timestamp >= (new Date()).getTime() - LOCATION_MAX_AGE) {
    callback(locations.data);
  } else {
    ajax(
      {
        url: SERVER_URL + '/locations',
        type: 'json'
      },
      function (data, status_, request) {
        locations = {
          data: data,
          timestamp: (new Date()).getTime()
        };
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
  title: "UV Alert",
  subtitle: getLocation(),
  body: "Use the timeline to view alerts.",
  action: {
    select: 'images/select-location.png',
    up: 'images/info.png'
  }
});

main.on('click', 'select', function () {
  getLocationList(function (locations) {
    var selected = getLocation();
    var selectedIndex = 0; // default to first element
    var items = locations.map(function (loc, i) {
      if (loc.city == selected) {
        selectedIndex = i;
      }
      return {
        title: loc.city
      };
    });
    var locationSelect = new UI.Menu({
      sections: [{
        title: "Select Location",
        items: items
      }]
    });
    locationSelect.setSelection(0, selectedIndex);
    locationSelect.on('select', function (e) {
      var loc = e.item.title;
      setLocation(loc);
      locationSelect.hide();
    });
    locationSelect.show();
  });
});

main.on('click', 'up', function () {
  var dataInfo = new UI.Card({
    title: "Data Information",
    body: "Some data on this app. is sourced from the Buerau of Meteorology." +
      "\n" + BOM_INFO_URL,
    scrollable: true
  });

  dataInfo.on('select', function () {
    // TODO: open the info URL on the phone
  });

  dataInfo.show();
});

main.show();

// Default location
if (!getLocation()) {
  setLocation("Melbourne");
}
