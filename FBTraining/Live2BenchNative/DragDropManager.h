//
//  DragDropManager.h
//  Live2BenchNative
//
//  Created by DEV on 2013-06-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragContext.h"

@interface DragDropManager : UIViewController{
    NSMutableArray *dragObjects;
    NSArray *dropAreas;
    DragContext *dragContext;
}

@property(nonatomic,strong)NSMutableArray *dragObjects;
@property(nonatomic,strong) NSArray *dropAreas;
@property(nonatomic,strong) DragContext *dragContext;

-(id)initWithDragSubjects:(NSMutableArray*)drag_objects andDropAreas:(NSArray*)drop_areas;
-(void)dragging:(id)sender;
@end
