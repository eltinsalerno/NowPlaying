//
// NowPlaying.m
// Now Playing Cordova Plugin
//

#import "NowPlaying.h"
#import <AVFoundation/AVFoundation.h>
@implementation NowPlaying
static NowPlaying *nowPlaying = nil;


static NSString* artist = nil;
static NSString* title = nil;
static NSString* album = nil;
static MPMediaItemArtwork* artwork = nil;
static NSNumber* duration  = nil;
static NSNumber* elapsed  = nil;

- (void)pluginInitialize
{
    NSLog(@"NowPlaying plugin start");
}

- (void)updateMetas:(CDVInvokedUrlCommand*)command
{
    NSLog(@"NowPlaying updateMetas");
    artist = [command.arguments objectAtIndex:0];
    title = [command.arguments objectAtIndex:1];
    album = [command.arguments objectAtIndex:2];
    NSString *cover = [command.arguments objectAtIndex:3];
    duration = [command.arguments objectAtIndex:4];
    elapsed = [command.arguments objectAtIndex:5];
    NSLog(@"updateMetas artist %@",artist);
    NSLog(@"updateMetas title %@",title);
    NSLog(@"updateMetas album %@",album);
    NSLog(@"updateMetas cover %@",cover);
    NSLog(@"updateMetas duration %@",duration);
    NSLog(@"updateMetas elapsed %@",elapsed);
    // async cover loading
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *image = nil;
        if (![cover isEqual: @""]) { // cover exist
            
            if ([cover hasPrefix: @"http://"] || [cover hasPrefix: @"https://"]) { // cover from url
                NSURL *imageURL = [NSURL URLWithString:cover];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                image = [UIImage imageWithData:imageData];
            }
            else { // cover from device
                NSString *fullPath = [NSString stringWithFormat:@"%@", cover];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
                if (fileExists) {
                    NSLog(@"NowPlaying fileExists");
                    image = [UIImage imageNamed:fullPath];
                }else{
                    NSLog(@"NowPlaying fileNOexists %@",fullPath);
                    image = [UIImage imageNamed:@"no-image"];
                }
            }
        }
        else {
            image = [UIImage imageNamed:@"no-image"];
        }
        CGImageRef cgref = [image CGImage];
        CIImage *cim = [image CIImage];
        if (cim != nil || cgref != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
                    artwork = [[MPMediaItemArtwork alloc] initWithImage: image];
                    [self applyMetas];
                }
            });
        }
    });
}

typedef void (^WaitCompletionBlock)();
void waitFor(NSTimeInterval duration, WaitCompletionBlock completion)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^
                   { completion(); });
}


- (void)setMetas:(CDVInvokedUrlCommand*)command
{
    [self applyMetas];
}
- (void)applyMetas
{
    
   
    
    if (NSClassFromString(@"MPNowPlayingInfoCenter") && title != nil)  {
        waitFor(0.1, ^
                {
                    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
                    infoCenter.nowPlayingInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     artist, MPMediaItemPropertyArtist,
                                     title, MPMediaItemPropertyTitle,
                                     album, MPMediaItemPropertyAlbumTitle,
                                     artwork, MPMediaItemPropertyArtwork,
                                    duration, MPMediaItemPropertyPlaybackDuration,
                                    elapsed, MPNowPlayingInfoPropertyElapsedPlaybackTime,
                                     nil];
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    NSLog(@"NowPlaying currentTime %@",audioSession);
                    
                });
    }
}


- (void)receiveRemoteEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        NSString *subtype = @"other";
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"playpause clicked.");
               // [self applyMetas];
                subtype = @"nowPlayingPlayPause";
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"play clicked.");
                [self applyMetas];
                subtype = @"nowPlayingPlay";
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self applyMetas];
                NSLog(@"nowplaying pause clicked.");
                subtype = @"nowPlayingPause";
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                //[self previousTrack: nil];
                NSLog(@"prev clicked.");
                subtype = @"nowPlayingPrevTrack";
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"next clicked.");
                subtype = @"nowPlayingNextTrack";
                //[self nextTrack: nil];
                break;
                
            default:
                break;
        }
        
//        NSDictionary *dict = @{@"subtype": subtype};
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options: 0 error: nil];
 //       NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsStatement = [NSString stringWithFormat:@"document.dispatchEvent(new Event('%@'));", subtype];
         NSLog(@"jsonString %@",jsStatement);
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];  

    }
}

+(NowPlaying *)nowPlaying
{
    
    //get the same instance
    
    if (!nowPlaying)
    {
        nowPlaying = [[NowPlaying alloc] init];
    }
    
    return nowPlaying;
}

@end
