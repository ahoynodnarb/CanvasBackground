#import <CBInfoSource.h>
#import <MRYIPCCenter.h>

@interface CBInfoSource ()
@property (nonatomic, strong) MRYIPCCenter *center;
@property (nonatomic, readwrite) NSString *bundleID;
@end

@implementation CBInfoSource

+ (instancetype)sourceWithBundleID:(NSString *)bundleID {
    return [[self alloc] initWithBundleID:bundleID];
}

- (instancetype)initWithBundleID:(NSString *)bundleID {
    if (self = [super init]) {
        self.center = [%c(MRYIPCCenter) centerNamed:@"CanvasBackground.CanvasServer"];
        self.bundleID = bundleID;
        [self.center callExternalVoidMethod:@selector(registerBundle:) withArguments:self.bundleID];
    }
    return self;
}

- (void)sendVideoPath:(NSString *)path {
    NSDictionary *userInfo = @{
        @"path": path,
        @"bundleID": self.bundleID
    };
    [self.center callExternalVoidMethod:@selector(updateVideoWithPath:) withArguments:userInfo];
}
- (void)sendVideoURL:(NSString *)URL {
    NSDictionary *userInfo = @{
        @"URL": URL,
        @"bundleID": self.bundleID
    };
    [self.center callExternalVoidMethod:@selector(updateVideoWithURL:) withArguments:userInfo];
}
- (void)sendImageData:(NSData *)data {
    NSDictionary *userInfo = @{
        @"data": data,
        @"bundleID": self.bundleID
    };
    [self.center callExternalVoidMethod:@selector(updateImageWithData:) withArguments:userInfo];
}

- (void)sendPlaybackState:(BOOL)playing {
    NSDictionary *userInfo = @{
        @"state": @(playing),
        @"bundleID": self.bundleID
    };
    [self.center callExternalVoidMethod:@selector(updatePlaybackState:) withArguments:userInfo];
}
@end