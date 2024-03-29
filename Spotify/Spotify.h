#import <UIKit/UIKit.h>
#import <CBInfoSource.h>

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
@property (nonatomic, strong) CBInfoSource *source;
@property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
+ (NSString *)localPathForCanvas:(NSString *)canvasURL;
- (void)sendTrackImage:(NSURL *)imageURL;
- (void)sendStaticCanvas:(NSURL *)imageURL;
- (void)writeCanvasToFile:(NSURL *)canvasURL filePath:(NSURL *)fileURL;
- (void)sendUpdateWithTrack:(SPTPlayerTrack *)track;
@end

SPTGLUEServiceImplementation *GLUEService;