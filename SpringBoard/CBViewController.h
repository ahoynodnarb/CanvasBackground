#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface CBViewController : UIViewController
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, assign) BOOL playerPlaying;
- (void)recreateCanvasWithVideoURL:(NSURL *)currentVideoURL imageData:(NSData *)imageData;
- (void)togglePlayer:(NSNotification *)note;
@end