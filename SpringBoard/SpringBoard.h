#import <UIKit/UIKit.h>
#import "CBViewController.h"

@interface SBApplication
@property (nonatomic, strong) NSString *bundleIdentifier;
@end
@interface SBMediaController
@property (nonatomic, strong) SBApplication *previousApplication;
@end
@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, assign) BOOL iconControllerHidden;
@end
@interface CSFixedFooterViewController : UIViewController
@end

CBViewController *lockscreenController;
CBViewController *homescreenController;