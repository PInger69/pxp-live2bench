//
//  BottomViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-24.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
////#import <QuartzCore/QuartzCore.h>
#import "ContentViewController.h"
#import <MediaPlayer/MediaPlayer.h>
//#import "AppQueue.h"
#import "UtilitiesController.h"
#import "Live2BenchViewController.h"
//#import "Globals.h"
#import "CustomButton.h"

@class ContentViewController;
@class Live2BenchViewController;
@class UtilitiesController;

@interface BottomViewController : UIViewController
{
    IBOutlet UIView *leftView;
    NSMutableDictionary *_tagNames;
    IBOutlet UIView *middleView;
    IBOutlet UIView *rightView;
    ContentViewController  *_playerDrawerLeft;
    UIImageView *_leftArrow;
    UIImageView  *_rightArrow;
    NSMutableArray *arrayOfLines;
    ContentViewController* _playerDrawerRight;
    IBOutlet UISegmentedControl *_periodSegmentedControl;
    IBOutlet UILabel *_periodLabel;
    IBOutlet UISegmentedControl *_homeSegControl;
    IBOutlet UISegmentedControl *_awaySegControl;
    MPMoviePlayerController *_moviePlayer;
    ///AppQueue *appQueue;
    NSString *oldName;
    NSDictionary *oldDict;
    NSDictionary *dict;
    NSString *thumbId;
    NSArray *paths;
    NSString *documentsDirectory;
    UtilitiesController *uController;
    Live2BenchViewController *live2BenchViewController;
//    Globals *globals;
    UILabel *strengthHomeLabel;
    UILabel *strengthAwayLabel;
    CustomButton *leftLineButtonWasSelected;
    CustomButton *rightLineButtonWasSelected;
    NSMutableArray *leftLineButtonArr;
    NSMutableArray *rightLineButtonArr;
    NSTimer *updateControlInfoTimer;
}

-(id)initWithController:(Live2BenchViewController *)l2b;
- (void)updateArray:(NSMutableArray*)arr index:(int)i;
-(void)sendTagInfo:(NSDictionary *)dict;

@property (nonatomic,strong) IBOutlet UISegmentedControl *homeSegControl;
@property (nonatomic,strong) IBOutlet UISegmentedControl* awaySegControl;
@property (nonatomic,strong)IBOutlet UISegmentedControl *periodSegmentedControl;
@property (nonatomic,strong) UILabel *periodLabel;
@property (nonatomic,strong) ContentViewController *playerDrawerRight;
@property (nonatomic,strong) UIImageView *rightArrow;
@property (nonatomic,strong) UIImageView *leftArrow;
@property (nonatomic,strong) ContentViewController *playerDrawerLeft;
@property (nonatomic,strong) NSMutableDictionary *tagNames;
@property (nonatomic,strong) IBOutlet UIView *leftView;
@property (nonatomic,strong) IBOutlet UIView *middleView;
@property (nonatomic,strong) IBOutlet UIView *rightView;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSString *oldName;
@property (nonatomic,strong) UtilitiesController *uController;
- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)periodSegmentValueChanged:(id)sender;


@end
