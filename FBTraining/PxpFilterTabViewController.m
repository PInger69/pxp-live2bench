//
//  ViewController.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import "PxpFilterTabViewController.h"
#import "Tag.h"

@interface PxpFilterTabViewController ()


@end

@implementation PxpFilterTabViewController

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"VC1";
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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modules = [[NSMutableArray alloc]initWithObjects:
                    _rightScrollView,_middleScrollView,_leftScrollView,_sliderView,_userButtons, nil];
    
    
    _middleScrollView.sortByPropertyKey     = @"name";
    _rightScrollView.sortByPropertyKey      = @"name";
    _leftScrollView.sortByPropertyKey       = @"name";
    _sliderView.sortByPropertyKey           = @"time";
    
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

    
    [_rightScrollView buildButtonsWith:[tempSet allObjects]];
    [_middleScrollView buildButtonsWith:@[@"none"]];
    [_leftScrollView buildButtonsWith:@[@"none"]];
    [_sliderView setEndTime:latestTagTime+1];
    
    


    [_userButtons buildButtonsWith:[userDatadict allValues]];
    
    // Do any additional setup after loading the view from its nib
    _filteredTagLabel.text = [NSString stringWithFormat:@"Filtered Tag(s): %lu",(unsigned long)self.pxpFilter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"Total Tag(s): %lu",(unsigned long)self.pxpFilter.unfilteredTags.count];


}





- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
    [self refreshUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
