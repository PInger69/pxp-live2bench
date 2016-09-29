//
//  EmailActivity.h
//  Live2BenchNative
//
//  Created by dev on 2016-09-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EmailActivity : UIActivity
@property (nonatomic,strong) UIViewController * presetingViewController;
@property (nonatomic,strong) MFMailComposeViewController * mailComposeViewController;

-(void)launch;

@end
