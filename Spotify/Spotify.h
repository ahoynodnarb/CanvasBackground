#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface SPTPlayerTrack : NSObject
@end
@interface SPTStatefulPlayer : NSObject
-(SPTPlayerTrack *)currentTrack;
-(SPTPlayerTrack *)nextTrack;
-(NSString *)getCanvasURLForTrack:(SPTPlayerTrack *)track;
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

SPTPlayerTrack *nextTrack;
SPTCanvasNowPlayingContentLoader *loader;
BOOL sentNotificationOnce;
BOOL shouldSend;