//
//  AbstractFilterViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "AbstractFilterViewController.h"
#import "FilterScrollView.h"
#import "FilterComponent.h"
#define ROWS_IN_EVENTS                 6
#define PADDING                        3
#define DIVIDER_COLOR [UIColor whiteColor]
#define UPDATE_INTERVAL                 1



@interface AbstractFilterViewController ()

@end


@implementation AbstractFilterViewController
{
    NSMutableArray   * selectTargets;
    NSMutableArray   * onSelectSelectors;
    id    swipeTarget;
    SEL   onSwipe;
    //NSMutableDictionary *rawTagData;
    //NSMutableArray      *rawTagArray;
    CGRect  onScreenRect;
    CGRect  offScreenRect;
    BOOL    isOpen;
    NSArray *exclusionKeys;
    NSArray *exclusionValues;
    UILabel *totalTagNumber;
    UILabel *filteredTagNumber;

    
}

@synthesize  finishedSwipe;
@synthesize  tabManager;




- (id)initWithTagData: (NSMutableDictionary *)tagData
{
    self = [super init];

    if (self) {
        // Custom initialization

        _rawTagData = tagData;
        selectTargets = [NSMutableArray array];
        onSelectSelectors = [NSMutableArray array];
         //tabManager = [[FilterTabViewController alloc]initWithFrame:CGRectMake(0, 0, FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT+50)];
         //[self.view addSubview:tabManager.view];
    }
    return self;
}

- (id)initWithTagArray: (NSMutableArray *)tagArray
{
    self = [super init];
    
    if (self) {
        // Custom initialization
        
        _rawTagArray = tagArray;
        selectTargets = [NSMutableArray array];
        onSelectSelectors = [NSMutableArray array];
         //tabManager = [[FilterTabViewController alloc]initWithFrame:CGRectMake(0, 0, FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT+50)];
         //[self.view addSubview:tabManager.view];
    }
    return self;
}

-(void)setRawTagArray:(NSMutableArray *)newRawTagArray{
    _rawTagArray = newRawTagArray;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self componentSetup];
}

/**
 *  Abstract method, this is ment to be overriden for all compoenents and linking
 */
-(void)componentSetup
{
       

}

-(void)setOrigin:(CGPoint)origin
{
    onScreenRect = CGRectMake(origin.x, origin.y,
                              self.view.frame.size.width, self.view.frame.size.height);
    offScreenRect = CGRectMake(origin.x +FULL_WIDTH, origin.y,
                               self.view.frame.size.width, self.view.frame.size.height);

}
-(void)open:(BOOL)animated
{
    if (isOpen) return;
    [self refresh];
    if (animated) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.view setFrame:onScreenRect];
                         }
                             completion:^(BOOL finished){
                                 isOpen = YES;
                             }];
        
    } else {
        [self.view setFrame:onScreenRect];
        isOpen = YES;
    }
    
 
}

-(void)close:(BOOL)animated
{
    if (!isOpen) return;
    if (animated) {
        [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view setFrame:offScreenRect];
                     }
                         completion:^(BOOL finished){
                             isOpen = NO;
                             [self.view removeFromSuperview];
                         }];
      } else {
          [self.view setFrame:offScreenRect];
          isOpen = NO;
      }
}

