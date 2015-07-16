//
//  MedicalViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "CustomTabViewController.h"

typedef NS_OPTIONS (NSInteger,MedicalScreenModes){
    
    MedicaScreenDisable,
    MedicalScreenRegular,
    MedicalScreenLive
};


@interface MedicalViewController : CustomTabViewController


@property (nonatomic,strong)    UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,assign)    MedicalScreenModes                mode;

@end
