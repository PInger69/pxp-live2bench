//
//  PxpFilterToggleButton.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-11.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterToggleButton : UIButton <PxpFilterModuleProtocol>


@property (nonatomic,weak)   PxpFilter          * parentFilter;
@property (nonatomic,strong) NSString           * filterPropertyKey;
@property (nonatomic,strong) NSString           * filterPropertyValue;
@property (nonatomic,strong) NSPredicate        * predicateToUse;

-(void)filterTags:(NSMutableArray*)tagsToFilter;
@end
