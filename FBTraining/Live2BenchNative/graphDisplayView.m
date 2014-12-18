//
//  GraphScrollView.m
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import "graphDisplayView.h"

#import "JPStyle.h"
#import "JPFont.h"


static const CGFloat graphTopOffset = 40;
static const CGFloat graphBottomOffset = 32;

const NSInteger kTagMarkConstant = 100;
const NSInteger kDashLineViewConst = 240;

const NSInteger kPeriodNameLabelConst = 149;

@interface graphDisplayView()

@property (nonatomic, assign) CGFloat totalZoneAverage;
@property (nonatomic, assign) CGFloat OZoneYPosition;
@property (nonatomic, assign) CGFloat DZoneYPosition;

@end

@implementation graphDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        _frame = frame;
        graphHeight = frame.size.height - graphTopOffset - graphBottomOffset;
        

        _tagIndicatorBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _tagIndicatorBackground.backgroundColor = [JPStyle colorWithHex:@"e6e6e6" alpha:1];
        _tagIndicatorBackground.clipsToBounds = YES;
        [self addSubview:_tagIndicatorBackground];

        dashedLineHeight = graphHeight + 37;
        _periodDashedLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(_periodDashedLinePath, NULL, 15, 45); //dashline view is 30 width
        CGPathAddLineToPoint(_periodDashedLinePath, NULL, 15, dashedLineHeight);
        
    }
    return self;
}



#pragma mark - Reloading Data

- (void)reloadData
{
    //return if info aren't set
    if(!self.dataSource || !self.horizontalIncrement)
    {
        return;
    }
    
    //Clear everything from before
    for(UIView* subview in [_tagIndicatorBackground subviews])
    {
        [subview removeFromSuperview];
    }
    _tagIndicatorBackground.frame = CGRectZero;
    
    self.totalZoneAverage = 0.0f;
    self.OZoneYPosition = 0.0f;
    self.DZoneYPosition = 0.0f;
    
    while([_dashedLineViews count] > 0)
    {
        [[_dashedLineViews firstObject] removeFromSuperview];
    }
    
    _dashedLineViews = [NSMutableArray array];
    
    //reload Everything
    CGFloat eventDuration = [self.dataSource eventDuration];    
    _tagIndicatorBackground.frame = CGRectMake(2, 5, eventDuration*self.horizontalIncrement + 30, 35);
    
    [self reloadTagData];
    [self reloadTotalZoneAverage];
    //////////////////////////////////////////////

    //Period End Lines
    CGFloat currentXPosition = 4;
    NSInteger numberOfPeriods = [self.dataSource numberOfTaggedPeriods];
    
    for(int i =0 ; i<numberOfPeriods ; i++)
    {
        currentXPosition = 4 + [self.dataSource timeForPeriodEnded:i]* self.horizontalIncrement;
        
        UIView* dashLineView = [[UIView alloc] initWithFrame:CGRectMake(currentXPosition - 15, graphTopOffset - 30, 30, dashedLineHeight)];
        // Adding the Dashed Line
        CAShapeLayer* dashedLine = [CAShapeLayer layer];
        dashedLine.path =  _periodDashedLinePath;
        dashedLine.lineDashPattern = @[@10, @5];
        dashedLine.lineDashPhase = 0.0f;
        dashedLine.lineWidth = 2;
        dashedLine.strokeColor = [UIColor darkGrayColor].CGColor;
        dashedLine.cornerRadius = 2;
        dashedLine.borderColor = [JPStyle colorWithName:@"blue"].CGColor;
        dashedLine.borderWidth = 2;
        [dashLineView.layer addSublayer:dashedLine];
        
        //Show a period name label when long pressed is detected at dashed line
        UILabel* periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, graphTopOffset - 25, 200, 25)];
        periodLabel.layer.borderWidth = 2;
        periodLabel.layer.borderColor = [JPStyle colorWithName:@"blue"].CGColor;
        periodLabel.layer.cornerRadius = 10;
        periodLabel.textAlignment = NSTextAlignmentLeft;
        periodLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:16.0f];
        if([self.dataSource respondsToSelector:@selector(nameForAllTaggedPeriod:)])
        {
            periodLabel.text = [NSString stringWithFormat:@" %@ ", [self.dataSource nameForAllTaggedPeriod:i]];
        }
        [periodLabel sizeToFit];
        periodLabel.tag = kPeriodNameLabelConst;
        periodLabel.hidden = YES;
        [dashLineView addSubview:periodLabel];
        
        //Adding touch recognizer for showing period name
        UILongPressGestureRecognizer* pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(periodDashlinePressed:)];
        [pressRecognizer setCancelsTouchesInView: NO];
        pressRecognizer.minimumPressDuration = 0.0f;
        [dashLineView addGestureRecognizer:pressRecognizer];
        
        [_dashedLineViews addObject:dashLineView];
        [self addSubview:dashLineView];
    }
    
    _currentEventDuration = eventDuration;
    
}



