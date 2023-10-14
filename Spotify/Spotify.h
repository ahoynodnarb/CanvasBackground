#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>

@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end

@interface SPTGLUEImageLoaderFactoryImplementation
- (SPTGLUEImageLoader *)createImageLoaderForSourceIdentifier:(NSString *)arg1;
@end

@interface SPTGLUEServiceImplementation
- (SPTGLUEImageLoaderFactoryImplementation *)provideImageLoaderFactory;
@end

@interface SPTPlayerTrack : NSObject
@property (nonatomic, strong) NSURL *URI;
@property (copy, nonatomic) NSDictionary *metadata;
@property (readonly, nonatomic) NSURL *imageURL;
@end

@interface SPTStatefulPlayerImplementation
@property (nonatomic, assign) BOOL isPaused;
@end

@interface SPTNowPlayingModel
@property (nonatomic, strong) MRYIPCCenter *center;
@property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
+ (NSURL *)localURLForCanvas:(NSURL *)canvasURL;
- (void)loadImageForTrack:(SPTPlayerTrack *)track completion:(void (^)(UIImage *, NSError *))completion;
- (void)sendTrackImage:(SPTPlayerTrack *)track;
- (void)sendUpdateWithTrack:(SPTPlayerTrack *)track;
@end

SPTGLUEServiceImplementation *GLUEService;