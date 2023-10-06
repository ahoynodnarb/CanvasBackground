#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@protocol CBCanvasObserver
@required
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithVideoItem:(AVPlayerItem *)item;
- (void)setPlaying:(BOOL)playing;
- (void)invalidate;
@end