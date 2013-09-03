//
//  ADControllerCollectionViewController.h
//  ADControllerCollectionViewController
//
//  Created by Adam Debono on 18/07/2013.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADControllerCollectionViewController : UIViewController

@property (nonatomic) NSArray *viewControllers;

@property (nonatomic) UIColor *tintColor;

- (void)setArrowsVisible:(BOOL)visible forViewControllerAtIndex:(NSUInteger)index;

@end
