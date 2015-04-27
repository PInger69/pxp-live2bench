//
//  PxpLogViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "AppDelegate.h"
#import "PxpLogViewController.h"
#import "PxpLog.h"

@interface PxpLogViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation PxpLogViewController

-(instancetype) initWithAppDelegate: (AppDelegate *) appDel{
    self = [super init];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame: self.view.bounds];
        //self.textView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        //[self.view addSubview: self.textView];
        self.view = self.textView;
        self.textView.backgroundColor = [UIColor blackColor];
        self.textView.font = [UIFont fontWithName:@"Courier" size:18.0];
        [self.textView setTextColor:[UIColor greenColor]];
        
        [[PxpLog getInstance] addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self.textView setText: [PxpLog getInstance].text];
}
@end
