#import <UIKit/UIKit.h>
#import "CBViewController.h"

@interface FBProcess
@property (nonatomic, strong) NSString *bundleIdentifier;
@end

@interface SBApplication
@property (nonatomic, strong) NSString *bundleIdentifier;
@end

@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, strong) CBViewController *canvasController;
@end

@interface CSCoverSheetView : UIView
@property (nonatomic, strong) UIView *slideableContentView;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@property (nonatomic, strong) CBViewController *canvasController;
@property (nonatomic, strong) UIView *panelBackgroundContainerView;
@end