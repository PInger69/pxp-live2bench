//
//  PxpFilterFootballTabViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-06.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterFootballTabViewController.h"

@interface PxpFilterFootballTabViewController ()

@end

@implementation PxpFilterFootballTabViewController

@synthesize tabImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Football";
        tabImage =  [UIImage imageNamed:@"settingsButton"];
        
        
    }
    
    
    return self;
}

- (void)UIUpdate:(NSNotification*)note {
    PxpFilter * filter = (PxpFilter *) note.object;
    _filteredTagLabel.text = [NSString stringWithFormat:@"Filtered Tag(s): %lu",(unsigned long)filter.tags.count];
    _totalTagLabel.text = [NSString stringWithFormat:@"Total Tag(s): %lu",(unsigned long)2147483647*2+1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    
}
- (IBAction)clearButtonPressed:(id)sender {
    if(!self.modules)return;
    for(id<PxpFilterModuleProtocol> module in self.modules){
        [module reset];
    }
}

- (void)show{
}
- (void)hide{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
