//
//  TwoButton&Toggo.m
//  Setting
//
//  Created by dev on 2015-01-06.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import "SwipeableTableViewCell.h"

static CGFloat const kBounceValue = 10.0f;

@interface SwipeableTableViewCell() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;

@end

NS_OPTIONS(NSInteger, style){
    toggleIsThere = 1<<0,
    toggleIsOn = 1<<1,
    listIsOn = 1<<2,
    oneButton = 1<<3,
    secondButton = 1<<4
};

@implementation SwipeableTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Adding the button1 programatically
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button1 addTarget:self
                    action:@selector(buttonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        [button1 setTitle:@"Button1" forState:UIControlStateNormal];
        button1.frame = CGRectMake(self.frame.size.width - 60, 0, 60, self.frame.size.height);
        button1.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.35];
        button1.tintColor = [UIColor whiteColor];
        [self.contentView addSubview:button1];
        self.button1 = button1;
        
        //Adding the button2 programatically
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button2 addTarget:self
                    action:@selector(buttonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        [button2 setTitle:@"Button2" forState:UIControlStateNormal];
        button2.frame = CGRectMake(self.frame.size.width - 120, 0, 60, self.frame.size.height);
        button2.backgroundColor =[UIColor colorWithRed:0.95 green:0.01 blue:0.01 alpha:0.75];
        button2.tintColor = [UIColor whiteColor];
        [self.contentView addSubview:button2];
        self.button2 = button2;
        
        
        
        //Adding a simple view
        UIView *anExtraView = [UIView new];
        anExtraView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:anExtraView];
        self.myContentView = anExtraView;
        
        // Adding the toggoButton programatically
        CGRect frame = CGRectMake(250, 6, 10, 10);
        UISwitch *addingSwitch = [[UISwitch alloc]initWithFrame:frame];
        [addingSwitch addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventValueChanged];
        [self.myContentView addSubview:addingSwitch];
        self.toggoButton = addingSwitch;
        self.toggoButton.hidden = YES;
        
        // Adding the Label programatically
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
        newLabel.font = [ UIFont fontWithName: @"Comic Sans" size: 18.0 ];
        [self.myContentView addSubview:newLabel];
        self.myTextLabel = newLabel;
        self.myTextLabel.font = [ UIFont fontWithName: @"Comic Sans" size: 18.0 ];
        
        //Adding the button2 programatically
        BorderlessButton *functionalityButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
        [functionalityButton addTarget:self
                    action:@selector(functionalButtonClicked)
          forControlEvents:UIControlEventTouchUpInside];
        functionalityButton.frame = CGRectMake(self.myContentView.frame.size.width - 120, 0, 60, self.myContentView.frame.size.height);
        [functionalityButton.titleLabel setTextAlignment: NSTextAlignmentRight];
        [functionalityButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        //button2.backgroundColor =[UIColor colorWithRed:0.95 green:0.01 blue:0.01 alpha:0.75];
        //button2.tintColor = [UIColor whiteColor];
        [self.myContentView addSubview: functionalityButton];
        self.functionalButton = functionalityButton;

        
        // Simple updates to the cell
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray *theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
        [self.contentView addConstraints: theConstraints];
        self.contentViewLeftConstraint = theConstraints[0];
        self.contentViewRightConstraint = theConstraints[1];
        
        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *theConstraintsAgain = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
        [self.contentView addConstraints: theConstraintsAgain];
        
        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        
    }
    return self;
}

