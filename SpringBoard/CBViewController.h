#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "CBInfoForwarder.h"
#import "CBObserver.h"

@interface CBViewController : UIViewController <CBObserver>
@property (nonatomic, weak) CBInfoForwarder *infoForwarder;
@property (nonatomic, assign) BOOL shouldSuspend;
- (instancetype)initWithInfoForwarder:(CBInfoForwarder *)infoForwarder;
- (void)setPlaying:(BOOL)playing;
- (void)updateWithImage:(UIImage *)image;
- (void)invalidate;
@end