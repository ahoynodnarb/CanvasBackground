#import <Foundation/NSDistributedNotificationCenter.h>

@interface SPTPlayerTrack : NSObject
@property (copy, nonatomic) NSDictionary *metadata;
@property (readonly, nonatomic) NSURL *imageURL;
@end
@interface SPTStatefulPlayerImplementation
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
@end
@interface SPTNowPlayingModel
@property (nonatomic, strong) SPTPlayerTrack *previousTrack;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
- (void)sendNotification;
@end
@interface SPTVideoURLAssetLoaderImplementation
- (BOOL)hasLocalAssetForURL:(NSURL *)arg1;
- (NSURL *)localURLForAssetURL:(NSURL *)arg1;
@end
@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end

SPTGLUEImageLoader *imageLoader;
SPTVideoURLAssetLoaderImplementation *assetLoader;