- (void)reloadTagData
{
    NSInteger numberOfTags = [self.dataSource numberOfTagsInGraphView:self];
    
    for(int i= 0; i<numberOfTags; i++)
    {
        NSDictionary* tagDict = [self.dataSource graphView:self tagInfoDictForTagNumber:i];
        NSString* timeString = [tagDict valueForKey:@"displaytime"];
        
        CGFloat hours = [[timeString substringWithRange:NSMakeRange(0, 1)] integerValue];
        CGFloat minutes = [[timeString substringWithRange:NSMakeRange(2, 2)] integerValue];
        CGFloat seconds = [[timeString substringWithRange:NSMakeRange(5, 2)] integerValue];
        CGFloat tagTime = hours*60*60 + minutes*60 + seconds; //in min
        ///////////////////////////////////

        //**Tag Mark View
        UIView* tagMarkView = [_tagIndicatorBackground viewWithTag:kTagMarkConstant + i];
        if(!tagMarkView)
        {
            tagMarkView = [[UIView alloc] init];
            tagMarkView.layer.cornerRadius = 8;
            tagMarkView.clipsToBounds = YES;
            tagMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
            tagMarkView.layer.borderWidth = 2;
            [_tagIndicatorBackground addSubview:tagMarkView];
        }
        
        tagMarkView.frame = CGRectMake(tagTime*self.horizontalIncrement - 15, 1, 33, 33);
        tagMarkView.tag = kTagMarkConstant + i;
        
        //Tag color
        NSString* tagColor = [tagDict valueForKey:@"colour"];
        tagMarkView.backgroundColor = [JPStyle colorWithHex:tagColor alpha:1];
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagMarkViewTapped:)];
        [tagMarkView addGestureRecognizer:tapRec];
        
        //Tag Letter
        UILabel* letterLabel;
        
        if([[tagMarkView subviews] firstObject]) //Letter exists already
        {
            letterLabel = [[tagMarkView subviews] firstObject];
        }
        else
        {
            letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
            letterLabel.textAlignment = NSTextAlignmentCenter;
            letterLabel.font = [UIFont boldSystemFontOfSize:25];
            letterLabel.textColor = [UIColor whiteColor];
            [tagMarkView addSubview:letterLabel];
        }
        
        NSString* tagName = [tagDict objectForKey:@"name"];
        NSString* letter = [tagName substringToIndex:1];
        letterLabel.text = letter;
        
    }
    
    _currentNumberOfTags  = numberOfTags;

}




- (void)reloadTotalZoneAverage //And No Info Label
{
    CGFloat eventDuration = [self.dataSource eventDuration]; //in Seconds
    NSUInteger dataPoints = [self.dataSource numberOfDataPointsInGraphView:self];
    
    JPZonePoint points[dataPoints+1];
    
    for (int i=0; i<dataPoints; i++)
    {
        points[i] = [self.dataSource graphView:self zonePointForPointNumber:i];
    }
    
    points[dataPoints] = JPZonePointMake(eventDuration, points[dataPoints-1].zone) ;
    
    //Calculation self.totalZoneAverage
    CGFloat zoneValueSum = 0;
    
    for (int i=0; i<dataPoints; i++)
    {
        JPZonePoint zonePoint = points[i];
        CGFloat zoneValue = zonePoint.zone;
        NSLog(@"nextPt:%f || thisPt:%f\n",points[i+1].minute,zonePoint.minute);
        NSLog(@"ZoneValue:%f", zoneValue);
        zoneValueSum += zoneValue * (points[i+1].minute - zonePoint.minute);
    }
    
    self.totalZoneAverage = zoneValueSum / eventDuration;
    
    if(dataPoints == 0) //if there weren't any dataPoints, avg points to Mid zone
    {
        self.totalZoneAverage = 50.0f;
    }
    
}


