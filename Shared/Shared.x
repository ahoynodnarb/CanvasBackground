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
    NSMutableDictionary *userInfo = [@{
        @"bundleID": self.bundleID
    } mutableCopy];
    if (path) [userInfo setObject:path forKey:@"path"];
    [self.center sendMessageName:@"updateVideoWithPath" userInfo:userInfo];
}
- (void)sendVideoURL:(NSString *)URL {
    NSMutableDictionary *userInfo = [@{
        @"bundleID": self.bundleID
    } mutableCopy];
    if (URL) [userInfo setObject:URL forKey:@"URL"];
    [self.center sendMessageName:@"updateVideoWithURL" userInfo:userInfo];
}
- (void)sendImageData:(NSData *)data {
    NSMutableDictionary *userInfo = [@{
        @"bundleID": self.bundleID
    } mutableCopy];
    if (data) [userInfo setObject:data forKey:@"data"];
    [self.center sendMessageName:@"updateImageWithData" userInfo:userInfo];
}

- (void)sendPlaybackState:(BOOL)playing {
    NSDictionary *userInfo = @{
        @"state": @(playing),
        @"bundleID": self.bundleID
    };
    [self.center sendMessageName:@"updatePlaybackState" userInfo:userInfo];
}
@end