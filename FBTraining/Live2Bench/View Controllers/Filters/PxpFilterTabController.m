//
//  PxpFilterTabController.m
//  Test12
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "PxpFilterTabController.h"

#import "PxpFilterButtonScrollView.h"
#import "Tag.h"

@interface PxpFilterTabController ()

@end

@implementation PxpFilterTabController

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

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTagNames];
}

- (void)show {
}

- (void)hide {
    
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) refreshTagNames {
    NSLog(@"refreshTagNames");
    PxpFilterButtonScrollView* tagNamesList = [self filterButtonScrollView];

    if (tagNamesList != nil) {
        
        
        NSMutableSet* tagNames = [NSMutableSet new];
        for (Tag* t in self.pxpFilter.unfilteredTags) {
            if (!t.deleted) {
                [tagNames addObject:t.name];
            }
        }
        [tagNamesList buildButtonsWith:[tagNames allObjects]];
    }
}

-(PxpFilterButtonScrollView*) filterButtonScrollView {
    PxpFilterButtonScrollView* result = nil;
    for (NSObject* module in self.modules) {
        if ([module isKindOfClass:[PxpFilterButtonScrollView class]]) {
            result = (PxpFilterButtonScrollView*) module;
            break;
        }
    }
    return result;
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
