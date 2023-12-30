// this class acts as a proxy to allow multiple observers to act as servers for spotify

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CBCanvasObserver.h"

@interface CBInfoTunnel : NSObject
@property (nonatomic, strong) NSMutableSet *observers;
@property (nonatomic, readonly) AVQueuePlayer *player;
@property (nonatomic, assign) BOOL playing;
+ (instancetype)sharedTunnel;
- (void)addObserver:(NSObject<CBCanvasObserver> *)observer;
- (void)removeObserver:(NSObject<CBCanvasObserver> *)observer;
- (void)executeObserverBlock:(void (^)(NSObject<CBCanvasObserver> *))block completion:(void (^)(void))completion;
- (void)invalidate;
- (void)updateVideo:(NSURL *)URL;
- (void)updateVideoWithURL:(NSString *)videoURL;
- (void)updateVideoWithPath:(NSString *)videoPath;
- (void)updateWithImageData:(NSData *)data;
- (void)setSuspended:(BOOL)suspended;
- (void)observerChangedSuspension:(NSObject<CBCanvasObserver> *)observer;
@end