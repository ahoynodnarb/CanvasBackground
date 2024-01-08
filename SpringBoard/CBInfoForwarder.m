#import "CBInfoForwarder.h"
#import <rocketbootstrap/rocketbootstrap.h>

@interface SBMediaController
@property (nonatomic, readonly) NSString *nowPlayingBundleID;
+ (instancetype)sharedInstance;
@end

@interface CBInfoForwarder () {
    AVPlayerLooper *playerLooper;
    CPDistributedMessagingCenter *center;
    NSMutableSet *registeredBundles;
}
@property (nonatomic, readonly) NSString *bundleID;
- (void)registerBundle:(NSString *)bundle;
- (void)updateVideo:(NSURL *)URL;
- (void)updateVideoWithURL:(NSDictionary *)userInfo;
- (void)updateVideoWithPath:(NSDictionary *)userInfo;
- (void)updateImageWithData:(NSDictionary *)userInfo;
- (void)updatePlaybackState:(NSDictionary *)userInfo;
- (BOOL)bundleValid:(NSString *)bundleID;
- (void)executeObserverBlock:(void (^)(NSObject<CBObserver> *))block completion:(void (^)(void))completion;
@end

@implementation CBInfoForwarder

+ (instancetype)sharedForwarder {
    static CBInfoForwarder *sharedForwarder;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        sharedForwarder = [[self alloc] init];
    });
    return sharedForwarder;
}

- (instancetype)init {
    if (self = [super init]) {
        _player = [[AVQueuePlayer alloc] init];
        _player.muted = YES;
        _player.preventsDisplaySleepDuringVideoPlayback = NO;
        self.observers = [NSMutableSet set];
        rocketbootstrap_distributedmessagingcenter_apply(center);
		[center runServerOnCurrentThread];
		[center registerForMessageName:@"registerBundle" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updateVideoWithPath" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updateVideoWithURL" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updateImageWithData" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updatePlaybackState" target:self selector:@selector(handleMessage:userInfo:)];
        registeredBundles = [NSMutableSet set];
    }
    return self;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self executeObserverBlock:^(NSObject<CBObserver> *observer) {
        [observer setPlaying:playing];
    } completion:^{
        if (_playing) [_player play];
        else [_player pause];
    }];
}

- (NSString *)bundleID {
    SBMediaController *sharedController = [NSClassFromString(@"SBMediaController") sharedInstance];
    return [sharedController nowPlayingBundleID];
}

- (void)addObserver:(id<CBObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)executeObserverBlock:(void (^)(NSObject<CBObserver> *))block completion:(void (^)(void))completion {
    // ensure that all finish at the same time
    dispatch_group_t group = dispatch_group_create();
    for (NSObject<CBObserver> *observer in self.observers) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(observer);
            dispatch_group_leave(group);
        });
    }
    if (completion) {
        dispatch_group_notify(group, dispatch_get_main_queue(), completion);
    }
}

- (void)invalidate {
    [self executeObserverBlock:^(NSObject<CBObserver> *observer) {
        [observer invalidate];
    } completion:nil];
    [_player removeAllItems];
}

- (void)handleMessage:(NSString *)messageName userInfo:(NSDictionary *)userInfo {
    if ([messageName isEqualToString:@"registerBundle"]) {
        [self registerBundle:[userInfo objectForKey:@"bundleID"]];
        return;
    }
    if ([messageName isEqualToString:@"updateVideoWithPath"]) {
        [self updateVideoWithPath:userInfo];
        return;
    }
    if ([messageName isEqualToString:@"updateVideoWithURL"]) {
        [self updateVideoWithURL:userInfo];
        return;
    }
    if ([messageName isEqualToString:@"updateImageWithData"]) {
        [self updateImageWithData:userInfo];
        return;
    }
    if ([messageName isEqualToString:@"updatePlaybackState"]) {
        [self updatePlaybackState:userInfo];
        return;
    }
}

- (BOOL)bundleValid:(NSString *)bundleID {
    return !bundleID || [bundleID isEqualToString:self.bundleID];
}

- (void)updateVideo:(NSURL *)URL {
    AVAsset *asset = [AVAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [_player removeAllItems];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 1)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        UIImage *image = [UIImage imageWithCGImage:im];
        [self executeObserverBlock:^(NSObject<CBObserver> *observer) {
            [observer updateWithImage:image];
        } completion:nil];
    }];
    playerLooper = [AVPlayerLooper playerLooperWithPlayer:_player templateItem:item];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
}

- (void)updateVideoWithURL:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![self bundleValid:bundleID]) return;
    NSString *videoURL = [userInfo objectForKey:@"URL"];
    NSURL *URL = [NSURL URLWithString:videoURL];
    [self updateVideo:URL];
}

- (void)updateVideoWithPath:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![self bundleValid:bundleID]) return;
    NSString *videoPath = [userInfo objectForKey:@"path"];
    NSURL *URL = [NSURL fileURLWithPath:videoPath];
    [self updateVideo:URL];
}


- (void)updateImageWithData:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![self bundleValid:bundleID]) return;
    NSData *data = [userInfo objectForKey:@"data"];
    [_player removeAllItems];
    UIImage *image = [UIImage imageWithData:data];
    [self executeObserverBlock:^(NSObject<CBObserver> *observer) {
        [observer updateWithImage:image];
    } completion:nil];
}

- (void)updatePlaybackState:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![self bundleValid:bundleID]) return;
    NSNumber *state = [userInfo objectForKey:@"state"];
    BOOL playing = [state boolValue];
    if (playing == self.playing) return;
    self.playing = playing;
}

- (BOOL)bundleRegistered:(NSString *)bundle {
    return [registeredBundles containsObject:bundle];
}

- (void)registerBundle:(NSString *)bundle {
    [registeredBundles addObject:bundle];
}

- (void)setSuspended:(BOOL)suspended {
    if (suspended) [_player pause];
    else if ([self playing]) [_player play];
}

- (void)observerChangedSuspension:(NSObject<CBObserver> *)observer {
    for (NSObject<CBObserver> *observer in self.observers) {
        if (!observer.shouldSuspend) {
            [self setSuspended:NO];
            return;
        }
    }
    [self setSuspended:YES];
}

@end