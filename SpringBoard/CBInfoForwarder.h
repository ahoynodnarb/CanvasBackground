// this class acts as a proxy to allow multiple observers to act as servers for spotify

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CBObserver.h"

@interface CBInfoForwarder : NSObject
@property (nonatomic, strong) NSMutableSet *observers;
@property (nonatomic, readonly) AVQueuePlayer *player;
@property (nonatomic, assign) BOOL playing;
+ (instancetype)sharedForwarder;
- (void)addObserver:(NSObject<CBObserver> *)observer;
- (void)removeObserver:(NSObject<CBObserver> *)observer;
- (void)invalidate;
- (BOOL)bundleRegistered:(NSString *)bundle;
- (void)setSuspended:(BOOL)suspended;
- (void)observerChangedSuspension:(NSObject<CBObserver> *)observer;
@end