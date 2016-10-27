//
//  SideTagSettingsViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SideTagSettingsViewController.h"
#import "SideTagEditButtonDisplayView.h"
#import "PopUpTagSetButtonEditViewController.h"
#import "TagSetEditPopUpViewController.h"
#import "UserCenter.h"

#define DEFAULT_TAG_SET @"Default (non editable)"


@interface SideTagSettingsViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic,strong) NSString * currentTagSetName;


@property (nonatomic,strong) NSMutableArray * listTagSetName;
@property (nonatomic,strong) NSMutableArray * tagSetData;

@property (nonatomic,strong) NSArray        * tagSetButtons;
@property (nonatomic,strong) PopUpTagSetButtonEditViewController * editTagPopup;
@property (nonatomic,strong) TagSetEditPopUpViewController * editTagSetPopup;


@end

@implementation SideTagSettingsViewController






- (void)viewDidLoad {
        [super viewDidLoad];
    self.tagSetButtons = @[self.buttonPlaceHolder1,
                           self.buttonPlaceHolder2,
                           self.buttonPlaceHolder3,
                           self.buttonPlaceHolder4,
                           self.buttonPlaceHolder5,
                           self.buttonPlaceHolder6,
                           self.buttonPlaceHolder7,
                           self.buttonPlaceHolder8,
                           self.buttonPlaceHolder9,
                           self.buttonPlaceHolder10,
                           self.buttonPlaceHolder11,
                           self.buttonPlaceHolder12,
                           self.buttonPlaceHolder13,
                           self.buttonPlaceHolder14,
                           self.buttonPlaceHolder15,
                           self.buttonPlaceHolder16,
                           self.buttonPlaceHolder17,
                           self.buttonPlaceHolder18,
                           self.buttonPlaceHolder19,
                           self.buttonPlaceHolder20,
                           self.buttonPlaceHolder21,
                           self.buttonPlaceHolder22,
                           self.buttonPlaceHolder23,
                           self.buttonPlaceHolder24];
    
    
    
   
    
    self.tagSetButtons = [self replacePlaceHolders:self.tagSetButtons];
    
    
    self.currentTagSetName          = DEFAULT_TAG_SET;
    self.listTagSetName             = [NSMutableArray new];
    self.tagSetPicker.dataSource    = self;
    self.tagSetPicker.delegate      = self;
    

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self.listTagSetName addObject:DEFAULT_TAG_SET];
    
  
    
//    [defaults setObject:nil forKey:[UserCenter getInstance].customerEmail];
//    [defaults synchronize];
//    return;
    // check to see if there is used data
    if ([UserCenter getInstance].customerEmail && [defaults objectForKey:[UserCenter getInstance].customerEmail]){
        NSDictionary * customersTagSetData = [defaults objectForKey:[UserCenter getInstance].customerEmail];
        self.currentTagSetName = customersTagSetData[@"currentTagSetName"];
        [UserCenter getInstance].currentTagSetName =self.currentTagSetName;
        NSArray * tagSetNames = [customersTagSetData[@"tagSets"] allKeys];
        
        // builds data from the picker
        for (NSString * key  in tagSetNames) {
            [self.listTagSetName addObject:key];
        }
        
        if (![self.listTagSetName containsObject:self.currentTagSetName]) {
            self.currentTagSetName = DEFAULT_TAG_SET;
            [UserCenter getInstance].currentTagSetName =self.currentTagSetName;
        }

        
        if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
            [self setUpButtons:[UserCenter getInstance].defaultTagNames];
        } else {
            [self setUpButtons:customersTagSetData[@"tagSets"][self.currentTagSetName]]; // buils UI
            // update Live2Bench
            [UserCenter getInstance].tagNames = self.tagSetData;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        }
        
    } else {
        // make user data becuase it does not have any
        if (![UserCenter getInstance].customerEmail) {
            [UserCenter getInstance].customerEmail = @"none";
        }
        [defaults setObject:@{@"currentTagSetName":DEFAULT_TAG_SET,@"tagSets":@{}} forKey:[UserCenter getInstance].customerEmail];
        [defaults synchronize];
        
        
    }

    if ([self.listTagSetName containsObject:self.currentTagSetName]) {
    [self.tagSetPicker selectRow: [self.listTagSetName indexOfObject:self.currentTagSetName] inComponent:0 animated:NO];
    }
}

