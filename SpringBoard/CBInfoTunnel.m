#import "CBInfoTunnel.h"
#import <MRYIPCCenter.h>

@interface CBInfoTunnel () {
    AVPlayerLooper *playerLooper;
    MRYIPCCenter *center;
}
@end

@implementation CBInfoTunnel

+ (instancetype)sharedTunnel {
    static CBInfoTunnel *sharedTunnel;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        sharedTunnel = [[self alloc] init];
    });
    return sharedTunnel;
}

- (instancetype)init {
    if (self = [super init]) {
        _player = [[AVQueuePlayer alloc] init];
        _player.muted = YES;
        _player.preventsDisplaySleepDuringVideoPlayback = NO;
        self.observers = [NSMutableSet set];
        center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        [center addTarget:self action:@selector(updateWithVideoInfo:)];
        [center addTarget:self action:@selector(updateWithImageData:)];
        [center addTarget:self action:@selector(updatePlaybackState:)];
    }
    return self;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self executeObserverBlock:^(NSObject<CBCanvasObserver> *observer) {
        [observer setPlaying:playing];
    } completion:^{
        if (_playing) [_player play];
        else [_player pause];
    }];
}

- (void)addObserver:(id<CBCanvasObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBCanvasObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)executeObserverBlock:(void (^)(NSObject<CBCanvasObserver> *))block completion:(void (^)(void))completion {
    // ensure that all finish at the same time
    dispatch_group_t group = dispatch_group_create();
    for (NSObject<CBCanvasObserver> *observer in self.observers) {
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
    [self executeObserverBlock:^(NSObject<CBCanvasObserver> *observer) {
        [observer invalidate];
    } completion:nil];
    [_player removeAllItems];
}

- (void)updateWithVideoInfo:(NSDictionary *)info {
    NSURL *URL = [NSURL URLWithString:info[@"url"]];
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    if (!item) {
        NSData *imageData = info[@"fallback"];
        [self updateWithImageData:imageData];
        return;
    }
    [_player removeAllItems];
    playerLooper = [AVPlayerLooper playerLooperWithPlayer:_player templateItem:item];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 1)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        UIImage *image = [UIImage imageWithCGImage:im];
        [self executeObserverBlock:^(NSObject<CBCanvasObserver> *observer) {
            [observer updateWithImage:image];
        } completion:nil];
    }];
}

- (void)updateWithImageData:(NSData *)data {
    [_player removeAllItems];
    UIImage *image = [UIImage imageWithData:data];
    [self executeObserverBlock:^(NSObject<CBCanvasObserver> *observer) {
        [observer updateWithImage:image];
    } completion:nil];
}

- (void)updatePlaybackState:(NSNumber *)number {
    BOOL playing = [number boolValue];
    if (playing == self.playing) return;
    self.playing = playing;
}

- (void)setSuspended:(BOOL)suspended {
    if (suspended) [_player pause];
    else if (self.playing) [_player play];
}

- (void)observerChangedSuspension:(NSObject<CBCanvasObserver> *)observer {
    for (NSObject<CBCanvasObserver> *observer in self.observers) {
        if (!observer.shouldSuspend) {
            [self setSuspended:NO];
            return;
        }
    }
    [self setSuspended:YES];
}

@end