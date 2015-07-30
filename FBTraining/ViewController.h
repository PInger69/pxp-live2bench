//
//  ViewController.h
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilterTabController.h"

@interface ViewController: PxpFilterTabController <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *aView;
    UIImageView *imgView;
    UIScrollView *myScrollView;
    
    UITableView *myTableView;
    NSMutableArray *myData;
}

@property (strong, nonatomic) IBOutlet UIScrollView *myLeftScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *myRightScrollView;


//scroll view
/*
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate;
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
 */

//- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;
//- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

//table view
/*
 - (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths
              withRowAnimation:(UITableViewRowAnimation)animation;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
                           forIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
              withRowAnimation:(UITableViewRowAnimation)animation;
- (NSArray *)visibleCells;
 */

@end
