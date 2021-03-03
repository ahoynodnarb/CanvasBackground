#import <MRYIPCCenter.h>
#import <UIKit/UIKit.h>
#import "Spotify.h"

@implementation CanvasIPCServer
{
    MRYIPCCenter *_center;
    NSDictionary *_data;
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
        NSLog(@"[CanvasIPCServer] running server in %@", [NSProcessInfo processInfo].processName);
    }
    return self;
}

- (void)updateCanvas:(NSDictionary *)args
{
    _data = args;
}
- (NSDictionary *)getCanvas
{
    return _data;
}
@end