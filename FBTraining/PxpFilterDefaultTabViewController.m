//
//  ViewController.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import "PxpFilterDefaultTabViewController.h"
#import "Tag.h"

@interface PxpFilterDefaultTabViewController ()


@end

@implementation PxpFilterDefaultTabViewController

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Default";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        

    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"Filtered Tag(s): %lu",(unsigned long)filter.filteredTags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"Total Tag(s): %lu",(unsigned long)2147483647*2+1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    PxpFilter.rawTags; //NSMutableSet
    /*NSArray * rawTags;
    NSMutableSet * tempSet = [[NSMutableSet alloc]init];
    
    for (Tag * tag in rawTags) {
        [tempSet addObject:tag.name];
    }*/

    
    //[_rightScrollView buildButtonsWith:[tempSet allObjects]];
    
    [_rightScrollView buildButtonsWith:@[@"ABC",@"CBA"]];
    _rightScrollView.sortByPropertyKey = @"name";
    [_middleScrollView buildButtonsWith:@[@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c",@"b",@"c"]];
    _middleScrollView.sortByPropertyKey = @"name";
    [_leftScrollView buildButtonsWith:@[@"PP",@"PK"]];
    _leftScrollView.sortByPropertyKey = @"name";
    
    self.modules = [[NSMutableArray alloc]initWithObjects:
                    _rightScrollView,_middleScrollView,_leftScrollView,_sliderView, nil];
    
    _sliderView.sortByPropertyKey = @"time";
    
    [_sliderView setEndTime:(2000)];
    
    //Test RangeSlider
    
    // Do any additional setup after loading the view from its nib
    
}

- (void)show{
    [_sliderView show];
}
- (void)hide{
    [_sliderView hide];
}

- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
