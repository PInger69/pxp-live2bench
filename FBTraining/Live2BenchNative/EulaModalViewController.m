//
//  EulaModalViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-02-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "EulaModalViewController.h"
@interface EulaModalViewController ()

@end

@implementation EulaModalViewController

UITextView *eulaTextView;

- (id)initWithController:(id)loginViewController;
{
    self = [super init];
    if(loginViewController)
    {
        lVController=loginViewController;
    }
    globals = [Globals instance];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0f)];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"EULA"];
    navBar.items = @[navItem];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    navItem.leftBarButtonItem = cancelButtonItem;
    [self.view addSubview:navBar];
    
    eulaTextView = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(navBar.frame)+5.0f, self.view.bounds.size.width-10.0f, self.view.bounds.size.height - 61.0f - CGRectGetMaxY(navBar.frame))];
    eulaTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    eulaTextView.font = [UIFont defaultFontOfSize:14.0f];
    eulaTextView.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
    eulaTextView.backgroundColor = [UIColor clearColor];
    [eulaTextView setEditable:NO];
    eulaTextView.scrollsToTop = YES;
    NSString *eulaTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"EulaString" ofType:@"txt"];
    eulaTextView.text = [NSString stringWithContentsOfFile:eulaTextPath encoding:NSUTF8StringEncoding error:nil];
    [self.view addSubview:eulaTextView];

    self.acceptEulaButton = [PopoverButton buttonWithType:UIButtonTypeCustom];
    self.acceptEulaButton.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.frame) - 46.0f, self.view.bounds.size.width, 44.0f);
    self.acceptEulaButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.acceptEulaButton setTitle:@"Accept" forState:UIControlStateNormal];
    [self.acceptEulaButton addTarget:self action:@selector(acceptEula:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptEulaButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15.0f, (self.acceptEulaButton.frame.origin.y - CGRectGetMaxY(eulaTextView.frame))/2 + CGRectGetMaxY(eulaTextView.frame), self.view.bounds.size.width - 30.0f, 1.0f)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    line.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self.view addSubview:line];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [eulaTextView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:NO];
}

- (void)didReceiveMemoryWarning
{
    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissView:(id)sender {
    globals.IS_EULA=FALSE;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"myplayXplay"
                          message: @"You must accept the End User License Agreement to continue"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
}
- (void)acceptEula:(id)sender {
    globals.IS_EULA=TRUE;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithContentsOfFile:globals.ACCOUNT_PLIST_PATH];
    [userInfo setObject:@"1" forKey:@"eula"];
    [userInfo writeToFile: globals.ACCOUNT_PLIST_PATH atomically:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if(lVController)
            [lVController dismissViewControllerAnimated:YES completion:nil];
    }];
    [globals.WHITE_BACKGROUND removeFromSuperview];
}
@end
