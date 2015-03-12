//
//  BookmarkFilterViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Globals.h"
#import "FilterScrollView.h"
#import "FilterTabViewController.h"
#import "CustomButton.h"

#define FILTER_AREA_WIDTH   925
#define FILTER_AREA_HEIGHT  340
#define FULL_WIDTH      1024
@interface AbstractFilterViewController : UIViewController<UIScrollViewDelegate>
{

    CustomButton            * clearAll;
    UILabel                 * numTagsLabel;
    UIView                  * backplate;
    FilterTabViewController * tabManager;
}


@property (nonatomic) BOOL finishedSwipe;
@property (strong,nonatomic) FilterTabViewController * tabManager;

@property (strong, nonatomic) NSMutableDictionary *rawTagData;
@property (strong, nonatomic) NSMutableArray      *rawTagArray;

-(IBAction)swipeFilter:(id)sender;
- (id)initWithTagData: (NSMutableDictionary *)tagData;
- (id)initWithTagArray: (NSMutableArray *)tagArray;

// New
-(NSArray*)processedList;
-(NSInteger)countOfFiltededTags;
-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target;
-(void)onSwipePerformSelector:(SEL)sel addTarget:(id)target;

-(void)exclusionKeys:(NSArray *)listOfKeys;
-(void)exclusionValues:(NSArray *)listOfValues;

-(void)componentSetup;
-(void)open:(BOOL)animated; //TODO Names this better
-(void)close:(BOOL)animated;//TODO Names this better
-(void)setOrigin:(CGPoint)origin;
-(void)refresh;
-(void)autoRefresh:(BOOL)enable;
-(BOOL)rawDataEmpty; //TODO fix this. it is do make sure it synced with the global kinda

@end
