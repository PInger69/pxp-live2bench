//
//  NameCameraCellView.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameCameraCellView : UIView
@property (strong, nonatomic)   IBOutlet UITextField *UserInputField;
@property (strong, nonatomic)   IBOutlet UILabel *camIDLabel;
@property (strong, nonatomic)   IBOutlet UIView *view;
@property (weak, nonatomic)     IBOutlet UILabel *ipAddressLabel;

@end