-(void)setupView
{
    
//    self.view.layer.borderWidth =1;
    self.view.frame =CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                                FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT+44);
    isOpen = YES;

    onScreenRect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                              self.view.frame.size.width, self.view.frame.size.height);
    offScreenRect = CGRectMake(self.view.frame.origin.x +FULL_WIDTH, self.view.frame.origin.y,
                               self.view.frame.size.width, self.view.frame.size.height);
    // This is the color of the filter back plate
    backplate = [[UIView alloc] init];
    [backplate setBackgroundColor:[Utility colorWithHexString:@"#e6e6e6"]];
    [backplate setFrame:CGRectMake(0, 44, FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT)];

    [self.view addSubview:backplate];
    
    // this is the main placement of the tabs
    
    if (!tabManager) {
        tabManager = [[FilterTabViewController alloc]initWithFrame:CGRectMake(0, 0, FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT+50)];
        [self.view addSubview:tabManager.view];
    }
    //tabManager = [[FilterTabViewController alloc]initWithFrame:CGRectMake(0, 0, FILTER_AREA_WIDTH, FILTER_AREA_HEIGHT+50)];

   
    
    //[self.view addSubview:tabManager.view];
    
    // this will show the total number of tabs
    /*numTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(backplate.bounds.size.width - 110.0f, 300.0f, 100.0f, 21.0f)];
//    [numTagsLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    numTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -100, self.view.frame.size.height - 20.0f, 300.0f, 100.0f)];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:@"Tags"];
    [numTagsLabel setTextColor:[UIColor darkGrayColor]];
    [numTagsLabel setBackgroundColor:[UIColor clearColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:17.0f]];
    //[self.view addSubview:numTagsLabel];*/

    // Filter clear button, this will always sit on top of all tabs but control the active tab unless connected
    clearAll = [CustomButton buttonWithType:UIButtonTypeCustom];
    [clearAll setFrame:CGRectMake(numTagsLabel.frame.origin.x+100, numTagsLabel.frame.origin.y, 60, 25)];
    [clearAll setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
    [clearAll setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
    [clearAll setAccessibilityLabel:@"allclear"];
    
    [clearAll addTarget:self action:@selector(clearAllTags:) forControlEvents:UIControlEventTouchUpInside];
    [clearAll setTitle:@"Clear all" forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    clearAll.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    [self.view addSubview:clearAll];
    [self.view setAutoresizingMask: UIViewAutoresizingNone];
    
    totalTagNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -560, self.view.frame.size.height -55, 160.0f, 20.0f)];
    [totalTagNumber setBackgroundColor:[UIColor clearColor]];
    [totalTagNumber setTextColor:[UIColor blackColor]];
    [totalTagNumber setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:totalTagNumber];
    
    filteredTagNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -420, self.view.frame.size.height -55, 160.0f, 20.0f)];
    [filteredTagNumber setBackgroundColor:[UIColor clearColor]];
    [filteredTagNumber setTextColor:[UIColor blackColor]];
    [filteredTagNumber setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:filteredTagNumber];
    
    
    

}




/**
 *  When the view appears the main Dict that is init with will be scrubbed to just its tags
 *  then it will take that dict and pass it into the FilterTabViewController (tabManager)
 *  this will make sure that all the tabs will be populated with and act separatly from each other
 *  if needed it will also send the selector for update to each tab and tab componenent.
 *  One update is done on first view
 */
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
    [tabManager onSelectPerformSelector:@selector(sortClipsBySelecting) addTarget:self];
    
}


/**
 *  This is meant to be overriden by the MyClipFilterViewController
 *  The reason is that the data used in the bookmark area has an extra layer of dicts based off event names
 */
-(NSMutableArray *)formatTagsForDisplay:(NSMutableArray *)unformatedTags
{
    return [unformatedTags copy];
}



-(void)clearAllTags:(id)sender
{
    
    //if ([tabManager prefilteredList].count == [tabManager currentTabProcessedList].count)return;
    
    [[tabManager getCurrentTab].componentList makeObjectsPerformSelector:@selector(deselectAll)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FILTER_CHANGE object:self userInfo:nil];
}


//sorting mechanism
-(void)sortClipsBySelecting
{

    NSInteger filteredTagCount = [self countOfFiltededTags];
    [filteredTagNumber setText:[NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"Filtered Tag", nil), (long)filteredTagCount]];
    
    NSInteger totalTagCount = [_rawTagArray count];
    [totalTagNumber setText:[NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"Total Tags", nil),(long)totalTagCount]];
    

    if (onSelectSelectors){
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for (int i =0; i < onSelectSelectors.count; ++i) {
            NSString *selectorString = onSelectSelectors[i];
            [selectTargets[i] performSelector: NSSelectorFromString(selectorString) withObject:self];
        }
        
    }

    // This is the list that will be the new display list
