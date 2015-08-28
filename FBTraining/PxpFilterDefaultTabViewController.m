//
//  ViewController.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import "PxpFilterDefaultTabViewController.h"
#import "Tag.h"
#import "UserCenter.h"
@interface PxpFilterDefaultTabViewController ()


@end

@implementation PxpFilterDefaultTabViewController
{
    BOOL    _isTelestrationActive;
    NSArray * _prefilterTagNames;
}
@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Default";
        tabImage =  [UIImage imageNamed:@"filter"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modules = [[NSMutableArray alloc]initWithArray:@[
                                                          _leftScrollView
                                                          ,_sliderView
                                                          ,_userButtons
                                                          ,_ratingButtons
                                                          ,_userInputView
                                                          ,_favoriteButton
                                                          ,_telestrationButton
                                                          ]
                    ];
    
    

    _leftScrollView.sortByPropertyKey       = @"name";
    _leftScrollView.buttonSize              = CGSizeMake(130, 30);
    _sliderView.sortByPropertyKey           = @"time";
    _preFilterSwitch.onTintColor            = PRIMARY_APP_COLOR;
    _preFilterSwitch.tintColor              = PRIMARY_APP_COLOR;
    [_userInputView loadView];
    [_preFilterSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    _favoriteButton.filterPropertyKey       = @"coachPick";
    _favoriteButton.filterPropertyValue     = @"1";
    
    _telestrationButton.titleLabel.text     = @"";
    [ _telestrationButton setPredicateToUse:[NSPredicate predicateWithBlock:^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings) {
        Tag * t =   (Tag *) evaluatedObject;
        return (t.type == TagTypeTele);
    }]];

    _telestrationButton.enabled = _isTelestrationActive;
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

- (void)show{

    [_sliderView show];
    [self refreshUI];
}
- (void)hide{
    [_sliderView hide];
}

-(void)refreshUI
{
    NSLog(@"1");
    NSArray                 * rawTags       = self.pxpFilter.unfilteredTags;
    NSMutableSet            * tempSet       = [[NSMutableSet alloc]init];
    NSMutableDictionary     * userDatadict  = [[NSMutableDictionary alloc]init];
    NSInteger               latestTagTime = 0;
    
    
    NSLog(@"11");
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

    NSLog(@"12");
    
    // This is so that if  user changes that it reflects
        NSMutableSet * temp = [NSMutableSet new];
        for (NSDictionary * d in [UserCenter getInstance].tagNames) {

            if (![[d[@"name"] substringToIndex:1] isEqualToString:@"-"]) {
                [temp addObject:d[@"name"]];
            }
        }
        _prefilterTagNames = [temp allObjects];

    NSLog(@"13");

    [_leftScrollView buildButtonsWith:([_preFilterSwitch isOn])?_prefilterTagNames :[tempSet allObjects]];
    [_sliderView setEndTime:latestTagTime];
    [_ratingButtons buildButtons];// Has to be what was selected last
    [_userButtons buildButtonsWith:[userDatadict allValues]];
    NSLog(@"14");
    // Do any additional setup after loading the view from its nib
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.unfilteredTags.count];
    NSLog(@"2");
    [self.pxpFilter refresh];
        NSLog(@"3");
}


- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
    [self refreshUI];
}

- (void) switchToggled:(id)sender {
     _leftScrollView.modified = true;
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
