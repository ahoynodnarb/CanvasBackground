#import <Foundation/NSDistributedNotificationCenter.h>

@interface SPTPlayerTrack
@property(readonly, nonatomic) NSURL *imageURL;
@end
@interface SPTStatefulPlayerImplementation
- (SPTPlayerTrack *)currentTrack;
- (void)sendNotification;
@end
@interface SPTCanvasModelImplementation
@property (readonly, copy, nonatomic) NSURL *contentURL;
@end
@interface SPTCanvasContentLayerViewControllerViewModel
@property (readonly, nonatomic) SPTCanvasModelImplementation *canvasModel;
@end
@interface SPTCanvasNowPlayingContentLoader
- (SPTCanvasContentLayerViewControllerViewModel *)canvasViewControllerViewModelForTrack:(id)arg1;
@end
@interface SPTVideoURLAssetLoaderImplementation
- (NSURL *)localURLForAssetURL:(NSURL *)arg1;
@end
@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end

SPTGLUEImageLoader *imageLoader;
SPTVideoURLAssetLoaderImplementation *assetLoader;
SPTCanvasNowPlayingContentLoader *contentLoader;