//
//  PxpFilterCFLTabController.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-01.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpFilterCFLTabController.h"
#import "Tag.h"
#import "UserCenter.h"
#import "PxpFilterButtonGroupController.h"
@interface PxpFilterCFLTabController ()

@end

@implementation PxpFilterCFLTabController
{
    BOOL    _isTelestrationActive;
    NSArray * _prefilterTagNames;
}
@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"CFL";
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
    PxpFilterButtonGroupController *halfGroupController = [[PxpFilterButtonGroupController alloc]init];
    [halfGroupController addButtonToGroup:_p1];
    [halfGroupController addButtonToGroup:_p2];
    [halfGroupController addButtonToGroup:_p3];
    [halfGroupController addButtonToGroup:_p4];
    halfGroupController.displayAllTagIfAllFilterOn = true;
    

    NSArray *array = @[halfGroupController];
    return array;
}

-(void)buttonPredicate{
    NSPredicate *half1Predicate = [NSPredicate predicateWithFormat:@"period == %@", _p1.accessibilityLabel? _p1.accessibilityLabel:_p1.titleLabel.text];
    _p1.ownPredicate = half1Predicate;
    NSPredicate *half2Predicate = [NSPredicate predicateWithFormat:@"period == %@", _p2.accessibilityLabel? _p2.accessibilityLabel:_p2.titleLabel.text];
    _p2.ownPredicate = half2Predicate;
    NSPredicate *halfPSPredicate = [NSPredicate predicateWithFormat:@"period == %@", _p3.accessibilityLabel? _p3.accessibilityLabel:_p3.titleLabel.text];
    _p3.ownPredicate = halfPSPredicate;
    NSPredicate *halfExtraPredicate = [NSPredicate predicateWithFormat:@"period == %@", _p4.accessibilityLabel? _p4.accessibilityLabel:_p4.titleLabel.text];
    _p4.ownPredicate = halfExtraPredicate;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
