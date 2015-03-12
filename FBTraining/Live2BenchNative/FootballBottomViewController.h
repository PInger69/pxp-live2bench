//
//  FootballBottomViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-08-14.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Globals.h"
#import "Live2BenchViewController.h"
#import "CustomButton.h"

@class Live2BenchViewController;
@interface FootballBottomViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

{
    UILabel *seriesLabel;
    UIPickerView *sTPickerView;
    UILabel *sTLabel;
    NSArray *specialTeamsArray;
    UILabel *teamSelectionLabel;
    
    UISlider *fieldPosSlider;
    UIPickerView *playCallOppPickerView;
    UIPickerView *playCallPickerView;
    NSMutableArray *playCallOppArray;
    NSMutableArray *playCallArray;
    UILabel *fieldPosSliderPos;
    
}


@property (nonatomic,strong) UIPickerView *playCallOppPickerView;
@property (nonatomic,strong) UIPickerView *playCallPickerView;
@property (nonatomic,strong) NSMutableArray *playCallOppArray;
@property (nonatomic,strong) NSMutableArray *playCallArray;
@property (strong, nonatomic) IBOutlet UIView *offLayoutView;
@property (strong, nonatomic) Live2BenchViewController *live2BenchViewController;
//@property (strong, nonatomic) Globals *globals;
@property (strong, nonatomic) CustomButton *offButton;
@property (strong, nonatomic) CustomButton *defButton;
@property (strong, nonatomic) CustomButton *stButton;
@property (strong, nonatomic) UIPickerView *seriesPickerView;
@property (strong, nonatomic) NSMutableArray *arrayOfQuarterButtons;
@property (strong, nonatomic) CustomButton *quarterButtonWasSelected;
@property (strong, nonatomic) NSMutableArray *arrayOfDownButtons;
@property (strong, nonatomic) CustomButton *downButtonWasSelected;
@property (strong, nonatomic) UIPickerView *distancePickerView;
@property (strong, nonatomic) UIPickerView *gainPickerView;
@property (strong, nonatomic) NSMutableArray *arrayOfActionButtons;
@property (strong, nonatomic) CustomButton *actionButtonWasSelected;
@property (strong, nonatomic) UIView *playcallEventsView;
@property (strong, nonatomic) UIView *playcallOppEventsView;
@property (nonatomic)int seriesNumber;
@property (nonatomic)int distanceNumber;
@property (nonatomic)int fieldNumber;
@property (nonatomic)int gainNumber;
@property (nonatomic)NSMutableArray *pickerViewDataArr;
@property (nonatomic)NSMutableArray *gainPickerViewDataArr;
@property (nonatomic,strong)NSMutableData *responseData;
@property (nonatomic)int selectedRowforSeries;
@property (nonatomic)int selectedRowforDistance;
@property (nonatomic)int selectedRowforField;
@property (nonatomic)int selectedRowforGain;
@property (nonatomic) CustomButton *stateButtonWasSelected;
@property (nonatomic) BOOL isNewTurn;
@property (nonatomic) BOOL isNextPlay;

- (id)initWithController:(Live2BenchViewController *)fv;

@end
