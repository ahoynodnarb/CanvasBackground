#import "CBInfoTunnel.h"
#import <MRYIPCCenter.h>
// #import <rocketbootstrap/rocketbootstrap.h>

@interface CBInfoTunnel () {
    AVQueuePlayer *player;
    BOOL playerPlaying;
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
        self.observers = [NSMutableSet set];
<<<<<<< Updated upstream
        self.center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
=======
        center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        [center addTarget:self action:@selector(updateWithVideoInfo:)];
        [center addTarget:self action:@selector(updateWithImageData:)];
        [center addTarget:self action:@selector(setPlaying:)];
>>>>>>> Stashed changes
    }
    return self;
}

- (AVQueuePlayer *)player {
    if (!player) {
        player = [[AVQueuePlayer alloc] init];
        player.muted = YES;
        player.preventsDisplaySleepDuringVideoPlayback = NO;
    }
    return player;
}

- (void)addObserver:(id<CBCanvasObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBCanvasObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)invalidate {
    for (id<CBCanvasObserver> observer in self.observers) {
        [observer invalidate];
    }
    [player removeAllItems];
}

<<<<<<< Updated upstream
- (BOOL)updateCanvas {
    NSDictionary *info = [self.center callExternalMethod:@selector(requestCanvasInfo) withArguments:nil];
    if (!info) {
        return NO;
    }
    NSURL *URL = [NSURL URLWithString:info[@"canvas-url"]];
    if (!URL) {
        NSData *imageData = info[@"canvas-image-data"];
        if (!imageData) {
            return NO;
        }
        [self updateWithImage:[UIImage imageWithData:imageData]];
        return YES;
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [self executeBlock:^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithVideoItem:item];
        }
    }];
    return YES;
}

- (void)updateWithImage:(UIImage *)image {
    [self executeBlock:^{
=======
- (void)updateWithVideoInfo:(NSDictionary *)info {
    NSURL *URL = [NSURL URLWithString:info[@"url"]];
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    if (!item) {
        NSData *imageData = info[@"fallback"];
        [self updateWithImageData:imageData];
        return;
    }
    playerLooper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:item];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 1)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        UIImage *image = [UIImage imageWithCGImage:im];
>>>>>>> Stashed changes
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithImage:image];
        }
    }];
<<<<<<< Updated upstream
}

- (void)setPlaying:(BOOL)playing {
    [self executeBlock:^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
    }];
=======
}

- (void)updateWithImageData:(NSData *)data {
    [player removeAllItems];
    UIImage *image = [UIImage imageWithData:data];
    for (id<CBCanvasObserver> observer in self.observers) {
        [observer updateWithImage:image];
    }
}

- (void)setPlaying:(NSNumber *)number {
    BOOL playing = [number boolValue];
    if (playing == playerPlaying) return;
    NSLog(@"canvasBackground started");
    playerPlaying = playing;
    void (^block)(void) = ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
        if (playing) [player play];
        else [player pause];
    };
    if ([NSThread isMainThread]) block();
    else dispatch_sync(dispatch_get_main_queue(), block);
    NSLog(@"canvasBackground ended");
>>>>>>> Stashed changes
}

- (void)setSuspended:(BOOL)suspended {
    if (suspended) [player pause];
    else if (playerPlaying) [player play];
}

- (void)observerChangedSuspension:(NSObject<CBCanvasObserver> *)observer {
    for (id<CBCanvasObserver> observer in self.observers) {
        if (!observer.shouldSuspend) {
            [self setSuspended:NO];
            return;
        }
    }
    [self setSuspended:YES];
}

@end