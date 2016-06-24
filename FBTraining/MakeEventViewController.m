//
//  MakeEventViewController.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "MakeEventViewController.h"
#import "DeviceVideoCollectionViewController.h"

@interface MakeEventViewController ()

@end

@implementation MakeEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.makeEventButton.layer.borderWidth = 1;
    self.makeEventButton.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.makeEventButton.enabled = NO;
    
    self.makeEventandLauncButton.layer.borderWidth = 1;
    self.makeEventandLauncButton.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.makeEventandLauncButton.enabled = NO;
    
    self.eventNameInput.delegate    = self;
    self.leagueNameInput.delegate   = self;
    self.awayTeamNameInput.delegate = self;
    self.homeTeamNameInput.delegate = self;

    self.videoTable.delegate        = self;
    
    
    self.videoCollectionController = [[DeviceVideoCollectionViewController alloc]init];
    self.videoCollectionController.collectionView = self.videoCollectionView;
    // Do any additional setup after loading the view.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{


    [self allFieldsFilled];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}




-(void)allFieldsFilled
{
    BOOL check = YES;
    
    
    if ([_eventNameInput.text isEqualToString:@""] ) check = NO;
    if ([_leagueNameInput.text isEqualToString:@""] ) check = NO;
    if ([_awayTeamNameInput.text isEqualToString:@""] ) check = NO;
    if ([_homeTeamNameInput.text isEqualToString:@""] ) check = NO;
    
    
    self.makeEventButton.enabled = self.makeEventandLauncButton.enabled = check;
}

- (IBAction)onMakeEvent:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(onMakeEvent:)]) {
        [self.delegate onMakeEvent:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onMakeEventAndLaunch:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onMakeEventAndLaunch:)]) {
        [self.delegate onMakeEventAndLaunch:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
