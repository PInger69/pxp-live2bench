//
//  EdgeSwipeEditButtonsView.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EdgeSwipeEditButtonsView.h"
#import "EdgeSwipeButton.h"

@implementation EdgeSwipeEditButtonsView

static const float kButtonHeight = 44.0f;
static const int JPControlEventCancel = 527;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _selectedButton = -1;
//        self.layer.borderWidth = 1;
        
//        UIPanGestureRecognizer* generalPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(entireViewPanned:)];
//        [self addGestureRecognizer: generalPanRecognizer];
        
        self.swipeButtons = [NSMutableArray array];
        
        NSArray* buttonImgNames = [NSArray arrayWithObjects:@"sort",@"filter",@"trash",@"share", nil];
        
        for(int i=0; i<4; i++)
        {
            EdgeSwipeButton* swipeButton = [[EdgeSwipeButton alloc] initWithFrame:CGRectMake(0, 200 + i*70, 60, 55) imageOffset:frame.size.width];
            
            swipeButton.image = [UIImage imageNamed:buttonImgNames[i]];
            
            swipeButton.tag = i;
            [swipeButton addTarget:self action:@selector(swipeButtonSelected:) forControlEvents:UIControlEventValueChanged];
            [swipeButton addTarget:self action:@selector(swipeButtonCancelled:event:) forControlEvents: UIControlEventEditingDidEnd];
            swipeButton.hidden = NO;
            
            if(i==2 || i==3)
            {
                swipeButton.type = JPSwipeButtonTypeRetain;
            }
            
            [self.swipeButtons addObject: swipeButton];
            
            // i know this is a hack and slash
            
           if ([buttonImgNames[i] isEqualToString:@"filter"]) [self addSubview:swipeButton];
            
        }
    
    }
    return self;
}


- (void)swipeButtonSelected: (EdgeSwipeButton*)button
{
    EdgeSwipeButton* swipeButton;
    
    if(button.tag == _selectedButton) //tap active button again
    {
        if(button.tag == 0)
        {
            [self.delegate reorderList:NO];
        }
        else if(button.tag == 2)
        {
            [self.delegate deleteCells];

        }
        else if(button.tag == 3)
        {
            if([self.delegate respondsToSelector:@selector(shareTags:)])
                [self.delegate shareTags:button];
        }
        
        button.selected = NO;
        
        if (button.tag != 1)
            _selectedButton = -1;
    }
    else //Button changed
    {
        //Deselect last button
        if(_selectedButton != -1)
        {
            swipeButton = [self.swipeButtons objectAtIndex:_selectedButton];
            swipeButton.selected = NO;
        }
        
        if(_selectedButton == 0)
            [self.delegate reorderList: NO];
        else if(_selectedButton == 2)
        {
            swipeButton = [self.swipeButtons objectAtIndex:2];
            [swipeButton retractButtonImage];
        }
        else if(_selectedButton == 3)
        {
            swipeButton = [self.swipeButtons objectAtIndex:3];
            [swipeButton retractButtonImage];
        }
        
        
        switch (button.tag) {
            case 0: //Reorder
                [self.delegate editingClips: NO];
                [self.delegate reorderList:YES];
                break;
            case 1: //Filter Box
                if([self.delegate respondsToSelector:@selector(editingClips:)])
                    [self.delegate editingClips: NO];
                
                [self.delegate slideFilterBox];
                break;
            case 2: //Delete Button
                [self.delegate editingClips: YES];
                break;
            case 3: //Share Button
                [self.delegate editingClips: YES];
                if([_delegate respondsToSelector:@selector(shareTagsFormatTwo:)])
                {
                    [self.delegate shareTagsFormatTwo:button];
                }
                break;
            default:
                break;
        }
        
        button.selected = YES;
        _selectedButton = button.tag;
        
        
    }
    
}



- (void)swipeButtonCancelled: (EdgeSwipeButton*)button event: (UIControlEvents)event
{
     if(button.tag == _selectedButton)
     {
         button.selected = NO;
         
        if(button.tag == 2)
        {
            [button retractButtonImage];
            [self.delegate editingClips:NO];
        }
        else if(button.tag == 3)
        {
            [button retractButtonImage];
            [self.delegate editingClips:NO];
        }
        else if(button.tag == 0)
        {
            [self.delegate reorderList:NO];
        }
        
        _selectedButton = -1;
     }
}




- (void)deselectButtonAtIndex:(NSInteger)index
{
    EdgeSwipeButton* button=[self.swipeButtons objectAtIndex:index];
    button.selected = NO;
    _selectedButton = -1;
    
    if(index==2 || index==3)
    {
        [button retractButtonImage];
    }
}


- (void)deselectAllButtons
{
    for(int index=0; index<4; index++)
    {
        EdgeSwipeButton* button=[self.swipeButtons objectAtIndex:index];
        button.selected = NO;
        if(index==2 || index==3)
        {
            [button retractButtonImage];
        }
    }
    
    _selectedButton = -1;
    
}



- (void)setDelegate:(id<EdgeSwipeButtonDelegate>)delegate
{
    _delegate = delegate;
    
    //Hiding buttons that are not used (reorder, share)
    if(![_delegate respondsToSelector:@selector(reorderList:)])
    {
        EdgeSwipeButton* button = self.swipeButtons[0];
        button.hidden = YES;
    }
    
    if(![_delegate respondsToSelector:@selector(shareTags:)] && ![_delegate respondsToSelector:@selector(shareTagsFormatTwo:)])
    {
        EdgeSwipeButton* button = self.swipeButtons[3];
        button.hidden = YES;
    }
    
    if(![_delegate respondsToSelector:@selector(deleteCells)])
    {
        EdgeSwipeButton* button = self.swipeButtons[2];
        button.hidden = YES;
    }
    
}






- (void)entireViewPanned: (UIPanGestureRecognizer*)rec
{
    
    if(rec.state == UIGestureRecognizerStateChanged)
    {
        
        
        
        
    }
    

}




@end
