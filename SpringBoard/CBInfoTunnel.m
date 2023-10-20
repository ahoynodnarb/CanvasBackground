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
        self.center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        [self.center addTarget:self action:@selector(updateWithVideoInfo:)];
        [self.center addTarget:self action:@selector(updateWithImageData:)];
        [self.center addTarget:self action:@selector(setPlaying:)];
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

- (void)updateWithVideoInfo:(NSDictionary *)info {
    NSURL *URL = [NSURL URLWithString:info[@"url"]];
    NSData *imageData = info[@"fallback"];
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    UIImage *fallbackImage = [UIImage imageWithData:imageData];
    void (^block)(void) = ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            if (item) [observer updateWithVideoItem:item];
            else [observer updateWithImage:fallbackImage];
        }
    };
    [self executeBlock:block];
}

- (void)updateWithImageData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    void (^block)(void) = ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithImage:image];
        }
    };
    [self executeBlock:block];
}

- (void)setPlaying:(NSNumber *)number {
    BOOL playing = [number boolValue];
    void (^block)(void) = ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
    };
    [self executeBlock:block];
}
@end