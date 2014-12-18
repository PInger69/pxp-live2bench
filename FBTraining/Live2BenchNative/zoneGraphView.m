//
//  zoneGraphView.m
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import "zoneGraphView.h"
#import "JPFont.h"
#import "JPStyle.h"
#import "DashedLineView.h"


static const CGFloat graphTopOffset = 70;
static const CGFloat graphBottomOffset = 50;

const CGFloat kOriginalHoriIncr = 2;
const CGFloat kScrollViewRightPadding = 30;

@implementation zoneGraphView
{
    int  scrollAccum;
    CGFloat  _lastPinchScale;
}

// View Relationships
// ZoneGraphViewController -> self(whole graph) -> graphScrollView(scrollable view that has a line graph) -> self.displayView (actual drawing of line graph)


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _currentHorizontalIncrement = kOriginalHoriIncr;
        _pastHorizIncrBeforePinch = kOriginalHoriIncr;
        _currentEventDuration = 60;
        
        //Graph Screen Coordinates
        _origin = CGPointMake(80, 450);
        _yMax = CGPointMake(_origin.x, 30);
        _xMax = CGPointMake(950, 450);
        _yMaxGraph = CGPointMake(_yMax.x, _yMax.y + 40);
        graphHeight = frame.size.height - graphTopOffset - graphBottomOffset;
        
        //**Init Main Components
        //Scroll view for the line graph
        _graphScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_yMax.x, _yMax.y, _xMax.x - _origin.x, _origin.y - _yMax.y + kScrollViewRightPadding)];
        _graphScrollView.showsHorizontalScrollIndicator = NO;
        _graphScrollView.showsVerticalScrollIndicator = NO;
        _graphScrollView.clipsToBounds = YES;
        _graphScrollView.contentSize = CGSizeMake(0, 50);
        _graphScrollView.backgroundColor = [UIColor clearColor];
        
        UIPinchGestureRecognizer* pinRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(graphScrollViewPinched:)];
        [_graphScrollView addGestureRecognizer:pinRec];
        
        //Adding displayView to Scroll View
        self.displayView = [[graphDisplayView alloc] initWithFrame:CGRectMake(0, 0, 0, _graphScrollView.frame.size.height)];
        self.displayView.horizontalIncrement = _currentHorizontalIncrement;
        [_graphScrollView addSubview:self.displayView];
        [self addSubview:_graphScrollView];
        
        //**Miscellaneous
        UILabel* tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 30, 500, 40)];
        tagsLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:15];
        tagsLabel.text = @"TAGS";
        [self addSubview:tagsLabel];
        
        //Color Background
        UIView* colorView = [[UIView alloc] initWithFrame:CGRectMake(_origin.x, graphTopOffset, _graphScrollView.frame.size.width, graphHeight)];
        colorView.userInteractionEnabled = NO;
        NSArray* backColors = @[[UIColor greenColor], [UIColor yellowColor], [UIColor redColor]];
        NSArray* backYCoord = @[@0,@0.333333,@0.666666];
        
        int colorCount = [backColors count];
        
        for(int i=0; i<colorCount; i++)
        {
            CALayer* greenLayer = [CALayer layer];
            greenLayer.frame = CGRectMake(0, [backYCoord[i] floatValue]*graphHeight, colorView.frame.size.width, 0.3333333* graphHeight);
            greenLayer.backgroundColor = [backColors[i] colorWithAlphaComponent:0.2].CGColor;
            [colorView.layer addSublayer:greenLayer];
        }
        
        [self addSubview:colorView];
        [self sendSubviewToBack:colorView];
        
        //Average Indicator
        _avgIndicator = [[UIButton alloc] initWithFrame:CGRectZero];
        [_avgIndicator setImage:[UIImage imageNamed:@"leftTriangleGrey.png"] forState:UIControlStateNormal];
        [_avgIndicator setImage:[UIImage imageNamed:@"leftTriangleSelected.png"] forState:UIControlStateSelected];
        [_avgIndicator addTarget:self action:@selector(avgIndicatorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _avgIndicator.enabled = NO;
        [self addSubview:_avgIndicator];
        
        UILabel* avgLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 30, 52, 20)];
        avgLabel.font = [UIFont systemFontOfSize:13];
        avgLabel.textAlignment = NSTextAlignmentLeft;
        avgLabel.text = @"AVG";
        [_avgIndicator addSubview:avgLabel];
        
        _dashedLine = [[DashedLineView alloc] init];
        _dashedLine.hidden = YES;
        [self addSubview:_dashedLine];
        
        //No Graph Label
        _noGraphInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 220, 300, 30)];
        _noGraphInfoLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:24];
        _noGraphInfoLabel.text = @"NO DATA AVAILABLE";
        _noGraphInfoLabel.textAlignment = NSTextAlignmentLeft;
        _noGraphInfoLabel.hidden = YES;
        
        [self addSubview:_noGraphInfoLabel];
        
        //Bring AVG indicator to the front
        [self bringSubviewToFront:_avgIndicator];
        
    }
    
    return self;
}


