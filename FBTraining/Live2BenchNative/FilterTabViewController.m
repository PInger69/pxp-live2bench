//
//  FilterTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 7/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterTabViewController.h"



@implementation FilterTabViewController
{
    
    
    NSArray     * rawTagData;
    NSArray     * allTabs;
    FilterTab   * currentTab;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        // Initialization code
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [UIColor randomColor].CGColor;
    }
    return self;
}



-(void)addTabList:(NSArray*)tabList
{
    
    allTabs = tabList;
    NSUInteger  count = tabList.count;
    
    for (int i = 0; i<count; i++) {
        FilterTab * checkTab =(FilterTab *) tabList[i];
        [checkTab setTabXposition:186*i];
        [self.view addSubview:checkTab];
        
        // needs to be moved to proper locaiton
        [self.view addSubview:checkTab.tabLabel];
                [checkTab.tabLabel setTag:i];
        
     [checkTab.tabLabel addTarget:self action:@selector(tabSelect:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [self tabSelect:[tabList lastObject]];
}

-(void)tabSelect:(id)tab
{
    for (FilterTab * tb in allTabs){
        [tb setIsSelected:FALSE];
    }
    NSUInteger i = [((FilterTab *)tab) tag];
    currentTab = (FilterTab *) allTabs[i];
    [currentTab setIsSelected:TRUE];
}



-(FilterTab *)getCurrentTab
{
    return currentTab;
}

-(void)onSelectPerformSelector:(SEL)sel addTarget:target
{
    for(FilterTab* filtertab in allTabs) {
        [filtertab onSelectPerformSelector:sel addTarget:target];
//        [[filtertab.componentList lastObject]onSelectPerformSelector:sel addTarget:target];
    }
}


/**
 *  This will be the main input for the first all the tags to be filtered
 *  This will also be the main input from the linked list
 *  @param list to be filtered
 */
-(void)inputArray:(NSArray*)list
{
    
    rawTagData = list;
    
    for(FilterTab* filtertab in allTabs) {
        [[filtertab.componentList firstObject] inputArray:list];
        [filtertab.componentList makeObjectsPerformSelector:@selector(populate:) withObject:list];
    }
}


-(NSArray *)currentTabProcessedList
{

    if (currentTab.componentList.count == 0){
        return rawTagData;// passes the raw data if there is no filter in the tab
    } else {
        return  currentTab.processedList;
    }
    
    
}

/**
 *  This is so you can set the default tab
 *
 *  @param tabName name of th etab
 */
-(void)setCurrentTab:(NSString*)tabName
{
    for(FilterTab * tb in allTabs) {
        if ([tb.name isEqualToString:tabName]){
            [self tabSelect:tb.tabLabel];
            break;
        }
    }
}

/**
 *  This returns the names of the components that have been selected in all tabs
 *  This reason for this is that maybe more then one tab can do filtering
 *  @return array of string names
 */
-(NSArray*)invokedComponentNames
{
    NSMutableArray* components =[[NSMutableArray alloc]init];
    for (int i = 0; i<allTabs.count;i++){
        FilterTab * compTab = [allTabs objectAtIndex:i];
        NSArray * compName = [compTab invokedComponentNames];
        
        if ([compName count]) [components addObjectsFromArray:compName];
    }
    return [components copy];
}



-(NSArray*)prefilteredList
{
    return rawTagData;
}




@end
