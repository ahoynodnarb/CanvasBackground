#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface CSCoverSheetViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
@end
@interface SBMediaController : NSObject
+ (id)sharedInstance;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end
@interface SPTCanvasTrackCheckerImplementation : NSObject
@property (nonatomic, strong) NSString *previousURI;
- (id)initWithTestManager:(id)arg1;
-(_Bool)isCanvasEnabledForTrack:(id)arg1;
-(void)saveCanvasWithURL:(NSURL *)canvasURL;
@end
@interface SPTStatefulPlayer : NSObject
-(id)currentTrack;
-(void)sendNotification;
@end
@interface SPTPlayerTrack : NSObject
@property(copy, nonatomic) NSURL *URI;
@end
@interface LSApplicationProxy
+(LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)bundleId;
-(NSURL *)containerURL;
@end

SPTPlayerTrack *currentTrack;
SPTCanvasTrackCheckerImplementation *impl;
NSString *downloadedItem = @"remove";