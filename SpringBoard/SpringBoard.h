#import <UIKit/UIKit.h>
#import "CBViewController.h"

@interface SBApplication
@property (nonatomic, strong) NSString *bundleIdentifier;
@end

@interface SBMediaController
@property (nonatomic, readonly) NSString *nowPlayingBundleID;
@property (nonatomic, strong) SBApplication *nowPlayingApplication;
+ (instancetype)sharedInstance;
@end

@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, strong) CBViewController *canvasController;
@end

@interface CSCoverSheetView : UIView
@property (nonatomic, strong) UIView *slideableContentView;
@end

@interface CSCoverSheetViewController : UIViewController
@property (nonatomic, strong) CBViewController *canvasController;
@property (nonatomic, strong) CSCoverSheetView *view;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@property (nonatomic, strong) CSCoverSheetViewController *contentViewController;
@property (nonatomic, strong) CBViewController *canvasController;
@property (nonatomic, strong) UIView *panelBackgroundContainerView;
@end