- (void)reloadDataCachedForScrolling
{
    //Reload Tag Data
    NSInteger numberOfTags = _currentNumberOfTags;
    
    for(int i= 0; i<numberOfTags; i++)
    {
        NSDictionary* tagDict = [self.dataSource graphView:self tagInfoDictForTagNumber:i];
        NSString* timeString = [tagDict valueForKey:@"displaytime"];
        
        CGFloat hours = [[timeString substringWithRange:NSMakeRange(0, 1)] integerValue];
        CGFloat minutes = [[timeString substringWithRange:NSMakeRange(2, 2)] integerValue];
        CGFloat seconds = [[timeString substringWithRange:NSMakeRange(5, 2)] integerValue];
        CGFloat tagTime = hours*60*60 + minutes*60 + seconds; //in min
        
        UIView* tagMarkView = [_tagIndicatorBackground viewWithTag:kTagMarkConstant + i];
        
        tagMarkView.frame = CGRectMake(tagTime*self.horizontalIncrement - 4, 1, 33, 33);
    }
    
    //Tag Indicator Background
    _tagIndicatorBackground.frame = CGRectMake(0, 5, _currentEventDuration*self.horizontalIncrement + 30, 35);
    
    //Period End Lines
    CGFloat currentXPosition = 4;
    NSInteger numberOfPeriods = [self.dataSource numberOfTaggedPeriods];
    
    for(int i =0 ; i<numberOfPeriods ; i++)
    {
        currentXPosition = 4 + [self.dataSource timeForPeriodEnded:i]* self.horizontalIncrement;
        
        UIView* dashLineView = [_dashedLineViews objectAtIndex:i];
        
        if(!dashLineView)
        {
            dashLineView = [[UIView alloc] init];
            [_dashedLineViews addObject:dashLineView];
            [self addSubview:dashLineView];
        }
        
        dashLineView.frame = CGRectMake(currentXPosition - 15, dashLineView.frame.origin.y, dashLineView.frame.size.width, dashLineView.frame.size.height);
        
    }
    
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(!self.dataSource || !self.horizontalIncrement)
    {
        return;
    }
    
    CGFloat eventDuration = [self.dataSource eventDuration]; //in Seconds
    NSUInteger dataPoints = [self.dataSource numberOfDataPointsInGraphView:self];
    if(eventDuration < 1 || dataPoints == 0)
    {
        return;
    }
    
    CGFloat verticalIncrement = graphHeight / 100.0f;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //Drawing Graph Lines
    JPZonePoint firstpt = [self.dataSource graphView:self zonePointForPointNumber:0];
    CGFloat cartesianY = firstpt.zone * verticalIncrement;
    
    CGContextMoveToPoint(context, 4, graphTopOffset + (graphHeight - cartesianY));
    
    JPZonePoint points[dataPoints+1]; //Extra Point when event ends
    points[0] = firstpt;
    CGFloat currHorizontalPoint = 0;
    
    for (int i=1; i<=dataPoints; i++) {
        
        JPZonePoint zonePoint;
        if(i == dataPoints) //last point just copies previous point
        {
            JPZonePoint lastZonePoint = [self.dataSource graphView:self zonePointForPointNumber:i-1];
            zonePoint = JPZonePointMake(eventDuration, lastZonePoint.zone);
        }
        else{
            zonePoint = [self.dataSource graphView:self zonePointForPointNumber:i];
        }
        
        points[i] = zonePoint;
        
        currHorizontalPoint = 4 + self.horizontalIncrement* zonePoint.minute;
        
        cartesianY = zonePoint.zone * verticalIncrement;
        CGFloat pointHeight = graphTopOffset + (graphHeight - cartesianY);
        
        CGContextAddLineToPoint(context, currHorizontalPoint, pointHeight);
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    
    //Drawing the graph vertex circle of the graph
    context = UIGraphicsGetCurrentContext();
    
    for (int i=0; i<=dataPoints; i++)
    {
        JPZonePoint zonePoint = points[i];
        float zoneValue = zonePoint.zone;
        
        currHorizontalPoint = 4 + self.horizontalIncrement * zonePoint.minute;
        cartesianY = zoneValue * verticalIncrement;
        CGFloat pointHeight = graphTopOffset + (graphHeight - cartesianY);

        CGRect ellipseRect = CGRectMake(currHorizontalPoint-5, pointHeight-5, 10, 10);
        CGContextAddEllipseInRect(context, ellipseRect);
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    ///////////////////////////////////////////////////////////////
    
    //Calculation self.totalZoneAverage
    CGFloat zoneValueSum = 0;
    
    for (int i=0; i< dataPoints; i++)
    {
        JPZonePoint zonePoint = points[i];
        zoneValueSum += zonePoint.zone * points[i+1].minute;
    }
    
    self.totalZoneAverage = zoneValueSum / eventDuration;
    
    ////////////////////////////////////////////////////////////////
    //Drawing time string and tick marks on the Horizontal Axis
    context = UIGraphicsGetCurrentContext();
    
    currHorizontalPoint = 4;
    
    int i = 0;
    while (currHorizontalPoint < 4 + self.horizontalIncrement * eventDuration)
    {
        //Time String
        NSString* timeString = [NSString stringWithFormat:@"%.00f min", i * 5.0];
        
        CGPoint timePoint = CGPointMake(currHorizontalPoint, graphTopOffset+graphHeight + 6);
        
        CGRect timeLabelRect = CGRectMake(timePoint.x - 20, timePoint.y + 5, 100, 30);
        if(i==0)
        {
            timeString = @"0";
            timeLabelRect = CGRectMake(timePoint.x - 3, timePoint.y + 5, 100, 30);
        }
        
        [timeString drawInRect:timeLabelRect withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:[JPFont defaultThinFont] size:16]}];
        
        // Tick Marks
        CGFloat colorComponents[] = {0,0,0,1};
        CGColorRef markColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), colorComponents);
        CGContextSetStrokeColorWithColor(context, markColor);
        
        CGContextSetLineWidth(context, 2);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGContextMoveToPoint(context, timePoint.x, timePoint.y);
        CGContextAddLineToPoint(context, timePoint.x, timePoint.y + 5);
        CGContextDrawPath(context, kCGPathStroke);

        currHorizontalPoint += 5*60*self.horizontalIncrement;
        
        i++;
    }
}



