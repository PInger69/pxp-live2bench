//
//  DragContext.h
//  Live2BenchNative
//
//  Created by DEV on 2013-06-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DragContext : NSObject{
    UIView *draggedView;
    CGPoint originalPosition;
    UIView *originalView;
}

@property(nonatomic,strong)UIView *draggedView;
@property(nonatomic,strong)UIView *originalView;
@property(nonatomic)CGPoint originalPosition;

-(id)initWithDraggedView:(UIView*)dragged_view;
-(void)snapToOriginalPosition;
@end
