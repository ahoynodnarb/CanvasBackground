#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

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
@property (nonatomic, strong) SPTPlayerTrack *previousTrack;
@property (nonatomic, strong) SPTPlayerTrack *currentTrack;
@property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
- (NSDictionary *)loadUserInfoForCanvas:(NSString *)filePath isImage:(BOOL)isImage;
- (void)loadUserInfoForImage:(NSURL *)imageURL callback:(void(^)(NSDictionary *))callback;
- (void)sendCanvasUpdateNotification;
@end

@interface SPTQueueServiceImplementation
@property(retain, nonatomic) id <SPTGLUEImageLoaderFactory> glueImageLoaderFactory;
@end