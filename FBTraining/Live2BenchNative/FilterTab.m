





//
//  FilterTab.m
//  Live2BenchNative
//
//  Created by dev on 7/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterTab.h"
#import "CustomButton.h"
#import "FilterScrollView.h"
#import "FilterComponent.h"
#import <QuartzCore/QuartzCore.h>
#define FILTER_FRAME_RECT   CGRectMake(0, 44, 925, 330)
#define TAB_BUTTON_HEIGHT   44
#define TAB_BUTTON_WIDTH    180

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation FilterTab
{
    NSArray * componentList;

    // These are for when a tab is pressed the filterin is run
    SEL onSelectSelector;
    id selTarget;

    
}
@synthesize tabLabel;
@synthesize name;
@synthesize componentList;
@synthesize clearOnLeaveTab;
-(id)initWithName:(NSString*)tabName
{
    self = [super initWithFrame:FILTER_FRAME_RECT];
    if (self) {
        name                = tabName;
        clearOnLeaveTab     = NO;
        componentList       = [[NSArray alloc]init];
        tabLabel            = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        [tabLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [tabLabel setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateSelected];
        tabLabel.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [tabLabel setFrame:CGRectMake(0, 0, TAB_BUTTON_WIDTH, TAB_BUTTON_HEIGHT)];
        [tabLabel setBackgroundColor:[Utility colorWithHexString:@"#e6e6e6"]];

         UIBezierPath * myFirstShape;
        myFirstShape = [[UIBezierPath alloc]init];
        

        [myFirstShape moveToPoint: CGPointMake(0,tabLabel.frame.size.height)];
        [myFirstShape addLineToPoint: CGPointMake(0,tabLabel.frame.size.height-10)];
        
        
        [myFirstShape addLineToPoint: CGPointMake(5,tabLabel.frame.size.height*.35)];

        [myFirstShape addQuadCurveToPoint:CGPointMake(20,0)
                           controlPoint:CGPointMake(10,0)];
      
        [myFirstShape addLineToPoint: CGPointMake(20,0)];
        
        

        [myFirstShape addLineToPoint: CGPointMake(tabLabel.frame.size.width-20,0)];
       
        [myFirstShape addQuadCurveToPoint:CGPointMake(tabLabel.frame.size.width-5,tabLabel.frame.size.height*.35)
                             controlPoint:CGPointMake(tabLabel.frame.size.width-10,0)];
       
        [myFirstShape addLineToPoint: CGPointMake(tabLabel.frame.size.width-5,tabLabel.frame.size.height*.35)];

        
        
        [myFirstShape addLineToPoint: CGPointMake(tabLabel.frame.size.width,tabLabel.frame.size.height-10)];
        [myFirstShape addLineToPoint: CGPointMake(tabLabel.frame.size.width,tabLabel.frame.size.height)];
        [myFirstShape closePath];
        
        CAShapeLayer* shapeLayer;
        shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
        shapeLayer.lineWidth = 1.0;
        
        shapeLayer.fillColor = [UIColor blueColor].CGColor;
        
        [tabLabel.layer addSublayer:shapeLayer];
        
        shapeLayer.path = myFirstShape.CGPath;
        tabLabel.layer.mask = shapeLayer;
        [tabLabel setTitle:tabName forState:UIControlStateNormal];
        
    }
    return self;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)setIsSelected:(BOOL)isSelect
{

    if (isSelect){
        [self setHidden:NO];
        
        [tabLabel setUserInteractionEnabled:NO];
        [tabLabel setSelected: YES];
         if (onSelectSelector) [selTarget performSelector:onSelectSelector withObject:self];
    } else {
        [self setHidden:YES];
        [tabLabel setUserInteractionEnabled:YES];
        [tabLabel setSelected: NO];
        
        
        
        
        if (clearOnLeaveTab) [componentList makeObjectsPerformSelector:@selector(deselectAll)];
        

    }
  
}


-(void)setTabXposition:(float)x
{
    [tabLabel setFrame:CGRectMake(x, 10, TAB_BUTTON_WIDTH, TAB_BUTTON_HEIGHT)];
}

///**
// *  This is like the normal addSubview but if its a type of FilterScrollView componenent then its added to the list
// *
// *  @param view add to tab
// */
//-(void)addSubview:(UIView *)view
//{
//    [super addSubview:view];
//   
//}


-(void)clearAllTags:(id)sender
{
    
    [componentList makeObjectsPerformSelector:@selector(deselectAll)];
}



/**
 *  This grabs the list to be displayed after the filter process
 *  The last element of the linked list is the final refined data
 *  @return list to be displayed
 */
-(NSArray*)processedList
{

    id <FilterComponent> checker = [componentList lastObject];
    NSArray * output = [checker refinedList];
    
    return output;
}


/**
 *  This links all the components together so they process the data in a series
 *  and populates the componentsList.
 *  This is ment to be a protected method and be used when extending this class
 *  @param cmpList component list
 */
-(void)linkComponents:(NSArray *)cmpList
{
    componentList = cmpList;
    int count = cmpList.count-1;
    for (int i= count; i>=0;i--){
        id <FilterComponent> cmpItem = cmpList[i];
        [cmpItem previousComponent:     (i == 0)? nil :  cmpList[i-1]];
        [cmpItem nextComponent:         (i == count)  ? nil : cmpList[i+1]];
    }
}


/**
 *  This returns the names of the components that have been selected in this tab
 *
 *  @return array of string names
 */
-(NSArray*)invokedComponentNames
{
    NSMutableArray* components =[[NSMutableArray alloc]init];
    for (int i = 0; i<componentList.count;i++){
        id <FilterComponent> comp = [componentList objectAtIndex:i];
        NSString * compName = [comp getName];
        if ([comp isInvoked]) [components addObject:compName];
    }
    return [components copy];
}



/**
 *  This is the method that will run when ever the component is tapped and is
 *  and is the last compoenent in the linked list.
 *  @param sel
 *  @param target
 */
-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target
{
    selTarget = target;
    onSelectSelector = sel;
    [[self.componentList lastObject]onSelectPerformSelector:sel addTarget:target];
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



-(void)drawLine:(CGPoint)from to:(CGPoint)to lineWidth:(float) lineWidth strokeColor:(UIColor*)strokeColor
{
    UIBezierPath *myFirstShape = [[UIBezierPath alloc]init];
    
    
    [myFirstShape moveToPoint: from];
    [myFirstShape addLineToPoint: to];
    //[myFirstShape closePath];
    
    CAShapeLayer* shapeLayer;
    shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    shapeLayer.lineWidth    = lineWidth;
    shapeLayer.strokeColor  = strokeColor.CGColor;

    
    [self.layer addSublayer:shapeLayer];
    
    shapeLayer.path = myFirstShape.CGPath;



}




@end