#pragma mark - Setter Methods

- (void)setDataSource:(id<JPZoneVisualizationDataSource>)dataSource
{
    _dataSource = dataSource;
    self.displayView.dataSource = dataSource;
}

- (void)setDelegate:(id<JPZoneGraphDelegate>)delegate
{
    _delegate = delegate;
    self.displayView.delegate = delegate;
}


#pragma mark - Other Methods

- (void)reloadData
{
    //Remove displayView
    while([_graphScrollView.subviews count]>0)
    {
        [[_graphScrollView.subviews firstObject] removeFromSuperview];
    }

    _currentHorizontalIncrement = kOriginalHoriIncr;
    
    //ReInitializing Display View
    CGFloat eventDuration = [self.dataSource eventDuration];
    
    self.displayView = [[graphDisplayView alloc] initWithFrame:CGRectMake(0, 0, _currentHorizontalIncrement*eventDuration + 50, _graphScrollView.frame.size.height)];

    self.displayView.horizontalIncrement = _currentHorizontalIncrement;
    self.displayView.dataSource = self.dataSource;
    self.displayView.delegate = self.delegate;
    [self.displayView reloadData];
    [_graphScrollView addSubview:self.displayView];
    _graphScrollView.contentSize = CGSizeMake(self.displayView.frame.size.width + 40, _graphScrollView.contentSize.height);
    
    //Resetting Average Indicator
    CGFloat zoneAverage  = [self.displayView totalZoneAverage]/100.0f;
    
    //Total Zone Average is out of 100.
    CGFloat cartesianHeight = graphHeight*zoneAverage;
    _totalAvgYPosition = graphTopOffset + graphHeight - cartesianHeight;
    _avgIndicator.frame = CGRectMake(920, _totalAvgYPosition - 15, 30, 30);
    _dashedLine.frame = CGRectMake(_origin.x, _totalAvgYPosition, 950 - _origin.x, 2);
    
    if([self.dataSource numberOfDataPointsInGraphView:self.displayView] > 0)
    {
        _avgIndicator.enabled = YES;
        _noGraphInfoLabel.hidden = YES;
    }
    else
    {
        _avgIndicator.enabled = NO;
        _noGraphInfoLabel.hidden = NO;
    }
    
    _currentEventDuration = [self.dataSource eventDuration];
    _currentGraphContentWidth = _graphScrollView.contentSize.width;
}



