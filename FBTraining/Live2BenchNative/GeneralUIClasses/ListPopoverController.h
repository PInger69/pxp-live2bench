//
//  ListPopoverController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-08.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverButton.h"

@interface ListPopoverController : UIPopoverController
{
    UIViewController    * contentVC;
    UIView              * content;
    UILabel             * messageText;
    NSMutableArray      * teamButtons;
    NSMutableArray      * onCompletionBlocks;
    
}
@property (nonatomic,assign) BOOL       animateDismiss;
@property (nonatomic,assign) BOOL       animatePresent;
@property (nonatomic,strong) NSString   * message;
@property (nonatomic,strong) NSArray    * listOfButtonNames;


-(id)initWithMessage:(NSString*)aMessage buttonListNames:(NSArray*)aListOfNames;

-(void)addOnCompletionBlock:(void (^)(NSString*pick))blockName;
-(void)presentPopoverCenteredIn:(UIView *)view animated:(BOOL)animated;

-(void)clear;


@end
