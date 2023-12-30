#import "CBInfoTunnel.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <rootless.h>

void log_impl(NSString *logStr) {
	// NSLog(@"BPS: %@", [logStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "]);
	NSString *logFile = ROOT_PATH_NS(@"/var/mobile/canvasbackground.log");
	NSFileManager *fm = NSFileManager.defaultManager;
	if (![fm fileExistsAtPath:logFile])
		[fm createFileAtPath:logFile contents:nil attributes:nil];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFile];
	[fileHandle seekToEndOfFile];
	[fileHandle writeData:[[NSString stringWithFormat:@"%@\n", logStr] dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandle closeFile];
}

#define LOG(...) log_impl([NSString stringWithFormat:__VA_ARGS__])

@interface CBInfoTunnel () {
    AVPlayerLooper *playerLooper;
    CPDistributedMessagingCenter *center;
    // MRYIPCCenter *center;
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
        rocketbootstrap_unlock("CanvasBackground.CanvasServer");
        center = [NSClassFromString(@"CPDistributedMessagingCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        LOG(@"initialized");
        // center = [NSClassFromString(@"MRYIPCCenter") centerNamed:@"CanvasBackground.CanvasServer"];
        rocketbootstrap_distributedmessagingcenter_apply(center);
		[center runServerOnCurrentThread];
		[center registerForMessageName:@"updateWithVideoURL" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updateWithImageData" target:self selector:@selector(handleMessage:userInfo:)];
		[center registerForMessageName:@"updatePlaybackState" target:self selector:@selector(handleMessage:userInfo:)];
        // [center addTarget:self action:@selector(updateWithVideoURL:)];
        // [center addTarget:self action:@selector(updateWithImageData:)];
        // [center addTarget:self action:@selector(updatePlaybackState:)];

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
        dispatch_async(dispatch_get_main_queue(), ^{
        // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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

- (void)handleMessage:(NSString *)messageName userInfo:(NSDictionary *)userInfo {
    id arg = [userInfo objectForKey:@"argument"];
    LOG(@"canvasBackground handling message");
    // switch (messageName) {
    //     case @"updateWithVideoURL":
    //         [self updateWithVideoURL:arg];
    //         break;
    //     case @"updateWithImageData":
    //         [self updateWithImageData:arg];
    //         break;
    //     case @"updatePlaybackState":
    //         [self updatePlaybackState:arg];
    //         break;
    // }
    if ([messageName isEqualToString:@"updateWithVideoURL"]) {
        // NSString *URL = [userInfo objectForKey:@"URL"];
        [self updateWithVideoURL:arg];
    }
    else if ([messageName isEqualToString:@"updateWithImageData"]) {
        // NSData *data = [userInfo objectForKey:@"data"];
        [self updateWithImageData:arg];
    }
    else if ([messageName isEqualToString:@"updatePlaybackState"]) {
        [self updatePlaybackState:arg];
    }
}

- (void)updateWithVideoURL:(NSString *)videoURL {
    NSURL *URL = [NSURL URLWithString:videoURL];
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [_player removeAllItems];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 1)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        UIImage *image = [UIImage imageWithCGImage:im];
        [self executeObserverBlock:^(NSObject<CBCanvasObserver> *observer) {
            [observer updateWithImage:image];
        } completion:nil];
    }];
    playerLooper = [AVPlayerLooper playerLooperWithPlayer:_player templateItem:item];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
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