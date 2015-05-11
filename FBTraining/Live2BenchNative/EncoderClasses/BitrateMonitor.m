//
//  BitrateMonitor.m
//  Live2BenchNative
//
//  Created by dev on 11/6/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "BitrateMonitor.h"
#import "GraphView.h"


#define MAX_COLOR [UIColor greenColor]
#define MID_COLOR [UIColor yellowColor]
#define MIN_COLOR [UIColor redColor]

@interface BitrateMonitor ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *rateLabel;
@property (strong, nonatomic) UILabel *camerasLabel;

@end


@implementation BitrateMonitor
{
   __weak id <EncoderProtocol>   encoder;
    UILabel         * label;
    GraphView       * graphView;
    double          maxLimit;
    double          highThresh;
    double          lowThresh;
    UIView          * mainview;
    UILabel         * nameLabelValue;
    UILabel         * statusLabelValue;
    UILabel         * rateLabelValue;
    UILabel         * camerasLabelValue;
}

@synthesize name;


static void * bitrateContext         = &bitrateContext;


-(id)initWithFrame:(CGRect)frame encoder:( id <EncoderProtocol> )aEncoder
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        maxLimit    = 5;//seconds
        lowThresh   = maxLimit * 0.33f;
        highThresh  = lowThresh * 2;
        //graphView   = [[GraphView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mainview    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        graphView   = [[GraphView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height -10)];
        encoder     = aEncoder;

        [(NSObject*)encoder addObserver:self forKeyPath:@"bitrate" options:NSKeyValueObservingOptionNew context:bitrateContext];
        //[self setBackgroundColor:[UIColor whiteColor]];
        //[self addSubview:graphView];
        [mainview setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:mainview];
        [mainview addSubview:graphView];
        
        graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [graphView setBackgroundColor:[UIColor clearColor]];
        [graphView setFill:YES];
        [graphView setSpacing:0];
        [graphView setStrokeColor: [UIColor colorWithWhite:0.4f alpha:0.9f]];
        [graphView setZeroLineStrokeColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [graphView setLineWidth:1];
        [graphView setCurvedLines:NO];
        graphView.layer.borderColor = [[UIColor colorWithWhite:0.7f alpha:1.0f] CGColor];
        graphView.layer.borderWidth = 1.0f;
        [graphView setFillColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f]];
        
        [self setupView];
    
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == bitrateContext){
        /*double val = ((Encoder*) object).bitrate;
        [self setBackgroundColorBasedOnRate:val];
        [self.statusLabel setText: [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"Status",nil),encoder.statusAsString ]];
        [self.rateLabel setText:[NSString stringWithFormat:@"%@:  %0.4f", NSLocalizedString(@"Rate",nil),val ]];
        [self.camerasLabel setText:[NSString stringWithFormat:@"%@:  %i",NSLocalizedString(@"Cameras",nil) ,encoder.cameraCount ]];*/
        
        double val = ( (Encoder*) object).bitrate;
        [nameLabelValue setText: [NSString stringWithFormat:@"%@",encoder.name]];
        [statusLabelValue setText:[NSString stringWithFormat:@"%@", encoder.statusAsString]];
        [rateLabelValue setText:[NSString stringWithFormat:@"%0.4f", val]];
        [camerasLabelValue setText:[NSString stringWithFormat:@"%i", encoder.cameraCount]];
        
    }
}


-(void)setupView{
    /*self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -20, 100, 20)];
    self.nameLabel.textColor = [UIColor blueColor];
    [self.nameLabel setText: [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"Name",nil), encoder.name ]];
    
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, -20, 100, 20)];
    [self.statusLabel setText: [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"Status",nil), encoder.statusAsString ]];
    
    self.rateLabel = [[UILabel alloc] initWithFrame: CGRectMake(260, -20, 120, 20)];
    
    self.camerasLabel = [[UILabel alloc] initWithFrame: CGRectMake(390, -20, 100, 20)];
    
    
    
    [self addSubview: self.nameLabel];
    [self addSubview: self.statusLabel];
    [self addSubview: self.rateLabel];
    [self addSubview: self.camerasLabel];*/
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -50, 30, 20)];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.nameLabel setFont:[UIFont boldSystemFontOfSize:0]];
    [self.nameLabel setText: NSLocalizedString(@"Name:", nil)];
    nameLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(40, -50, 80, 20)];
    nameLabelValue.textColor = [UIColor blackColor];

    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, -50, 30, 20)];
    self.statusLabel.textColor = [UIColor blackColor];
    [self.statusLabel setFont:[UIFont boldSystemFontOfSize:0]];
    [self.statusLabel setText:NSLocalizedString(@"Status", nil)];
    statusLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(170, -50, 80 , 20)];
    statusLabelValue.textColor = [UIColor blackColor];
    
    self.rateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -20, 100, 20)];
    self.rateLabel.textColor = [UIColor blackColor];
    [self.rateLabel setFont:[UIFont boldSystemFontOfSize:0]];
    [self.rateLabel setText:NSLocalizedString(@"Rate", nil)];
    rateLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(40, -20, 80, 20)];
    rateLabelValue.textColor = [UIColor blackColor];
    
    self.camerasLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, -20, 100, 20)];
    self.camerasLabel.textColor = [UIColor blackColor];
    [self.camerasLabel setFont:[UIFont boldSystemFontOfSize:0]];
    [self.camerasLabel setText:NSLocalizedString(@"Cameras", nil)];
    rateLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(170, -20, 80, 20)];
    rateLabelValue.textColor = [UIColor blackColor];
    
    [mainview addSubview:self.nameLabel];
    [mainview addSubview:self.statusLabel];
    [mainview addSubview:self.rateLabel];
    [mainview addSubview:self.camerasLabel];


}
/**
 *  The range is between 0.1 is max and 4.0 is min 2.0 is around mid
 
 *
 *  @param bRate seconds for responce
 */
-(void)setBackgroundColorBasedOnRate:(double)bRate
{
    
    bRate = MIN(5,bRate);
    // adjust colors
    if (bRate < lowThresh){
        [self setBackgroundColor:MAX_COLOR];
    } else if (bRate > highThresh) {
        [self setBackgroundColor:MIN_COLOR];
    } else {
        [self setBackgroundColor:MID_COLOR];
    }
    
    
//    double modRate = bRate;
    
    [graphView setPoint: 1000-200*bRate];

}


-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [(NSObject*)encoder removeObserver:self forKeyPath:@"bitrate"];
}


@end
