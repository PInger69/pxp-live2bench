//
//  PxpFilterHockeyTabViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterHockeyTabViewController.h"
#import "Tag.h"

@interface PxpFilterHockeyTabViewController ()

@end

@implementation PxpFilterHockeyTabViewController

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Hockey";
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
    [_middleScrollView buildButtonsWith:@[@"1",@"2",@"3",@"OT",@"PS"]];
    _middleScrollView.sortByPropertyKey = @"period";
    [_leftScrollView buildButtonsWith:@[@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4"]];
    _leftScrollView.sortByPropertyKey = @"name";
    
    self.modules = [[NSMutableArray alloc]initWithObjects:
                    _rightScrollView,_middleScrollView,_leftScrollView, nil]; // removed the slider
    
     _sliderView.sortByPropertyKey = @"time";
    
    
    
    [_sliderView setEndTime:(2000)];
    
    //Test RangeSlider
    
    // Do any additional setup after loading the view from its nib
    
}
- (IBAction)clearButtonPressed:(id)sender {
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
}

- (void)show{
    [_sliderView show];
}
- (void)hide{
    [_sliderView hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
