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

@interface CSMainPageContentViewController : UIViewController
@property (nonatomic, strong) CBViewController *canvasController;
@end