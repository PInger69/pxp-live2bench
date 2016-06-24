//
//  MakeEventViewController.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MakeEventViewController;
@protocol MakeEventViewControllerDelegate <NSObject>

-(void)onMakeEvent:(MakeEventViewController*)sender;
-(void)onMakeEventAndLaunch:(MakeEventViewController*)sender;

@end




@interface MakeEventViewController : UIViewController <UITextFieldDelegate , UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventNameInput;
@property (weak, nonatomic) IBOutlet UITextField *leagueNameInput;
@property (weak, nonatomic) IBOutlet UITextField *awayTeamNameInput;
@property (weak, nonatomic) IBOutlet UITextField *homeTeamNameInput;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property (strong, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (strong, nonatomic) UICollectionViewController *videoCollectionController;


@property (weak, nonatomic) IBOutlet UIButton *makeEventButton;
@property (weak, nonatomic) IBOutlet UIButton *makeEventandLauncButton;

@property (weak, nonatomic) id <MakeEventViewControllerDelegate> delegate;




@end
