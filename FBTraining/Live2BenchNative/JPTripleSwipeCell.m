//
//  JPTripleSwipeCell.m
//  TripleSwipeTableDemo
//
//  Created by Si Te Feng on 8/1/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "JPTripleSwipeCell.h"
#import "JPStyle.h"
#import "JPFont.h"
#import "JPReorderTableView.h"


#define kSwipeDistance      70.0f
#define kSwipeThreshold     20.0f


@interface JPTripleSwipeCell()



@end


static const NSInteger kCellCustomViewTag = 324;

@implementation JPTripleSwipeCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    //Change Default Behaviours
    self.contentView.backgroundColor = [UIColor grayColor];
    self.separatorInset = UIEdgeInsetsZero;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.hidden = YES;
    self.clipsToBounds = YES;
    
    //Initialize iVars
    _viewXPosBeforePan = 0;
    _panningCell = NO;
    _shouldStayInPanning = NO;
    self.selectionType = JPTripleSwipeCellSelectionNone;
    
    //Gesture Recognizer
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellPanned:)];
    panRecognizer.delegate = self;
    panRecognizer.maximumNumberOfTouches = 1;
    
    UILongPressGestureRecognizer* longRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed:)];
    longRec.minimumPressDuration = 0;
    longRec.delegate = self;
    longRec.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longRec];
    
    UITapGestureRecognizer* doubleTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDoubleTapped:)];
    doubleTapRec.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapRec];
    
    
    //Main View
    self.mainCellView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mainCellView.backgroundColor = [UIColor whiteColor];
    self.mainCellView.layer.shadowOffset = CGSizeMake(0, 3);
    self.mainCellView.layer.shadowOpacity = 0.7;
    self.mainCellView.layer.shadowRadius = 10;
    [self addSubview:self.mainCellView];
    
    [self addGestureRecognizer: panRecognizer];
    
    //SubViews on Main View
    self.mainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.mainLabel.font = [UIFont fontWithName:[JPFont defaultFont] size:20];
    [self.mainCellView addSubview:self.mainLabel];
    
    //For customizing the Triple Swipe Cell, add to customView
    self.customView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mainCellView addSubview:self.customView];
    
    _infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    UITapGestureRecognizer* infoTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoButtonPressed)];
    [_infoButton addGestureRecognizer:infoTapRec];
    [self.mainCellView addSubview:_infoButton];
    
    //Subviews Under Main View
    _shareView = [[UIView alloc] initWithFrame:CGRectZero];
    _shareView.backgroundColor = [UIColor greenColor];
    
    UIImage* shareIcon= [UIImage imageNamed:@"swipeShareIcon.png"];
    _shareImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 35, 35)];
    _shareImgView.contentMode = UIViewContentModeScaleAspectFit;
    _shareImgView.image = [shareIcon imageWithColor:[UIColor whiteColor]];
    _shareImgView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_shareView addSubview:_shareImgView];
    
    [self addSubview:_shareView];
    
    
    _deleteView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage* deleteIcon= [UIImage imageNamed:@"swipeTrashIcon"];
    _deleteImgView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 5, 35, 35)];
    _deleteImgView.contentMode = UIViewContentModeScaleAspectFit;
    _deleteImgView.image = [deleteIcon imageWithColor:[UIColor whiteColor]];
    _deleteImgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

    _deleteView.backgroundColor = [UIColor redColor];
    [_deleteView addSubview:_deleteImgView];
    [self addSubview:_deleteView];
    

    [self bringSubviewToFront:self.mainCellView];

    return self;
}


#pragma mark - Gesture Recognizer Target Methods

- (void)cellPanned: (UIPanGestureRecognizer*)recognizer
{
    CGFloat transX = [recognizer translationInView:self.mainCellView].x;
    CGFloat transY = [recognizer translationInView:self.mainCellView].y;
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        if((fabs(transX)<fabs(transY))  &&
           !_shouldStayInPanning
           )
        {
            [self cancelGestureRecognizer:recognizer];
            [self cellPanningStopped: recognizer];
        }
        
        if(fabs(transX) > kSwipeThreshold) {
            [self shouldStayInPanning];
        }
        
        [self cellPanningChanged: recognizer];
        
    }
    else
    {
        [self cellPanningStopped: recognizer];
    }
    
 
}

