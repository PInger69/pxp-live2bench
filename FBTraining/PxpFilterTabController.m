//
//  PxpFilterTabController.m
//  Test12
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "PxpFilterTabController.h"

@interface PxpFilterTabController ()

@end

@implementation PxpFilterTabController
@synthesize pxpFilter = _pxpFilter;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil tabImage:nil];
}

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabImage:(nullable UIImage *)tabImage {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabImage = tabImage;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIUpdate:) name:NOTIF_FILTER_TAG_CHANGE object:nil];
    }
    return self;
}

- (void)setPxpFilter:(PxpFilter*)pxpFilter{
    [_pxpFilter removeAllModules];
    _pxpFilter = pxpFilter;
    
    for (id <PxpFilterModuleProtocol> mod in _modules){
        mod.parentFilter = _pxpFilter;
    }
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

- (void)show{
    
}

- (void)hide{
    
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
