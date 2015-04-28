//
//  RangeSlider.m
//  RangeSlider
//
//  Crea0ted by dev on 2015-02-02.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "RangeSlider.h"
#import "QuartzCore/QuartzCore.h"
#import "FilterItemProtocol.h"


RangeSlider *theRangeSlider;
CALayer* _trackLayer;
CALayer* _upperKnobLayer;
CALayer* _lowerKnobLayer;
BOOL _lowerKnobLayerSelected;
BOOL _upperKnobLayerSelected;

@interface LayerDelegate : NSObject

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;

@end

@interface RangeSlider ()

@property (strong, nonatomic) LayerDelegate *layerDelegate;
@property (strong, nonatomic) NSArray *arrayOfOriginalTags;
@property (strong, nonatomic) UILabel *rightLabel;
@property (strong, nonatomic) UILabel *leftLabel;



@property (nonatomic) float maximumValue;
@property (nonatomic) float minimumValue;
@property (nonatomic) float upperValue;
@property (nonatomic) float lowerValue;
@property (nonatomic) Float64 highestOriginalValue;


- (float) positionForValue:(float)value;

@end


@implementation LayerDelegate

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if(layer == _trackLayer)
    {
        float cornerRadius = layer.bounds.size.height * theRangeSlider.curvaceousness/ 2.0;
        CGRect roundedRect = CGRectMake(layer.bounds.origin.x , layer.bounds.origin.y + layer.bounds.size.height/3, layer.bounds.size.width, layer.bounds.size.height/4);
        UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:roundedRect
                                                             cornerRadius:cornerRadius];
        CGContextAddPath(ctx, switchOutline.CGPath);
        CGContextClip(ctx);
    
        // 1) fill the track
        CGContextSetFillColorWithColor(ctx, theRangeSlider.trackColour.CGColor);
        CGContextAddPath(ctx, switchOutline.CGPath);
        CGContextFillPath(ctx);
    
        // 2) fill the highlighed range
        CGContextSetFillColorWithColor(ctx, theRangeSlider.trackHighlightColour.CGColor);
        float lower = [theRangeSlider positionForValue:theRangeSlider.lowerValue];
        float upper = [theRangeSlider positionForValue:theRangeSlider.upperValue];
        CGContextFillRect(ctx, CGRectMake(lower, 0, upper - lower, theRangeSlider.bounds.size.height));
    }
    
    else if(layer == _upperKnobLayer || layer == _lowerKnobLayer)
    {
        
        CGRect knobFrame = CGRectInset(layer.bounds, 2.0, 2.0);
        
        UIBezierPath *knobPath = [UIBezierPath bezierPathWithRoundedRect: knobFrame
                                                            cornerRadius:knobFrame.size.height * theRangeSlider.curvaceousness / 2.0];
        
        // 1) fill - with a subtle shadow
        //CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 1.0, [UIColor grayColor].CGColor);
        
        CGContextSetFillColorWithColor(ctx, theRangeSlider.knobColour.CGColor);
        CGContextAddPath(ctx, knobPath.CGPath);
        CGContextFillPath(ctx);
        
        // 2) outline
        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGContextSetLineWidth(ctx, theRangeSlider.knobBorderThickness);
        CGContextAddPath(ctx, knobPath.CGPath);
        CGContextStrokePath(ctx);
    }
}

@end






@implementation RangeSlider
{
    
    float _knobWidth;
    float _useableTrackLength;
    CGPoint _previousTouchPoint;
}



#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
if (_##PROPERTY != PROPERTY) { \
_##PROPERTY = PROPERTY; \
[self UPDATER]; \
} \
}

GENERATE_SETTER(trackHighlightColour, UIColor*, setTrackHighlightColour, redrawLayers)

GENERATE_SETTER(trackColour, UIColor*, setTrackColour, redrawLayers)

GENERATE_SETTER(curvaceousness, float, setCurvaceousness, redrawLayers)

GENERATE_SETTER(knobColour, UIColor*, setKnobColour, redrawLayers)

GENERATE_SETTER(maximumValue, float, setMaximumValue, setLayerFrames)

GENERATE_SETTER(minimumValue, float, setMinimumValue, setLayerFrames)

GENERATE_SETTER(lowerValue, float, setLowerValue, setLayerFrames)

GENERATE_SETTER(upperValue, float, setUpperValue, setLayerFrames)


-(void)setHighestValue:(Float64)highestValue{
    _highestValue = highestValue;
    _highestOriginalValue = highestValue;
    
    [self setLayerFrames];
}


- (void) redrawLayers
{
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
    [_trackLayer setNeedsDisplay];
    
    [self.rightLabel setNeedsDisplay];
    [self.leftLabel setNeedsDisplay];
}

