//
//  VBBottomViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-05-31.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PlayerCollectionViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppQueue.h"
#import "UtilitiesController.h"
#import "FirstViewController.h"
#import "Globals.h"
#import "CustomButton.h"
#import "DragDropManager.h"

@class PlayerCollectionViewController;
@class FirstViewController;
@class UtilitiesController;

@interface VBBottomViewController : UIViewController<UIScrollViewDelegate,UIScrollViewAccessibilityDelegate>{
    NSMutableDictionary *_tagNames;
    PlayerCollectionViewController *_playerDrawer;
    UIImageView *_arrow;
    NSMutableArray *arrayOfRotations;
    //ContentViewController *_playerDrawerRight;
    MPMoviePlayerController *_moviePlayer;
    AppQueue *appQueue;
    NSString *oldName;
    NSDictionary *oldDict;
    NSDictionary *dict;
    NSString *thumbId;
    NSArray *paths;
    NSString *documentsDirectory;
    UtilitiesController *uController;
    FirstViewController *firstViewController;
    Globals *globals;
    CustomButton *rotationButtonWasSelected;
    CustomButton *rightRotationButtonWasSelected;
    NSMutableArray *rotationButtonArr;
    NSMutableArray *rightRotationButtonArr;
    NSTimer *updateControlInfoTimer;
    UIView *allPlayersView;
    UIView *rotationView;
    NSMutableArray *dragDropObjects;
    NSArray *dragDropViews;
    DragDropManager *dragDropManager;
    CGPoint originalPosition;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil controller:(FirstViewController *)fv;
- (void)updateArray:(NSMutableArray*)arr index:(int)i;
-(void)sendTagInfo:(NSDictionary *)dict;
-(void)initLayout;



@property PlayerCollectionViewController *playerDrawerRight;
@property UIImageView *arrow;
@property PlayerCollectionViewController *playerDrawer;
@property NSMutableDictionary *tagNames;
@property IBOutlet UIView *leftView;
@property IBOutlet UIView *middleView;
@property IBOutlet UIView *rightView;
@property (nonatomic,retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic,retain) NSString *oldName;
@property (nonatomic,retain) UtilitiesController *uController;
@property (nonatomic,retain) UIView *allPlayersView;
@property (nonatomic,retain) UIView *rotationView;
@property (nonatomic,retain)  NSMutableArray *dragDropObjects;
@property (nonatomic,retain) NSArray *dragDropViews;
@property (nonatomic,retain) DragDropManager *dragDropManager;
@property (nonatomic)CGPoint originalPosition;

@end
