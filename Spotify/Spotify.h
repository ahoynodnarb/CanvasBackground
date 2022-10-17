#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface SPTPlayerTrack : NSObject
@property (copy, nonatomic) NSDictionary *metadata;
@property (readonly, nonatomic) NSURL *imageURL;
@end
@interface SPTStatefulPlayerImplementation
@property (nonatomic, assign) BOOL isPaused;
@end
@interface SPTNowPlayingModel
@property (nonatomic, strong) SPTPlayerTrack *previousTrack;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
- (void)sendNotification;
@end
@interface SPTGLUEImageLoader
- (void)loadImageForURL:(NSURL *)url imageSize:(CGSize)size completion:(id)completion;
@end
@protocol SPTGLUEImageLoaderFactory
- (id)createImageLoaderForSourceIdentifier:(NSString *)arg1;
@end
@interface SPTQueueServiceImplementation
@property(retain, nonatomic) id <SPTGLUEImageLoaderFactory> glueImageLoaderFactory;
@end

SPTGLUEImageLoader *imageLoader;