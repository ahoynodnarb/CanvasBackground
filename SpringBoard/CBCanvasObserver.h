#import <UIKit/UIKit.h>

@protocol CBCanvasObserver
@required
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithVideoURL:(NSURL *)URL;
- (void)setPlaying:(BOOL)playing;
@end