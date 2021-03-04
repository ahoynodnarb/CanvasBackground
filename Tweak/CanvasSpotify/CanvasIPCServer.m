#import <MRYIPCCenter.h>
#import <UIKit/UIKit.h>
#import "Spotify.h"

@implementation CanvasIPCServer
{
    MRYIPCCenter *_center;
    NSArray *_data;
}

+ (void)load
{
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    __strong static CanvasIPCServer *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
        [_center addTarget:self action:@selector(getCanvas:)];
        [_center addTarget:self action:@selector(updateCanvas:)];
    }
    return self;
}

- (void)updateCanvas:(NSArray *)args
{
    _data = args;
}
- (NSArray *)getCanvas
{
    return _data;
}
@end