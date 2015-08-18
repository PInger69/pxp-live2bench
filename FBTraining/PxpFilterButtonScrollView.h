//
//  PxpFilterButtonScrollView.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"
#import "PxpFilterModuleDelegate.h"

typedef NS_ENUM (NSInteger,PxpFilterButtonScrollViewStyle){
    PxpFilterButtonScrollViewStylePortrate                  = 0,
    PxpFilterButtonScrollViewStyleLandscape                 = 1
};



@interface PxpFilterButtonScrollView : UIScrollView <UIScrollViewDelegate,PxpFilterModuleProtocol>


@property (nonatomic,strong) NSString           * sortByPropertyKey;
@property (nonatomic,strong) NSMutableArray     * buttonList;
@property (nonatomic,strong) NSMutableArray     * userSelected;
@property (assign,nonatomic) CGSize             buttonSize; // used only during populate method
@property (assign,nonatomic) CGSize             buttonMargin; // used only during populate method
@property (nonatomic,assign) PxpFilterButtonScrollViewStyle style;
@property (nonatomic,strong) NSPredicate        * predicate;
@property (nonatomic,assign) BOOL displayAllTagIfAllFilterOn;

@property (nonatomic,weak) id <PxpFilterModuleDelegate> delegate;

// Protocol
@property (nonatomic,assign)    BOOL        modified;
@property (nonatomic,weak)      PxpFilter   * parentFilter;


-(void)buildButtonsWith:(NSArray*)buttonLabels;



// Protocol
-(void)filterTags:(NSMutableArray *)tagsToFilter;

-(void)reset;


@end
