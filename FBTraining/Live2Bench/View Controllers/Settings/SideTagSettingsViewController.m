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
#import "PxpTagDefinition.h"

#define DEFAULT_TAG_SET @"Default (non editable)"


@interface SideTagSettingsViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic,strong) NSString * currentTagSetName;


@property (nonatomic,strong) NSMutableArray * listTagSetName;
//@property (nonatomic,strong) NSMutableArray * tagSetData;
@property (nonatomic,strong) NSMutableDictionary* tagDefinitions;

@property (nonatomic,strong) NSArray        * tagSetButtons;
@property (nonatomic,strong) PopUpTagSetButtonEditViewController * editTagPopup;
@property (nonatomic,strong) TagSetEditPopUpViewController * editTagSetPopup;


@end

@implementation SideTagSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SideTagSettingsViewController viewDidLoad");
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
    self.tagDefinitions             = [NSMutableDictionary new];
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
            [UserCenter getInstance].tagNames = [NSMutableArray arrayWithArray:[self tagDefinitionsAsArrayOfDictionaries]];
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

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // if we've just logged in, we might not have set up the default tags
    if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET] && self.tagDefinitions.count == 0) {
        [self setUpButtons:[UserCenter getInstance].defaultTagNames];
    }
}

// this is to comfirm that changes then the post a Notification to update the tags in L2B
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    /*
    NSMutableArray * temp   = [NSMutableArray new];
    
    for (NSInteger k=0; k<24; k++) {
        NSString * pos = (k<12)?@"left":@"right";
        [temp addObject:@{@"name":@"--", @"order":[NSNumber numberWithInteger:k],@"position":pos}];
    }
    
    
    NSMutableSet * indexes  = [NSMutableSet new];
    
    for (NSDictionary * dict in self.tagSetData) {
        NSInteger n = [dict[@"order"]integerValue];
        
        
        [indexes addObject:[NSNumber numberWithInteger:n]];
    }
    
    
    
    for (NSInteger i=0; i<[self.tagSetData count]; i++) {
        
        NSDictionary * tagSet = self.tagSetData[i];
        NSInteger order = [tagSet[@"order"]integerValue];
        temp[order] = tagSet;
    }
    */
    
    NSArray* temp = [self tagDefinitionsAsArrayOfDictionaries];
    
    
    
    if ([self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
        [UserCenter getInstance].tagNames = [UserCenter getInstance].defaultTagNames;
    } else {
        [UserCenter getInstance].tagNames = [temp mutableCopy];
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

        NSInteger leftCount = 0;
        NSInteger rightCount = 12;
        for (NSInteger i = 0; i<[tags count]; i++) {
            NSString * pos  = tags[i][@"position"];
            
            NSInteger offset = 0;
            if ([pos isEqualToString:@"right"]){
                offset = rightCount;
                rightCount++;
            } else {
                offset = leftCount;
                leftCount++;
            }
            SideTagEditButtonDisplayView * display = self.tagSetButtons[offset];

            [display.button setTitle:tags[i][@"name"] forState:UIControlStateNormal];
            display.typeLabel.text = (tags[i][@"type"])?tags[i][@"type"]:@"Normal";
            PxpTagDefinition* tagDefinition = [[PxpTagDefinition alloc] initWithName:tags[i][@"name"] order:offset position:[pos isEqualToString:@"left"] ? PxpTagDefinitionPositionLeft : PxpTagDefinitionPositionRight];
            [self addOrRemoveDefinition:tagDefinition key:@(offset)];
            
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

            PxpTagDefinition* tagDefinition = [[PxpTagDefinition alloc] initWithName:tags[i][@"name"] order:order position:[pos isEqualToString:@"left"] ? PxpTagDefinitionPositionLeft : PxpTagDefinitionPositionRight];
            [self addOrRemoveDefinition:tagDefinition key:@(order)];
            
            SideTagEditButtonDisplayView * display = self.tagSetButtons[order];
            [display.button setTitle:tags[i][@"name"] forState:UIControlStateNormal];
            display.typeLabel.text = (tags[i][@"type"])?tags[i][@"type"]:@"Normal";
            
            if ([display.typeLabel.text isEqualToString:@"Normal"]) {
                display.typeLabel.textColor = [UIColor blackColor];
            }
        }
    }

    /*
    if (!tags.count){
        self.tagSetData = [NSMutableArray new];
    } else {
        self.tagSetData = [tags mutableCopy];  // Saves Data
    }
     */
    
}

