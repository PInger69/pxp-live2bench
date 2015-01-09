//
//  TablePopoverController.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TablePopoverController : UIPopoverController
{
    UITableView     * myTableView;
}

@property (nonatomic,strong) NSString * userPick;
@property (nonatomic,assign) BOOL       animateDismiss;
@property (nonatomic,assign) BOOL       animatePresent;

-(void)populateWith:(NSArray*)aList;
-(void)addOnCompletionBlock:(void (^)(NSString*pick))blockName;
-(void)clear;

@end
