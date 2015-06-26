//
//  ListViewFullScreenViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-17.
//  Copyright © 2015 DEV. All rights reserved.
//

#define LISTVIEW_FULLSCREEN_MODE_DISABLE     0
#define LISTVIEW_FULLSCREEN_MODE_REGULAR     1
#define LISTVIEW_FULLSCREEN_MODE_CLIP        2


#import "FullScreenViewController.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "SeekButton.h"
#import "CustomButton.h"

typedef NS_OPTIONS (NSInteger,ListViewFullScreenModes){
    
    ListViewFullScreenDisable,
    ListViewFullScreenRegular,
    ListViewFullScreenClip
};


@interface ListViewFullScreenViewController : FullScreenViewController


@property (nonatomic,assign) ListViewFullScreenModes                mode;
@property (strong,nonatomic) SeekButton         * seekForward;
@property (strong,nonatomic) SeekButton         * seekBackward;
@property (strong,nonatomic) Slomo              * slomo;
@property (strong,nonatomic) CustomButton       * startRangeModifierButton;         //extends duration button (old start time - 5)
@property (strong,nonatomic) CustomButton       * endRangeModifierButton;
@property (strong,nonatomic) UILabel            * tagLabel;
@property (strong,nonatomic) UIButton           * prev;
@property (strong,nonatomic) UIButton           * next;

-(void)setTagName:(NSString *)name;

@end
