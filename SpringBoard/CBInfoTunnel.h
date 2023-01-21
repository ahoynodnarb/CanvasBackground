// this class acts as a proxy to allow multiple observers to act as servers for spotify

#import <Foundation/Foundation.h>
#import "CBCanvasObserver.h"

@interface CBInfoTunnel : NSObject
@property (nonatomic, strong) NSMutableSet *observers;
+ (instancetype)sharedTunnel;
- (void)addObserver:(id<CBCanvasObserver>)observer;
- (void)removeObserver:(id<CBCanvasObserver>)observer;
- (void)updateWithVideoURL:(NSString *)URLString;
- (void)updateWithImageData:(NSData *)data;
- (void)setPlaying:(NSNumber *)number;
@end