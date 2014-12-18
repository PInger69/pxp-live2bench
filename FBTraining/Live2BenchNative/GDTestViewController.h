//
//  GDTestViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/12/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface GDTestViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>



@property (nonatomic, strong) GTLServiceDrive *driveService;




@end