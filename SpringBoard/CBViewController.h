#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface SBApplication : NSObject
@end
@interface SBMediaController : NSObject
+ (id)sharedInstance;
-(BOOL)isApplicationActivityActive;
-(SBApplication *)nowPlayingApplication;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end
@interface CBViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL shouldPlayCanvas;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
-(void)togglePlayer:(NSNotification *)note;
@end