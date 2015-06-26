//
//  VideoBarListViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoBarMyClipViewController.h"
#define LISTVIEW_MODE_DISABLE     0
#define LISTVIEW_MODE_REGULAR     1
#define LISTVIEW_MODE_CLIP        2

typedef NS_OPTIONS (NSInteger,ListViewModes){
    
    ListViewModeDisable,
    ListViewModeRegular,
    ListViewModeClip
};


@interface VideoBarListViewController : VideoBarMyClipViewController

@property (nonatomic,strong) CustomButton * startRangeModifierButton;
@property (nonatomic,strong) CustomButton * endRangeModifierButton;
@property (nonatomic,assign) ListViewModes                mode;

@end
