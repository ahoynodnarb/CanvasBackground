#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@protocol CBCanvasObserver
@required
@property (nonatomic, assign) BOOL shouldSuspend;
- (void)updateWithImage:(UIImage *)image;
- (void)setPlaying:(BOOL)playing;
- (void)invalidate;
@end