#import <CBInfoSource.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface CBInfoSource ()
@property (nonatomic, strong) CPDistributedMessagingCenter *center;
@property (nonatomic, readwrite) NSString *bundleID;
@end

@implementation CBInfoSource

+ (instancetype)sourceWithBundleID:(NSString *)bundleID {
    return [[self alloc] initWithBundleID:bundleID];
}

- (instancetype)initWithBundleID:(NSString *)bundleID {
    if (self = [super init]) {
        self.center = [%c(CPDistributedMessagingCenter) centerNamed:@"CanvasBackground.CanvasServer"];
        rocketbootstrap_distributedmessagingcenter_apply(self.center);
        self.bundleID = bundleID;
        NSDictionary *userInfo = @{
            @"bundleID": self.bundleID
        };
        [self.center sendMessageName:@"registerBundle" userInfo:userInfo];
    }
    return self;
}

- (void)sendVideoPath:(NSString *)path {
    NSDictionary *userInfo = @{
        @"path": path,
        @"bundleID": self.bundleID
    };
    [self.center sendMessageName:@"updateVideoWithPath" userInfo:userInfo];
}
- (void)sendVideoURL:(NSString *)URL {
    NSDictionary *userInfo = @{
        @"URL": URL,
        @"bundleID": self.bundleID
    };
    [self.center sendMessageName:@"updateVideoWithURL" userInfo:userInfo];
}
- (void)sendImageData:(NSData *)data {
    NSDictionary *userInfo = @{
        @"data": data,
        @"bundleID": self.bundleID
    };
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