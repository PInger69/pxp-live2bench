//
//  RicoPlayerPool.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RicoPlayerViewController.h"
#import "RicoPlayerViewControllerSO.h"
@interface RicoPlayerPool : NSObject


+(instancetype)instance;


@property(atomic,strong) NSMutableArray              * pooledPlayers;
@property(atomic,strong) RicoPlayerViewController    * defaultController;



@end