- (void)shouldStayInPanning
{
    _shouldStayInPanning = YES;
    
    //Cancel Scrolling of the Table View
    JPReorderTableView* tableView = (JPReorderTableView*)self.superview.superview;
    tableView.scrollEnabled = NO;
}


- (void)cellPanningChanged: (UIPanGestureRecognizer*)recognizer
{
    _panningCell = YES;
    
    CGFloat transX = [recognizer translationInView:self.mainCellView].x;

    CGFloat currXPos = _viewXPosBeforePan + transX;
    
    if(currXPos > kSwipeDistance*2)
        currXPos = kSwipeDistance*2;
    else if(currXPos < -kSwipeDistance*2)
        currXPos = -kSwipeDistance*2;
    
    if(fabs(transX) > kSwipeThreshold)
        self.mainCellView.frame = CGRectMake(currXPos, self.mainCellView.frame.origin.y, self.mainCellView.frame.size.width, self.mainCellView.frame.size.height);
    
}


- (void)cellPanningStopped: (UIPanGestureRecognizer*)recognizer
{
    self.mainCellView.backgroundColor = [UIColor whiteColor];
    
    _panningCell = NO;
    _shouldStayInPanning = NO;
    
    //Resume Scrolling of the Table View
    JPReorderTableView* tableView = (JPReorderTableView*)self.superview.superview;
    tableView.scrollEnabled = YES;
    
    //Bounce Back to Desired Position
    CGFloat transX = [recognizer translationInView:self.mainCellView].x;
    CGFloat currXPos = _viewXPosBeforePan + transX;
    
    CGFloat destinationXPos = 0;
    
    JPTripleSwipeCellSelection transitionToSelection = JPTripleSwipeCellSelectionNone;
    
    if(currXPos > 0) //right swipe
    {
        if(currXPos > kSwipeDistance/2) //success
        {
            transitionToSelection=JPTripleSwipeCellSelectionLeft;
            destinationXPos = kSwipeDistance;
        }
        
    }
    else //left swipe
    {
        if(currXPos < -kSwipeDistance/2) //success
        {
            transitionToSelection=JPTripleSwipeCellSelectionRight;
            destinationXPos = -kSwipeDistance;
        }
    }
    
    [self setSelectionType:transitionToSelection animated:YES];
    
    //Send Info to Table View
    if([self.delegate respondsToSelector:@selector(cellSelectedAtIndexPath:withSelectionType:)])
    {
        [self.delegate cellSelectedAtIndexPath:self.indexPath withSelectionType:transitionToSelection];
    }
    
    _viewXPosBeforePan = self.mainCellView.frame.origin.x;
   
    
}


#pragma mark - Tapping On Cell

- (void)cellPressed: (UILongPressGestureRecognizer*)longRec
{
    if(longRec.state == UIGestureRecognizerStateBegan)
    {
        self.customView.backgroundColor = [JPStyle colorWithHex:@"e6e6e6" alpha:1];
        _cellPressCancelled = NO;
    }
    else if(longRec.state == UIGestureRecognizerStateEnded)
    {
        self.customView.backgroundColor = [UIColor clearColor];
        
        if([self.delegate respondsToSelector:@selector(cellPressed:)] && !_cellPressCancelled)
            [self.delegate cellPressed: self.indexPath];
    }
    else {
        _cellPressCancelled = YES;
    }
    
}