-(NSArray*)replacePlaceHolders:(NSArray*)list
{
    NSMutableArray * createdList = [list mutableCopy];
    
    for (NSInteger i = 0; i< [list count]; i++) {
        UIView * holder = list[i];
        
        SideTagEditButtonDisplayView * display =  [[SideTagEditButtonDisplayView alloc]initWithFrame:holder.frame];
        [display.button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        display.button.tag  = i;
        display.order = [NSNumber numberWithInteger:i];
        display.position = (holder.frame.origin.x > 100)?@"right":@"left";
        
        
        display.typeLabel.text = @"None";
        display.typeLabel.textColor = [UIColor grayColor];
        [display.button setTitle:@"" forState:UIControlStateNormal];
        display.enabled = ![self.currentTagSetName isEqualToString:DEFAULT_TAG_SET];
        
        [holder removeFromSuperview];
        [self.view addSubview:display];
        createdList[i] = display;
    }
    return [createdList copy];
}




-(void)setUpButtons:(NSArray*)tags
{

    for (SideTagEditButtonDisplayView * d in self.tagSetButtons) {
        d.typeLabel.text = @"None";
        d.typeLabel.textColor = [UIColor grayColor];
        [d.button setTitle:@"" forState:UIControlStateNormal];
        d.enabled = ![self.currentTagSetName isEqualToString:DEFAULT_TAG_SET];        // you cant mod the default
    }
    
    if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
    
        NSArray *sortedTags = [tags sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSNumber * first   = [(NSDictionary *)a objectForKey:@"order"];
            NSNumber * second  = [(NSDictionary *)b objectForKey:@"order"];
            NSComparisonResult result =  [first compare:second];
            return result;
        }];
        
        
        
        NSInteger rightCount = 0;
        for (NSInteger i = 0; i<[tags count]; i++) {
            NSString * pos  = tags[i][@"position"];
            NSInteger offset = i;
            
            if ([pos isEqualToString:@"right"]){
                offset = rightCount+12;
                rightCount += 1;
            }
            SideTagEditButtonDisplayView * display = self.tagSetButtons[offset];
            
            [display.button setTitle:tags[i][@"name"] forState:UIControlStateNormal];
            display.typeLabel.text = (tags[i][@"type"])?tags[i][@"type"]:@"Normal";
            
            if ([display.typeLabel.text isEqualToString:@"Normal"]) {
                display.typeLabel.textColor = [UIColor blackColor];
            }
        }

    } else {
    
        for (NSInteger i = 0; i<[tags count]; i++) {
            NSInteger order = [tags[i][@"order"]integerValue];
            NSString * pos  = tags[i][@"position"];
            
            if (order < 12 && [pos isEqualToString:@"right"]){
                order += 12;
            }
            
            SideTagEditButtonDisplayView * display = self.tagSetButtons[order];
            [display.button setTitle:tags[i][@"name"] forState:UIControlStateNormal];
            display.typeLabel.text = (tags[i][@"type"])?tags[i][@"type"]:@"Normal";
            
            if ([display.typeLabel.text isEqualToString:@"Normal"]) {
                display.typeLabel.textColor = [UIColor blackColor];
            }
        }

    
    }
    
      if (!tags.count){
        self.tagSetData = [NSMutableArray new];
    } else {
        self.tagSetData = [tags mutableCopy];  // Saves Data
    }
    
}


-(void)onButtonPress:(id)sender
{
    
    
    UIButton    * button = sender;
    SideTagEditButtonDisplayView * display = self.tagSetButtons[button.tag];
    display.selected = YES;
    
    // show pop up and add tagset on complete
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Name Tag"
                                  message:@"Set the name of the tag"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    
    

    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Set"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    
                                    NSString * nameNew = ((UITextField *)alert.textFields[0]).text;
                                    
                                    if ([nameNew isEqualToString:@""] ||[nameNew isEqualToString:@" "]) {
                                        display.typeLabel.text = @"None";
                                        display.typeLabel.textColor = [UIColor grayColor];
                                        display.name                = @"";
                                        display.selected = NO;
                                        for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
                                            
                                            NSInteger order = [self.tagSetData[i][@"order"]integerValue];
                                            
                                            if (order == display.button.tag) {
                                                [self.tagSetData removeObjectAtIndex:i];
                                                [self onButtonEditComplete];
                                                return;
                                            }
                                        }
                                        
                                        [self onButtonEditComplete];
                                        return;
                                    }
                                    
                                    display.typeLabel.text      = @"Normal";
                                    display.typeLabel.textColor = [UIColor blackColor];
                                    display.name                = nameNew;
                                    display.selected            = NO;
                                    
                                    for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
                                        if (i == display.button.tag) {
                                            self.tagSetData[i] = [display data];
                                            [self onButtonEditComplete];
                                            return;
                                        }
                                    }
                                    
                                    [self.tagSetData addObject:[display data]];
                                    [self onButtonEditComplete];