#pragma mark - Gesture Recognizers

- (void)tagMarkViewTapped: (UITapGestureRecognizer*)rec
{
    if(rec.state == UIGestureRecognizerStateRecognized)
    {
        if([self.delegate respondsToSelector:@selector(tagTapped:)])
        {
            [self.delegate tagTapped: rec.view];
        }
    }
}


- (void)periodDashlinePressed: (UILongPressGestureRecognizer*)rec
{
    UIView* dashView = rec.view;
    UILabel* periodLabel = (UILabel*)[dashView viewWithTag:kPeriodNameLabelConst];
    
    if(rec.state == UIGestureRecognizerStateBegan)
    {
        periodLabel.hidden = NO;
    }
    else if (rec.state == UIGestureRecognizerStateCancelled || rec.state == UIGestureRecognizerStateEnded || rec.state == UIGestureRecognizerStateFailed)
    {
        periodLabel.hidden = YES;
    }
}



#pragma mark - Other Methods

- (CGFloat)totalZoneAverage
{
    if(!self.dataSource || !self.horizontalIncrement)
    {
        return -1.0f;
    }
    return _totalZoneAverage;
}



JPZonePoint JPZonePointMake(CGFloat seconds, float zone)
{
    JPZonePoint zonePoint;
    zonePoint.minute = seconds;
    zonePoint.zone = zone;
    
    return zonePoint;
}









@end
