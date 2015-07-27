//
//  ARCalendarTableViewCell.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ARCalendarTableViewCell.h"


@interface ARCalendarTableViewCell()

@end

@implementation ARCalendarTableViewCell
{
    UILabel * _dateDescription;
    UILabel * _leagueDescription;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupView];
    }
    return self;
}


-(void)setupView{
    [super setupView];
    
    CGFloat leftMargin      = 5;
    CGFloat topMargin       = 5;
    CGFloat txtBoxHeight    = 26;
    
    self.deleteButton.frame = CGRectMake(448, 0, 70 , 79);
    //self.shareButton.frame = CGRectMake(0, 0, 70 , 44);
    
    
    _dateDescription =    [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin+txtBoxHeight, 120, txtBoxHeight)];
    [_dateDescription setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    _dateDescription.text   = @"Event start time:";
    
    
    _leagueDescription =    [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin+txtBoxHeight+txtBoxHeight, 60, txtBoxHeight)];
    [_leagueDescription setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    _leagueDescription.text   = @"League:";
    
    self.dateLabel =    [[UILabel alloc] initWithFrame:CGRectMake(125+leftMargin, topMargin+txtBoxHeight, 100, txtBoxHeight)];
    [self.dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
   
    self.timeLabel =    [[UILabel alloc] initWithFrame:CGRectMake(125+105,      topMargin+txtBoxHeight, 50, txtBoxHeight)];
   [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, 380, txtBoxHeight)];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    
    self.downloadInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(390, topMargin, 100, 50)];
    [self.downloadInfoLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    self.downloadInfoLabel.numberOfLines = 2;
    self.downloadInfoLabel.lineBreakMode = NSLineBreakByClipping;

//    self.downloadInfoLabel.layer.borderWidth = 1;
//    self.dateLabel.layer.borderWidth = 1;
//    self.timeLabel.layer.borderWidth = 1;
//    self.titleLabel.layer.borderWidth = 1;

//    self.playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [self.playButton setFrame:CGRectMake(460, 15, 30,30)];
//    //don't set tag to 0, by default, uiview's tag is 0
//    [self.playButton setTag:101];
//    [self.playButton setEnabled:YES];
//    [self.playButton setPlayButton];
//    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    //[self.playButton setShowsTouchWhenHighlighted: YES];
//    
//    self.downloadButton = [DownloadButton buttonWithType:UIButtonTypeCustom];
//    [self.downloadButton setAutoresizingMask:UIViewAutoresizingNone];
//    [self.downloadButton setFrame:CGRectMake(400, 15, 30,35)];
//    [self.downloadButton setTag:98];
//    [self.downloadButton addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.myContentView addSubview: self.downloadInfoLabel];
    [self.myContentView addSubview: self.dateLabel];
    [self.myContentView addSubview: self.timeLabel];
    [self.myContentView addSubview: self.titleLabel];
    [self.myContentView addSubview: _dateDescription];
    [self.myContentView addSubview: _leagueDescription];
    
    //[self.myContentView addSubview: self.playButton];
}
//-(void)prepareForReuse{
//
//}

//-(void)playButtonPressed: (UIButton *) sender{
//    self.sendUserInfo();
//}
//
//-(void)downloadButtonPressed{
//    self.downloadButtonBlock();
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)isSelected:(BOOL)selected{
    
    UIColor * color;
    
    // this is just to get the colors to reflect the tint change
    
    color = [Utility ligherColorOf:self.tintColor];

    
 //   color =     [self.tintColor colorWithAlphaComponent:.5]; //[UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f];

    UIColor * textColor = [UIColor colorWithWhite:0.224 alpha:1.0f];
    if (selected) {
        self.myContentView.backgroundColor = color;
        [self.dateLabel setTextColor:textColor];
        [self.timeLabel setTextColor:textColor];
        //self.backgroundColor = color;
    }else{
        self.myContentView.backgroundColor = [UIColor whiteColor];
        [self.dateLabel setTextColor:[UIColor blackColor]];
        [self.timeLabel setTextColor:[UIColor blackColor]];
        [self.titleLabel setTextColor:[UIColor blackColor]];
    }
    // Configure the view for the selected state
}

@end