//                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    UIAlertAction* noneButton = [UIAlertAction
                                actionWithTitle:@"None"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    display.typeLabel.text = @"None";
                                    display.typeLabel.textColor = [UIColor grayColor];
                                    display.name                = @"";
                                    display.selected = NO;
                                    for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
                                        
                                        NSInteger order = [self.tagSetData[i][@"order"]integerValue];
                                        
                                        if (order == display.button.tag) {
                                            [self.tagSetData removeObjectAtIndex:i];
                                            [self onButtonEditComplete];
                                            return;
                                        }
                                    }

                                    [self onButtonEditComplete];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
            display.selected = NO;
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";//display.name;
    }];
    

    
    
    [alert addAction:yesButton];
    [alert addAction:noneButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
    
//    self.editTagPopup = [PopUpTagSetButtonEditViewController new];
//    self.editTagPopup.contentViewController.modalInPopover = NO;
//    self.editTagPopup.delegate = self;
//    
////    [self.editTagPopup presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
//    [self.editTagPopup presentPopoverFromRect: display.frame inView:display permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    
    
//    PopUpTagSetButtonEditViewController *controller = [PopUpTagSetButtonEditViewController new];
//    controller.modalInPopover = YES;
//    
//    [self presentViewController:controller animated:YES completion:nil];
//    
//    UIPopoverPresentationController *presentationController = [controller popoverPresentationController];
//    presentationController.sourceView = self.view;
//    presentationController.delegate = controller;
//
//    UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 400, 200)];
//    
//    UIPopoverPresentationController *presentationController = [self popoverPresentationController];
//    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
//    presentationController.sourceView               = v;
//    presentationController.permittedArrowDirections = 0;
//    
//    [self presentViewController:v animated:YES completion:nil];
//[self presentViewController:controller animated:YES completion:nil];
}

-(void)onButtonEditComplete
{
    NSUserDefaults      * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * userDefaults = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    userDefaults[@"currentTagSetName"] = self.currentTagSetName;
    userDefaults[@"tagSets"] =  [userDefaults[@"tagSets"] mutableCopy];
    userDefaults[@"tagSets"][self.currentTagSetName] = self.tagSetData;
    [defaults setObject:userDefaults forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];

}






-(void)makeNewTagSet:(NSString*)name
{
    NSUserDefaults      * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * customersTagSetData = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    NSMutableDictionary * userTagSets = [customersTagSetData[@"tagSets"] mutableCopy];
  
    [userTagSets setObject:@{} forKey:name];
    [customersTagSetData setObject:userTagSets forKey:@"tagSets"];
    
    [defaults setObject:customersTagSetData forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];
    
    [self setUpButtons:nil]; // clear out the list
    
    [self.listTagSetName addObject:name];
    
    [self.tagSetPicker reloadAllComponents];
//    self.tagSetPicker set
    [self.tagSetPicker selectRow:[self.listTagSetName count]-1 inComponent:0 animated:YES];
    self.currentTagSetName = nil;
    [self pickerView:self.tagSetPicker didSelectRow:[self.listTagSetName indexOfObject:name] inComponent:0];
    
    //save te set
}

