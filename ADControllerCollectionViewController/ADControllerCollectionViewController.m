//
//  ADControllerCollectionViewController.m
//  ADControllerCollectionViewController
//
//  Created by Adam Debono on 18/07/2013.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADControllerCollectionViewController.h"

#import "ADViewControllerCell.h"

#import "UIView+findFirstResponder.h"

@interface ADControllerCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIButton *pageBackwardButton;
@property (nonatomic) UIButton *pageForwardButton;

@property (nonatomic) NSMutableArray *arrowsVisible;

@property (nonatomic) BOOL hasViewLoaded;

@end

@implementation ADControllerCollectionViewController

- (id)init {
	if (self = [super init]) {
		[self initialisation];
	}
	
	return self;
}

- (void)awakeFromNib {
	[self initialisation];
}

- (void)initialisation {
	_viewControllers = @[];
	_arrowsVisible = [NSMutableArray array];
	_tintColor = nil;
	_hasViewLoaded = NO;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Collection View
	_flowLayout = [[UICollectionViewFlowLayout alloc] init];
	[[self flowLayout] setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	[[self flowLayout] setMinimumInteritemSpacing:0];
	[[self flowLayout] setMinimumLineSpacing:0];
	[[self flowLayout] setSectionInset:UIEdgeInsetsZero];
	[[self flowLayout] setItemSize:[[self view] frame].size];
	
	_collectionView = [[UICollectionView alloc] initWithFrame:[[self view] bounds] collectionViewLayout:[self flowLayout]];
	[[self collectionView] registerClass:[ADViewControllerCell class] forCellWithReuseIdentifier:@"viewController"];
	[[self view] addSubview:[self collectionView]];
	[[self view] sendSubviewToBack:[self collectionView]];
	
	[[self collectionView] setDataSource:self];
	[[self collectionView] setDelegate:self];
	
	[[self collectionView] setAllowsSelection:NO];
	
	[[self collectionView] setShowsHorizontalScrollIndicator:NO];
	[[self collectionView] setAlwaysBounceVertical:NO];
	[[self collectionView] setShowsVerticalScrollIndicator:NO];
	[[self collectionView] setPagingEnabled:YES];
	
	[[self collectionView] setContentInset:UIEdgeInsetsZero];
	
	//Page Control
	_pageControl = [[UIPageControl alloc] init];
	[[self pageControl] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[[self pageControl] setDefersCurrentPageDisplay:YES];
	
	[[self pageControl] addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	[[self view] addSubview:[self pageControl]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_pageControl]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(36)]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)]];
	
	//Pagination Buttons
	_pageForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[[self pageForwardButton] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[[self pageForwardButton] addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
	
	[[self view] addSubview:[self pageForwardButton]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_pageForwardButton(44)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageForwardButton)]];
	[[self view] addConstraint:[NSLayoutConstraint constraintWithItem:[self view] attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self pageForwardButton] attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageForwardButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageForwardButton)]];
	
	_pageBackwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[[self pageBackwardButton] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[[self pageBackwardButton] addTarget:self action:@selector(previousPage:) forControlEvents:UIControlEventTouchUpInside];
	
	[[self view] addSubview:[self pageBackwardButton]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_pageBackwardButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageBackwardButton)]];
	[[self view] addConstraint:[NSLayoutConstraint constraintWithItem:[self view] attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self pageBackwardButton] attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageBackwardButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageBackwardButton)]];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
		[[self pageForwardButton] setImage:[[UIImage imageNamed:@"arrow-forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[[self pageBackwardButton] setImage:[[UIImage imageNamed:@"arrow-backward"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	} else {
		[[self pageForwardButton] setImage:[UIImage imageNamed:@"arrow-forward"] forState:UIControlStateNormal];
		[[self pageBackwardButton] setImage:[UIImage imageNamed:@"arrow-backward"] forState:UIControlStateNormal];
	}
	
	//
	[[self view] addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
	
	if (![self tintColor]) {
		[self setTintColor:[UIColor blackColor]];
	} else {
		[self setTintColor:[self tintColor]];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"frame"]) {
		[[self collectionView] setFrame:[[self view] bounds]];
		[[self flowLayout] setItemSize:[[self view] frame].size];
		[[self collectionView] reloadData];
	}
}

- (void)dealloc {
	[[self view] removeObserver:self forKeyPath:@"frame"];
}

- (void)setTintColor:(UIColor *)tintColor {
	_tintColor = tintColor;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
		[[self view] setTintColor:tintColor];
	} else {
		[[self pageControl] setPageIndicatorTintColor:[tintColor colorWithAlphaComponent:0.5]];
		[[self pageControl] setCurrentPageIndicatorTintColor:tintColor];
	}
}

