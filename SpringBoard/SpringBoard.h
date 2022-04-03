#import "CBViewController.h"

@interface SBApplication
@property (nonatomic, strong) NSString *bundleIdentifier;
@end
@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, assign) BOOL iconControllerHidden;
@end
@interface CSFixedFooterViewController : UIViewController
@end

CBViewController *lockscreenController;
CBViewController *homescreenController;