- (void)cellDoubleTapped: (UITapGestureRecognizer*)tapRec
{
    if(![self.delegate respondsToSelector:@selector(selectAllCellsWithSelectionType:)])
        return;
    
    if(tapRec.state != UIGestureRecognizerStateRecognized)
        return;
    
    CGPoint location = [tapRec locationInView:self];
    if(self.selectionType != JPTripleSwipeCellSelectionNone)
    {
         [self.delegate selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
    }
    else
    {
        if(location.x < self.cellRect.size.width/2.0)
        {
            [self.delegate selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionLeft];
        } else {
            [self.delegate selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionRight];
        }
    }
    
}


- (void)infoButtonPressed
{
    if([self.delegate respondsToSelector:@selector(cellInfoButtonPressed:)])
        [self.delegate cellInfoButtonPressed:self.indexPath];
}



#pragma mark - Gesture Recognizer Related Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer.class == [UILongPressGestureRecognizer class])
        return YES;
    else
        return NO;
}


- (void)cancelGestureRecognizer: (UIGestureRecognizer*)rec
{
    rec.enabled = NO;
    rec.enabled = YES;
}




#pragma mark - Setter Methods

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.mainCellView.backgroundColor = backgroundColor;
}


- (void)setCustomView:(UIView *)customView
{
    _customView = customView;
    [_customView setUserInteractionEnabled:NO];
    customView.tag = kCellCustomViewTag;
    
    [[self.mainCellView viewWithTag:kCellCustomViewTag] removeFromSuperview];
    [self.mainCellView addSubview:self.customView];
    
}


- (void)setCellRect:(CGRect)cellRect
{
    _cellRect = cellRect;
    self.mainCellView.frame = CGRectMake(0, 0, cellRect.size.width, cellRect.size.height);
    _viewXPosBeforePan = self.mainCellView.frame.origin.x;
    
    self.customView.frame = CGRectMake(0, 0, self.mainCellView.frame.size.width, self.mainCellView.frame.size.height);
    _infoButton.frame = CGRectMake(cellRect.size.width - 44, 0, 44, 44);
    _shareView.frame = CGRectMake(0, 0, cellRect.size.width/2.0, cellRect.size.height);
    _shareImgView.frame = CGRectMake(15, 5, 34, 34);
    _deleteView.frame = CGRectMake(cellRect.size.width/2.0, 0, cellRect.size.width/2.0, cellRect.size.height);
    _deleteImgView.frame = CGRectMake(cellRect.size.width/2.0 - 52, 5, 34, 34);
    
    _mainLabel.frame = CGRectMake(5, 0, cellRect.size.width - 10, cellRect.size.height);

    [self.mainCellView bringSubviewToFront:_infoButton];
}



- (void)setSelectionType:(JPTripleSwipeCellSelection)selectionType
{
    _selectionType = selectionType;

    switch (selectionType) {
        case JPTripleSwipeCellSelectionNone:
            self.mainCellView.frame = CGRectMake(0, self.mainCellView.frame.origin.y, self.mainCellView.frame.size.width, self.mainCellView.frame.size.height);
            break;
        case JPTripleSwipeCellSelectionLeft:
            self.mainCellView.frame = CGRectMake(kSwipeDistance, self.mainCellView.frame.origin.y, self.mainCellView.frame.size.width, self.mainCellView.frame.size.height);
            break;
        case JPTripleSwipeCellSelectionRight:
            self.mainCellView.frame = CGRectMake(-kSwipeDistance, self.mainCellView.frame.origin.y, self.mainCellView.frame.size.width, self.mainCellView.frame.size.height);
            break;
        default:
            break;
    }
    
    _viewXPosBeforePan = self.mainCellView.frame.origin.x;
    
}


- (void)setSelectionType:(JPTripleSwipeCellSelection)selectionType animated: (BOOL)animated{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.selectionType = selectionType;
        
    }];
}


- (void)setShouldShowInfoButton:(BOOL)shouldShowInfoButton
{
    _shouldShowInfoButton = shouldShowInfoButton;
    
    _infoButton.hidden = !shouldShowInfoButton;
}



- (void)prepareForReuse
{
    self.customView = [[UIView alloc] initWithFrame:self.customView.frame];
    
    self.mainLabel.text = @"";
    self.selectionType = JPTripleSwipeCellSelectionNone;
    self.shouldShowInfoButton = YES;
}





@end