#pragma mark -

- (void)setViewControllers:(NSArray *)viewControllers {
	//remove current view controllers as children
	for (UIViewController *controller in [self viewControllers]) {
		[[controller view] removeFromSuperview];
		[controller willMoveToParentViewController:nil];
		[controller removeFromParentViewController];
	}
	
	_viewControllers = viewControllers?viewControllers:@[];
	
	for (UIViewController *controller in [self viewControllers]) {
		[self addChildViewController:controller];
		[controller didMoveToParentViewController:self];
	}
	
	for (int i=0; i<[viewControllers count]; i++) {
		if (i >= [[self arrowsVisible] count]) {
			[[self arrowsVisible] addObject:@YES];
		}
	}
	
	[[self collectionView] reloadData];
	
	[[self pageControl] setNumberOfPages:[[self viewControllers] count]];
	[self setPage:0 animated:NO];
}

- (void)setArrowsVisible:(BOOL)visible forViewControllerAtIndex:(NSUInteger)index {
	if (index < [[self arrowsVisible] count]) {
		[[self arrowsVisible] replaceObjectAtIndex:index withObject:@(visible)];
		[self updateCurrentPage];
	}
}

#pragma mark - Pagination

- (void)updateCurrentPage {
	CGFloat pageWidth = [[self view] frame].size.width;
	int page = floor(([[self collectionView] contentOffset].x - pageWidth / 2) / pageWidth) + 1;
	[[self pageControl] setCurrentPage:page];
	
	BOOL hideArrows = ![[[self arrowsVisible] objectAtIndex:page] boolValue];
	
	if ([[self pageControl] currentPage] == 0 || hideArrows) {
		if ([[self pageBackwardButton] alpha] == 1) {
			[UIView animateWithDuration:0.25 animations:^{
				[[self pageBackwardButton] setAlpha:0];
			}];
		}
	} else if ([[self pageBackwardButton] alpha] == 0) {
		[UIView animateWithDuration:0.25 animations:^{
			[[self pageBackwardButton] setAlpha:1];
		}];
	}
	
	if ([[self pageControl] currentPage] == [[self pageControl] numberOfPages] - 1 || hideArrows) {
		if ([[self pageForwardButton] alpha] == 1) {
			[UIView animateWithDuration:0.25 animations:^{
				[[self pageForwardButton] setAlpha:0];
			}];
		}
	} else if ([[self pageForwardButton] alpha] == 0) {
		[UIView animateWithDuration:0.25 animations:^{
			[[self pageForwardButton] setAlpha:1];
		}];
	}
}

- (void)pageControlChanged:(UIPageControl *)sender {
	[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[sender currentPage] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)nextPage:(id)sender {
	if ([[self pageControl] currentPage] < [[self pageControl] numberOfPages] - 1) {
		[self setPage:[[self pageControl] currentPage]+1 animated:YES];
	}
}

- (void)previousPage:(id)sender {
	if ([[self pageControl] currentPage] > 0) {
		[self setPage:[[self pageControl] currentPage]-1 animated:YES];
	}
}

- (void)setPage:(NSInteger)page animated:(BOOL)animated {
	if (animated) {
		[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
	} else {
		[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
		[self updateCurrentPage];
	}
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [[self viewControllers] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ADViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"viewController" forIndexPath:indexPath];
		
	UIViewController *controller = [[self viewControllers] objectAtIndex:[indexPath item]];
	[[controller view] setFrame:[cell bounds]];
	[[cell contentView] addSubview:[controller view]];
	
	return cell;
}

#pragma mark - Collection View Delegate

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[scrollView findFirstResponder] resignFirstResponder];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self updateCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updateCurrentPage];
}

@end
