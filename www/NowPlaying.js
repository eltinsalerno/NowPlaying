//
// NowPlaying.js
// Now Playing Cordova Plugin
//

var nowPlaying = module.exports;


//params = [artist, title, album, cover, duration]
nowPlaying.updateMetas = function(success, fail, params) {
    cordova.exec(success, fail, 'NowPlaying', 'updateMetas', params);
};

nowPlaying.setMetas = function(success, fail, params) {
    cordova.exec(success, fail, 'NowPlaying', 'setMetas', params);
};

nowPlaying.receiveRemoteEvent = function(event) {
	var ev = new Event("remote-event");
	 document.dispatchEvent(ev);
}
