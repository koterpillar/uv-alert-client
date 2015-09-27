/**
 * Main application code.
 */

var ajax = require('ajax');
var UI = require('ui');

var main = new UI.Card({
  title: 'UV Alert',
  subtitle: 'Useless screen',
  body: 'Press any button.'
});

function sendToken() {
  ajax(
      {
        url: SERVER_URL,
        method: 'POST',
        data: {
          'token': getToken(),
        }
      },
      function (data) {
        main.subtitle("Token sent.");
      },
      function (error) {
        main.subtitle("Error sending token.");
      }
  );
}

main.show();
