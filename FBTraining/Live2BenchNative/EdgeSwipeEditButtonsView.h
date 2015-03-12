//
//  EdgeSwipeEditButtonsView.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EdgeSwipeButtonDelegate;
@class EdgeSwipeButton;
@interface EdgeSwipeEditButtonsView : UIView <UIGestureRecognizerDelegate>
{
    

    
    
}

//@property (nonatomic, strong) EdgeSwipeButton* sortButton;
//@property (nonatomic, strong) EdgeSwipeButton* filterButton;
//@property (nonatomic, strong) EdgeSwipeButton* selectionButton;
//@property (nonatomic, strong) EdgeSwipeButton* trashButton;
//@property (nonatomic, strong) EdgeSwipeButton* shareButton;

@property (nonatomic, assign) NSInteger selectedButton;

@property (nonatomic, strong) NSMutableArray* swipeButtons; //array of EdgeSwipeButtons

@property (nonatomic, weak) id<EdgeSwipeButtonDelegate> delegate;

- (void)deselectButtonAtIndex: (NSInteger)index;

- (void)deselectAllButtons;

@end



@protocol EdgeSwipeButtonDelegate<NSObject>

@required
- (void)slideFilterBox;


@optional
- (void)editingClips:(BOOL)isEditing;
- (void)deleteCells;
- (void)reorderList: (BOOL)isEditing;
- (void)shareTags:(EdgeSwipeButton*)eButton;
- (void)shareTagsFormatTwo:(EdgeSwipeButton*)eButton;

@end
