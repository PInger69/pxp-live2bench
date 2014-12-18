//
//  DurationTableViewCell.m
//  StatsImportXML
//
//  Created by Si Te Feng on 7/10/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "DurationTableViewCell.h"
#import "JPFont.h"
#import "UIFont+Default.h"


@implementation DurationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UILabel* idLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 150, 25)];
        idLabel.font = [UIFont boldFontOfSize:16];
        idLabel.text = @"ID: ";
        [idLabel sizeToFit];
        [self addSubview:idLabel];
        
        
        UILabel* codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 150, 25)];
        codeLabel.font = [UIFont boldFontOfSize:16];
        codeLabel.text = @"Code: ";
        [codeLabel sizeToFit];
        [self addSubview:codeLabel];
        
        
        UILabel* startLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 20, 150, 25)];
        startLabel.font = [UIFont boldFontOfSize:16];
        startLabel.text = @"Start: ";
        [startLabel sizeToFit];
        [self addSubview:startLabel];
        
        
        UILabel* endLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 60, 150, 25)];
        endLabel.font = [UIFont boldFontOfSize:16];
        endLabel.text = @"End: ";
        [endLabel sizeToFit];
        [self addSubview:endLabel];
        
        
        
        self.idValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(idLabel.frame), 20 -3 , CGRectGetMinX(startLabel.frame)-CGRectGetMaxX(idLabel.frame), 25)];
        self.idValueLabel.font = [UIFont defaultFontOfSize: 16];
        self.idValueLabel.text = @"";
        [self addSubview:self.idValueLabel];
        
        self.codeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(codeLabel.frame), 60 - 3,  CGRectGetMinX(endLabel.frame)-CGRectGetMaxX(codeLabel.frame), 25)];
        self.codeValueLabel.font = [UIFont defaultFontOfSize: 16];
        self.codeValueLabel.text = @"";
        [self addSubview:self.codeValueLabel];
        
        self.startValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(startLabel.frame), 20 -3 , 100, 25)];
        self.startValueLabel.font = [UIFont defaultFontOfSize: 16];
        self.startValueLabel.text = @"";
        [self addSubview:self.startValueLabel];
        
        self.endValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(endLabel.frame), 60 -3, 100, 25)];
        self.endValueLabel.font = [UIFont defaultFontOfSize: 16];
        self.endValueLabel.text = @"";
        [self addSubview:self.endValueLabel];
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}







@end