-(instancetype)initWithFrame: (CGRect) frame Name: (NSString *)name AccessLable: (NSString *)accessLabel{
    
    self = [self initWithFrame: frame];
    
    [self redrawLayers];
    if (self) {
    }
    //UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50 + frame.origin.x, frame.origin.y - frame.size.height, frame.size.width - 50, frame.size.height)];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _highestValue = 10;
        self.lowestValue = 0;
        
        // Initialization code
        _maximumValue = 10.0;
        _minimumValue = 0.0;
        _upperValue = 10.0;
        _lowerValue = 0.0;
        _knobBorderThickness = 0.5;
        
        _trackHighlightColour = PRIMARY_APP_COLOR;//colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
        _trackColour = [UIColor colorWithWhite:0.9 alpha:1.0];
        _knobColour = [UIColor whiteColor];
        _curvaceousness = 1.0;
        _maximumValue = 10.0;
        _minimumValue = 0.0;
        
        self.layerDelegate = [[LayerDelegate alloc]init];
        
        _trackLayer = [CALayer layer];
        _trackLayer.contentsScale = [UIScreen mainScreen].scale;
        _trackLayer.delegate = self.layerDelegate;
        //_trackLayer.slider = self;
        [self.layer addSublayer:_trackLayer];
        
        _upperKnobLayer = [CALayer layer];
        _upperKnobLayer.contentsScale = [UIScreen mainScreen].scale;
        _upperKnobLayer.delegate = self.layerDelegate;
        [self.layer addSublayer:_upperKnobLayer];
        
        _lowerKnobLayer = [CALayer layer];
        _lowerKnobLayer.contentsScale = [UIScreen mainScreen].scale;
        _lowerKnobLayer.delegate = self.layerDelegate;
        [self.layer addSublayer:_lowerKnobLayer];
        
        self.rightLabel = [[UILabel alloc]init];
        self.leftLabel = [[UILabel alloc]init];
        
        [self.leftLabel setTextColor:[UIColor whiteColor]];
        [self.rightLabel setTextColor:[UIColor whiteColor]];
        
        [self.layer addSublayer:self.rightLabel.layer];
        [self.layer addSublayer:self.leftLabel.layer];
        
        [self.leftLabel setTextAlignment: NSTextAlignmentRight];
        
        [self setLayerFrames];
        [self addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    }
    theRangeSlider = self;
    return self;
}



- (void) setLayerFrames
{
    _trackLayer.frame = CGRectInset(self.bounds, 0, self.bounds.size.height / 3.5);
    //_trackLayer.delegate = self;
    [_trackLayer setNeedsDisplay];
    
    _knobWidth = self.bounds.size.height;
    _useableTrackLength = self.bounds.size.width - _knobWidth;
    
    float upperKnobCentre = [self positionForValue:_upperValue];
    _upperKnobLayer.frame = CGRectMake(upperKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);
    
    float lowerKnobCentre = [self positionForValue:_lowerValue];
    _lowerKnobLayer.frame = CGRectMake(lowerKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);
    
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
    
    
    //Checking to make sure the 2 labels do not collide
    
    if ( (_upperKnobLayer.frame.origin.x - _lowerKnobLayer.frame.origin.x) < 30){
        float difference = 30 - (_upperKnobLayer.frame.origin.x - _lowerKnobLayer.frame.origin.x);
        
        [self.rightLabel setFrame:CGRectMake(upperKnobCentre - _knobWidth / 2 + difference/2, -20, 80, 20)];
        [self.rightLabel setNeedsDisplay];
        
        [self.leftLabel setFrame:CGRectMake(lowerKnobCentre - _knobWidth / 2  - 53 - difference/2, -20, 80, 20)];
        [self.leftLabel setNeedsDisplay];
        
    } else{
        [self.rightLabel setFrame:CGRectMake(upperKnobCentre - _knobWidth / 2,  -20, 80, 20)];
        [self.rightLabel setNeedsDisplay];
        
        [self.leftLabel setFrame:CGRectMake(lowerKnobCentre - _knobWidth / 2  - 53, -20, 80, 20)];
        [self.leftLabel setNeedsDisplay];
    }
    
    [self.leftLabel setText: [self formatTimeFromSeconds:(_lowerValue/10) * self.highestOriginalValue]];
    [self.rightLabel setText: [self formatTimeFromSeconds: (_upperValue/10) * self.highestOriginalValue]];
    
}

- (float) positionForValue:(float)value
{
    return _useableTrackLength * (value - _minimumValue) /
    (_maximumValue - _minimumValue) + (_knobWidth / 2);
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    
    
    // This condition only executes if both knobs
    // are at 0
    if(_lowerValue == 0 && _upperValue == 0){
        _upperKnobLayerSelected = YES;
        [_upperKnobLayer setNeedsDisplay];
        return YES;
    }

    
    // hit test the knob layers
    if(CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint))
    {
        _lowerKnobLayerSelected = YES;
        [_lowerKnobLayer setNeedsDisplay];
    }
    else if(CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
    {
        _upperKnobLayerSelected = YES;
        [_upperKnobLayer setNeedsDisplay];
    }
    
    
    return _upperKnobLayerSelected || _lowerKnobLayerSelected;
}

