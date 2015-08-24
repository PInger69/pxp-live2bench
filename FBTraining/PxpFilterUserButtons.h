//
//  PxpFilterUserButtons.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"
@interface PxpFilterUserButtons : UIView <PxpFilterModuleProtocol>

@property (nonatomic,assign)    BOOL    modified;
@property (nonatomic,weak)      PxpFilter  * parentFilter;

-(void)filterTags:(NSMutableArray*)tagsToFilter;

-(void)buildButtonsWith:(NSArray*)userColors;


@end
