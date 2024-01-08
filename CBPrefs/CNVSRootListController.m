#import <Foundation/Foundation.h>
#import "CNVSRootListController.h"

@implementation CNVSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
