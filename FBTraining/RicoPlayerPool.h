//
//  RicoPlayerPool.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RicoPlayerViewController.h"

@interface RicoPlayerPool : NSObject


+(instancetype)instance;


@property(nonatomic,strong) NSMutableArray              * pooledPlayers;
@property(nonatomic,strong) RicoPlayerViewController    * defaultController;



@end
