#import <AVKit/AVKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>

@interface CSCoverSheetViewController : UIViewController
- (void)setCanvas;
@end
@interface SPTVideoDisplayView : UIView
@property(readonly, nonatomic) AVPlayerLayer *playerLayer;
@property(nonatomic, strong, readwrite) AVPlayer *player;
-(void)test;
@end