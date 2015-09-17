//
//  PxpFilterFootballTabViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-06.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterFootballTabViewController.h"
#import "Tag.h"
#import "UserCenter.h"
#import "PxpFilterButtonGroupController.h"

@interface PxpFilterFootballTabViewController (){
}

@end

@implementation PxpFilterFootballTabViewController{
    BOOL    _isTelestrationActive;
    NSArray * _prefilterTagNames;
}

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Football";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        _isTelestrationActive = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTelestationFilterButton:) name:NOTIF_ENABLE_TELE_FILTER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTelestationFilterButton:) name:NOTIF_DISABLE_TELE_FILTER object:nil];

    }
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.unfilteredTags.count];
}


-(void)toggleTelestationFilterButton:(NSNotification*)note
{
    _isTelestrationActive = ([note.name isEqualToString:NOTIF_ENABLE_TELE_FILTER])?YES:NO;
    self.telestrationButton.enabled = _isTelestrationActive;
}

-(NSArray*)buttonGroupView{
    PxpFilterButtonGroupController *quarterGroupController = [[PxpFilterButtonGroupController alloc]init];
    [quarterGroupController addButtonToGroup:_quarter1];
    [quarterGroupController addButtonToGroup:_quarter2];
    [quarterGroupController addButtonToGroup:_quarter3];
    [quarterGroupController addButtonToGroup:_quarter4];
    quarterGroupController.displayAllTagIfAllFilterOn = true;
    
    PxpFilterButtonGroupController *lineGroupController = [[PxpFilterButtonGroupController alloc]init];
    [lineGroupController addButtonToGroup:_offenseDown1];
    [lineGroupController addButtonToGroup:_offenseDown2];
    [lineGroupController addButtonToGroup:_offenseDown3];
    [lineGroupController addButtonToGroup:_defenseDown1];
    [lineGroupController addButtonToGroup:_defenseDown2];
    [lineGroupController addButtonToGroup:_defenseDown3];
    lineGroupController.displayAllTagIfAllFilterOn = false;
    
    PxpFilterButtonGroupController *typeGroupController = [[PxpFilterButtonGroupController alloc]init];
    [typeGroupController addButtonToGroup:_passTypeButton];
    [typeGroupController addButtonToGroup:_runTypeButton];
    [typeGroupController addButtonToGroup:_kickTypeButton];
    typeGroupController.displayAllTagIfAllFilterOn = false;
    
    NSArray *array = @[quarterGroupController,lineGroupController,typeGroupController];
    return array;
}

-(void)buttonPredicate{
    NSPredicate *quarter1Predicate = [NSPredicate predicateWithFormat:@"period == %@", _quarter1.accessibilityLabel? _quarter1.accessibilityLabel:_quarter1.titleLabel.text];
    _quarter1.ownPredicate = quarter1Predicate;
     NSPredicate *quarter2Predicate = [NSPredicate predicateWithFormat:@"period == %@", _quarter2.accessibilityLabel? _quarter2.accessibilityLabel:_quarter2.titleLabel.text];
    _quarter2.ownPredicate = quarter2Predicate;
     NSPredicate *quarter3Predicate = [NSPredicate predicateWithFormat:@"period == %@", _quarter3.accessibilityLabel? _quarter3.accessibilityLabel:_quarter3.titleLabel.text];
    _quarter3.ownPredicate = quarter3Predicate;
     NSPredicate *quarter4Predicate = [NSPredicate predicateWithFormat:@"period == %@", _quarter4.accessibilityLabel? _quarter4.accessibilityLabel:_quarter4.titleLabel.text];
    _quarter4.ownPredicate = quarter4Predicate;
    
    NSPredicate *offenseDown1Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"o"] && [words[3] isEqualToString:@"1"]);
    }];
    _offenseDown1.ownPredicate = offenseDown1Predicate;
    NSPredicate *offenseDown2Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"o"] && [words[3] isEqualToString:@"2"]);
    }];
    _offenseDown2.ownPredicate = offenseDown2Predicate;
    NSPredicate *offenseDown3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"o"] && [words[3] isEqualToString:@"3"]);
    }];
    _offenseDown3.ownPredicate = offenseDown3Predicate;
    
    NSPredicate *defenseDown1Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"d"] && [words[3] isEqualToString:@"1"]);
    }];
    _defenseDown1.ownPredicate = defenseDown1Predicate;
    NSPredicate *defenseDown2Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"d"] && [words[3] isEqualToString:@"2"]);
    }];
    _defenseDown2.ownPredicate = defenseDown2Predicate;
    NSPredicate *defenseDown3Predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *line = tag.extraDic[@"line"];
        NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        return ([words[2] isEqualToString:@"d"] && [words[3] isEqualToString:@"3"]);
    }];
    _defenseDown3.ownPredicate = defenseDown3Predicate;
    
    NSPredicate *runTypePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *type = tag.extraDic[@"type"];
        return ([type isEqualToString:@"Run"]);
    }];
    _runTypeButton.ownPredicate = runTypePredicate;
    NSPredicate *passTypePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *type = tag.extraDic[@"type"];
        return ([type isEqualToString:@"Pass"]);
    }];
    _passTypeButton.ownPredicate = passTypePredicate;
    NSPredicate *kickTypePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Tag *tag = evaluatedObject;
        NSString *type = tag.extraDic[@"type"];
        return ([type isEqualToString:@"Kick"]);
    }];
    _kickTypeButton.ownPredicate = kickTypePredicate;
}