#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
//    static int rangeSliderUpdate = 0;
//    rangeSliderUpdate++;
//    NSLog(@"The range slider update count is %i", rangeSliderUpdate);
    
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float delta = touchPoint.x - _previousTouchPoint.x;
    float valueDelta = (self.maximumValue - self.minimumValue) * delta / _useableTrackLength;
    
    _previousTouchPoint = touchPoint;
    
    // 2. update the values
    if (_lowerKnobLayerSelected)
    {
        _lowerValue += valueDelta;
        _lowerValue = BOUND(_lowerValue, _upperValue, _minimumValue);
        [self.layer addSublayer: _lowerKnobLayer];
    }
    if (_upperKnobLayerSelected)
    {
        _upperValue += valueDelta;
        _upperValue = BOUND(_upperValue, _maximumValue, _lowerValue);
        
        [self.layer addSublayer: _upperKnobLayer];
    }
    
    // 3. Update the UI state
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerKnobLayerSelected = _upperKnobLayerSelected = NO;
    _highestValue = (_upperValue/10) * self.highestOriginalValue;
    _lowestValue = (_lowerValue/10) * self.highestOriginalValue;
    [self update];
    [_lowerKnobLayer setNeedsDisplay];
    [_upperKnobLayer setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) resetKnobs{
    _highestValue = _highestOriginalValue;
    _lowestValue = 0;
    
    _lowerValue = 0;
    _upperValue = 10;
    [self setLayerFrames];
}

#pragma mark - Filter Component Methods

-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey
{
    self.filterBlock = madeKey;
    [self.filterP setFilterBlock:madeKey];
    
}

-(void)deselectAll
{
    [self resetKnobs];
    [self.selectedTags removeAllObjects];
    self.invoked = NO;
    [self update];
    
}


-(void)inputArray:(NSArray*)list
{
    [self redrawLayers];
    self.arrayOfOriginalTags = [list copy];
    self.arrayOfTags = [NSMutableArray arrayWithArray:list];
    [self filter];
    if(self.next) [self.next inputArray:self.arrayOfTags];//[self.filterP processedList]];
}

/**
 *  Returns the list after its been filtered by the component
 *  this will mostly be directed to the next linked object or to the Filter View for displaying
 *  @return new list of tags
 */
-(NSArray*)refinedList
{
    return [self.filterP processedList];
}

-(void)populate:(NSArray *)list{
    [self inputArray:list];
}

-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target
{
    self.selTarget = target;
    self.onSelectSelector = sel;
}


-(void)nextComponent:(id <FilterComponent>)nxt
{
    self.next = nxt;
}

-(void)previousComponent:(id <FilterComponent>)prev
{
    self.previous = prev;
}

-(NSString*)getName
{
    return self.name;
}

-(void)update
{
    //[self.previous update];
    [self filter];
    self.invoked = ([self.selectedTags count])? YES : NO; // a quick bool for if its used or not
    //[self.filterP updateWith: self.selectedTags]; //what ever is selected or unselected
    if(self.next){
        [self.next inputArray: self.arrayOfTags];//[self.filterP processedList]];
        [self.next update];
    } else {
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (self.onSelectSelector) [self.selTarget performSelector: self.onSelectSelector withObject:self];
    }
    
    
}

-(BOOL)isInvoked
{
    return self.invoked;
}

-(void)keepSelectionOnRefresh:(NSMutableArray*)allButtons buttonsSelected:(NSMutableSet*)selTag
{
    if ([selTag count] == 0) return; // if noselectTags skip this part
    
    for (UIButton *activeButton in allButtons){
        if ([selTag containsObject:activeButton.titleLabel.text])
        {
            activeButton.selected = YES;
        }
    }
    [self update];
    
}

-(void) filter{
    if (self.arrayOfOriginalTags && self.highestValue) {
        self.arrayOfTags = [NSMutableArray arrayWithArray:self.arrayOfOriginalTags];
        NSMutableArray *removingTags = [[NSMutableArray alloc] init];
        for (id <FilterItemProtocol> filterItem in self.arrayOfOriginalTags){
            
            if(filterItem.time  > self.highestValue || filterItem.time < self.lowestValue){

                [removingTags addObject: filterItem];
            }
            
        }
        for(id tag in removingTags){
            [self.arrayOfTags removeObject:tag];
        }
    }
    
}


-(NSString *)formatTimeFromSeconds:(int)numberOfSeconds
{
    
    int seconds = numberOfSeconds % 60;
    int minutes = (numberOfSeconds / 60) % 60;
    int hours = numberOfSeconds / 3600;
    
    //we have >=1 hour => example : 3h:25m
    if (hours) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    }
    //we have 0 hours and >=1 minutes => example : 3m:25s
    if (minutes) {
        return [NSString stringWithFormat:@"00:%02d:%02d", minutes, seconds];
    }
    //we have only seconds example : 25s
    return [NSString stringWithFormat:@"00:00:%d", seconds];
}

@end

