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
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil tabImage:[UIImage imageNamed:@"filter"]];
    if (self) {
        self.title = @"Default";
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

                                                          ]];
    
    
    
    _eventScrollView.sortByPropertyKey        = @"name";
    _eventScrollView.style                    = PxpFilterButtonScrollViewStylePortrate;
    _eventScrollView.buttonSize               = CGSizeMake(_eventScrollView.frame.size.width, 40);
    
    _teamsScrollView.sortByPropertyKey        = @"teams";
    _teamsScrollView.style                    = PxpFilterButtonScrollViewStylePortrate;
    _teamsScrollView.buttonSize               = CGSizeMake(_teamsScrollView.frame.size.width, 40);
    _teamsScrollView.filterModuleDelegate                 = self;
    
    _playersScrollView.sortByPropertyKey      = @"players";
    _playersScrollView.displayAllTagIfAllFilterOn = NO;
    _playersScrollView.style                  = PxpFilterButtonScrollViewStylePortrate;
    _playersScrollView.buttonSize             = CGSizeMake(40, 40);
    _playersScrollView.filterModuleDelegate               = self;
    
    _dateScrollView.sortByPropertyKey       = @"date";
    _dateScrollView.style                   = PxpFilterButtonScrollViewStylePortrate;    
    _dateScrollView.buttonSize              = CGSizeMake(_dateScrollView.frame.size.width, 40);
    _dateScrollView.filterModuleDelegate    = self;

  [_ratingButtons buildButtons];// Has to be what was selected last

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
    
    [_eventScrollView buildButtonsWith:[[tempSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [_teamsScrollView buildButtonsWith:[[tempTeamSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
  
    

//    NSSortDescriptor *sorter2 =[NSSortDescriptor
//                                sortDescriptorWithKey:@"eventName"
//                                ascending:YES
//                                selector:@selector(caseInsensitiveCompare:)];
//    
//    
//    sorter2 = NSSortDescriptor so
//
//    
//    return [NSMutableArray arrayWithArray:[toSort sortedArrayUsingDescriptors:@[sorter2,sorter1]]];
    
//    NSArray * sortedList = [[tempDateSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]re;
//    NSArray * sortedList = [[tempDateSet allObjects] sortedArrayUsingDescriptors:@[sorter2]];
//    [_dateScrollView buildButtonsWith:sortedList];
    

    [_dateScrollView buildButtonsWith:[[tempDateSet allObjects]sortedArrayUsingComparator:^(id obj1, id obj2) {
        return (NSComparisonResult) [obj2 integerValue] - [obj1 integerValue];
    }]];
    
    

    NSArray * playerList = [[tempPlayerSet allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return (NSComparisonResult) [obj1 integerValue] - [obj2 integerValue];
    }];
    
    [_playersScrollView buildButtonsWith:playerList];
    
    // Do any additional setup after loading the view from its nib
    _filteredTagLabel.text  = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.filteredTags.count];
    _totalTagLabel.text     = [NSString stringWithFormat:@"%lu",(unsigned long)self.pxpFilter.unfilteredTags.count];
    
    [self.pxpFilter refresh];
}

// custom filtering
-(void)onUserInput:(id)inputObject
{
    
    
    PxpFilterButtonScrollView * sender = (PxpFilterButtonScrollView *)inputObject;
    
    if (sender == _playersScrollView) {
        //^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings)
        sender.predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)  {
                Clip * c = (Clip *)evaluatedObject;
                for (UIButton * button in sender.userSelected) {
                    if ([c.players containsObject:button.titleLabel.text]){
                        return YES;
                    }
                }
                return NO;
            }];
    } else if (sender == _teamsScrollView) {
                //^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings)
        sender.predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)  {
            Clip * c = (Clip *)evaluatedObject;
            NSString * teamVS = [NSString stringWithFormat:@"%@ VS %@",c.homeTeam,c.visitTeam];
            for (UIButton * button in sender.userSelected) {
                if ([button.titleLabel.text isEqualToString:teamVS]){
                    return YES;
                }
            }
            return NO;
        }];
    
    } else if (sender == _dateScrollView) {
                //^BOOL(id  __nonnull evaluatedObject, NSDictionary<NSString *,id> * __nullable bindings)
        sender.predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Clip * c = (Clip *)evaluatedObject;
            NSString * clipDate = [Utility dateFromEvent: c.eventName];
            
            for (UIButton * button in sender.userSelected) {
                
                if ([button.titleLabel.text isEqualToString:clipDate]){
                    return YES;
                }
            }
            return NO;
        }];
        
    }

}


- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
    [self refreshUI];
}


@end
