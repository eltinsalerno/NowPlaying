//
// NowPlaying.h
// Now Playing Cordova Plugin
//
#import <Cordova/CDVPlugin.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>


@interface NowPlaying : CDVPlugin {
    
}
+(NowPlaying*)nowPlaying;
- (void)setMetas:(CDVInvokedUrlCommand*)command;
- (void)updateMetas:(CDVInvokedUrlCommand*)command;
- (void)receiveRemoteEvent:(UIEvent *)receivedEvent;

@end
