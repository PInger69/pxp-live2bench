//
//  EulaModalViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-02-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EulaModalViewController : UIViewController
{

}
@property (nonatomic,assign)    BOOL accepted;

-(void)onCompleteAccept:(void(^)(void))onAccept;

- (void)dismissView:(id)sender;
- (void)acceptEula:(id)sender;


@property (strong, nonatomic) UIButton *acceptEulaButton;


@end
