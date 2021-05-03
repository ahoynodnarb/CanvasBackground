#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface CSCoverSheetViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
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
@interface SPTPlayerTrack : NSObject
@end
@interface SPTStatefulPlayer : NSObject
-(SPTPlayerTrack *)currentTrack;
-(void)sendNotification;
@end
@interface SPTCanvasModelImplementation : NSObject
@property(readonly, copy, nonatomic) NSURL *contentURL;
@end
@interface SPTCanvasContentLayerViewControllerViewModel : NSObject
@property(readonly, nonatomic) SPTCanvasModelImplementation *canvasModel;
@end
@interface SPTCanvasNowPlayingContentLoader : NSObject
- (SPTCanvasContentLayerViewControllerViewModel *)canvasViewControllerViewModelForTrack:(id)arg1;
@end

SPTCanvasNowPlayingContentLoader *loader;
BOOL sentNotificationOnce;
BOOL shouldPlayCanvas;