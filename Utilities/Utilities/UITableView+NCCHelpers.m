// UITableView+NCCHelpers.m
//
// Copyright (c) 2013-2014 NCCCoreDataClient (http://coredataclient.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UITableView+NCCHelpers.h"
#import <objc/runtime.h>

@implementation UITableView (NCCHelpers)

- (NSIndexPath *)lastIndexPath
{
    NSUInteger lastSectionIndex = [self numberOfSections] - 1;
    NSUInteger lastRowInLastSectionIndex = [self numberOfRowsInSection:lastSectionIndex] - 1;
    
    return [NSIndexPath indexPathForRow:lastRowInLastSectionIndex inSection:lastSectionIndex];
}

- (NSIndexPath *)nextVisibleIndexPath
{
    NSArray *visibleIndexPaths = [self indexPathsForVisibleRows];
    NSIndexPath *lastVisibleIndexPath = [visibleIndexPaths objectAtIndex:visibleIndexPaths.count - 1];
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:lastVisibleIndexPath.section + 1];
    
    if ([nextIndexPath compare:self.lastIndexPath] == NSOrderedDescending) {
        return self.lastIndexPath;
    }
    
    return nextIndexPath;
}

- (BOOL)hasScrolledPastBottom
{
    BOOL scroll = ((self.contentSize.height - self.contentOffset.y) < self.frame.size.height);

    return scroll;
}

- (BOOL)isDisplayingLastIndexPath
{
    NSArray *visibleIndexPaths = [self indexPathsForVisibleRows];
    NSIndexPath *lastVisibleIndexPath = [visibleIndexPaths objectAtIndex:visibleIndexPaths.count - 1]; // get row that is currently visible (not enqueuing) at the bottom
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    
    return ([lastVisibleIndexPath compare:lastIndexPath] == NSOrderedSame);
    
    return NO;
}

- (void)reloadSelectedIndexPaths
{
    [self reloadSelectedIndexPathsWithCompletion:nil];
}

- (void)reloadSelectedIndexPathsWithCompletion:(void(^)(NSSet *reloadIndexPaths))completion
{
    NSMutableSet *reloadIndexPaths = [NSMutableSet set];
    if (self.previousSelectedIndexPath) {
        [reloadIndexPaths addObject:self.previousSelectedIndexPath];
    }
    
    if (self.currentSelectedIndexPath) {
        [reloadIndexPaths addObject:self.currentSelectedIndexPath];
    }
    
    if (reloadIndexPaths.count) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion) {
                completion(reloadIndexPaths);
            }
        }];
//        [self beginUpdates];
        [self selectRowAtIndexPath:self.currentSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self reloadRowsAtIndexPaths:[reloadIndexPaths allObjects] withRowAnimation:UITableViewRowAnimationFade];
//        [self endUpdates];
        [CATransaction commit];
    }
}

- (void)expandSelectedIndexPaths
{
    [self expandSelectedIndexPathsWithCompletion:nil];
}

- (void)expandSelectedIndexPathsWithCompletion:(void(^)(NSSet *reloadIndexPaths))completion
{
    NSMutableSet *reloadIndexPaths = [NSMutableSet set];
    if (self.previousSelectedIndexPath) {
        [reloadIndexPaths addObject:self.previousSelectedIndexPath];
    }
    
    if (self.currentSelectedIndexPath) {
        [reloadIndexPaths addObject:self.currentSelectedIndexPath];
    }
    
    if (reloadIndexPaths.count) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion) {
                completion(reloadIndexPaths);
            }
        }];
        [self beginUpdates];
        [self selectRowAtIndexPath:self.currentSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self endUpdates];
        [CATransaction commit];
    }
}

/*
#pragma mark - Loading Indicators

- (void)showTableViewLoadingIndicators:(NSUInteger)count size:(CGSize)size indicatorType:(STVSeriesActivityIndicatorType)indicatorType
{
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, size.height);
    STV_FocusViewGridActivityIndicatorView *activityIndicatorsView = [[STV_FocusViewGridActivityIndicatorView alloc] initWithFrame:frame];
    activityIndicatorsView.activityIndicatorType = indicatorType;
    
    activityIndicatorsView.columns = count;
    [activityIndicatorsView setNeedsLayout];
    
    self.tableFooterView = activityIndicatorsView;
}
*/
- (void)hideTableViewLoadingIndicators
{
    if (self.tableFooterView) {
        self.tableFooterView = nil;
    }
}

#pragma mark - Getters / Setters

- (void)setCurrentSelectedIndexPath:(id)currentSelectedIndexPath {
    if (![currentSelectedIndexPath isEqual:self.currentSelectedIndexPath]) {
        self.previousSelectedIndexPath = self.currentSelectedIndexPath;
        objc_setAssociatedObject(self, @selector(currentSelectedIndexPath), currentSelectedIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id)currentSelectedIndexPath {
    return objc_getAssociatedObject(self, @selector(currentSelectedIndexPath));
}

- (void)setPreviousSelectedIndexPath:(id)previousSelectedIndexPath {
    objc_setAssociatedObject(self, @selector(previousSelectedIndexPath), previousSelectedIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)previousSelectedIndexPath {
    return objc_getAssociatedObject(self, @selector(previousSelectedIndexPath));
}

#pragma mark - UI_Appearance

- (void)setCellHeightNormal:(CGFloat)cellHeightNormal {
    objc_setAssociatedObject(self, @selector(cellHeightNormal), @(cellHeightNormal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeightNormal {
    return [objc_getAssociatedObject(self, @selector(cellHeightNormal)) floatValue];
}

- (void)setCellHeightExpanded:(CGFloat)cellHeightExpanded {
    objc_setAssociatedObject(self, @selector(cellHeightExpanded), @(cellHeightExpanded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeightExpanded {
    return [objc_getAssociatedObject(self, @selector(cellHeightExpanded)) floatValue];
}

- (void)setTableHeaderViewHeight:(CGFloat)tableHeaderViewHeight {
    objc_setAssociatedObject(self, @selector(tableHeaderViewHeight), @(tableHeaderViewHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tableHeaderViewHeight {
    return [objc_getAssociatedObject(self, @selector(tableHeaderViewHeight)) floatValue];
}

- (void)setTableHeaderViewBackgroundColor:(UIColor *)tableHeaderViewBackgroundColor {
    objc_setAssociatedObject(self, @selector(tableHeaderViewBackgroundColor), tableHeaderViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)tableHeaderViewBackgroundColor {
    return objc_getAssociatedObject(self, @selector(tableHeaderViewBackgroundColor));
}

@end
