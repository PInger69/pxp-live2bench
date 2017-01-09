//
//  RicoSourcePickerButtons.m
//  Live2BenchNative
//
//  Created by dev on 2016-03-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoSourcePickerButtons.h"

@implementation RicoSourcePickerButtons
{
    CGSize buttonsSize;

}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonArray = [NSMutableArray new];
        
        buttonsSize = CGSizeMake(40, 30);
        self.deselectedColor = [UIColor lightGrayColor];
        self.selectedColor   = [UIColor orangeColor];
    }
    return self;
}

-(void)buildButtonsWithString:(NSArray*)arrayOfString
{
    NSLog(@"RicoSourcePicker button strings: %@", arrayOfString);
    
    self.stringArray = [arrayOfString sortedArrayUsingSelector:@selector(compare:)];
    
    // clear any old buttons
    for (UIButton * b in self.buttonArray) {
        [b removeFromSuperview];
    }
    [self.buttonArray removeAllObjects];

    
    
    CGFloat w   = buttonsSize.width;
    CGFloat h   = buttonsSize.height;
    CGFloat m   = 8;


    NSInteger c = [self.stringArray count] ;
    UIButton * scrButton;
    
    for (NSInteger i =0; i<c; i++) {
        scrButton = [[UIButton alloc]initWithFrame:CGRectMake((w+m) *i, 0, w, h)];
        [scrButton addTarget:self action:@selector(onSelection:) forControlEvents:UIControlEventTouchUpInside];
        scrButton.tag = i;
        [self.buttonArray addObject:scrButton];
        scrButton.layer.cornerRadius = 3;
    
        if (i) {
            [scrButton setBackgroundColor:self.deselectedColor] ;
        } else {
            [scrButton setBackgroundColor:self.selectedColor] ;//PRIMARY_APP_COLOR
        }
        [self addSubview:scrButton];
    }

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            CGRectGetMaxX(scrButton.frame),
                            self.frame.size.height);

}

-(void)selectButtonByIndex:(NSInteger)index
{
    if (![self.buttonArray count]) return;
    UIButton* button        = self.buttonArray[index];
    self.selectedTag        = button.tag;
    self.selectedString     = self.stringArray[button.tag];

    // set color
    for (UIButton * b in self.buttonArray) {
        [b setBackgroundColor:self.deselectedColor] ;
    }

    [button setBackgroundColor:self.selectedColor] ;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPressButton:)]) {
        [self.delegate onPressButton:self];
    }
}


-(void)selectButtonByString:(NSString*)buttonString
{
    NSInteger index = [self.stringArray indexOfObject:buttonString];
    if ([self.stringArray indexOfObject:buttonString] != NSNotFound) {
        [self selectButtonByIndex:index];
    }
}



-(void)highlightButtonByIndex:(NSInteger)index
{
    if (![self.buttonArray count]) return;
    UIButton* button        = self.buttonArray[index];
    self.selectedTag        = button.tag;
    self.selectedString     = self.stringArray[button.tag];
    
    // set color
    for (UIButton * b in self.buttonArray) {
        [b setBackgroundColor:self.deselectedColor] ;
    }
    
    [button setBackgroundColor:self.selectedColor] ;
}

-(void)highlightButtonByString:(NSString*)buttonString
{
    NSInteger index = [self.stringArray indexOfObject:buttonString];
    if ([self.stringArray indexOfObject:buttonString] != NSNotFound) {
        UIButton* button        = self.buttonArray[index];
        [button setBackgroundColor:self.selectedColor] ;
    }
}



-(void)onSelection:(id)sender
{
    UIButton * button = sender;
    [self selectButtonByIndex:button.tag];
}

-(void)deselectAll
{
    
    self.selectedTag = -1;
    self.selectedString = nil;
    // clear any old buttons
    for (UIButton * b in self.buttonArray) {
         [b setBackgroundColor:self.deselectedColor] ;
    }
}


@end
