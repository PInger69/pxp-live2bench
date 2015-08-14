//
//  PxpFilterHockeyTabViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterHockeyTabViewController.h"
#import "Tag.h"
#import "UserCenter.h"
#import "PxpFilterButtonGroupController.h"

@interface PxpFilterHockeyTabViewController ()

@end

@implementation PxpFilterHockeyTabViewController{
    NSArray * _prefilterTagNames;
}

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Hockey";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"Filtered Tag(s): %lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"Total Tag(s): %lu",(unsigned long)filter.unfilteredTags.count];
}

-(NSArray*)buttonGroupView{
    PxpFilterButtonGroupController *periodGroupController = [[PxpFilterButtonGroupController alloc]init];
    [periodGroupController addButtonToGroup:_period1];
    [periodGroupController addButtonToGroup:_period2];
    [periodGroupController addButtonToGroup:_period3];
    [periodGroupController addButtonToGroup:_periodOT];
    [periodGroupController addButtonToGroup:_periodPS];
    
    PxpFilterButtonGroupController *lineGroupController = [[PxpFilterButtonGroupController alloc]init];
    [lineGroupController addButtonToGroup:_offenseLine1];
    [lineGroupController addButtonToGroup:_offenseLine2];
    [lineGroupController addButtonToGroup:_offenseLine3];
    [lineGroupController addButtonToGroup:_offenseLine4];
    [lineGroupController addButtonToGroup:_defenseLine1];
    [lineGroupController addButtonToGroup:_defenseLine2];
    [lineGroupController addButtonToGroup:_defenseLine3];
    [lineGroupController addButtonToGroup:_defenseLine4];
    [lineGroupController addButtonToGroup:_getAllStrengthTags];
    
    PxpFilterButtonGroupController *strengthGroupController = [[PxpFilterButtonGroupController alloc]init];
    [strengthGroupController addButtonToGroup:_homeStrength3];
    [strengthGroupController addButtonToGroup:_homeStrength4];
    [strengthGroupController addButtonToGroup:_homeStrength5];
    [strengthGroupController addButtonToGroup:_homeStrength6];
    [strengthGroupController addButtonToGroup:_awayStrength3];
    [strengthGroupController addButtonToGroup:_awayStrength4];
    [strengthGroupController addButtonToGroup:_awayStrength5];
    [strengthGroupController addButtonToGroup:_awayStrength6];
    
    NSArray *array = @[periodGroupController,lineGroupController,strengthGroupController];
    return array;
}

