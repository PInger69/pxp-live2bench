//
//  CommentingField.m
//  QuickTest
//
//  Created by dev on 6/13/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "CommentingField.h"
#import "UIFont+Default.h" // should this be added to the common file
#import "BorderButton.h"

#define BORDER_COLOR [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f]
#define DISABLE_ALPHA           0.5f
#define DEFALT_BUTTON_WIDTH     50
#define DEFALT_BUTTON_HEIGHT    30


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation CommentingField
{
    CGRect thisFrame;
    SEL onSaveSelector;
    SEL onClearSelector;
    id clearTarget;
    id saveTarget;
}


@synthesize fieldTitle;
@synthesize textField;
@synthesize saveButton;
@synthesize clearButton;
@synthesize saveMessage;
@synthesize enabled;
@synthesize title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        thisFrame = frame;
        self.title = @"";
        [self initComponents];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame title:(NSString *)titleName
{
    self = [super initWithFrame:frame];
    if (self) {
        thisFrame = frame;
        self.title = titleName;
        [self initComponents];
    }
    return self;
}

-(void)initComponents
{
    enabled = TRUE;
    
    CGRect textViewFrame =CGRectMake(0, 0, thisFrame.size.width, thisFrame.size.height-DEFALT_BUTTON_HEIGHT -5);
    
    textField = [[UITextView alloc] initWithFrame:textViewFrame];
    textField.layer.borderColor = BORDER_COLOR.CGColor;
    textField.layer.borderWidth = 1;
    textField.text = @"";
    [textField setFont:[UIFont defaultFontOfSize:18.0f]];
    //    [textField setDelegate:]; // the delegate is the parent
    [self addSubview:textField];
    
    // Setting up labels
    fieldTitle =[[UILabel alloc]initWithFrame:CGRectMake(thisFrame.size.width/2 - 75, textViewFrame.size.height+5, 130, 25)];
    [fieldTitle setText:title];
    [fieldTitle setFont:[UIFont defaultFontOfSize:18.0f]];
    [fieldTitle setTextColor:[UIColor colorWithRed:0.224 green:0.224 blue:0.224 alpha:1.0]];
    [fieldTitle setBackgroundColor:[UIColor clearColor]];
    [self addSubview:fieldTitle];
    
    saveMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textViewFrame.size.width, 25)];
    saveMessage.center = textField.center;
    [saveMessage setText: [NSString stringWithFormat:@"%@ %@",title, @"was saved!"]];
    [saveMessage setFont:[UIFont defaultFontOfSize:18.0f]];
    [saveMessage setTextColor:PRIMARY_APP_COLOR];
    [saveMessage setBackgroundColor:[UIColor clearColor]];
    [saveMessage setTextAlignment:NSTextAlignmentCenter];
    [saveMessage setHidden:TRUE];
    [self addSubview:saveMessage];
    
    
    // Setting up buttons
    saveButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(thisFrame.size.width - DEFALT_BUTTON_WIDTH -5, textViewFrame.size.height+5, DEFALT_BUTTON_WIDTH, DEFALT_BUTTON_HEIGHT)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];
    
    clearButton = [BorderButton  buttonWithType:UIButtonTypeCustom];
    [clearButton setFrame:CGRectMake(5, textViewFrame.size.height+5, DEFALT_BUTTON_WIDTH, DEFALT_BUTTON_HEIGHT)];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearButton];
    
    
    
}

/**
 *  This allows for aditional actions to be executed when the clear button is pressed
 *
 *  @param sel    method
 *  @param target object that contains the method
 */
-(void)onPressClearPerformSelector:(SEL)sel addTarget:(id)target
{
    clearTarget = target;
    onClearSelector = sel;
}



/**
 *  This allows for aditional actions to be executed when the save button is pressed. (like making tags)
 *
 *  @param sel    method
 *  @param target object that contains the method
 */
-(void)onPressSavePerformSelector:(SEL)sel addTarget:(id)target
{
    saveTarget = target;
    onSaveSelector = sel;
}


-(void)onClear:(id)sender{
    [self clear];
    if (onClearSelector){
        [clearTarget performSelector:onClearSelector withObject:self];
    }
}


-(void)onSave:(id)sender{
    if (onSaveSelector){
        [saveTarget performSelector:onSaveSelector withObject:self];
    }
    CustomButton *button = (CustomButton *)sender;
    [button resignFirstResponder];
    [textField setTextColor:[UIColor whiteColor]];
    textField.editable = NO;
    [saveMessage setHidden:FALSE];
    [self performSelector:@selector(hideMsgLabel:) withObject:saveMessage afterDelay:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Save in %@", self.context] object:self];
}

-(BOOL)enabled
{
    return enabled;
}

/**
 *  If set to NO/FALSE this will stop all tap events and alpha out the instance. Setting to YES/TRUE will enable all buttons and set alpha to f1.0
 *
 *  @param val Boolean
 */
-(void)setEnabled:(BOOL) val
{
    if (val && !enabled){
        [self setAlpha: 1.0f];
        [self setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
        [saveButton setUserInteractionEnabled:TRUE];
        [textField setUserInteractionEnabled:TRUE];
        [clearButton setUserInteractionEnabled:TRUE];
    } else if (!val && enabled) {
        [self setAlpha: DISABLE_ALPHA];
        [self setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
        [saveButton setUserInteractionEnabled:FALSE];
        [textField setUserInteractionEnabled:FALSE];
        [clearButton setUserInteractionEnabled:FALSE];
        [textField resignFirstResponder];
    }
    enabled = val;
}

/**
 *  This just clears the textfield, this does not save
 */
-(void)clear
{
    textField.text = @"";
}

-(void)setText:(NSString*)txt
{
    textField.text = txt;
}
-(NSString*)text
{
    return textField.text;
}


-(void)hideMsgLabel:(UILabel*)label{
    [label setHidden:TRUE];
    textField.editable = YES;
    [textField setTextColor:[UIColor blackColor]];
}


@end
