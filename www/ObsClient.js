var exec = require("cordova/exec");
var ObsClient = {
  upload: function (params, success, error) {
    exec(success, error, "ObsClientPlugin", "upload", params);
  }
};

module.exports = ObsClient;