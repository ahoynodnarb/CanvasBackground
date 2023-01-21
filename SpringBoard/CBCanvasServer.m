#import "CBCanvasServer.h"
#import <MRYIPCCenter.h>

@interface CBCanvasServer ()
@property (nonatomic, strong) MRYIPCCenter *center;
@end

@implementation CBCanvasServer
static CBCanvasServer *server;

+ (instancetype)sharedServer {
    if (!server) {
        server = [[self alloc] init];
    }
    return server;
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

- (void)addObserver:(id<CBCanvasObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBCanvasObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)updateWithVideoURL:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithVideoURL:URL];
        }
    });
}

- (void)updateWithImageData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer updateWithImage:image];
        }
    });
}

- (void)setPlaying:(NSNumber *)number {
    BOOL playing = [number boolValue];
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (id<CBCanvasObserver> observer in self.observers) {
            [observer setPlaying:playing];
        }
    });
}
@end