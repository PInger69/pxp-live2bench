//
//  PlayerCollectionViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
#import "Globals.h"
#import "BorderButton.h"

@interface PlayerCollectionViewController : UIViewController<UIScrollViewDelegate>{
    NSMutableArray *displayData;
    NSMutableArray *playersDidSelected;
    NSMutableArray *playerButtons;
    Globals *globals;
    IBOutlet UIScrollView *scrollView;
    
}
@property (strong, nonatomic) CustomButton *zoneButtonWasSelected;
@property (strong, nonatomic) NSString *zoneDidSelected;

- (void)clearCellSelections;
-(NSMutableArray*)getAllSelectedPlayers;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil index:(int)i side:(NSString*)whichSide;

@end
