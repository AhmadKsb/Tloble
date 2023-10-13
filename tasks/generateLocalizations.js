var childProcess = require('child_process');

//Note: when a new localization sheet is created, add the exact name of the newly created sheet to the 'sheetsNames' array below,
//and make sure to add a folder with the same name under 'i18n' folder in flutter and web projects.
//sheets names
var sheetsNames = ['WKBeast'];

var defaultSheetName = sheetsNames[0];

function runScript(scriptPath, argv, callback) {
    var invoked = false;
    var process = childProcess.fork(scriptPath, argv);

    process.on('error', function (err) {
        if (invoked) return;
        invoked = true;
        callback(err);
    });

    process.on('exit', function (code) {
        if (invoked) return;
        invoked = true;
        var err = code === 0 ? null : new Error('exit code ' + code);
        callback(err);
    });

}

function translateAll() {
    for (var i = 0; i < sheetsNames.length; i++) {
        var path = sheetsNames[i];
        var sheet = sheetsNames[i] + '!A2:F';

        if (path === defaultSheetName) {
            runScript('./translate.js', [sheet], function (err) {
                if (err) {
                    console.log('error is generate localizations 1: ' + err);
                }
            });
        } else {
            runScript('./translate.js', [sheet, path], function (err) {
                if (err) {
                    console.log('error is generate localizations 2: ' + err);
                }
            });
        }
    }
}

translateAll();