-(void)onUserInput:(id)inputObject{
    PxpFilterButtonScrollView * sender = (PxpFilterButtonScrollView *)inputObject;
    
    if (sender == _playersScrollView) {
        sender.predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Tag * tag = (Tag *)evaluatedObject;
            for (UIButton * button in sender.userSelected) {
                if ([tag.players containsObject:button.titleLabel.text]){
                    return YES;
                }
            }
            return NO;
        }];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buttonPredicate];
    NSArray *groupViews = [self buttonGroupView];
    
    self.modules = [[NSMutableArray alloc]initWithArray:@[
                                                          _tagNameScrollView,
                                                          _sliderView,
                                                          _favoriteButton,
                                                          _userButton,
                                                          groupViews[0],
                                                          groupViews[1],
                                                          groupViews[2],
                                                          _telestrationButton,
                                                          _playersScrollView
                                                          ]];
    
    _tagNameScrollView.sortByPropertyKey = @"name";
    _tagNameScrollView.buttonSize = CGSizeMake(130, 30);
    
    _playersScrollView.sortByPropertyKey      = @"players";
    _playersScrollView.displayAllTagIfAllFilterOn = NO;
    _playersScrollView.style                  = PxpFilterButtonScrollViewStylePortrate;
    _playersScrollView.buttonSize             = CGSizeMake(40, 40);
    _playersScrollView.filterModuleDelegate   = self;
    
    _preFilterSwitch.onTintColor            = PRIMARY_APP_COLOR;
    _preFilterSwitch.tintColor              = PRIMARY_APP_COLOR;
    [_preFilterSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    _sliderView.sortByPropertyKey = @"time";
    
    _favoriteButton.filterPropertyKey       = @"coachPick";
    _favoriteButton.filterPropertyValue     = @"1";
    
    _telestrationButton.enabled = _isTelestrationActive;
    _telestrationButton.titleLabel.text     = @"";
    [ _telestrationButton setPredicateToUse:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Tag * t =   (Tag *) evaluatedObject;
        return (t.type == TagTypeTele);
    }]];
    [_telestrationButton setTitle:@"" forState:UIControlStateNormal];
    [_telestrationButton setBackgroundImage:[[UIImage imageNamed:@"telestrationIconOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_telestrationButton setTitle:@"" forState:UIControlStateSelected];
    [_telestrationButton setBackgroundImage:[[UIImage imageNamed:@"telestrationIconOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    
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
    NSMutableSet            * tempPlayerSet = [[NSMutableSet alloc]init];
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
        
        // build players
        if (tag.players){
            [tempPlayerSet addObjectsFromArray:tag.players];
        }
    }
    
    
    // This is so that if  user changes that it reflects
    NSMutableSet * temp = [NSMutableSet new];
    for (NSDictionary * d in [UserCenter getInstance].tagNames) {
        
        if (![[d[@"name"] substringToIndex:1] isEqualToString:@"-"]) {
            [temp addObject:d[@"name"]];
        }
    }
    _prefilterTagNames = [temp allObjects];
    
    
    NSArray * playerList = [[tempPlayerSet allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return (NSComparisonResult) [obj1 integerValue] - [obj2 integerValue];
    }];
    
    [_playersScrollView buildButtonsWith:playerList];
    
    
    [_tagNameScrollView buildButtonsWith:([_preFilterSwitch isOn])?_prefilterTagNames :[tempSet allObjects]];
    [_sliderView setEndTime:latestTagTime];
    [_userButton buildButtonsWith:[userDatadict allValues]];
    
    
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
    _tagNameScrollView.modified = true;
    [self refreshUI];
}

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
