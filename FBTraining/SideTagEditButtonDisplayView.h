//
//  SideTagEditButtonDisplayView.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideTagEditButtonDisplayView : UIView

@property (nonatomic,weak) IBOutlet UILabel     * typeLabel;
@property (nonatomic,weak) IBOutlet UIButton    * button;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * position;
@property (nonatomic,strong) NSNumber * order;
@property (nonatomic,assign) BOOL   enabled;
@property (nonatomic,assign) BOOL   selected;

-(NSDictionary*)data;

@end
