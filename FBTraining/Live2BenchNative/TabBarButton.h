//
//  TabBarButton.h
//  Live2BenchNative
//
//  Created by Dev on 2013-09-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomButton.h"

@interface TabBarButton : CustomButton

@property (nonatomic, strong) NSString *tabName;
@property (nonatomic, strong) NSString *imageName;

- (id)initWithName:(NSString*)tabName andImageName:(NSString*)imageName;
- (UIImage*)normalImage;
- (UIImage*)selectedImage;


@end
