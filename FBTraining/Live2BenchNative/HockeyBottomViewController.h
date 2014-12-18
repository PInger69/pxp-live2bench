//
//  HockeyBottomViewController.h
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
#import "Globals.h"
#import "CustomButton.h"
#import "CustomLabel.h"

@class ContentViewController;
@class Live2BenchViewController;
@class UtilitiesController;

@interface HockeyBottomViewController : UIViewController
{
    UIView *leftView;
    NSMutableDictionary *_tagNames;
    UIView *middleView;
    UIView *rightView;
    ContentViewController  *_playerDrawerLeft;
    UIImageView *_leftArrow;
    UIImageView  *_rightArrow;
    NSMutableArray *arrayOfLines;
    ContentViewController* _playerDrawerRight;
    UISegmentedControl *_periodSegmentedControl;
    CustomLabel *_periodLabel;
    UISegmentedControl *_homeSegControl;
    UISegmentedControl *_awaySegControl;
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
    Globals *globals;
    CustomLabel *strengthHomeLabel;
    CustomLabel *strengthAwayLabel;
    CustomButton *leftLineButtonWasSelected;
    CustomButton *rightLineButtonWasSelected;
    NSMutableArray *leftLineButtonArr;
    NSMutableArray *rightLineButtonArr;
    NSTimer* updateSeekInfoHockeyTimer;
}

-(id)initWithController:(Live2BenchViewController *)l2b;
-(void)updateArray:(NSMutableArray*)arr index:(int)i;
-(void)sendTagInfo:(NSDictionary *)dict;

@property (nonatomic,strong) UISegmentedControl *homeSegControl;
@property (nonatomic,strong) UISegmentedControl* awaySegControl;
@property (nonatomic,strong) UISegmentedControl *periodSegmentedControl;
@property (nonatomic,strong) CustomLabel *periodLabel;
@property (nonatomic,strong) CustomLabel *strengthLabel;
@property (nonatomic,strong) ContentViewController *playerDrawerRight;
@property (nonatomic,strong) UIImageView *rightArrow;
@property (nonatomic,strong) UIImageView *leftArrow;
@property (nonatomic,strong) ContentViewController *playerDrawerLeft;
@property (nonatomic,strong) NSMutableDictionary *tagNames;
@property (nonatomic,strong) UIView *segmentControlView;
@property (nonatomic,strong) UIView *leftView;
@property (nonatomic,strong) UIView *middleView;
@property (nonatomic,strong) UIView *rightView;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSString *oldName;
@property (nonatomic,strong) UtilitiesController *uController;
@property (nonatomic,strong)NSMutableData *responseData;
- (void)segmentValueChanged:(id)sender;
- (void)periodSegmentValueChanged:(id)sender;


@end