-(void)buttonPredicate{
    NSPredicate *period1Predicate = [NSPredicate predicateWithFormat:@"period == %@", _period1.accessibilityLabel? _period1.accessibilityLabel:_period1.titleLabel.text];
    _period1.ownPredicate = period1Predicate;
    NSPredicate *period2Predicate = [NSPredicate predicateWithFormat:@"period == %@", _period2.accessibilityLabel? _period2.accessibilityLabel:_period2.titleLabel.text];
    _period2.ownPredicate = period2Predicate;
    NSPredicate *period3Predicate = [NSPredicate predicateWithFormat:@"period == %@", _period3.accessibilityLabel? _period3.accessibilityLabel:_period3.titleLabel.text];
    _period3.ownPredicate = period3Predicate;
    NSPredicate *periodOTPredicate = [NSPredicate predicateWithFormat:@"period == %@", _periodOT.accessibilityLabel? _periodOT.accessibilityLabel:_periodOT.titleLabel.text];
    _periodOT.ownPredicate = periodOTPredicate;
    NSPredicate *periodPSPredicate = [NSPredicate predicateWithFormat:@"period == %@", _periodPS.accessibilityLabel? _periodPS.accessibilityLabel:_periodPS.titleLabel.text];
    _periodPS.ownPredicate = periodPSPredicate;
    
    NSPredicate *getAllStrengthTagsPredicate = [NSPredicate predicateWithFormat:@"type = %ld",TagTypeHockeyStrengthStop];
    _getAllStrengthTags.ownPredicate = getAllStrengthTagsPredicate;
    
    NSPredicate *offenseLine1Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppOLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"f"] && [words[2] isEqualToString:@"1"]);
        }
        return NO;
    }];
    _offenseLine1.ownPredicate = offenseLine1Predicate;
    NSPredicate *offenseLine2Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppOLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"f"] && [words[2] isEqualToString:@"2"]);
        }
        return NO;
    }];
    _offenseLine2.ownPredicate = offenseLine2Predicate;
    NSPredicate *offenseLine3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppOLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"f"] && [words[2] isEqualToString:@"3"]);
        }
        return NO;
    }];
    _offenseLine3.ownPredicate = offenseLine3Predicate;
    NSPredicate *offenseLine4Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppOLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"f"] && [words[2] isEqualToString:@"4"]);
        }
        return NO;
    }];
    _offenseLine4.ownPredicate = offenseLine4Predicate;
    
    
    NSPredicate *defenseLine1Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppDLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"d"] && [words[2] isEqualToString:@"1"]);
        }
        return NO;
    }];
    _defenseLine1.ownPredicate = defenseLine1Predicate;
    NSPredicate *defenseLine2Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppDLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"d"] && [words[2] isEqualToString:@"2"]);
        }
        return NO;
    }];
    _defenseLine2.ownPredicate = defenseLine2Predicate;
    NSPredicate *defenseLine3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppDLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"d"] && [words[2] isEqualToString:@"3"]);
        }
        return NO;
    }];
    _defenseLine3.ownPredicate = defenseLine3Predicate;
    NSPredicate *defenseLine4Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyOppDLineStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
            return ([words[1] isEqualToString:@"d"] && [words[2] isEqualToString:@"4"]);
        }
        return NO;
    }];
    _defenseLine4.ownPredicate = defenseLine4Predicate;

    
    NSPredicate *homeStrength3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[0] isEqualToString:@"3"]);
        }
        return NO;
    }];
    _homeStrength3.ownPredicate = homeStrength3Predicate;
    NSPredicate *homeStrength4Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[0] isEqualToString:@"4"]);
        }
        return NO;
    }];
    _homeStrength4.ownPredicate = homeStrength4Predicate;
    NSPredicate *homeStrength5Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[0] isEqualToString:@"5"]);
        }
        return NO;
    }];
    _homeStrength5.ownPredicate = homeStrength5Predicate;
    NSPredicate *homeStrength6Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[0] isEqualToString:@"6"]);
        }
        return NO;
    }];
    _homeStrength6.ownPredicate = homeStrength6Predicate;
    
    
    NSPredicate *awayStrength3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[1] isEqualToString:@"3"]);
        }
        return NO;
    }];
    _awayStrength3.ownPredicate = awayStrength3Predicate;
    NSPredicate *awayStrength4Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[1] isEqualToString:@"4"]);
        }
        return NO;
    }];
    _awayStrength4.ownPredicate = awayStrength4Predicate;
    NSPredicate *awayStrength5Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[1] isEqualToString:@"5"]);
        }
        return NO;
    }];
    _awayStrength5.ownPredicate = awayStrength5Predicate;
    NSPredicate *awayStrength6Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        if (tag.type == TagTypeHockeyStrengthStop) {
            NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            return ([words[1] isEqualToString:@"6"]);
        }
        return NO;
    }];
    _awayStrength6.ownPredicate = awayStrength6Predicate;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buttonPredicate];
    NSArray *groupViews = [self buttonGroupView];
    
    self.modules = [[NSMutableArray alloc]initWithArray:@[
                                                          _tagNameScrollView,
                                                          _sliderView,
                                                          groupViews[0],
                                                          groupViews[1],
                                                          groupViews[2],
                                                          _favoriteButton,
                                                          _telestrationButton
                                                          ]];
    
    _tagNameScrollView.sortByPropertyKey = @"name";
    _tagNameScrollView.buttonSize = CGSizeMake(130, 30);
    _preFilterSwitch.onTintColor            = PRIMARY_APP_COLOR;
    _preFilterSwitch.tintColor              = PRIMARY_APP_COLOR;
    [_preFilterSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    _sliderView.sortByPropertyKey = @"time";
    
    _favoriteButton.filterPropertyKey       = @"coachPick";
    _favoriteButton.filterPropertyValue     = @"1";
    
    _telestrationButton.titleLabel.text     = @"";
    _telestrationButton.filterPropertyKey   = @"type";
    _telestrationButton.filterPropertyValue = @"4";
    
    [_telestrationButton setTitle:@"" forState:UIControlStateNormal];
    [_telestrationButton setBackgroundImage:[UIImage imageNamed:@"telestrationIconOff"] forState:UIControlStateNormal];
    
    [_telestrationButton setTitle:@"" forState:UIControlStateSelected];
    [_telestrationButton setBackgroundImage:[UIImage imageNamed:@"telestrationIconOn"] forState:UIControlStateSelected];
  

    //    PxpFilter.rawTags; //NSMutableSet
    /*NSArray * rawTags;
     NSMutableSet * tempSet = [[NSMutableSet alloc]init];
     
     for (Tag * tag in rawTags) {
     [tempSet addObject:tag.name];
     }*/
    
    
    /*[_rightScrollView buildButtonsWith:[tempSet allObjects]];
    [_rightScrollView buildButtonsWith:@[@"ABC",@"CBA"]];
    _rightScrollView.sortByPropertyKey = @"name";
    [_middleScrollView buildButtonsWith:@[@"1",@"2",@"3",@"OT",@"PS"]];
    _middleScrollView.sortByPropertyKey = @"period";
    [_leftScrollView buildButtonsWith:@[@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4"]];
    _leftScrollView.sortByPropertyKey = @"name";
    
    self.modules = [[NSMutableArray alloc]initWithObjects:
                    _rightScrollView,_middleScrollView,_leftScrollView, nil]; // removed the slider
    
     _sliderView.sortByPropertyKey = @"time";
    
    
    
    [_sliderView setEndTime:(2000)];*/
    
    //Test RangeSlider
    
    // Do any additional setup after loading the view from its nib
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUI];
}

