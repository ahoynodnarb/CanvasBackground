#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface SPTPlayerTrack : NSObject
@end
@interface SPTPlayerState : NSObject
@end
@interface SPTStatefulPlayerQueue : NSObject
- (SPTPlayerTrack *)trackAtRelativePosition:(long long)arg1 forState:(id)arg2;
@end
@interface SPTStatefulPlayer : NSObject
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property(readonly, nonatomic) SPTStatefulPlayerQueue *queue;
@property(retain, nonatomic) SPTPlayerState *playerState;
-(SPTPlayerTrack *)currentTrack;
-(SPTPlayerTrack *)nextTrack;
-(void)addCanvasToUserInfo:(SPTPlayerTrack *)track key:(NSString *)key;
-(void)sendNotification;
@end
@interface SPTCanvasModelImplementation : NSObject
@property(readonly, copy, nonatomic) NSURL *contentURL;
@end
@interface SPTCanvasContentLayerViewControllerViewModel : NSObject
@property(readonly, nonatomic) SPTCanvasModelImplementation *canvasModel;
@end
@interface SPTCanvasNowPlayingContentLoader : NSObject
- (SPTCanvasContentLayerViewControllerViewModel *)canvasViewControllerViewModelForTrack:(id)arg1;
@end
@interface SPTVideoURLAssetLoaderImplementation : NSObject
- (NSURL *)localURLForAssetURL:(NSURL *)arg1;
@end

SPTVideoURLAssetLoaderImplementation *assetLoader;
SPTCanvasNowPlayingContentLoader *loader;
BOOL sentNotificationOnce;
BOOL shouldSend;