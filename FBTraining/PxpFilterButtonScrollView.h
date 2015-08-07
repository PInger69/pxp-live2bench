//
//  PxpFilterButtonScrollView.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterButtonScrollView : UIScrollView <UIScrollViewDelegate,PxpFilterModuleProtocol>


@property (nonatomic,strong) NSString           * sortByPropertyKey;
@property (nonatomic,strong) NSMutableArray     * buttonList;
@property (assign,nonatomic) CGSize             buttonSize; // used only during populate method
@property (assign,nonatomic) CGSize             buttonMargin; // used only during populate method

// Protocol
@property (nonatomic,weak) PxpFilter * parentFilter;


-(void)buildButtonsWith:(NSArray*)buttonLabels;



// Protocol
-(void)filterTags:(NSMutableArray *)tagsToFilter;

-(void)reset;


@end
