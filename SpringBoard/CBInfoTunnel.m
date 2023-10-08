#import "CBInfoTunnel.h"
#import <AVKit/AVKit.h>
#import <MRYIPCCenter.h>
// #import <rocketbootstrap/rocketbootstrap.h>

@interface CBInfoTunnel ()
@property (nonatomic, strong) MRYIPCCenter *center;
@end

@implementation CBInfoTunnel
static CBInfoTunnel *tunnel;

+ (instancetype)sharedTunnel {
    if (!tunnel) tunnel = [[self alloc] init];
    return tunnel;
}

- (instancetype)init {
    if (self = [super init]) {
        self.observers = [NSMutableSet set];
        self.center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
    }
    return self;
}

- (void)executeBlock:(void (^)(void))block {
    if ([NSThread isMainThread]) block();
    else dispatch_sync(dispatch_get_main_queue(), block);
}

- (void)addObserver:(id<CBCanvasObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBCanvasObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)invalidate {
    void (^block)(void) = ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer invalidate];
        }
    };
    [self executeBlock:block];
}

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
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithImage:image];
        }
    }];
}

- (void)setPlaying:(BOOL)playing {
    [self executeBlock:^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
    }];
}
@end