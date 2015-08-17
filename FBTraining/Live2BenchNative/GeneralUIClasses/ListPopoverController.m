//
//  ListPopoverController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-08.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ListPopoverController.h"



#define BUTTON_HEIGHT   50
#define POP_WIDTH       400
@implementation ListPopoverController


@synthesize animateDismiss      = _animateDismiss;
@synthesize animatePresent      = _animatePresent;
@synthesize message             = _message;
@synthesize listOfButtonNames   = _listOfButtonNames;

-(id)initWithMessage:(NSString*)aMessage buttonListNames:(NSArray*)aListOfNames
{
    UIViewController *viewController = [[UIViewController alloc] init];
    self                            = [super initWithContentViewController:viewController];
    if (self) {
        contentVC = viewController;
        content                     = contentVC.view;
        content.backgroundColor     = [UIColor whiteColor];
        
        _message                    = aMessage;
        _listOfButtonNames          = aListOfNames;
        messageText                 = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, POP_WIDTH-40, 50)];
        messageText.lineBreakMode   = NSLineBreakByWordWrapping;
        messageText.numberOfLines   = 0;
        messageText.textAlignment   = NSTextAlignmentCenter;
        messageText.text            = _message;
        messageText.font            = [UIFont defaultFontOfSize:17.0f];
        [content addSubview:messageText];
        
        _animateDismiss             = NO;
        _animatePresent             = NO;
        
//        contentVC.view              = content;
        contentVC.modalInPopover    = YES;
        self.contentViewController  = contentVC;
        
        teamButtons                 = [[NSMutableArray alloc]init];
        onCompletionBlocks          = [[NSMutableArray alloc]init];
        
        for (int i=0; i<_listOfButtonNames.count; i++) {
            NSString * nm = [_listOfButtonNames objectAtIndex:i];
            [self _buildButton:nm index:i];
        }
        
        [content setFrame:CGRectMake(0, 0, POP_WIDTH, (BUTTON_HEIGHT*_listOfButtonNames.count)+90-22)];
        [self setPopoverContentSize:CGSizeMake(content.frame.size.width, content.frame.size.height) animated:_animatePresent];
    }
    
    return self;
}

-(void)onSelectAListItem:(id)sender
{
    
    NSString * thePick = ((CustomButton*)sender).currentTitle;
    
    for ( void (^aBlock)(NSString*pick) in onCompletionBlocks) {
        aBlock(thePick);
    }
    [self dismissPopoverAnimated:_animateDismiss];
}

-(void)_buildButton:(NSString*)aButtonName index:(int)aIndex
{
    PopoverButton *button = [PopoverButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0f, 70.0f+(50.0f*aIndex), content.bounds.size.width, 50.0f)];
    [button setTitle:aButtonName forState:UIControlStateNormal];
    [button setAccessibilityLabel:[NSString stringWithFormat: @"%d",aIndex]];
    [button addTarget:self action:@selector(onSelectAListItem:) forControlEvents:UIControlEventTouchUpInside];
    

    // if you want line breaks
    CGFloat borderWidth = .5;
    
    [button setFrame:CGRectMake(-borderWidth, 70.0f+((50.0f-borderWidth)*aIndex), content.bounds.size.width+(borderWidth*2), 50.0f)];
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = borderWidth;
    
    
    [content addSubview:button];
    [teamButtons addObject:button];

}


-(void)addOnCompletionBlock:(void (^)(NSString*pick))aBlock
{

    [onCompletionBlocks addObject:aBlock];

}

-(void)clear
{
    for (PopoverButton *button in teamButtons) {
        [button removeFromSuperview];
    }
    
    [teamButtons removeAllObjects];
    [onCompletionBlocks removeAllObjects];
}

-(void)setMessage:(NSString *)message
{
    [self willChangeValueForKey:@"message"];
    _message                = message;
    messageText.text        = _message;
    [self didChangeValueForKey:@"message"];
}

-(NSString*)message
{
    return _message;
    
}

-(void)setListOfButtonNames:(NSArray *)aListOfButtonNames
{
    
    NSArray * listOfButtonNames = [aListOfButtonNames sortedArrayUsingSelector:@selector(compare:)];
    
    [self willChangeValueForKey:@"listOfButtonNames"];
    [teamButtons removeAllObjects];
    _listOfButtonNames                = listOfButtonNames;
    for (int i=0; i<_listOfButtonNames.count; i++) {
        NSString * nm = [_listOfButtonNames objectAtIndex:i];
        [self _buildButton:nm index:i];
    }
    [self didChangeValueForKey:@"listOfButtonNames"];
    [content setFrame:CGRectMake(0, 0, POP_WIDTH, (BUTTON_HEIGHT*_listOfButtonNames.count)+90-22)];
    [self setPopoverContentSize:CGSizeMake(content.frame.size.width, content.frame.size.height) animated:_animatePresent];
}

-(NSArray *)listOfButtonNames
{
    return _listOfButtonNames;
}

-(void)presentPopoverCenteredIn:(UIView *)view animated:(BOOL)animated
{
   
    float centerX = CGRectGetMidX([view bounds]) - (content.frame.size.width/2);
    float centerY = CGRectGetMidY([view bounds]) - (content.frame.size.height/2);
    
    [super presentPopoverFromRect:CGRectMake(centerX, centerY , content.frame.size.width, content.frame.size.height)
                           inView:view
         permittedArrowDirections:0
                         animated:animated];

}



@end
