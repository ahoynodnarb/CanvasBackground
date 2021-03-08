#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/NSDistributedNotificationCenter.h>

//#import <MRYIPCCenter.h>
// @interface CanvasBackgroundServer : NSObject
// + (id)sharedInstance;
// @end
@interface CSCoverSheetViewController : UIViewController
- (void)setCanvas;
@end
@interface SPTCanvasNowPlayingContentLayerCellCollectionViewCell : UICollectionViewCell
@property(retain, nonatomic) UIView *canvasView;
@end
@interface SPTVideoDisplayView : UIView
@property(nonatomic, strong, readwrite) AVPlayer *player;
- (id)playerLayer;
@end
// @interface SPTCanvasAttributionView : UIView
// @end