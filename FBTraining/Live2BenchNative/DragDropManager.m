//
//  DragDropManager.m
//  Live2BenchNative
//
//  Created by DEV on 2013-06-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "DragDropManager.h"

@interface DragDropManager ()

@end

@implementation DragDropManager

@synthesize dragObjects;
@synthesize dropAreas;
@synthesize dragContext;


-(id)initWithDragSubjects:(NSMutableArray*)drag_objects andDropAreas:(NSArray*)drop_areas{
    self = [super init];
    if (self) {
        dragObjects = drag_objects;
        dropAreas = drop_areas;
        dragContext = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)dragObjectAccordingToGesture:(UILongPressGestureRecognizer*)recognizer{
    if (self.dragContext) {
        CGPoint pointOnView = [recognizer locationInView:recognizer.view];
        self.dragContext.draggedView.center = pointOnView;
    }
}

-(void)dragging:(id)sender{
    UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*)sender;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            for (UIView *dragObject in dragObjects) {
                CGPoint pointinObjectView = [recognizer locationInView:dragObject];
                BOOL pointInSideDraggableObject = [dragObject pointInside:pointinObjectView withEvent:nil];
                if (pointInSideDraggableObject) {
                    self.dragContext = [[DragContext alloc]initWithDraggedView:dragObject];
                    [dragObject removeFromSuperview];
                    [recognizer.view addSubview:dragObject];
                    [self dragObjectAccordingToGesture:recognizer];
                }else{
                    //NSLog(@"started drag outside drag subjects");
                }
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            [self dragObjectAccordingToGesture:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.dragContext) {
                UIView *viewBeingDragged = self.dragContext.draggedView;
                BOOL droppedViewInKnownArea = NO;
                for(UIView *dropArea in self.dropAreas){
                    CGPoint pointInDropView = [recognizer locationInView:dropArea];
                    if ([dropArea pointInside:pointInDropView withEvent:nil]) {
                        droppedViewInKnownArea = YES;
                        [viewBeingDragged removeFromSuperview];
                        [dropArea addSubview:viewBeingDragged];
                        viewBeingDragged.frame = CGRectMake(pointInDropView.x - (viewBeingDragged.frame.size.width /2), pointInDropView.y - (viewBeingDragged.frame.size.height/2), viewBeingDragged.frame.size.width, viewBeingDragged.frame.size.height);
                    }
                }
                
                if (!droppedViewInKnownArea) {
                    [self.dragContext snapToOriginalPosition];
                }
                
                self.dragContext = nil;
            }
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
   
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
    // Dispose of any resources that can be recreated.
}

@end