- (void)reloadGraphViewForScrolling
{
    self.displayView.horizontalIncrement = _currentHorizontalIncrement;
    
    self.displayView.frame = CGRectMake(0, 0, _currentHorizontalIncrement*_currentEventDuration + 50, _graphScrollView.frame.size.height);
    
    CGFloat scrollViewHeight = _graphScrollView.contentSize.height;
    
    _graphScrollView.contentSize = CGSizeMake(self.displayView.frame.size.width + 40, scrollViewHeight);
    
    //ContentOffset for Natural Zooming
    //Constant Calculations
    CGFloat graphScale = _currentHorizontalIncrement/kOriginalHoriIncr;
    CGFloat graphScaleBeforeCurrPinch = _pastHorizIncrBeforePinch/kOriginalHoriIncr;
    
    //______________________________________(Adjusting for scroll right padding)
    CGFloat distPinchLocToOriginLocBefore = (_currentPinchLocInDisplayView + kScrollViewRightPadding/2.0) * graphScaleBeforeCurrPinch;
    CGFloat distPinchLocToOriginLocAfter  = (_currentPinchLocInDisplayView + kScrollViewRightPadding/2.0) * graphScale;
    
    //Scroll adjustments
    CGFloat newGraphOriginFromPreoffsetOrigin = - (distPinchLocToOriginLocBefore - distPinchLocToOriginLocAfter);
    
    //Content initial offset (jump to origin problem when pinch starts)
    CGFloat contentXoffsetForDisplayView = _currentPinchLocInScrollView - _currentPinchLocInDisplayView;

    _graphScrollView.contentOffset = CGPointMake(-contentXoffsetForDisplayView + newGraphOriginFromPreoffsetOrigin, 0);
    
    [self.displayView reloadDataCachedForScrolling];
    [self.displayView setNeedsDisplay];
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetLineWidth(context, 3);
    
    CGContextMoveToPoint(context, _yMaxGraph.x, _yMaxGraph.y - 35);
    
    CGContextAddLineToPoint(context, _origin.x, _origin.y);
    CGContextAddLineToPoint(context, _xMax.x, _xMax.y);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    NSArray* stringArray = @[@"DZone", @"NZone", @"OZone"];
    
    NSArray* textHeights = @[[NSNumber numberWithFloat:graphTopOffset+0.166666*graphHeight],[NSNumber numberWithFloat:graphTopOffset+0.5*graphHeight],[NSNumber numberWithFloat:graphTopOffset+0.833333*graphHeight]];
    
    int i = 0;
    
    for(NSString* string in stringArray)
    {
        CGFloat textHeight = [[textHeights objectAtIndex:i] floatValue];
        CGRect textRect = CGRectMake(18, textHeight - 15, 80, 30);

        NSDictionary* attributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:[JPFont defaultThinFont] size:17]};
        
        [string drawInRect:textRect withAttributes:attributes];
        
        i++;
    }
    
}




- (void)avgIndicatorButtonPressed: (UIButton*)button
{
    if(button.selected)
    {
        button.selected = NO;
        _dashedLine.hidden = YES;
    }
    else
    {
        button.selected = YES;
        _dashedLine.hidden = NO;
    }
    
}



- (void)graphScrollViewPinched: (UIPinchGestureRecognizer*)rec
{
    if(rec.state == UIGestureRecognizerStateBegan)
    {
        _currentPinchLocInDisplayView = [rec locationInView: self.displayView].x;
        _currentPinchLocInScrollView  = [rec locationInView: self].x - _origin.x;
        
        scrollAccum = 0;
        _lastPinchScale = 1;
    }
    else if(rec.state == UIGestureRecognizerStateChanged && scrollAccum >= 2)
    {
        _currentHorizontalIncrement += (rec.scale - _lastPinchScale) * _graphScrollView.contentSize.width * 0.001;
        _lastPinchScale = rec.scale;
        
        if(_currentHorizontalIncrement < 0)
        {
            _currentHorizontalIncrement = 0;
        }
        else if(_currentHorizontalIncrement > 5)
        {
            _currentHorizontalIncrement = 5;
        }
    
        [self reloadGraphViewForScrolling];
        
        _currentGraphContentWidth = _graphScrollView.contentSize.width;
        
        scrollAccum = 0;
    }
    else if(rec.state == UIGestureRecognizerStateEnded)
    {
        _pastHorizIncrBeforePinch = _currentHorizontalIncrement;
        
        //If graph view doesn't start from left axis, swing back to it
        BOOL whiteSpaceBefore = (_graphScrollView.contentOffset.x < 0);
        
        CGFloat scrollViewWidth = _graphScrollView.frame.size.width;
        BOOL unscrollable     = (_graphScrollView.contentSize.width < scrollViewWidth);
        
        BOOL whiteSpaceAfter  = (_graphScrollView.contentOffset.x > _graphScrollView.contentSize.width-scrollViewWidth);
        
        if(whiteSpaceBefore || unscrollable)
        {
            [_graphScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        else if(whiteSpaceAfter)
        {
            [_graphScrollView setContentOffset:CGPointMake(_graphScrollView.contentSize.width-scrollViewWidth, 0) animated:YES];
        }
    }
    
    scrollAccum++;
}














@end


