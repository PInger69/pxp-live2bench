//
//  PxpMailClipActivity.h
//  Live2BenchNative
//
//  Created by dev on 2016-07-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxpMailClipActivity : UIActivity

@property (nonatomic,strong) UIViewController * presetingViewController;
@property (nonatomic,strong) NSArray * clips;

- (instancetype)initWithClips:(NSArray*)clips;

@end
