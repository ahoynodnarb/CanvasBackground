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