//
//
//-(instancetype) initForSettingsTableViewController{
//    self = [super init];
//    if (self){
//       
//        //Adding the button1 programatically
//        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [button1 addTarget:self
//                    action:@selector(buttonClicked:)
//          forControlEvents:UIControlEventTouchUpInside];
//        [button1 setTitle:@"Button1" forState:UIControlStateNormal];
//        button1.frame = CGRectMake(self.frame.size.width - 60, 0, 60, self.frame.size.height);
//        button1.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.35];
//        button1.tintColor = [UIColor whiteColor];
//        [self.contentView addSubview:button1];
//        self.button1 = button1;
//    
//        //Adding the button2 programatically
//        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [button2 addTarget:self
//                    action:@selector(buttonClicked:)
//          forControlEvents:UIControlEventTouchUpInside];
//        [button2 setTitle:@"Button2" forState:UIControlStateNormal];
//        button2.frame = CGRectMake(self.frame.size.width - 120, 0, 60, self.frame.size.height);
//        button2.backgroundColor =[UIColor colorWithRed:0.95 green:0.01 blue:0.01 alpha:0.75];
//        button2.tintColor = [UIColor whiteColor];
//        [self.contentView addSubview:button2];
//        self.button2 = button2;
//    
//        //Adding a simple view
//        UIView *anExtraView = [UIView new];
//        anExtraView.backgroundColor = [UIColor whiteColor];
//        [self.contentView addSubview:anExtraView];
//        self.myContentView = anExtraView;
//    
//        // Adding the toggoButton programatically
//        CGRect frame = CGRectMake(250, 6, 10, 10);
//        UISwitch *addingSwitch = [[UISwitch alloc]initWithFrame:frame];
//        [addingSwitch addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventValueChanged];
//        [self.myContentView addSubview:addingSwitch];
//        self.toggoButton = addingSwitch;
//    
//        // Adding the Label programatically
//        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
//        newLabel.font = [ UIFont fontWithName: @"Comic Sans" size: 18.0 ];
//        [self.myContentView addSubview:newLabel];
//        self.myTextLabel = newLabel;
//        self.myTextLabel.font = [ UIFont fontWithName: @"Comic Sans" size: 18.0 ];
//    
//        // Simple updates to the cell
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        NSArray *theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
//        [self.contentView addConstraints: theConstraints];
//        self.contentViewLeftConstraint = theConstraints[0];
//        self.contentViewRightConstraint = theConstraints[1];
//        
//        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        NSArray *theConstraintsAgain = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
//        [self.contentView addConstraints: theConstraintsAgain];
//
//        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    }
//    
//    
//    return self;
//}
//
////- (NSDictionary *) cellInfoDictionary{
////    NSDictionary *returnDict = @{ @"Setting Label": self.itemText, @"OptionChar": [NSNumber numberWithChar:<#(char)#>]
////}
//
//-(instancetype) initForDetailController{
//    self = [super init];
//    if (self){
//        // Adding the Label programatically
//        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, self.frame.size.height)];
//        [self.contentView addSubview:newLabel];
//        self.myTextLabel = newLabel;
//        self.myTextLabel.font = [ UIFont fontWithName: @"Comic Sans" size: 18.0 ];
//        
//        // Simple updates to the cell
//        self.selectionStyle = UITableViewCellSelectionStyleBlue;
//    }
//    return self;
//}

-(void) setFrame:(CGRect)frame{
    if(frame.size.width == 703.5){
        CGRect newFrame = frame;
        newFrame.origin.x = frame.origin.x + 15;
        newFrame.size.width = frame.size.width - 30;
        [super setFrame: newFrame];
    }else{
        [super setFrame:frame];
    }
    
    [self.toggoButton setFrame:CGRectMake(self.frame.size.width - 60, 6, 10, 10)];
    [self.button1 setFrame: CGRectMake(self.frame.size.width - 60, 0, 60, self.frame.size.height)];
    [self.button2 setFrame: CGRectMake(self.frame.size.width - 120, 0, 60, self.frame.size.height)];
    [self.functionalButton setFrame: CGRectMake(self.frame.size.width - 120, 0, 120, self.frame.size.height)];
    
}

-(void)setTintColor:(UIColor *)tintColor{
    [super setTintColor:tintColor];
    self.toggoButton.onTintColor = tintColor;
    self.toggoButton.tintColor = tintColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)buttonClicked:(id)sender {
    if (sender == self.button1) {
        // This is where the signal is passed to the Settings Table View Controller
        [self.delegate buttonOneActionForItemText: self.myTextLabel.text];
    } else if (sender == self.button2) {
        [self.delegate buttonTwoActionForItemText: self.myTextLabel.text];
    } else {
        NSLog(@"Clicked unknown button!");
    }
}

-(void)switchClicked:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        // This is where the signal is passed to the Settings Table View Controller
        [self.delegate switchStateSignal:YES fromCell:self];
    } else {
        [self.delegate switchStateSignal:NO fromCell: self];
    }
    
}

- (void)functionalButtonClicked{
    [self.delegate functionalButtonFromCell:self];
}


//- (void)setItemText:(NSString *)itemText {
//    //Update the instance variable
//    _itemText = itemText;
//    
//    //Set the text to the custom label.
//    self.myTextLabel.text = _itemText;
//}

-(void)prepareForReuse{
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.myTextLabel setTextColor:[UIColor blackColor]];
    self.toggoButton.hidden = YES;
    self.button1.hidden = YES;
    self.button2.hidden = YES;
    
    self.functionalButton.enabled = YES;
    self.functionalButton.hidden = YES;

}

#pragma mark - Swiping functionality

- (void)awakeFromNib {
    [super awakeFromNib];
    self.swipeRecognizer =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myContentView addGestureRecognizer:self.swipeRecognizer];

}


- (void)panThisCell:(UISwipeGestureRecognizer *)recognizer {
    recognizer.direction = self.swipeRecognizer.direction;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizer];
        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.myContentView addGestureRecognizer:self.swipeRecognizer];
    }
    else
    {
        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizer];
        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.myContentView addGestureRecognizer:self.swipeRecognizer];
    }

}


- (CGFloat)buttonTotalWidth {
    if(self.button2.hidden){
        return CGRectGetWidth(self.frame) - CGRectGetMaxX(self.button2.frame);
    }else{
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.button2.frame);
    }
}


- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}


- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{

    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
 
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {

            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}


- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}




@end
