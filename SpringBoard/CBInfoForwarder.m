#import "CBInfoForwarder.h"
#import <MRYIPCCenter.h>

@interface SBMediaController
@property (nonatomic, readonly) NSString *nowPlayingBundleID;
+ (instancetype)sharedInstance;
@end

@interface CBInfoForwarder () {
    AVPlayerLooper *playerLooper;
    CPDistributedMessagingCenter *center;
}
@property (nonatomic, readonly) NSString *bundleID;
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
        center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        [center addTarget:self action:@selector(updateVideoWithURL:)];
        [center addTarget:self action:@selector(updateVideoWithPath:)];
        [center addTarget:self action:@selector(updateImageWithData:)];
        [center addTarget:self action:@selector(updatePlaybackState:)];
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
    if (![bundleID isEqualToString:self.bundleID]) return;
    NSString *videoURL = [userInfo objectForKey:@"URL"];
    NSURL *URL = [NSURL URLWithString:videoURL];
    [self updateVideo:URL];
}

- (void)updateVideoWithPath:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![bundleID isEqualToString:self.bundleID]) return;
    NSString *videoPath = [userInfo objectForKey:@"path"];
    NSURL *URL = [NSURL fileURLWithPath:videoPath];
    [self updateVideo:URL];
}


- (void)updateImageWithData:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![bundleID isEqualToString:self.bundleID]) return;
    NSData *data = [userInfo objectForKey:@"data"];
    [_player removeAllItems];
    UIImage *image = [UIImage imageWithData:data];
    [self executeObserverBlock:^(NSObject<CBObserver> *observer) {
        [observer updateWithImage:image];
    } completion:nil];
}

- (void)updatePlaybackState:(NSDictionary *)userInfo {
    NSString *bundleID = [userInfo objectForKey:@"bundleID"];
    if (![bundleID isEqualToString:self.bundleID]) return;
    NSNumber *state = [userInfo objectForKey:@"state"];
    BOOL playing = [state boolValue];
    if (playing == self.playing) return;
    self.playing = playing;
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