-(void)refreshUI
{
    
    NSArray                 * rawTags       = self.pxpFilter.unfilteredTags;
    NSMutableSet            * tempSet       = [[NSMutableSet alloc]init];
    NSMutableDictionary     * userDatadict  = [[NSMutableDictionary alloc]init];
    NSInteger               latestTagTime = 0;
    
    
    
    for (Tag * tag in rawTags) {
        
        // build tag names
        [tempSet addObject:tag.name];
        
        // build user data
        if (![userDatadict objectForKey:tag.user]) {
            [userDatadict setObject:@{@"user":tag.user,@"color":[ Utility colorWithHexString:tag.colour] } forKey:tag.user];
        }
        
        // build time
        NSInteger checkTime = tag.time;
        if (checkTime > latestTagTime) latestTagTime = checkTime;
    }
    
    
    // This is so that if  user changes that it reflects
    NSMutableSet * temp = [NSMutableSet new];
    for (NSDictionary * d in [UserCenter getInstance].tagNames) {
        
        if (![[d[@"name"] substringToIndex:1] isEqualToString:@"-"]) {
            [temp addObject:d[@"name"]];
        }
    }
    _prefilterTagNames = [temp allObjects];
    
    
    
    [_tagNameScrollView buildButtonsWith:([_preFilterSwitch isOn])?_prefilterTagNames :[tempSet allObjects]];
    [_sliderView setEndTime:latestTagTime];

    
    // Do any additional setup after loading the view from its nib
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.unfilteredTags.count];
    
    [self.pxpFilter refresh];
}
- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
    [self refreshUI];
}

- (void) switchToggled:(id)sender {
    [self refreshUI];
}

/*- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
}*/

- (void)show{
    [_sliderView show];
    [self refreshUI];
}
- (void)hide{
    [_sliderView hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
