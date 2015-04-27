//
//  SegmentedViewController.m
//  SegmentedViewController
//
//  Created by dev on 2015-01-23.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "SegmentedView.h"

@interface SegmentedView()

@property (strong, nonatomic) UILabel *Label1;
@property (strong, nonatomic) UILabel *Label2;


@end


@implementation SegmentedView
@synthesize frame = _frame;
@synthesize parentView = _parentView;
@synthesize tintColor = _tintColor;

-(instancetype)initWithDataDictionary: (NSDictionary *)dataDictionary andPlistDictionary: (NSDictionary *)plistDictionary{
    self = [super init];
    if (self) {
        
        self.segmentQuantity = [dataDictionary[@"segmentQuantity"] intValue];
        self.informationArray = dataDictionary[@"initializationArray"];
        self.name = dataDictionary[@"segmentName"];
        
        
        
        self.segmentView = [[UISegmentedControl alloc]initWithItems: [self segmentItemsArray]];
        self.tintColor = [UIColor orangeColor];
        [self.segmentView addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationNoticed:) name:@"Selection" object:nil];
        
        //---------------------------------------
        self.segmentTitle = [[UILabel alloc]init];
        self.segmentTitle.text = self.name;
        self.segmentView.selectedSegmentIndex = [[dataDictionary[@"selectedIndex"] objectAtIndex:0] intValue];
        
        if (self.segmentQuantity == 2) {
            self.secondSegmentView = [[UISegmentedControl alloc]initWithItems: [self segmentItemsArray]];
            //[self.secondSegmentView addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventValueChanged];
            self.secondSegmentView.tintColor = [UIColor orangeColor];
            self.secondSegmentView.selectedSegmentIndex = [[dataDictionary[@"selectedIndex"] objectAtIndex:1] intValue];
        }
        
    }
    
    CGRect frame = CGRectMake([[plistDictionary[@"Position"] objectForKey:@"xPosition"] doubleValue], [[plistDictionary[@"Position"] objectForKey:@"yPosition"] doubleValue], [[plistDictionary[@"Position"] objectForKey:@"width"] floatValue], [[plistDictionary[@"Position"] objectForKey:@"height"] floatValue]);
    self.frame = frame;
    
    return self;
}


#pragma mark - custom setter properties
/**
 *  This method also adds the segment view to the View Controllers view.
 *  The segmentView is added to the view controller here, because this is the
 *  first time that SegmentedView receives a reference to its View controller
 *
 *  @param viewController is just a delegate that abides by the view receiver protocol,
 *  this allows the SegmentedView to get access to the View Controllers view
 */
-(void)setParentView: (UIView *)parentView{
    _parentView = parentView;
    //[self.parentView addSubview:self.segmentView];
    [self.parentView addSubview:self.viewForEachPart];
}


/**
 *  This property will also change the tint Color of its segmented View
 *  therefore when this property is changed, the segmented view will change
 *  colour instantaneously
 *
 *  @param tintColor this is just a simple UIColor object
 */
-(void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    [self.segmentView setTintColor:tintColor];
}


/**
 *  The frame of the first segment piece is the only one that has to be specified.
 *  The rest will be set based on its width and height
 *
 *  @param frame, this is only the frame of the first segment
 */
