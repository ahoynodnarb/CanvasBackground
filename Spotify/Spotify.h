#import <UIKit/UIKit.h>
// #import <rocketbootstrap/rocketbootstrap.h>
#import <MRYIPCCenter.h>

@interface SPTPlayerTrack : NSObject
@property (nonatomic, strong) NSURL *URI;
@property (copy, nonatomic) NSDictionary *metadata;
@property (readonly, nonatomic) NSURL *imageURL;
@end

@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end

@protocol SPTGLUEImageLoaderFactory
- (SPTGLUEImageLoader *)createImageLoaderForSourceIdentifier:(NSString *)arg1;
@end

@interface SPTQueueServiceImplementation
@property (nonatomic, strong) id <SPTGLUEImageLoaderFactory> glueImageLoaderFactory;
@end

@interface SPTStatefulPlayerImplementation
@property (nonatomic, assign) BOOL isPaused;
@end

@interface SPTNowPlayingModel : NSObject
@property (nonatomic, strong) MRYIPCCenter *center;
@property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
+ (NSURL *)localURLForCanvas:(NSURL *)canvasURL;
- (NSDictionary *)requestCanvasInfo;
- (void)loadImageForTrack:(SPTPlayerTrack *)track completion:(void (^)(UIImage *, NSError *))completion;
- (void)sendTrackImage:(SPTPlayerTrack *)track;
// - (void)sendUpdateWithTrack:(SPTPlayerTrack *)track;
@end

@interface SPTPlayerState
@property (nonatomic, strong) SPTPlayerTrack *track;
@end

@interface SPTStatefulPlayerQueue
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
@end