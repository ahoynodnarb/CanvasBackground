#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "CBCanvasServer.h"
#import "CBCanvasObserver.h"

@interface CBViewController : UIViewController <CBCanvasObserver>
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, weak) CBCanvasServer *server;
- (instancetype)initWithCanvasServer:(CBCanvasServer *)server;
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithVideoURL:(NSURL *)URL;
- (void)invalidate;
@end