-(void)setFrame:(CGRect)frame{
    if (self.segmentQuantity == 1) {
        //_frame = frame;
        self.segmentView.frame = CGRectMake(0, frame.size.height, frame.size.width * self.informationArray.count , frame.size.height);
        _frame = self.viewForEachPart.frame;
        //------------------------------------------------
        self.viewForEachPart = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width *  self.informationArray.count , frame.size.height*2)];
        [self.segmentTitle setFrame:CGRectMake(0, 0, self.segmentView.frame.size.width, frame.size.height)];
        self.segmentTitle.text = self.name;
        [self.viewForEachPart addSubview:self.segmentView];
        [self.viewForEachPart addSubview:self.segmentTitle];
        
        
    } else {
        self.viewForEachPart = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width *  (self.informationArray.count+1), frame.size.height*3.2)];
        self.segmentView.frame = CGRectMake(frame.size.width, frame.size.height, frame.size.width * self.informationArray.count , frame.size.height);
        self.secondSegmentView.frame = CGRectMake(frame.size.width, frame.size.height * 2.2, frame.size.width * self.informationArray.count, frame.size.height);
        [self.segmentTitle setFrame:CGRectMake(0, 0, self.segmentView.frame.size.width, frame.size.height)];
        [self.viewForEachPart addSubview:self.segmentView];
        [self.viewForEachPart addSubview:self.secondSegmentView];
        [self.viewForEachPart addSubview:self.segmentTitle];
        
        self.Label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.1*frame.size.width, frame.size.height, frame.size.height, frame.size.height)];
        self.Label1.text = @"H";
        self.Label1.textColor = [UIColor whiteColor];
        self.Label1.backgroundColor = [UIColor grayColor];
        self.Label1.textAlignment = NSTextAlignmentCenter;
        
        self.Label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.1*frame.size.width, frame.size.height*2.2, frame.size.height, frame.size.height)];
        self.Label2.text = @"A";
        self.Label2.textColor = [UIColor whiteColor];
        self.Label2.backgroundColor = [UIColor grayColor];
        self.Label2.textAlignment = NSTextAlignmentCenter;
        
        [self.viewForEachPart addSubview:self.Label1];
        [self.viewForEachPart addSubview:self.Label2];
    }
    
}

-(CGRect)frame{
    return _frame;
}
#pragma mark - method implementations

/**
 *  This method extracts the Name information that is in the information Array
 *
 *  @return an array with all the names of each segment view is returned. The names
 *  are then displayed as the segment titles.
 */
-(NSArray *)segmentItemsArray{
    NSMutableArray *returningArray = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < self.informationArray.count; ++i){
        [returningArray addObject:[(self.informationArray[i]) objectForKey:@"Name"]];
    }
    
    return [returningArray copy];
}


-(void)removeFromSuperview{
    [self.segmentView removeFromSuperview];
    [self.secondSegmentView removeFromSuperview];
    [self.segmentTitle removeFromSuperview];
    [self.Label1 removeFromSuperview];
    [self.Label2 removeFromSuperview];
    
}


#pragma mark - Notification methods
/**
 *  This method is only called upon if there is a notification that alerts this object
 *  to change the selected index
 *
 *  @param theNotification is a simple Notification object that has all the necessary information
 */
-(void) notificationNoticed: (NSNotification *)theNotification{
    id index = theNotification.userInfo[@"Index"];
    id name = theNotification.userInfo[@"Name"];
    if(index){
        self.segmentView.selectedSegmentIndex = (int)index;
    }else{
        NSArray *arrayWithNames = [self segmentItemsArray];
        int index2 = (int)[arrayWithNames indexOfObject:name];
        self.segmentView.selectedSegmentIndex = index2;
    }
}

/**
 *  This method simply puts out a notification with the original information of each segment
 *
 *  @param sender This is the segmentView itself, and by knowing its index, the appropriate information is
 *  sent out.
 */
-(void)segmentTapped: (UISegmentedControl *) sender{
    
//    void (^notificationBlock)(float time) = ^void(float time){
//        NSDictionary *userInfo = @{ @"type": [NSNumber numberWithInt: self.type], @"name": [self segmentItemsArray][sender.selectedSegmentIndex] , @"time": [NSNumber numberWithFloat:time], @"period": [NSNumber numberWithInt: sender.selectedSegmentIndex]};
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_POSTED object:nil userInfo:userInfo];
//    };
    
    
    //NSDictionary *videoPlayerUserInfo = @{@"Context": STRING_LIVE2BENCH_CONTEXT , @"notificationBlock": notificationBlock};
   // NSNotification *sendingNotification = [NSNotification notificationWithName:NOTIF_CURRENT_TIME_REQUEST object:self userInfo: videoPlayerUserInfo];
    //[[NSNotificationCenter defaultCenter] postNotification: sendingNotification];
}



@end
