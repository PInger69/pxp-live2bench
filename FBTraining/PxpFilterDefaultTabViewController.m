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

    NSArray * _prefilterTagNames;
}
@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Default";
        tabImage =  [UIImage imageNamed:@"filter"];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
        
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.unfilteredTags.count];
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
    _telestrationButton.filterPropertyKey   = @"type";
    _telestrationButton.filterPropertyValue = @"4";
//    [_telestrationButton setBackgroundImage:@"" forState:UIControlStateNormal];
//    [_telestrationButton setBackgroundImage:@"" forState:UIControlStateSelected];
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

    

    [_leftScrollView buildButtonsWith:([_preFilterSwitch isOn])?_prefilterTagNames :[tempSet allObjects]];
    [_sliderView setEndTime:latestTagTime];
    [_ratingButtons buildButtons];// Has to be what was selected last
    [_userButtons buildButtonsWith:[userDatadict allValues]];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
