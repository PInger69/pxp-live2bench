//
//  PxpUserFilter.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpUserFilter : UIView <PxpFilterModuleProtocol>



@property (nonatomic,weak)      PxpFilter  * parentFilter;

-(void)filterTags:(NSMutableArray*)tagsToFilter;

-(void)buildButtonsWith:(NSArray*)userColors;



@end
