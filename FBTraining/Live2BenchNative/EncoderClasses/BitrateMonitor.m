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
@property (strong, nonatomic) UILabel * encoderVersion;

@end


@implementation BitrateMonitor
{
  //__weak id <EncoderProtocol>   encoder;
    __weak Encoder  * encoder;
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
    UILabel         * encoderVersionLableValue;
}

@synthesize name;


static void * bitrateContext         = &bitrateContext;


-(id)initWithFrame:(CGRect)frame encoder:( Encoder *)aEncoder
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        maxLimit    = 5;//seconds
        lowThresh   = maxLimit * 0.33f;
        highThresh  = lowThresh * 2;
        //graphView   = [[GraphView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mainview    = [[UIView alloc] initWithFrame:CGRectMake(80, -50, frame.size.width, frame.size.height*2 -50)];
        graphView   = [[GraphView alloc]initWithFrame:CGRectMake(0, frame.size.height - 35 , frame.size.width +3 , frame.size.height -10)];
        //[graphView setBackgroundColor:[UIColor blueColor]];
        
        encoder     = aEncoder;

        [(NSObject*)encoder addObserver:self forKeyPath:@"bitrate" options:NSKeyValueObservingOptionNew context:bitrateContext];
        //[self setBackgroundColor:[UIColor whiteColor]];
        //[self addSubview:graphView];
        [mainview setBackgroundColor:[UIColor whiteColor]];
        mainview.layer.cornerRadius = 5;
        mainview.layer.masksToBounds = YES;
        [self addSubview:mainview];
        [mainview addSubview:graphView];
        
        graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [graphView setBackgroundColor:[UIColor clearColor]];
        [graphView setFill:YES];
        [graphView setSpacing:0];
        [graphView setStrokeColor: [UIColor colorWithWhite:0.4f alpha:0.9f]];
        [graphView setZeroLineStrokeColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [graphView setZeroLineStrokeColor:[UIColor whiteColor]];
        [graphView setLineWidth:1];
        [graphView setCurvedLines:NO];
        //graphView.layer.borderColor = [[UIColor colorWithWhite:0.7f alpha:1.0f] CGColor];
        //graphView.layer.borderWidth = 1.0f;
        [graphView setFillColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f]];
        
        [self setupView];
    
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == bitrateContext){
        
        double val = ( (Encoder*) object).bitrate;
        [self setBackgroundColorBasedOnRate:val];
        [nameLabelValue setText: [NSString stringWithFormat:@"%@",encoder.name]];
        [nameLabelValue sizeToFit];
        [statusLabelValue setText:[NSString stringWithFormat:@"%@", encoder.statusAsString]];
        [statusLabelValue sizeToFit];
        [rateLabelValue setText:[NSString stringWithFormat:@"%0.4f", val]];
        [rateLabelValue sizeToFit];
        [camerasLabelValue setText:[NSString stringWithFormat:@"%ld", (long)encoder.cameraCount]];
        [camerasLabelValue sizeToFit];
        [encoderVersionLableValue setText:[NSString stringWithFormat:@"%@",encoder.version ]];
        [encoderVersionLableValue sizeToFit];
        
    }
}


-(void)setupView{

    int startwidth = 390/2;
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(mainview.frame.size.width -390, mainview.frame.size.height - 147, 65, 20)];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.nameLabel setFont:[UIFont boldSystemFontOfSize: [UIFont systemFontSize]]];
    [self.nameLabel setText: NSLocalizedString(@"Name:", nil)];
    nameLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -330, mainview.frame.size.height - 147, 100, 20)];
    nameLabelValue.textColor = [UIColor blackColor];

    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(mainview.frame.size.width -390, mainview.frame.size.height - 127, 65, 20)];
    self.statusLabel.textColor = [UIColor blackColor];
    [self.statusLabel setFont:[UIFont boldSystemFontOfSize: [UIFont systemFontSize]]];
    [self.statusLabel setText:NSLocalizedString(@"Status:", nil)];
    statusLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -330, mainview.frame.size.height - 127, 100 , 20)];
    statusLabelValue.textColor = [UIColor blackColor];
    
    self.rateLabel = [[UILabel alloc]initWithFrame:CGRectMake(mainview.frame.size.width -390+startwidth, mainview.frame.size.height - 147, 65, 20)];
    self.rateLabel.textColor = [UIColor blackColor];
    [self.rateLabel setFont:[UIFont boldSystemFontOfSize: [UIFont systemFontSize]]];
    [self.rateLabel setText:NSLocalizedString(@"Rate:", nil)];
    rateLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -340+startwidth, mainview.frame.size.height - 147, 100, 20)];
    rateLabelValue.textColor = [UIColor blackColor];

    
    self.camerasLabel = [[UILabel alloc]initWithFrame:CGRectMake(mainview.frame.size.width -390+startwidth, mainview.frame.size.height - 127, 65, 20)];
    self.camerasLabel.textColor = [UIColor blackColor];
    [self.camerasLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [self.camerasLabel setText:NSLocalizedString(@"Cameras:", nil)];
    camerasLabelValue = [ [UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -315+startwidth, mainview.frame.size.height - 127, 100, 20)];
    camerasLabelValue.textColor = [UIColor blackColor];
    
    self.encoderVersion = [[UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -390, mainview.frame.size.height - 107, 120, 20)];
    self.encoderVersion.textColor = [UIColor blackColor];
    [self.encoderVersion setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [self.encoderVersion setText:NSLocalizedString(@"Version:", nil)];
    encoderVersionLableValue = [ [UILabel alloc] initWithFrame:CGRectMake(mainview.frame.size.width -330, mainview.frame.size.height - 107, 100, 20)];
    encoderVersionLableValue.textColor = [UIColor blackColor];
    
    
    
    [mainview addSubview:self.nameLabel];
    [mainview addSubview:nameLabelValue];
    [mainview addSubview:self.statusLabel];
    [mainview addSubview:statusLabelValue];
    [mainview addSubview:self.rateLabel];
    [mainview addSubview:rateLabelValue];
    [mainview addSubview:self.camerasLabel];
    [mainview addSubview:camerasLabelValue];
    [mainview addSubview:self.encoderVersion];
    [mainview addSubview:encoderVersionLableValue];


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
        [graphView setBackgroundColor:MAX_COLOR];
    } else if (bRate > highThresh) {
        [graphView setBackgroundColor:MIN_COLOR];
    } else {
        [graphView setBackgroundColor:MID_COLOR];
    }
    //[graphView setBackgroundColor:[UIColor yellowColor]];
    
    
//    double modRate = bRate;
    
    [graphView setPoint: 1000-200*bRate];

}


-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [(NSObject*)encoder removeObserver:self forKeyPath:@"bitrate"];
}


@end