//    NSArray * test = [self processedList];

}




- (IBAction)swipeFilter:(id)sender {
     if (onSwipe){
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [swipeTarget performSelector:onSwipe withObject:self];
    }
    // [[superArgs objectForKey:@"controller"] slideFilterBox];
}


-(void)onSwipePerformSelector:(SEL)sel addTarget:(id)target
{
    swipeTarget = target;
    onSwipe = sel;
}




//#pragma mark - IS DEAD?
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
////    [self.bookmarkViewController dismissFilterToolbox];
//    
//}


/**
 *  This will be used to update the display of its controlling tab
 *
 *  @param sel    update the display with the new list from this filter
 *  @param target tab controller
 */
-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target
{
    [selectTargets addObject: target];
    [onSelectSelectors addObject:NSStringFromSelector(sel)];
    //onSelect = sel;
}


/**
 *  This grabs the list to be displayed after the filter process
 *  The last element of the linked list is the final refined data
 *  @return list to be displayed
 */
-(NSArray*)processedList
{
    return [tabManager currentTabProcessedList];
}


/**
 *  Count of tages after filtering
 *
 *  @return count
 */
-(NSInteger)countOfFiltededTags
{
    return [self processedList].count;
}

/**
 *  This pulls the data again from the rawData
 */
-(void)refresh
{
    
    
    // a sort on view appeared
    if (_rawTagData) {
        _rawTagArray = [[_rawTagData allValues] mutableCopy];
    }
    
    NSMutableArray *allBookmarkDictArr = [NSMutableArray arrayWithArray:[self formatTagsForDisplay: _rawTagArray]];
    
    
    
    // TODO make this a better filter
    //    if (exclusionKeys) {
    //        // remove all tags with the key of...
    //
    //        for (NSString * thekey in exclusionKeys) {
    //
    //            int count = [allBookmarkDictArr count]-1;
    //
    //            for (int i=count; i>=0; i--) {
    //                if ([[allBookmarkDictArr objectAtIndex:i]objectForKey:thekey]){
    //
    //                    [allBookmarkDictArr removeObjectAtIndex:i];
    //                }
    //            }
    //
    //        }
    //    }
    //
    //    if (exclusionValues) {
    //        for (NSString * thekey in exclusionValues) {
    //
    //            for (NSMutableDictionary * tagDict in allBookmarkDictArr) {
    //                NSArray * allVals = [tagDict allValues];
    //                for (id currentValue in allVals)
    //                {
    //                   if ([currentValue isEqualToString:thekey]) [allBookmarkDictArr removeObject:tagDict];
    //                }
    //            }
    //        }
    //    }
    
    if ([self isDifference:[tabManager prefilteredList] and:allBookmarkDictArr])return; // This finds if there is a difference in the new and the old list and only refreshes if there is a difference
    [tabManager inputArray:allBookmarkDictArr];
    [self sortClipsBySelecting];
}


-(BOOL)isDifference:(NSArray*)listRaw and:(NSArray*)listProcessed
{
    NSSet           * set1      = [NSSet setWithArray:listRaw];
    NSSet           * set2      = [NSSet setWithArray:listProcessed];
    
    
    return [set2 isEqualToSet:set1] ;
}


-(void)exclusionKeys:(NSArray *)listOfKeys
{
    exclusionKeys = listOfKeys;
}

-(void)exclusionValues:(NSArray *)listOfValues
{
    exclusionValues = listOfValues;
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    
    if ([self.view window] == nil) self.view = nil;
    // Dispose of any resources that can be recreated.
}

-(BOOL)rawDataEmpty
{
    return !(BOOL)[_rawTagData count];

}



@end
