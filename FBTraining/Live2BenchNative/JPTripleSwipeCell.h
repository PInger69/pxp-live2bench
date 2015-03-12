//
//  JPTripleSwipeCell.h
//  TripleSwipeTableDemo
//
//  Created by Si Te Feng on 8/1/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JPTripleSwipeCellSelection)
{
    JPTripleSwipeCellSelectionNone = 0,
    JPTripleSwipeCellSelectionLeft,
    JPTripleSwipeCellSelectionRight
};

@protocol JPTripleSwipeCellDelegate;
@interface JPTripleSwipeCell : UITableViewCell <UIGestureRecognizerDelegate>
{
    CGFloat  _viewXPosBeforePan;
    UIButton* _infoButton;
    
    UIView*  _shareView;
    UIView*  _deleteView;
    UIImageView*  _shareImgView;
    UIImageView*  _deleteImgView;
    
    BOOL     _panningCell;
    BOOL     _shouldStayInPanning;
    
    BOOL     _cellPressCancelled; //cellPressed:
}


@property (nonatomic, strong) id originalCell;
@property (nonatomic, weak)   id<JPTripleSwipeCellDelegate> delegate;


@property (nonatomic, strong) UIView* mainCellView;
@property (nonatomic, strong) UIView* customView;
@property (nonatomic, assign) BOOL    shouldShowInfoButton;

@property (nonatomic, strong) UILabel* mainLabel;//NOT Using TextLabel

@property (nonatomic, assign) JPTripleSwipeCellSelection selectionType;


//Set These
@property (nonatomic, assign) CGRect cellRect;
@property (nonatomic, strong) NSIndexPath* indexPath;


- (void)setSelectionType:(JPTripleSwipeCellSelection)selectionType animated: (BOOL)animated;



@end

@protocol JPTripleSwipeCellDelegate <NSObject>

@optional
- (void)cellSelectedAtIndexPath: (NSIndexPath*)indexPath withSelectionType: (JPTripleSwipeCellSelection)type;

- (void)selectAllCellsWithSelectionType: (JPTripleSwipeCellSelection)type;

- (void)cellPressed:(NSIndexPath*)indexPath;
- (void)cellInfoButtonPressed: (NSIndexPath*)indexPath;


@end




