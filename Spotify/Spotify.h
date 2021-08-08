#import <Foundation/NSDistributedNotificationCenter.h>
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIKit.h>

@interface SPTPlayerTrack : NSObject
@end
@interface SPTStatefulPlayerImplementation : NSObject
@property (nonatomic, strong) NSMutableDictionary *userInfo;
-(SPTPlayerTrack *)currentTrack;
-(SPTPlayerTrack *)nextTrack;
// -(void)setArtworkImage;
-(void)addCanvasToUserInfo:(SPTPlayerTrack *)track key:(NSString *)key;
-(void)sendNotification;
@end
@interface SPTCanvasModelImplementation : NSObject
@property(copy, nonatomic) NSURL *albumCoverURL;
@property (readonly, copy, nonatomic) NSURL *contentURL;
@end
@interface SPTCanvasContentLayerViewControllerViewModel : NSObject
@property (readonly, nonatomic) SPTCanvasModelImplementation *canvasModel;
@end
@interface SPTCanvasNowPlayingContentLoader : NSObject
- (SPTCanvasContentLayerViewControllerViewModel *)canvasViewControllerViewModelForTrack:(id)arg1;
@end
@interface SPTVideoURLAssetLoaderImplementation : NSObject
- (NSURL *)localURLForAssetURL:(NSURL *)arg1;
@end

// SPTCanvasModelImplementation *canvasModel;
SPTVideoURLAssetLoaderImplementation *assetLoader;
SPTCanvasNowPlayingContentLoader *contentLoader;