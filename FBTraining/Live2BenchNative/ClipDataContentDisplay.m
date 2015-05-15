//
//  ClipDataContentDisplay.m
//  Live2BenchNative
//
//  Created by dev on 2015-05-15.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ClipDataContentDisplay.h"
#import "Clip.h"


typedef enum : NSUInteger {
    Normal,
    Bold
} TextStyle;

@implementation ClipDataContentDisplay
{
    NSDictionary                * NormalAttrs;
    NSDictionary                * BoldAttrs;
    NSMutableAttributedString   * contentText;
    UITextView                  * tagDetailsView;
}

@synthesize ratingAndCommentingView = _ratingAndCommentingView;



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor  = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth  = 1.0f;
        self.backgroundColor    = [UIColor whiteColor];
        //[tagDetailsView setText:[NSString stringWithFormat:@"%@: %@ \n%@: %@ \n%@: %@ \n%@: %@ \n%@: %@\n%@: %@ \n%@: %@",NSLocalizedString(@"Event Date",nil),eventDate,NSLocalizedString(@"Event Time",nil),eventTime,NSLocalizedString(@"Home Team",nil),homeTeam,NSLocalizedString(@"Visit Team",nil),visitTeam,NSLocalizedString(@"League",nil),leagueName,NSLocalizedString(@"Tag Name",nil),[data objectForKey:@"name"],NSLocalizedString(@"Tag Time",nil) ,[data objectForKey:@"displaytime"]]];
        [tagDetailsView setFont:[UIFont boldSystemFontOfSize:18.f]];
        [tagDetailsView setUserInteractionEnabled:FALSE];
        [self addSubview:tagDetailsView];
        
        _ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, (frame.size.height+20)) andData: nil];
        [self addSubview:self.ratingAndCommentingView.view];
        
        // Create the attributes
        
        const CGFloat fontSize      = 18.f;
        UIFont *boldFont            = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont         = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor    = [UIColor blackColor];
        
        BoldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                     boldFont, NSFontAttributeName,
                     foregroundColor, NSForegroundColorAttributeName, nil];
        
        NormalAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                       regularFont, NSFontAttributeName,
                       nil];
        
        
        contentText = [[NSMutableAttributedString alloc]init];

        [self addText: [NSString stringWithFormat:@"%@:\t", NSLocalizedString(@"Event Date", nil)]     style:Bold];          [self addText: @"" style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Event Time", nil)]   style:Bold];          [self addText: @"" style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Home Team", nil)]    style:Bold];          [self addText: @"" style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Visit Team", nil)]   style:Bold];          [self addText: @"" style:Normal];
//        if(![leagueName isEqualToString:@""]){
//            [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"League", nil)]       style:Bold];          [self addText: leagueName style:Normal];
//        }
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Tag Name", nil)]     style:Bold];          [self addText: @"" style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t\t", NSLocalizedString(@"Tag Time", nil)]   style:Bold];          [self addText: @"" style:Normal];
        
        
        
        
        [tagDetailsView setAttributedText:contentText];
    }
    return self;
}



-(void)displayClip:(Clip*)clip
{
    if (!clip){
        // disabled version
        return;
    }

}




-(void)addText:(NSString*)txt style:(TextStyle)tStyle
{
    if (!tStyle) tStyle = Normal;
    NSMutableAttributedString *concatText;
    switch (tStyle) {
        case Normal:
            concatText = [[NSMutableAttributedString alloc] initWithString:txt attributes:NormalAttrs];
            break;
            
        case Bold:
            concatText = [[NSMutableAttributedString alloc] initWithString:txt attributes:BoldAttrs];
            break;
            
    }
    [contentText insertAttributedString:concatText atIndex:contentText.length];
}



@end
