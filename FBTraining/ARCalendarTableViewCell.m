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
    
    self.deleteButton.frame = CGRectMake(448, 0, 70 , 80);
    
    self.dateLabel =[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 40)];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 5, 200, 40)];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 400, 40)];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    
    self.playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //[self.playButton setBackgroundImage:[UIImage imageNamed:@"play_video"] forState:UIControlStateNormal];
    [self.playButton setFrame:CGRectMake(460, 15, 30,30)];
    //don't set tag to 0, by default, uiview's tag is 0
    [self.playButton setTag:101];
    [self.playButton setEnabled:YES];
    [self.playButton setPlayButton];
    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.playButton setShowsTouchWhenHighlighted: YES];
    
    self.downloadButton = [DownloadButton buttonWithType:UIButtonTypeCustom];
    [self.downloadButton setAutoresizingMask:UIViewAutoresizingNone];
    [self.downloadButton setFrame:CGRectMake(460, 15, 30,35)];
    [self.downloadButton setTag:98];
    [self.downloadButton addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self.myContentView addSubview: self.dateLabel];
    [self.myContentView addSubview: self.timeLabel];
    [self.myContentView addSubview: self.titleLabel];
    [self.myContentView addSubview: self.downloadButton];
    [self.myContentView addSubview: self.playButton];
}
//-(void)prepareForReuse{
//
//}

-(void)playButtonPressed: (UIButton *) sender{
    self.sendUserInfo();
}

-(void)downloadButtonPressed{
    self.downloadButtonBlock();
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

