//
//  BookmarkViewCell.h
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkViewCell : UITableViewCell{

}


@property (strong, nonatomic) UILabel *tagName;

@property (strong, nonatomic) UILabel *tagTime;


@property (strong, nonatomic) UILabel *eventDate;

-(void)updateIndexWith:(int)newIndex;

@end
