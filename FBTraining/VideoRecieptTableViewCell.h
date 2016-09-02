//
//  VideoRecieptTableViewCell.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRecieptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton * onCopyButton;
@property (weak, nonatomic) IBOutlet UIButton * onEmailButton;
@property (weak, nonatomic) IBOutlet UIButton * viewersToLogButton;
@property (weak, nonatomic) IBOutlet UIView   * indicatorView;
@property (weak, nonatomic) IBOutlet UILabel  * tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamLabel;

@property (weak, nonatomic) IBOutlet UILabel * labelReciept;


@property (nonatomic,strong) NSString * linkUrl;

@end
