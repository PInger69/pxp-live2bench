//
//  ToggleSettingViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SettingItemViewController.h"

@protocol ToggleSettingViewControllerDelegate <NSObject>

- (void)toggleStateDidChangeWithIdentifier:(nonnull NSString *)identifier state:(BOOL)on;

@end

@interface ToggleSettingViewController : SettingItemViewController

@property (readonly, nonatomic, nonnull) NSArray *toggles;
@property (weak, nonatomic, nullable) id<ToggleSettingViewControllerDelegate> delegate;

// toggles = @[@{ @"Name": NSString, @"Identifier": NSString}, ...]
//  Name: display name
//  Identifier: plist identifier
- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier toggles:(nonnull NSArray*)toggles;

@end
