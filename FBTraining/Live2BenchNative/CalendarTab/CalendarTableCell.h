//
//  CalendarTableCell.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-09.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "AutoScrollLabel.h"
#import "DownloadButton.h"


@interface CalendarTableCell : UITableViewCell
{
    UIView* backgroundView;

}

@property (nonatomic,assign) BOOL               isLastViewed;
@property (nonatomic,assign) BOOL               viewed;
@property (nonatomic,strong) NSString           * eventHid;
@property (nonatomic,strong) CustomButton       * playButton;
@property (nonatomic,strong) AutoScrollLabel    * textScrollView;
@property (nonatomic,strong) DownloadButton     * downloadButton;


-(instancetype)reset;
-(void)setCellText:(NSString *)text;

@end
