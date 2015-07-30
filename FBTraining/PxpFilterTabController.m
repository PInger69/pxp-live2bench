//
//  PxpFilterTabController.m
//  CWPopupDemo
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "PxpFilterTabController.h"

@interface PxpFilterTabController ()

@end

@implementation PxpFilterTabController

- (void)setPxpFilter:(PxpFilter*)pxpFilter{
    [_pxpFilter removeAllModules];
    _pxpFilter = pxpFilter;
    if(_modules)[pxpFilter addModules:self.modules];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