-(void)deleteTagSet:(NSString*)name
{

    NSUserDefaults      * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * customersTagSetData = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    NSMutableDictionary * userTagSets = [customersTagSetData[@"tagSets"] mutableCopy];
    
//
//    [customersTagSetData setObject:DEFAULT_TAG_SET forKey:@"currentTagSetName"];
//    
//    [userTagSets removeObjectForKey:name];
//    [customersTagSetData setObject:userTagSets forKey:@"tagSets"];
//    
//    [defaults setObject:customersTagSetData forKey:[UserCenter getInstance].customerEmail];
//    [defaults synchronize];
//    
//    [self.listTagSetName removeObject:name];
//    [self.tagSetPicker reloadAllComponents];
//    self.currentTagSetName = name;
//    
//    self.currentTagSetName = nil;
//    
//    [self pickerView:self.tagSetPicker didSelectRow:0 inComponent:0];
//    [self.tagSetPicker selectRow:[self.listTagSetName indexOfObject:DEFAULT_TAG_SET] inComponent:0 animated:YES];
//
//    
    
    

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Tag Set Builder"
                                  message:@"Are you sure you want to delete this tag set"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [customersTagSetData setObject:DEFAULT_TAG_SET forKey:@"currentTagSetName"];
                                    
                                    [userTagSets removeObjectForKey:name];
                                    [customersTagSetData setObject:userTagSets forKey:@"tagSets"];
                                    
                                    [defaults setObject:customersTagSetData forKey:[UserCenter getInstance].customerEmail];
                                    [defaults synchronize];
                                    
                                    [self.listTagSetName removeObject:name];
                                    [self.tagSetPicker reloadAllComponents];
                                    self.currentTagSetName = name;
                                    
                                    self.currentTagSetName = nil;
                                    
                                    [self pickerView:self.tagSetPicker didSelectRow:0 inComponent:0];
                                    [self.tagSetPicker selectRow:[self.listTagSetName indexOfObject:DEFAULT_TAG_SET] inComponent:0 animated:YES];

                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];

    
    
}

#pragma mark - UIPickerViewDataSource Delegate Methods
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.listTagSetName count];
}


#pragma mark - UIPickerViewDelegate Delegate Methods
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.listTagSetName[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ( [self.listTagSetName[row] isEqualToString:self.currentTagSetName]) return ;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.currentTagSetName = self.listTagSetName[row];
    
    if ( [self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
        
        [self setUpButtons:[UserCenter getInstance].defaultTagNames];
    } else {

        NSDictionary * customersTagSetData = [defaults objectForKey:[UserCenter getInstance].customerEmail];
        [self setUpButtons:customersTagSetData[@"tagSets"][self.listTagSetName[row]]];
    }
    

    NSMutableDictionary * userDefaults = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    userDefaults[@"currentTagSetName"] = self.currentTagSetName;

    [defaults setObject:userDefaults forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];

}



// this is to comfirm that changes then the post a Notification to update the tags in L2B
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    NSMutableArray * temp   = [NSMutableArray new];
    
    for (NSInteger k=0; k<24; k++) {
        NSString * pos = (k<12)?@"left":@"right";
        [temp addObject:@{@"name":@"--", @"order":[NSNumber numberWithInteger:k],@"position":pos}];
    }
    
    
    NSMutableSet * indexes  = [NSMutableSet new];
    
    for (NSDictionary * dict in self.tagSetData) {
        NSInteger * n = [dict[@"order"]integerValue];
        
        
        [indexes addObject:[NSNumber numberWithInteger:n]];
    }
    
    
    
    for (NSInteger i=0; i<[self.tagSetData count]; i++) {
        
        NSDictionary * tagSet = self.tagSetData[i];
        NSInteger order = [tagSet[@"order"]integerValue];
        temp[order] = tagSet;
    }
    
    
    
    
    
    if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
        [UserCenter getInstance].tagNames = [UserCenter getInstance].defaultTagNames;
    } else {
        [UserCenter getInstance].tagNames = temp;
    }
    
    
    
    NSMutableSet * autoSet = [NSMutableSet new];
    for (SideTagEditButtonDisplayView * display in self.tagSetButtons) {
        if (display.autoSwitch.isOn) {
            [autoSet addObject:display.name];
        }
    }
    [UserCenter getInstance].tagsFlaggedForAutoDownload = [autoSet copy];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
}

#pragma mark Stepper Method

 - (IBAction)changeValue:(id)sender
{
    double val = self.addRemoveControl.value;
    
    if (val) {
        // show pop up and add tagset on complete
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Tag Set Builder"
                                      message:@"Name the new tag set."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Make"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                       
                                        NSString * nameNew = ((UITextField *)alert.textFields[0]).text;
                                        [self makeNewTagSet:nameNew];
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            NSString * meh;
//            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];

    } else {
        self.addRemoveControl.value = 1;
        // delete current tag set, if its default then do nothing
        if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) return;
        
        [self deleteTagSet:self.currentTagSetName];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
