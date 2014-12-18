//
//  ViewController.h
//  StatsImportXML
//
//  Created by Si Te Feng on 7/4/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatsCell.h"
#import "ImportTagsSync.h"

typedef CGPoint JPTagTime; //x: start, y: end


@class Globals, EventTagParserDelegate, CustomButton, LDProgressView, ImportTagsSync;
@interface ImportTagsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, JPImportTagsSyncDelegate, UIAlertViewDelegate>
{
    Globals *    _globals;
    
    NSString*     _urlString;
    BOOL          _importedFile;
    EventTagParserDelegate* _parserDelegate;
    
    //MODEL OBJECTS
    //helper objects
    NSMutableDictionary* _groupToTextNames;  //dictionary of group key to array of NSStrings
    
    //Reorganizing tags with its name
    NSMutableDictionary* _groupTags;
    // {"tackle":[{start:25, end:36, code: "Ross", id: 1}, XMLTag(...)], "tag2":[...]}
    NSMutableDictionary* _textTags;
    
    NSMutableDictionary* _originalGroupTags;
    NSMutableDictionary* _originalTextTags;
    
    //info data objects
    NSMutableDictionary* _groupDataDict;
    //{"tackle": [[],[{id:1, start:25, end:36...},{}],[],[]....16...]
    NSMutableDictionary* _textDataDict;
    
    NSMutableArray*    _selectedPlayerButtonNames;
    NSMutableArray*    _selectedGroupButtonNames;
    
    BOOL       _eventIsAGroup; //for table view data
    
    //For Saving Tag Data
    NSTimer*        _streamTimer;
    ImportTagsSync* _tagSyncer;
    
    
    
    //UI ELEMENTS
    UIButton*     _timeLineInfoButton; //not user interactive
    
    //2 Tag ScrollViews
    UIScrollView*      _playerTagScrollView;
    UIButton*      _noPlayerLabel;
    UIScrollView*      _groupTagScrollView;
    UIButton*      _noGroupLabel;
    
    UISwitch*      _streamSwitch;
    UISwitch*      _saveSwitch;
    BOOL           _saveSwitchWasOn;
    
    UIActivityIndicatorView* _activityView;
    UITextField*           _delayTextField;
    
    UIView*        _savingView;
    LDProgressView*    _progressView;
}


@property (nonatomic, assign) float endTime;
@property (nonatomic, assign) float startTime;
@property (nonatomic, assign) float timeInterval;

@property (nonatomic, strong) UIView*      tabContentView;
@property (nonatomic, strong) UITextField* fileNameField;

//stats table view for displaying stats data
@property(nonatomic, strong)UITableView *statsTableView;


//NOT CURRENTLY USED
//picker view for selecting the start time for the table time line
@property(nonatomic,strong)UIPickerView *startTimePickerView;

//picker view for selecting the time interval the table time line
@property(nonatomic,strong)UIPickerView *endTimePickerView;

@property(nonatomic,strong)UIPopoverController *durationPopController;



@end

