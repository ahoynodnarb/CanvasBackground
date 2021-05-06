#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface CSCoverSheetViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) AVPlayerItem *previousItem;
-(void)loopVideo;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
-(void)togglePlayer:(NSNotification *)note;
@end
@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
-(void)togglePlayer:(NSNotification *)note;
@end
@interface SBApplication : NSObject
@end
@interface SBMediaController : NSObject
+ (id)sharedInstance;
-(BOOL)isApplicationActivityActive;
-(SBApplication *)nowPlayingApplication;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end

BOOL shouldPlayCanvas;