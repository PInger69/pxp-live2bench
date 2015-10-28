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
    Bold,
    Disabled
} TextStyle;

@implementation ClipDataContentDisplay
{
    NSDictionary                * NormalAttrs;
    NSDictionary                * BoldAttrs;
    NSDictionary                * DisableAttrs;
    NSMutableAttributedString   * contentText;
    UITextView                  * tagDetailsView;
    BOOL                        isLeague;
}

@synthesize ratingAndCommentingView = _ratingAndCommentingView;
@synthesize enable =_enable;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor  = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth  = 1.0f;
        self.backgroundColor    = [UIColor whiteColor];
        _enable                 = YES;

        tagDetailsView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5,frame.size.width, frame.size.height)];
        [tagDetailsView setFont:[UIFont boldSystemFontOfSize:18.f]];
        [tagDetailsView setUserInteractionEnabled:FALSE];
        
        _ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, (frame.size.height+20)) andData: nil];
        // Create the attributes
        
        const CGFloat fontSize      = 18.f;
        UIFont *boldFont            = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont         = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor    = [UIColor blackColor];
        
        BoldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                     boldFont, NSFontAttributeName,
                     foregroundColor, NSForegroundColorAttributeName, nil];
        
        DisableAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                     boldFont, NSFontAttributeName,
                     foregroundColor, NSForegroundColorAttributeName, nil];
        
        NormalAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                       regularFont, NSFontAttributeName,
                       nil];
        
        
        contentText = [[NSMutableAttributedString alloc]init];

        [self makeText:nil];
        [tagDetailsView setAttributedText:contentText];
        
        [self addSubview:tagDetailsView];
        [self addSubview:self.ratingAndCommentingView.view];
        
    }
    return self;
}



-(void)displayClip:(Clip*)clip
{
    if (!clip){
        // disabled version
        [self makeText:nil];
        [self.ratingAndCommentingView.view removeFromSuperview];
        _ratingAndCommentingView = nil;
        _ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, (self.frame.size.height+20)) andData: nil];
        [self addSubview:self.ratingAndCommentingView.view];
        return;
    }
    [self makeText:[clip.localRawData copy]];
    
    float offset = (isLeague)?115:100;
    [self.ratingAndCommentingView.view removeFromSuperview];
    _ratingAndCommentingView = nil;
    _ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, offset, self.frame.size.width, (self.frame.size.height+20)) andData: clip.localRawData];
    [self addSubview:self.ratingAndCommentingView.view];
}

-(void)makeText:(NSDictionary *)data
{
    [[contentText mutableString] setString:@""];
    if (!data){
        [self addText: [NSString stringWithFormat:@"%@:\t", NSLocalizedString(@"Event Date", nil)]     style:Disabled];          [self addText: @" " style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Event Time", nil)]   style:Disabled];          [self addText: @" " style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Home Team", nil)]    style:Disabled];          [self addText: @" " style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Visit Team", nil)]   style:Disabled];          [self addText: @" " style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Tag Name", nil)]     style:Disabled];          [self addText: @" " style:Normal];
        [self addText: [NSString stringWithFormat:@"\n%@:\t\t", NSLocalizedString(@"Tag Time", nil)]   style:Disabled];          [self addText: @" " style:Normal];
        return;
    }
    
    
    NSArray *tempArr            = [[data objectForKey:@"event" ] componentsSeparatedByString:@"_"];
    NSString *eventDate         =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
    NSArray *tempTime           = [[NSString stringWithFormat:@"%@",[tempArr objectAtIndex:1]]componentsSeparatedByString:@"-"] ;
    NSString *eventTime         = [NSString stringWithFormat:@"%@ : %@ : %@",[tempTime objectAtIndex:0],[tempTime objectAtIndex:1],[tempTime objectAtIndex:2]];
    
    NSDictionary *teamInfo;// = [[allEvents objectForKey:[data objectForKey:@"event"]] copy];
    NSString *homeTeam;
    NSString *visitTeam;
    NSString *leagueName;
    
    if (teamInfo){
        homeTeam = [teamInfo objectForKey:@"homeTeam"];
        visitTeam = [teamInfo objectForKey:@"visitTeam"];
        leagueName = [teamInfo objectForKey:@"league"];
    } else {
        homeTeam = [data objectForKey:@"homeTeam"];
        visitTeam = [data objectForKey:@"visitTeam"];
        leagueName = @"";
    }
    
    [self addText: [NSString stringWithFormat:@"%@:\t", NSLocalizedString(@"Event Date", nil)]     style:Bold];          [self addText: eventDate style:Normal];
    [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Event Time", nil)]   style:Bold];          [self addText: eventTime style:Normal];
    [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Home Team", nil)]    style:Bold];          [self addText: homeTeam style:Normal];
    [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Visit Team", nil)]   style:Bold];          [self addText: visitTeam style:Normal];
    if(![leagueName isEqualToString:@""]){
        [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"League", nil)]       style:Bold];          [self addText: leagueName style:Normal];
        isLeague = YES;
    }
    [self addText: [NSString stringWithFormat:@"\n%@:\t", NSLocalizedString(@"Tag Name", nil)]     style:Bold];          [self addText: [data objectForKey:@"name"] style:Normal];
    [self addText: [NSString stringWithFormat:@"\n%@:\t\t", NSLocalizedString(@"Tag Time", nil)]   style:Bold];          [self addText: [data objectForKey:@"displaytime"] style:Normal];
    
    [tagDetailsView setAttributedText:contentText];

}

-(void)setEnable:(BOOL)enable
{
    if (enable == _enable) return;
    
    [self willChangeValueForKey:@"enable"];
    if (_enable && !enable){
        _ratingAndCommentingView.enable = NO;
        tagDetailsView.alpha = 0.5f;
    } else if (!_enable && enable){
        _ratingAndCommentingView.enable = YES;
        tagDetailsView.alpha = 1.0f;
    }
    _enable = enable;
    [self didChangeValueForKey:@"enable"];
}

-(BOOL)enable
{
    return _enable;
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
        case Disabled:
            concatText = [[NSMutableAttributedString alloc] initWithString:txt attributes:DisableAttrs];
            break;
            
    }
    [contentText insertAttributedString:concatText atIndex:contentText.length];
}



@end