-(void) assignNewTag:(NSString*) name view:(SideTagEditButtonDisplayView*) display {
    
    PxpTagDefinition* tagDefinition = name == nil ? nil : [[PxpTagDefinition alloc] initWithName:name order:[display.order integerValue] position:[display.position isEqualToString:@"left"] ? PxpTagDefinitionPositionLeft : PxpTagDefinitionPositionRight];
    [self addOrRemoveDefinition:tagDefinition key:display.order];
    
    if (tagDefinition == nil) {
        display.typeLabel.text = @"None";
        display.typeLabel.textColor = [UIColor grayColor];
        display.name                = @"";
        display.selected = NO;
        /*
        for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
            
            NSInteger order = [self.tagSetData[i][@"order"]integerValue];
            
            if (order == display.button.tag) {
                [self.tagSetData removeObjectAtIndex:i];
                [self persistTags];
                return;
            }
        }
        */
        
        [self persistTags];
        return;
    }
    
    display.typeLabel.text      = @"Normal";
    display.typeLabel.textColor = [UIColor blackColor];
    display.name                = name;
    display.selected            = NO;
    
    /*
    for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
        if (i == display.button.tag) {
            self.tagSetData[i] = [display data];
            [self persistTags];
            return;
        }
    }
    [self.tagSetData addObject:[display data]];
     */
    [self persistTags];
}

-(void) addOrRemoveDefinition:(PxpTagDefinition*) tagDefinition key:(NSNumber*) order {
    if (tagDefinition == nil) {
        [self.tagDefinitions removeObjectForKey:order];
    } else {
        [self.tagDefinitions setObject:tagDefinition forKey:order];
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
                                    [self assignNewTag:nameNew view:display];
                                    
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
                                    [self addOrRemoveDefinition:nil key:display.order];
                                    /*
                                    for (NSInteger i= 0; i<[self.tagSetData count];i++ ) {
                                        
                                        NSInteger order = [self.tagSetData[i][@"order"]integerValue];
                                        
                                        if (order == display.button.tag) {
                                            [self.tagSetData removeObjectAtIndex:i];
                                            [self persistTags];
                                            return;
                                        }
                                    }
                                    */

                                    [self persistTags];
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
}

-(void) persistTags {
    NSUserDefaults      * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * userDefaults = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    userDefaults[@"currentTagSetName"] = self.currentTagSetName;
    userDefaults[@"tagSets"] =  [userDefaults[@"tagSets"] mutableCopy];
    userDefaults[@"tagSets"][self.currentTagSetName] = [self tagDefinitionsAsArrayOfDictionaries]; //self.tagSetData;
    [defaults setObject:userDefaults forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];

}


-(NSArray*) tagDefinitionsAsArrayOfDictionaries {
    NSMutableArray* result = [NSMutableArray new];
    for (PxpTagDefinition* tagDefinition in [self.tagDefinitions allValues]) {
        [result addObject:[tagDefinition toDictionary]];
    }
    return [NSArray arrayWithArray:result];
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
    
    [self.tagDefinitions removeAllObjects];
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

    [self.tagDefinitions removeAllObjects];
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
        if (![self.currentTagSetName isEqualToString:DEFAULT_TAG_SET]) {
            [self deleteTagSet:self.currentTagSetName];
        }
    }
}

@end
