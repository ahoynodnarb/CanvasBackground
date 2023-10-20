#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "CBInfoTunnel.h"
#import "CBCanvasObserver.h"

@interface CBViewController : UIViewController <CBCanvasObserver>
@property (nonatomic, weak) CBInfoTunnel *infoTunnel;
@property (nonatomic, assign) BOOL shouldSuspend;
- (instancetype)initWithInfoTunnel:(CBInfoTunnel *)infoTunnel;
- (void)setPlaying:(BOOL)playing;
- (void)updateWithImage:(UIImage *)image;
- (void)invalidate;
@end