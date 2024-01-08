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
- (void)executeObserverBlock:(void (^)(NSObject<CBObserver> *))block completion:(void (^)(void))completion;
- (void)invalidate;
- (void)updateVideo:(NSURL *)URL;
- (void)updateVideoWithURL:(NSDictionary *)userInfo;
- (void)updateVideoWithPath:(NSDictionary *)userInfo;
- (void)updateImageWithData:(NSDictionary *)userInfo;
- (void)updatePlaybackState:(NSDictionary *)userInfo;
- (void)setSuspended:(BOOL)suspended;
- (void)observerChangedSuspension:(NSObject<CBObserver> *)observer;
@end