//
//  ListPopoverControllerWithImages.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#define BUTTON_HEIGHT   200
#define POP_WIDTH       300

#import "ListPopoverControllerWithImages.h"

@implementation ListPopoverControllerWithImages
-(id)initWithMessage:(NSString*)aMessage buttonListNames:(NSArray*)aListOfNames{
    //self = [super initWithContentViewController:contentVC];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    self                            = [super initWithContentViewController:viewController];

    
    if (self) {
         contentVC = viewController;
        self.arrayOfButtons = [[NSMutableArray alloc] init];
        //contentVC  = [[UIViewController alloc] init];
        self.theScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, POP_WIDTH, (BUTTON_HEIGHT*2)+10)];
        //self.theScrollView.contentSize = CGSizeMake(self.theScrollView.frame.size.width, (BUTTON_HEIGHT * 5));
        //contentVC.view = self.theScrollView;
        
        self.message                    = aMessage;
        self.listOfButtonNames          = aListOfNames;
        self.messageText                = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, POP_WIDTH-40, 20)];
        self.messageText.lineBreakMode   = NSLineBreakByWordWrapping;
        self.messageText.numberOfLines   = 0;
        self.messageText.textAlignment   = NSTextAlignmentCenter;
        self.messageText.text            = self.message;
        self.messageText.font            = [UIFont defaultFontOfSize:17.0f];
        [contentVC.view addSubview:self.messageText];
        
        self.animateDismiss             = NO;
        self.animatePresent             = NO;
        
        //        contentVC.view              = content;
        contentVC.modalInPopover    = YES;
        self.contentViewController  = contentVC;
        
        teamButtons                 = [[NSMutableArray alloc]init];
        onCompletionBlocks          = [[NSMutableArray alloc]init];
        
        [contentVC.view addSubview:self.theScrollView];
        for (int i=0; i< self.listOfButtonNames.count; i++) {
            NSString * nm = [ self.listOfButtonNames objectAtIndex:i];
            [self _buildButton:nm index:i];
        }
        
        
        [self setPopoverContentSize:CGSizeMake(self.theScrollView.frame.size.width, (BUTTON_HEIGHT * 2)+50-22) animated:self.animatePresent];
    }
    
    return self;
    
}

-(void)_buildButton:(NSString*)aButtonName index:(int)aIndex
{
    PopoverButton *button = [PopoverButton buttonWithType:UIButtonTypeCustom];
    //[button setFrame:CGRectMake(0.0f, 70.0f+(50.0f*aIndex), content.bounds.size.width, 50.0f)];
    [button setTitle:aButtonName forState:UIControlStateNormal];
    [button setAccessibilityLabel:[NSString stringWithFormat: @"%d",aIndex]];
    [button addTarget:self action:@selector(onSelectAListItem:) forControlEvents:UIControlEventTouchUpInside];
    
    button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    button.titleLabel.layer.shadowRadius = 2.0;
    button.titleLabel.layer.shadowOpacity = 0.5;
    button.titleLabel.layer.shadowOffset = CGSizeZero;
    
    // if you want line breaks
    CGFloat borderWidth = .5;
    
    [button setFrame:CGRectMake(-borderWidth, ((BUTTON_HEIGHT-borderWidth)*aIndex), POP_WIDTH + borderWidth, BUTTON_HEIGHT)];
    button.layer.borderColor = [UIColor darkGrayColor].CGColor;
    button.layer.borderWidth = borderWidth;
    
    
    [self.theScrollView addSubview:button];
    [teamButtons addObject:button];
    [self.arrayOfButtons addObject:button];
    
    
}

-(void)setListOfButtonNames:(NSArray *)aListOfButtonNames
{
    [self clear];
    NSArray * listOfButtonNames = [aListOfButtonNames sortedArrayUsingSelector:@selector(compare:)];
    
    [self willChangeValueForKey:@"listOfButtonNames"];
    [teamButtons removeAllObjects];
    
    for (int i=0; i<listOfButtonNames.count; i++) {
        NSString * nm = [listOfButtonNames objectAtIndex:i];
        [self _buildButton:nm index:i];
    }
    [self didChangeValueForKey:@"listOfButtonNames"];
    self.theScrollView.contentSize = CGSizeMake(POP_WIDTH, (BUTTON_HEIGHT*listOfButtonNames.count)+10);
    //[self setPopoverContentSize:CGSizeMake(content.frame.size.width, content.frame.size.height) animated:self.animatePresent];
}
-(void)clear
{
    for (PopoverButton *button in teamButtons) {
        [button removeFromSuperview];
    }
    for (UIButton *button in _arrayOfButtons) {
        [button removeFromSuperview];
    }
    
    [teamButtons removeAllObjects];
    [onCompletionBlocks removeAllObjects];
    [self.arrayOfButtons removeAllObjects];
}

-(void)dismissPopoverAnimated:(BOOL)animated{
    [super dismissPopoverAnimated:animated];
    
    
}

@end

