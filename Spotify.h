#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface CSCoverSheetViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) AVPlayerLooper *playerLooper;
- (void)setCanvas;
@end
@interface SPTVideoDisplayView : UIView
// @property(readonly, nonatomic) AVPlayerLayer *playerLayer;
@property(nonatomic, strong, readwrite) AVPlayer *player;
@end
@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPaused;
- (BOOL)isPlaying;
@end