//
//  SoccerBottomViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBottomViewController.h"
#import "BottomViewControllerProtocol.h"
//#import "Live2BenchViewController.h"
//#import "CustomLabel.h"

//@class Live2BenchViewController;
@interface SoccerBottomViewController : AbstractBottomViewController <BottomViewControllerProtocol>
   // UISegmentedControl *zoneSegmentedControl;
   // UISegmentedControl *periodSegmentedControl;
   // Live2BenchViewController *live2BenchViewController;
   // UIView *playerViewController;
    //AppQueue *appQueue;
//    Globals *globals;
 //   NSString *thumbId;
//    UtilitiesController *uController;
  //  NSString *nameforZone;
  //  NSString *oldNameforZone;
  //  NSDictionary *dictforZone;
  //  NSDictionary *oldDictforZone;
  //  NSString *nameforHalf;
  //  NSString *oldNameforHalf;
  //  NSDictionary *dictforHalf;
  //  NSDictionary *oldDictforHalf;
    //NSTimer *updateControlInfoTimer;
   // NSMutableArray *playerButtons;

    //BOOL isUpdatingSeek;
    //NSTimer *updateSeekInfoTimer;


//@property (strong, nonatomic) CustomLabel *zoneLabel;
//@property (strong, nonatomic) UISegmentedControl *zoneSegmentedControl;
//@property (strong, nonatomic) UILabel *halfLabel;
//@property (strong, nonatomic) UISegmentedControl *periodSegmentedControl;
//@property (strong, nonatomic) Live2BenchViewController *live2BenchViewController;
//@property (strong, nonatomic) CustomButton *playerbuttonWasSelected;
//@property (strong, nonatomic) NSMutableData *responseData;

//@property (assign,nonatomic) BOOL *isDuration;

//- (id)initWithController:(Live2BenchViewController *)l2b;
//- (void)halfValueChanged:(id)sender;
//- (void)zoneValueChanged:(id)sender;
//duration tag for soccer game, events tag buttons and player tag buttons are in seperated view controllers; When making event duration tag , need to deselected any player button which is highlighted
//-(void)deSelectTagButton;
@end
