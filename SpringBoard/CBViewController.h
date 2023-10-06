#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "CBInfoTunnel.h"
#import "CBCanvasObserver.h"

@interface CBViewController : UIViewController <CBCanvasObserver>
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, weak) CBInfoTunnel *server;
- (instancetype)initWithCanvasServer:(CBInfoTunnel *)server;
- (void)setSuspended:(BOOL)suspended;
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithVideoItem:(AVPlayerItem *)item;
- (void)invalidate;
@end