//
//  PxpFilterMyClipTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterMyClipTabViewController.h"
#import "Clip.h"
@implementation PxpFilterMyClipTabViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Default";
       self.tabImage =  [UIImage imageNamed:@"filter"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    if (filter != self.pxpFilter) return ;
    
    _filteredTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)filter.unfilteredTags.count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modules = [[NSMutableArray alloc]initWithArray:@[
                                                          _eventScrollView
                                                          ,_teamsScrollView
                                                          ,_playersScrollView
                                                          ,_dateScrollView
                                                          ,_ratingButtons

//                                                          ,_favoriteButton

                                                          ]
                    ];
    
    
    
    _eventScrollView.sortByPropertyKey        = @"name";
    _eventScrollView.style                    = PxpFilterButtonScrollViewStylePortrate;
    _eventScrollView.buttonSize               = CGSizeMake(_eventScrollView.frame.size.width, 40);
    
    _teamsScrollView.sortByPropertyKey        = @"teams";
    _teamsScrollView.style                    = PxpFilterButtonScrollViewStylePortrate;
    _teamsScrollView.buttonSize               = CGSizeMake(_teamsScrollView.frame.size.width, 40);
    
    _playersScrollView.sortByPropertyKey      = @"players";
    _playersScrollView.style                  = PxpFilterButtonScrollViewStylePortrate;
    _playersScrollView.buttonSize             = CGSizeMake(40, 40);
    
    
    _dateScrollView.sortByPropertyKey       = @"date";
    _dateScrollView.buttonSize              = CGSizeMake(_dateScrollView.frame.size.width, 40);
    
    
//    _favoriteButton.filterPropertyKey       = @"coachPick";
//    _favoriteButton.filterPropertyValue     = @"1";
    
  [_ratingButtons buildButtons];// Has to be what was selected last

    _teamsScrollView.predicate = [NSPredicate predicateWithBlock:^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings) {
                Clip * t =   (Clip *) evaluatedObject;
                return (t.type == TagTypeTele);
    }];
    



}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUI];
}

- (void)show{

    [self refreshUI];
}
- (void)hide{
 
}

-(void)refreshUI
{
    NSArray                 * rawTags           = self.pxpFilter.unfilteredTags;
    NSMutableSet            * tempSet           = [[NSMutableSet alloc]init];
    NSMutableSet            * tempDateSet       = [[NSMutableSet alloc]init];
    NSMutableSet            * tempTeamSet       = [[NSMutableSet alloc]init];
    NSMutableSet            * tempPlayerSet     = [[NSMutableSet alloc]init];

    
    for (Clip * clip in rawTags) {
        
        // build tag names
        [tempSet addObject:clip.name];
        [tempDateSet addObject:[Utility dateFromEvent: clip.eventName]];
        if (![clip.homeTeam isEqualToString:@""] && ![clip.visitTeam isEqualToString:@""]){
            [tempTeamSet addObject:[NSString stringWithFormat:@"%@ VS %@",clip.homeTeam,clip.visitTeam]];
        }
        
        if (clip.players){
            [tempPlayerSet addObjectsFromArray:clip.players];
        }
        
    }
    
    
    // This is so that if  user changes that it reflects
//    NSMutableSet * temp = [NSMutableSet new];
//    for (NSDictionary * d in [UserCenter getInstance].tagNames) {
//        
//        if (![[d[@"name"] substringToIndex:1] isEqualToString:@"-"]) {
//            [temp addObject:d[@"name"]];
//        }
//    }
//    _prefilterTagNames = [temp allObjects];
//    
//    
//
    
    // @"eventName"
    
        [_eventScrollView buildButtonsWith:[[tempSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [_dateScrollView buildButtonsWith:[[tempDateSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [_teamsScrollView buildButtonsWith:[[tempTeamSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [_playersScrollView buildButtonsWith:[[tempPlayerSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
////    [_leftScrollView buildButtonsWith:([_preFilterSwitch isOn])?_prefilterTagNames :[tempSet allObjects]];
//    [_sliderView setEndTime:latestTagTime];
//    [_ratingButtons buildButtons];// Has to be what was selected last
//    [_userButtons buildButtonsWith:[userDatadict allValues]];
//    
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


@end
