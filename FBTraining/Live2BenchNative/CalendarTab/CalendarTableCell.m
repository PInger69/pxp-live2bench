//
//  CalendarTableCell.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-09.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CalendarTableCell.h"


#define VIEWED_BACKGROUND_COLOR     [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]
#define MAX_LABEL_LENGTH            390

@implementation CalendarTableCell

static NSString * lastViewed;

@synthesize viewed          = _viewed;
@synthesize isLastViewed    = _isLastViewed;
@synthesize eventHid        = _eventHid;
@synthesize playButton      = _playButton;
@synthesize textScrollView  = _textScrollView;
@synthesize downloadButton  = _downloadButton;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle             = UITableViewCellSelectionStyleNone;
        self.imageView.contentMode      = UIViewContentModeScaleAspectFill;
        self.selectedBackgroundView     = [[UIView alloc]initWithFrame:CGRectZero];
        backgroundView                  = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView             = backgroundView;
        _eventHid                       = @"";
        _textScrollView                 = [self _buildAutoScrollLabel];
        _playButton                     = [self _buildPlayButton];
        
        [self addSubview:_playButton];
        [self addSubview:_textScrollView];
        [self addSubview:_downloadButton];
        [self setUserInteractionEnabled:TRUE];
        [self reset];
    }
    return self;
}


-(instancetype)reset
{
    _viewed                                     = NO;
    _textScrollView.text                        = @"";
    self.selectedBackgroundView.backgroundColor = [UIColor orangeColor];
    self.layer.borderColor                      = [[UIColor orangeColor] CGColor];
    self.layer.borderWidth                      = 0.0f;
    backgroundView.backgroundColor              = [UIColor clearColor];
    return self;
}



-(CustomButton *)_buildPlayButton
{
    CustomButton * button = [CustomButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"play_video"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(480, 7, 30,30)];
    //don't set tag to 0, by default, uiview's tag is 0
    [button setTag:101];

    [button setEnabled:YES];

    return button;
}

-(AutoScrollLabel *)_buildAutoScrollLabel
{
    AutoScrollLabel *autoScrollView = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(7, 7, MAX_LABEL_LENGTH, 30)];
   
    [autoScrollView setTextColor: [UIColor colorWithWhite:0.224 alpha:1.0]];
    [autoScrollView setAccessibilityLabel:  @"scrollableText"];
    [autoScrollView setFont: [UIFont defaultFontOfSize:20.0f] ];

    
    return autoScrollView;
}

-(DownloadButton *)_buildDownloadButton
{
    DownloadButton * button = [DownloadButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton setFrame:CGRectMake(415, 7, 30,30)];
    [_downloadButton setTag:98];
    
    return button;
}



-(void)setCellText:(NSString *)text
{
    self.textScrollView.text = text;
}


// Getters and setters

-(void)setViewed:(BOOL)viewed
{
    if (viewed == _viewed)return;
    [self willChangeValueForKey:@"viewed"];
    if (viewed){
        self.backgroundView.backgroundColor = VIEWED_BACKGROUND_COLOR;
    } else if (!viewed) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    _viewed = viewed;
    [self didChangeValueForKey:@"viewed"];
}

-(BOOL)viewed
{
    return _viewed;
}


-(void)setIsLastViewed:(BOOL)last
{
    if (!last)return;
    [self willChangeValueForKey:@"isLastViewed"];
    lastViewed = _eventHid;
    [self didChangeValueForKey:@"isLastViewed"];
}

-(BOOL)isLastViewed
{
    return [lastViewed isEqualToString:_eventHid];
}

- (void)prepareForReuse
{




}




@end
