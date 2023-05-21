#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "CBInfoTunnel.h"
#import "CBCanvasObserver.h"

@interface CBViewController : UIViewController <CBCanvasObserver>
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, weak) CBInfoTunnel *server;
- (instancetype)initWithCanvasServer:(CBInfoTunnel *)server;
- (void)setVisible:(BOOL)visible;
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithVideoURL:(NSURL *)URL;
- (void)invalidate;
@end