#import "CBInfoTunnel.h"
#import <AVKit/AVKit.h>
#import <MRYIPCCenter.h>

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
        [self.center addTarget:self action:@selector(updateWithVideoInfo:)];
        [self.center addTarget:self action:@selector(updateWithImageData:)];
        [self.center addTarget:self action:@selector(setPlaying:)];
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