//
//  PxpFilterRatingView.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterRatingView.h"
#define STAR_SIZE   40
#define MARGIN      5

@implementation PxpFilterRatingView
{
    NSInteger           _selectedCount;
    NSMutableArray      * _starButtons;
    UIImage             * _starOnImage;
    UIImage             * _starOffImage;
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _selectedCount = 0;
        self.backgroundColor    = [UIColor clearColor];
        _starOnImage            = [Utility starImageSelected:YES size:CGSizeMake(STAR_SIZE, STAR_SIZE)];
        _starOffImage           = [Utility starImageSelected:NO size:CGSizeMake(STAR_SIZE, STAR_SIZE)];
        _starButtons            = [NSMutableArray new];
    }
    return self;
}

-(void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedCount          = 0;
        self.backgroundColor    = [UIColor clearColor];
        _starOnImage            = [Utility starImageSelected:YES size:CGSizeMake(STAR_SIZE, STAR_SIZE)];
        _starOffImage           = [Utility starImageSelected:NO  size:CGSizeMake(STAR_SIZE, STAR_SIZE)];
        _starButtons            = [NSMutableArray new];
    }
    return self;
}


-(void)buildButtons
{
    
    for (UIButton* butt in _starButtons) {
        [butt removeFromSuperview];
    }
    [_starButtons removeAllObjects];
  //  _selectedCount = 0;
    
    for(int i = 0;i<5;i++) {
        UIButton * ratingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat sqSize = (self.frame.size.width - (MARGIN *4))/5;

        
        [ratingButton setFrame:CGRectMake((sqSize+MARGIN)*i, 0, sqSize,sqSize)];
        [ratingButton setImage:_starOffImage forState:UIControlStateNormal];
        [ratingButton setImage:_starOnImage forState:UIControlStateSelected];
        ratingButton.selected = (i < _selectedCount)?YES:NO;
        ratingButton.tag = i+1;
        [ratingButton.imageView setContentMode:UIViewContentModeScaleAspectFit]; /// can this be applied to the image it self ??
        [ratingButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:ratingButton];
        [_starButtons addObject:ratingButton];
    }
    
//    _selectedCount = _selectedCount;

}


// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    UIButton    * button   = (UIButton *)sender;
    
    if (_selectedCount == button.tag) {
        // if you press the same button again deselect
        [self deselect];
    } else {
        _selectedCount   = button.tag;
        for(NSInteger i = 0;i<5;i++) {
            UIButton *ratingButton = _starButtons[i];
            ratingButton.selected = (i < button.tag)?YES:NO;
        }
    }
    [_parentFilter refresh];
}

-(void)deselect
{
    for (UIButton* butt in _starButtons) {
        butt.selected = NO;
    }
    _selectedCount = 0;
}




-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    if (_selectedCount == 0 || [tagsToFilter count]==0) return; // all or none are selected
    [tagsToFilter filterUsingPredicate:[NSPredicate predicateWithFormat:@"rating == %i", _selectedCount]];
}

-(void)reset{
    [self deselect];
}


@end
