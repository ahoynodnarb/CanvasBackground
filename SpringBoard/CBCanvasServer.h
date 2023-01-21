#import <Foundation/Foundation.h>
#import "CBCanvasObserver.h"

@interface CBCanvasServer : NSObject
@property (nonatomic, strong) NSMutableSet *observers;
+ (instancetype)sharedServer;
- (void)addObserver:(id<CBCanvasObserver>)observer;
- (void)removeObserver:(id<CBCanvasObserver>)observer;
- (void)updateWithVideoURL:(NSString *)URLString;
- (void)updateWithImageData:(NSData *)data;
- (void)setPlaying:(NSNumber *)number;
@end