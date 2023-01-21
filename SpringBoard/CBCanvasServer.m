#import "CBCanvasServer.h"
#import <MRYIPCCenter.h>

// @interface CBCanvasServer ()
// @property (nonatomic, readwrite) NSMutableSet *observers;
// @end

@implementation CBCanvasServer
static MRYIPCCenter *center;
static CBCanvasServer *server;

+ (instancetype)sharedServer {
    if (!server) {
        server = [[self alloc] init];
    }
    return server;
}

- (instancetype)init {
    if (!server) {
        NSLog(@"canvasbackground init");
        server = [super init];
        server.observers = [NSMutableSet set];
        center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        NSLog(@"canvasbackground %@", center);
        [center addTarget:server action:@selector(updateWithImageData:)];
        [center addTarget:server action:@selector(updateWithVideoURL:)];
    }
    return server;
}

- (void)addObserver:(id<CBCanvasObserver>)observer {
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<CBCanvasObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)updateWithVideoURL:(NSString *)URLString {
    NSLog(@"canvasbackground updating with URL: %@", URLString);
    NSURL *URL = [NSURL URLWithString:URLString];
    for (id<CBCanvasObserver> observer in self.observers) {
        [observer updateWithVideoURL:URL];
    }
}

- (void)updateWithImageData:(NSData *)data {
    NSLog(@"canvasbackground updating with image: %@", data);
    UIImage *image = [UIImage imageWithData:data];
    for (id<CBCanvasObserver> observer in self.observers) {
        [observer updateWithImage:image];
    }
}

- (void)setPlaying:(NSNumber *)number {
    BOOL playing = [number boolValue];
    for (id<CBCanvasObserver> observer in self.observers) {
        [observer setPlaying:playing];
    }
}
@end