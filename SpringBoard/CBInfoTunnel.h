// this class acts as a proxy to allow multiple observers to act as servers for spotify

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CBCanvasObserver.h"

@interface CBInfoTunnel : NSObject
@property (nonatomic, strong) NSMutableSet *observers;
@property (nonatomic, readonly) AVQueuePlayer *player;
+ (instancetype)sharedTunnel;
- (void)addObserver:(NSObject<CBCanvasObserver> *)observer;
- (void)removeObserver:(NSObject<CBCanvasObserver> *)observer;
- (void)invalidate;
<<<<<<< Updated upstream
- (BOOL)updateCanvas;
- (void)updateWithImage:(UIImage *)image;
- (void)setPlaying:(BOOL)playing;
=======
- (void)updateWithVideoInfo:(NSDictionary *)info;
- (void)updateWithImageData:(NSData *)data;
- (void)setPlaying:(NSNumber *)number;
- (void)setSuspended:(BOOL)suspended;
- (void)observerChangedSuspension:(NSObject<CBCanvasObserver> *)observer;
>>>>>>> Stashed changes
@end