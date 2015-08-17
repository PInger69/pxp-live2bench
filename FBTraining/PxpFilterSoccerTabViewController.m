//
//  PxpFilterSoccerTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterSoccerTabViewController.h"
#import "Tag.h"
#import "UserCenter.h"
#import "PxpFilterButtonGroupController.h"

@interface PxpFilterSoccerTabViewController ()

@end

@implementation PxpFilterSoccerTabViewController{
     NSArray * _prefilterTagNames;
}

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Soccer";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.unfilteredTags.count];
}

-(NSArray*)buttonGroupView{
    PxpFilterButtonGroupController *halfGroupController = [[PxpFilterButtonGroupController alloc]init];
    [halfGroupController addButtonToGroup:_half1];
    [halfGroupController addButtonToGroup:_half2];
    [halfGroupController addButtonToGroup:_halfExtra];
    [halfGroupController addButtonToGroup:_halfPS];
    
    PxpFilterButtonGroupController *zoneGroupController = [[PxpFilterButtonGroupController alloc]init];
    [zoneGroupController addButtonToGroup:_zoneOFF];
    [zoneGroupController addButtonToGroup:_zoneMID];
    [zoneGroupController addButtonToGroup:_zoneDEF];
    
    NSArray *array = @[halfGroupController,zoneGroupController];
    return array;
}

-(void)buttonPredicate{
    NSPredicate *half1Predicate = [NSPredicate predicateWithFormat:@"period == %@", _half1.accessibilityLabel? _half1.accessibilityLabel:_half1.titleLabel.text];
    _half1.ownPredicate = half1Predicate;
    NSPredicate *half2Predicate = [NSPredicate predicateWithFormat:@"period == %@", _half2.accessibilityLabel? _half2.accessibilityLabel:_half2.titleLabel.text];
    _half2.ownPredicate = half2Predicate;
    NSPredicate *halfPSPredicate = [NSPredicate predicateWithFormat:@"period == %@", _halfPS.accessibilityLabel? _halfPS.accessibilityLabel:_halfPS.titleLabel.text];
    _halfPS.ownPredicate = halfPSPredicate;
    NSPredicate *halfExtraPredicate = [NSPredicate predicateWithFormat:@"period == %@", _halfExtra.accessibilityLabel? _halfExtra.accessibilityLabel:_halfExtra.titleLabel.text];
    _halfExtra.ownPredicate = halfExtraPredicate;
    
    NSPredicate *zoneOFFPredicate = [NSPredicate predicateWithFormat:@"name == %@",_zoneOFF.accessibilityLabel? _zoneOFF.accessibilityLabel:_zoneOFF.titleLabel.text];
    _zoneOFF.ownPredicate = zoneOFFPredicate;
    NSPredicate *zoneMIDPredicate = [NSPredicate predicateWithFormat:@"name == %@",_zoneMID.accessibilityLabel? _zoneMID.accessibilityLabel:_zoneMID.titleLabel.text];
    _zoneMID.ownPredicate = zoneMIDPredicate;
    NSPredicate *zoneDEFPredicate = [NSPredicate predicateWithFormat:@"name == %@",_zoneDEF.accessibilityLabel? _zoneDEF.accessibilityLabel:_zoneDEF.titleLabel.text];
    _zoneDEF.ownPredicate = zoneDEFPredicate;
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
    [ _telestrationButton setPredicateToUse:[NSPredicate predicateWithBlock:^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings) {
        Tag * t =   (Tag *) evaluatedObject;
        return (t.type == TagTypeTele);
    }]];
    [_telestrationButton setTitle:@"" forState:UIControlStateNormal];
    [_telestrationButton setBackgroundImage:[UIImage imageNamed:@"telestrationIconOff"] forState:UIControlStateNormal];
    [_telestrationButton setTitle:@"" forState:UIControlStateSelected];
    [_telestrationButton setBackgroundImage:[UIImage imageNamed:@"telestrationIconOn"] forState:UIControlStateSelected];
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
