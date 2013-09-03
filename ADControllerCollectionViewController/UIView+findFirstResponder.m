//
//  UIView+findFirstResponder.m
//  Maps
//
//  Created by Adam Debono on 24/02/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "UIView+findFirstResponder.h"

@implementation UIView (findFirstResponder)

- (id)findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
	
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
		
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
	
    return nil;
}

@end
