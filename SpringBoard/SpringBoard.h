#import "CBViewController.h"

@interface SBFWallpaperView : UIView
@end
@interface _SBFakeBlurView : UIView
@end
@interface CSCoverSheetViewController : UIViewController
@property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
-(void)togglePlayer:(NSNotification *)note;
@end
@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *firstFrameView;
@property (nonatomic, assign) BOOL isVisible;
-(void)recreateCanvasPlayer:(NSNotification *)note;
-(void)resizeCanvas;
-(void)togglePlayer:(NSNotification *)note;
@end

CBViewController *lockscreenController;
CBViewController *homescreenController;