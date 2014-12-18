//
//  TagMarker.h
//  Live2BenchNative
//
//  Created by dev on 13-01-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagMarker : NSObject{

}

@property (nonatomic) double xValue;
@property (nonatomic, strong) NSString* tagID;
@property (strong,nonatomic) UIView *markerView;
@property (nonatomic) float tagTime;
@property (nonatomic, strong) TagMarker *leadTag;
//@property (strong,nonatomic) NSString *tagName;
@property (nonatomic, strong)UIColor *color;

-(id)initWithXValue:(double)xVal tagColour:(UIColor*)color tagTime:(CGFloat)time tagId:(NSString*)tagID;

@end
