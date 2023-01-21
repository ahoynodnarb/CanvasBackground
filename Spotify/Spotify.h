#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>

@protocol SPTGLUEImageLoaderFactory
- (id)createImageLoaderForSourceIdentifier:(NSString *)arg1;
@end

@interface SPTPlayerTrack : NSObject
@property (copy, nonatomic) NSDictionary *metadata;
@property (readonly, nonatomic) NSURL *imageURL;
@end

@interface SPTStatefulPlayerImplementation
@property (nonatomic, assign) BOOL isPaused;
@end

@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end

@interface SPTNowPlayingModel
@property (nonatomic, strong) MRYIPCCenter *center;
@property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
+ (NSURL *)localURLForCanvas:(NSURL *)canvasURL;
- (void)sendUpdateMessage;
@end

@interface SPTQueueServiceImplementation
@property(retain, nonatomic) id <SPTGLUEImageLoaderFactory> glueImageLoaderFactory;
@end