//
//  FilterCell.h
//  Live2BenchNative
//
//  Created by DEV on 2013-02-11.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell
{
    IBOutlet UILabel *_filterTitle;
    
}

@property (nonatomic,strong) IBOutlet UILabel *filterTitle;
@end
