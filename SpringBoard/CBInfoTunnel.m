#import "CBInfoTunnel.h"
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
        [self.center addTarget:self action:@selector(updateWithVideoURL:)];
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

- (void)updateWithVideoURL:(NSString *)URLString {
    void (^block)(void) = ^{
        NSURL *URL = [NSURL URLWithString:URLString];
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithVideoURL:URL];
        }
    };
    [self executeBlock:block];
}

- (void)updateWithImageData:(NSData *)data {
    void (^block)(void) = ^{
        UIImage *image = [UIImage imageWithData:data];
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithImage:image];
        }
    };
    [self executeBlock:block];
}

- (void)setPlaying:(NSNumber *)number {
    void (^block)(void) = ^{
        BOOL playing = [number boolValue];
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
    };
    [self executeBlock:block];
}
@end