//
//  TagSetEditPopUpViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagSetEditDelegate <NSObject>
@required
-(void)selectedColor:(UIColor *)newColor;
@end



@interface TagSetEditPopUpViewController : UIViewController

@property (nonatomic, weak) id<TagSetEditDelegate> delegate;


@end
