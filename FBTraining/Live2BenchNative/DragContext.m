//
//  DragContext.m
//  Live2BenchNative
//
//  Created by DEV on 2013-06-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "DragContext.h"

@implementation DragContext
@synthesize draggedView;
@synthesize originalPosition;
@synthesize originalView;

-(id)initWithDraggedView:(UIView*)dragged_view{
    self = [super init];
    if (self) {
        draggedView = draggedView;
        originalPosition = draggedView.frame.origin;
        originalView = draggedView.superview;
        
    }
    
    return self;
}

-(void)snapToOriginalPosition{
    [draggedView removeFromSuperview];
    [originalView addSubview:draggedView];
    draggedView.frame = CGRectMake(originalPosition.x, originalPosition.y, draggedView.frame.size.width, draggedView.frame.size.height);
}


@end
