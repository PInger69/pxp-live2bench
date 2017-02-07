//
//  Live2BenchTagUIViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideTagButton.h"
#import "BorderButton.h"
#import "FullScreenViewController.h"
#import "PlayerCollectionViewController.h"
#import "OverlayViewController.h"
#import "SideTagButton.h"

#define STATE_FULLSCREEN @"fullscreen"
#define STATE_SMALLSCREEN @"smallscreen"

@class Live2BenchTagUIViewController;

@protocol Live2BenchTagUIViewControllerDelegate <NSObject>

-(void)onFinishBusy:(Live2BenchTagUIViewController*)live2BenchTagUI;

@end



@interface Live2BenchTagUIViewController : UIViewController
{
    NSInteger               tagCount;
    NSMutableDictionary     * buttons;
}

@property (strong,nonatomic) NSMutableArray                     * tagButtonsLeft;
@property (strong,nonatomic) NSMutableArray                     * tagButtonRight;

@property (weak,nonatomic) Event                                * currentEvent;
@property (assign,nonatomic) BOOL                               enabled;
@property (assign,nonatomic) BOOL                               hidden;
@property (assign,nonatomic) CGSize                             buttonSize;
@property (assign,nonatomic) CGFloat                            gap;
@property (assign,nonatomic) CGFloat                            topOffset;
@property (strong,nonatomic) NSString                           * state;
@property (assign,nonatomic) SideTagButtonModes                 buttonStateMode;
@property (strong,nonatomic) FullScreenViewController           * fullScreenViewController;
@property (strong,nonatomic) PlayerCollectionViewController     * playerCollectionViewController;         //it will show up when swiping tag button;Its view contains all the player buttons
@property (nonatomic,assign,readonly) BOOL                               isBusy;
@property (readonly, strong, nonatomic) UIView *leftTray;
@property (readonly, strong, nonatomic) UIView *rightTray;

@property (nonatomic,weak) id<Live2BenchTagUIViewControllerDelegate> delegate;

-(id)initWithView:(UIView*)view;
-(void)inputTagData:(NSArray*)listOfDicts;
-(void)addActionToAllTagButtons:(SEL)sel addTarget:(id)target forControlEvents:(UIControlEvents)controlEvent;

-(void)clear;
-(BorderButton*)getButtonByName:(NSString*)btnName;

-(void)minimize;
-(void)maximize;
-(void)close;
-(void)open;
-(void)allToggleOnOpenTags:(Event *)event;

-(void)setButtonState:(SideTagButtonModes)mode;
-(void)onEventChange:(Event*)event;
-(void)disEnableButton;
//-(void)unHighlightButton:(SideTagButton *)button;
-(void)closeAllOpenTagButtons;
-(void)_fullScreen;

@end
