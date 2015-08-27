//
//  SideTagButton.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"


typedef NS_OPTIONS (NSInteger,SideTagButtonModes){
    
    SideTagButtonModeDisable,
    SideTagButtonModeRegular,
    SideTagButtonModeToggle
};


@interface SideTagButton : UIButton

@property (nonatomic,strong) NSString               *durationID;
@property (nonatomic,assign) BOOL                   isOpen;
@property (nonatomic,assign) SideTagButtonModes     mode;


@end
