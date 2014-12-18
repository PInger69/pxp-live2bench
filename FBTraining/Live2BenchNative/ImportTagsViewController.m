//
//  ViewController.m
//  StatsImportXML
//
//  Created by Si Te Feng on 7/4/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "ImportTagsViewController.h"
#import "JPStyle.h"
#import "JPFont.h"
#import "UserInterfaceConstants.h"
#import "UIFont+Default.h"
#import "EventTagParserDelegate.h"
#import "JPXMLTag.h"
#import "DurationTableViewController.h"
#import "CustomButton.h"
#import "Globals.h"
#import "ImportTagsSync.h"
#import "LDProgressView.h"
#import "UIColor+RGBValues.h"


#define STATS_TABLE_VIEW_WIDTH 1024
#define STATS_TABLE_VIEW_HEIGHT 540
#define GRID_CELL_HEIGHT 50
#define GRID_CELL_BUTTON_WIDTH 40
#define EVENT_NAME_CELL_LENGTH 134
#define TOTAL_NUMBER_CELL_LENGTH 90

#define TAG_NAME_BUTTON_WIDTH 100
#define TAG_NAME_BUTTON_HEIGHT 30
#define PLAYER_BUTTON_WIDTH 50
#define PLAYER_BUTTON_HEIIGHT 30

#define TIME_LABEL_WIDTH 45
#define TOTAL_TIME_DURATION 320


#define kTableSections 16
#define popoverTableCellHeight 100


@interface ImportTagsViewController ()


@end

const NSUInteger kDelayTextFieldTag = 194;

@implementation ImportTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self)
    {
        self.title = @"XML Import";
        _globals = [Globals instance];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _importedFile = NO;
    
    self.startTime = 0.0f;
    self.endTime = 0.0f;
    self.timeInterval = self.endTime / kTableSections;
    
    UILabel* tabTempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kiPadWidthLandscape, 55)];
    tabTempLabel.text = @"XML TAG CHART";
    tabTempLabel.font = [UIFont defaultFontOfSize:29];
    tabTempLabel.backgroundColor = [UIColor orangeColor];
    tabTempLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tabTempLabel];
    
    self.tabContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 1024,768 - 60 - 50)];
    [self.view addSubview:self.tabContentView];
    
    //TOP CONTROL ELEMENTS
    //init time line info button
    _timeLineInfoButton = [[UIButton alloc]init];//buttonWithType:UIButtonTypeCustom];
    [_timeLineInfoButton setFrame:CGRectMake(2, 0, 160, 40)];
    [_timeLineInfoButton setTitle:[NSString stringWithFormat:@"Duration: [%.0f, %.0f)",self.startTime,self.endTime] forState:UIControlStateNormal];
    [_timeLineInfoButton addTarget:self action:@selector(timeLineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _timeLineInfoButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    [_timeLineInfoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _timeLineInfoButton.layer.borderWidth = 2;
    [_timeLineInfoButton.titleLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    //The duration is set automatically
//    _timeLineInfoButton.userInteractionEnabled = NO;
    [self.tabContentView addSubview:_timeLineInfoButton];

    //File Import text field
    self.fileNameField = [[UITextField alloc] initWithFrame:CGRectMake(180, 0, 250, 40)];
    self.fileNameField.borderStyle = UITextBorderStyleRoundedRect;
    self.fileNameField.text = @"defencexml";
    self.fileNameField.placeholder = @"File Name or File URL";
    self.fileNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.tabContentView addSubview:self.fileNameField];
    
    UIButton* importButton = [[UIButton alloc] initWithFrame:CGRectMake(440, self.fileNameField.frame.origin.y, 100, 40)];
    [importButton setTitle:@"Import File" forState:UIControlStateNormal];
    [importButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [importButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [importButton addTarget:self action:@selector(importButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.tabContentView addSubview:importButton];
    
    //Streaming
    _streamSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(550, 5, 50, 30)];
    _streamSwitch.on = NO;
    _streamSwitch.tag = 0;
    [_streamSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.tabContentView addSubview:_streamSwitch];
    
    UILabel* streamLabel = [[UILabel alloc] initWithFrame:CGRectMake(602, 10, 50, 20)];
    streamLabel.font = [UIFont defaultFontOfSize:15];
    streamLabel.text = @"Stream";
    [self.tabContentView addSubview:streamLabel];
    
    //Save
    _saveSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(658, 5, 50, 30)];
    _saveSwitch.on = YES;
    _saveSwitchWasOn = YES;
    _saveSwitch.tag = 1;
    [_saveSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.tabContentView addSubview:_saveSwitch];
    
    UILabel* saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(710, 10, 50, 20)];
    saveLabel.font = [UIFont defaultFontOfSize:15];
    saveLabel.text = @"Save";
    [self.tabContentView addSubview:saveLabel];
    
    //Saving
    _savingView = [[UIView alloc] initWithFrame:CGRectMake(770, 0, 80, 40)];
    UIActivityIndicatorView* savingInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 10, 20, 20)];
    savingInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [savingInd startAnimating];
    UILabel* savingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    savingLabel.font = [UIFont defaultFontOfSize:15];
    savingLabel.textColor = [UIColor orangeColor];
    savingLabel.text = @"Saving";
    [_savingView addSubview:savingLabel];
    [_savingView addSubview:savingInd];
    _savingView.hidden = YES;
    [self.tabContentView addSubview:_savingView];
    
    //Saving Progress
    _progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-10, 45, kiPadWidthLandscape + 20, 18)];
    _progressView.flat = @0;
    _progressView.color = [[UIColor orangeColor] lighterColor];
    _progressView.type = LDProgressSolid;
    _progressView.progress = 100.0f;
    _progressView.animate = @0;
    [self.tabContentView addSubview:_progressView];
    
    //Delay Fields
    UILabel* delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(860, 0, 70, 40)];
    delayLabel.font = [UIFont defaultFontOfSize:17.0f];
    delayLabel.textAlignment = NSTextAlignmentRight;
    delayLabel.text = @"Delay:";
    [self.tabContentView addSubview:delayLabel];
    
    _delayTextField = [[UITextField alloc] initWithFrame:CGRectMake(940, 0, 60, 40)];
    _delayTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _delayTextField.placeholder = @"sec.";
    _delayTextField.text = @"0";
    _delayTextField.delegate = self;
    _delayTextField.tag = kDelayTextFieldTag;
    _delayTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.tabContentView addSubview:_delayTextField];
    

    //Player ScrollView
    _playerTagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 63, kiPadWidthLandscape, PLAYER_BUTTON_HEIIGHT)];
    [self.tabContentView addSubview:_playerTagScrollView];
    
    //No Player Label(not a button)
    _noPlayerLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noPlayerLabel setBackgroundImage:[UIImage imageNamed:@"StatsImportXML.bundle/line-button-grey.png"] forState:UIControlStateNormal];
    [_noPlayerLabel setFrame:CGRectMake(0, 0, kiPadWidthLandscape, PLAYER_BUTTON_HEIIGHT)];
    [_noPlayerLabel setTitle:@"No Players Available" forState:UIControlStateNormal];
    [_noPlayerLabel.titleLabel setFont:[JPFont defaultFontOfSize:15.0f]];
    [_noPlayerLabel setUserInteractionEnabled:FALSE];
    _noPlayerLabel.hidden = NO;
    [_noPlayerLabel.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_playerTagScrollView addSubview:_noPlayerLabel];
    
    
    //Group Scroll View
    _groupTagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 620, kiPadWidthLandscape, PLAYER_BUTTON_HEIIGHT)];
    _groupTagScrollView.showsHorizontalScrollIndicator = NO;
    [self.tabContentView addSubview:_groupTagScrollView];
    
    _noGroupLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noGroupLabel setBackgroundImage:[UIImage imageNamed:@"StatsImportXML.bundle/line-button-grey.png"] forState:UIControlStateNormal];
    [_noGroupLabel setFrame:CGRectMake(0, 0, kiPadWidthLandscape, PLAYER_BUTTON_HEIIGHT)];
    [_noGroupLabel.titleLabel setFont:[JPFont defaultFontOfSize:15.0f]];
    [_noGroupLabel setUserInteractionEnabled:FALSE];
    _noGroupLabel.hidden = NO;
    [_noGroupLabel.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_noGroupLabel setTitle:@"No Groups Available" forState:UIControlStateNormal];
    [_groupTagScrollView addSubview:_noGroupLabel];
    
    
    //Table View
    self.statsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_playerTagScrollView.frame), kiPadWidthLandscape, 527)];
    [self.statsTableView registerClass:[StatsCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    self.statsTableView.delegate = self;
    self.statsTableView.dataSource = self;
    [self.tabContentView addSubview:self.statsTableView];
    
}

                                                                        
#pragma mark - Button Call Back Methods

- (void)importButtonPressed
{
    if(_importedFile)
    {
        [[[UIAlertView alloc] initWithTitle:@"Importing File" message:@"Are you sure to import again? Duplicate tags might be saved if using the same file" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil] show];
        return;
    }
    
    //Remove Things from previous xml
    _progressView.progress = 0.0f;
    _progressView.animate = @NO;
    
    //Parse new xml
    _urlString = self.fileNameField.text;
    
    NSURL* contentURL = [[NSBundle mainBundle] URLForResource:_urlString withExtension:@"xml"];
    if(!contentURL)
        return;
    
    _parserDelegate = [[EventTagParserDelegate alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [_parserDelegate parseDocumentWithURL:contentURL];
        if(!success)
            NSLog(@"File Parsing Failed");
        
        [self performSelectorOnMainThread:@selector(eventDocumentParsed) withObject:nil waitUntilDone:YES];
    });
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        _importedFile = NO;
        [self importButtonPressed];
    }
}

- (void)timeLineButtonPressed: (UIButton*)sender
{
    
    //Not currently used, timeline is automatically set
    
}


- (void)switchToggled:(UISwitch*)swi
{
    
    if(swi.tag == 0) // stream
    {
        
        
        
    }
    else if(swi.tag == 1) // Save
    {
        if(_saveSwitchWasOn == swi.on)
            return;
        
        if(_saveSwitch.on && _importedFile)
        {
            [_tagSyncer start];
            _progressView.progress = _tagSyncer.progress;
            _progressView.animate = @YES;
            _progressView.showText = @YES;
            _progressView.type = LDProgressStripes;
            _savingView.hidden = NO;
            _saveSwitchWasOn = YES;
        }
        else
        {
            [_tagSyncer pause];
            _progressView.animate = @NO;
            _progressView.showText = @NO;
            _savingView.hidden = YES;
            _saveSwitchWasOn = NO;
        }
        
    }
    
}



#pragma mark - Loading Data

- (void)eventDocumentParsed
{
    _importedFile = YES;
    
    //Player Tags Scroll View
    [self reloadPlayerTagScrollView];
    
    //Reload add data iVars
    [self reloadTableViewDataInfoFromDelegate];
    
    //Put into the Original Tags Dictionary
    _originalGroupTags = [_groupTags mutableCopy];
    _originalTextTags  = [_textTags mutableCopy];
    
    [_tagSyncer pause];
    _tagSyncer = [[ImportTagsSync alloc] initWithGroupXMLTags:_originalGroupTags textXMLTags:_originalTextTags delay:[_delayTextField.text floatValue]];
    _tagSyncer.delegate = self;
    
    if(_saveSwitch.on)
    {
        _savingView.hidden = NO;
        _progressView.progress = 0;
        _progressView.type = LDProgressStripes;
        _progressView.animate = @YES;
        [_tagSyncer start];
    }
    
    //Group Tag ScrollView
    [self reloadGroupTagScrollView];
    
    //Table View
    [self.statsTableView reloadData];
}


- (void)reloadTableViewDataInfoFromDelegate
{
    //Clear Everything
    _groupToTextNames = [NSMutableDictionary dictionary];
    _groupTags = [NSMutableDictionary dictionary];
    _textTags = [NSMutableDictionary dictionary];
    _groupDataDict = [NSMutableDictionary dictionary];
    _textDataDict  = [NSMutableDictionary dictionary];

    
    //Start Loading Info
    NSArray* xmlDataArray = _parserDelegate.tagDicts;
    
    //insert into _groupTimes, and textTimes first, filling Names while that's happening.
    for(NSDictionary* xmlDict in xmlDataArray)
    {
        
        NSArray* xmlDictLabels = [xmlDict objectForKey:@"labels"];
        float dictStartTime = [[xmlDict objectForKey:@"start"] floatValue]/60.0;
        float dictEndTime   = [[xmlDict objectForKey:@"end"] floatValue]/60.0;
        NSUInteger dictId   = [[xmlDict objectForKey:@"ID"] integerValue];
        NSString* dictCode  = [xmlDict objectForKey:@"code"];
        
        //change self.endTime dynamically
        if(dictEndTime > self.endTime - 1)
        {
            self.endTime = dictEndTime + 1;
        }
        
        if(xmlDictLabels)
        {
            for(NSDictionary* labelDict in xmlDictLabels)
            {
                NSString* groupName = [labelDict valueForKey:@"group"];
                NSString* textName  = [labelDict valueForKey:@"text"];
                
                //New groupTag Dictionary Key-Object Pair
                NSMutableArray* groupTimeDicts = [_groupTags objectForKey:groupName];
                NSMutableArray* textNamesArray = [_groupToTextNames objectForKey:groupName];
                
                if(!groupTimeDicts && groupName)
                {
                    groupTimeDicts = [NSMutableArray array];
                    [_groupTags setObject:groupTimeDicts forKey:groupName];
                    
                    textNamesArray = [NSMutableArray array];
                    [_groupToTextNames setObject:textNamesArray forKey:groupName];
                }
                
                
                //New textTag dictionary key-object pair
                NSMutableArray* textTimeDicts = [_textTags objectForKey:textName];
                
                if(!textTimeDicts && textName)
                {
                    textTimeDicts = [NSMutableArray array];
                    [_textTags setObject:textTimeDicts forKey:textName];
                }
                
                BOOL textNameExists = [textNamesArray containsObject:textName];
                if(!textNameExists)
                {
                    [textNamesArray addObject:textName];
                }
                
                //Adding Objects into groupTimeDicts and textTimeDicts
                if(textName)
                {
                    JPXMLTag* tagInfo = [[JPXMLTag alloc] initWithId:dictId :dictCode :dictStartTime :dictEndTime textName:textName];
                    [textTimeDicts addObject:tagInfo];
                    
                    if(groupName)
                        [groupTimeDicts addObject:tagInfo];
                }
    
            }
        }
    }
    
    //After Loaded _groupTags and _textTags, reload other model Objects
    [self reloadTableViewDataInfoFromTagsDictionary];

}


- (void)reloadTableViewDataInfoFromTagsDictionary
{
    _groupDataDict = [NSMutableDictionary dictionary];
    _textDataDict  = [NSMutableDictionary dictionary];

    //_groupDataDict
    NSArray* groupKeyNameArray = [[_groupTags allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    for(int i=0; i<[groupKeyNameArray count]; i++)
    {
        NSString* keyName = [groupKeyNameArray objectAtIndex:i];
        NSArray* tagsInfo = [_groupTags objectForKey:keyName];
        
        NSMutableArray* _groupTableTagData = [NSMutableArray array];
        
        float colStart = 0;
        for(float i =0; i< kTableSections; i++)
        {
            NSMutableArray* _groupSectionTagData = [NSMutableArray array];
            for(JPXMLTag* tag in tagsInfo)
            {
                BOOL tagStartInBound = (tag.self.startTime >= colStart && tag.self.startTime < colStart+self.timeInterval);
                BOOL tagEndInBound = (tag.self.endTime < colStart+self.timeInterval && tag.self.endTime >= colStart);
                if(tagStartInBound || tagEndInBound)
                {
                    [_groupSectionTagData addObject:tag];
                }
            }
            
            [_groupTableTagData addObject:_groupSectionTagData];
            
            colStart+=self.timeInterval;
        }
        
        [_groupDataDict setObject:_groupTableTagData forKey:keyName];
    }
    
    
    //_textDataDict
    NSArray* textKeyNameArray = [[_textTags allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    for(int i=0; i<[textKeyNameArray count]; i++)
    {
        NSString* keyName = [textKeyNameArray objectAtIndex:i];
        NSArray* tagsInfo = [_textTags objectForKey:keyName];
        
        NSMutableArray* _textTableTagData = [NSMutableArray array];
        
        float colStart = 0;
        for(float i =0; i< kTableSections; i++)
        {
            NSMutableArray* _textSectionTagData = [NSMutableArray array];
            for(JPXMLTag* tag in tagsInfo)
            {
                BOOL tagStartInBound = (tag.self.startTime >= colStart && tag.self.startTime < colStart+self.timeInterval);
                BOOL tagEndInBound = (tag.self.endTime < colStart+self.timeInterval && tag.self.endTime >= colStart);
                if(tagStartInBound || tagEndInBound)
                {
                    [_textSectionTagData addObject:tag];
                }
                
            }
            [_textTableTagData addObject:_textSectionTagData];
            
            colStart+=self.timeInterval;
        }
        
        [_textDataDict setObject:_textTableTagData forKey:keyName];
    }

}



- (void)reloadPlayerTagScrollView
{
    _selectedPlayerButtonNames = [NSMutableArray array];
    [[_playerTagScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if([_parserDelegate.codeColors count] > 0)
        [_noPlayerLabel setHidden:YES];
    else
        [_noPlayerLabel setHidden:NO];
    
    NSMutableArray* codeArray = [_parserDelegate.codeColors mutableCopy];
    [codeArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        return [[obj1 objectForKey:@"code"] compare:[obj2 objectForKey:@"code"] options:NSCaseInsensitiveSearch];
    }];
    
    float currXPos = 2;
    
    for(NSDictionary* codeDict in codeArray)
    {
        NSString* codeName = [codeDict objectForKey:@"code"];
        float red= (float)[[codeDict objectForKey: @"R"] integerValue] /65535;
        float green= (float)[[codeDict objectForKey: @"G"] integerValue] /65535;
        float blue= (float)[[codeDict objectForKey: @"B"] integerValue] /65535;
        
        if(codeName && ![codeName isEqual:@""])
        {
            CustomButton* playerTag = [[CustomButton alloc] initWithFrame:CGRectMake(currXPos, 0, 110, _playerTagScrollView.frame.size.height)];
            [playerTag setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]] forState:UIControlStateNormal];
            [playerTag setBackgroundImage:[UIImage imageNamed:@"StatsImportXML.bundle/line-button"] forState:UIControlStateSelected];
            [playerTag addTarget:self action:@selector(playerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [playerTag setTitle:codeName forState:UIControlStateNormal];
            
            [playerTag setFont:[UIFont defaultFontOfSize:15.0f]];
            [playerTag setUserInteractionEnabled:YES];
            [playerTag.titleLabel setTextAlignment:NSTextAlignmentCenter];
            if(red + green + blue > 2.1 || (green > 0.9 && red+green+blue>1.5) || (blue >0.9 && red+green+blue > 1.9))
            {
                [playerTag setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
            [_playerTagScrollView addSubview:playerTag];
            
            currXPos += playerTag.frame.size.width + 2;
        }
        
    }
    
    _playerTagScrollView.contentSize = CGSizeMake(currXPos, PLAYER_BUTTON_HEIIGHT);
    
}



- (void)reloadGroupTagScrollView //(groupTags)
{
    _selectedGroupButtonNames = [NSMutableArray array];
    [[_groupTagScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if([[_groupTags allKeys] count] > 0)
    {
        _noGroupLabel.hidden = YES;
    } else {
        _noGroupLabel.hidden = NO;
    }
    
    float currXPos = 2;
    
    NSMutableArray* groupNamesArray = [[_groupTags allKeys] mutableCopy];
    [groupNamesArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
     
    for(NSString* groupName in groupNamesArray)
    {
        CustomButton* playerTag = [[CustomButton alloc] initWithFrame:CGRectMake(currXPos, 0, 200, _playerTagScrollView.frame.size.height)];
        [playerTag setBackgroundImage:[UIImage imageNamed:@"StatsImportXML.bundle/line-button-grey.png"] forState:UIControlStateNormal];
        [playerTag setBackgroundImage:[UIImage imageNamed:@"StatsImportXML.bundle/line-button.png"] forState:UIControlStateSelected];
        [playerTag addTarget:self action:@selector(groupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [playerTag setFont:[UIFont defaultFontOfSize:15.0f]];
        [playerTag setTitle:groupName forState:UIControlStateNormal];
        [_groupTagScrollView addSubview:playerTag];
        
        currXPos += playerTag.frame.size.width + 2;
    }
    
    _groupTagScrollView.contentSize = CGSizeMake(currXPos, PLAYER_BUTTON_HEIIGHT);
    
    
}



#pragma mark - Table View Delegate and Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_groupDataDict count] > 0 || [_textDataDict count] > 0)
    {
        if([_selectedGroupButtonNames count] == 0)
            return [_originalGroupTags count] + [_originalTextTags count];
        else
        {
            int rows =0;
            
            for(NSString* groupName in _selectedGroupButtonNames)
            {
                rows++;
                NSArray* textNames = [_groupToTextNames objectForKey:groupName];
                rows += [textNames count];
            }
            
            return rows;
        }
        
    }
    else
        return 10;
    
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsCell* cell = [[StatsCell alloc] initWithFrame:CGRectMake(0, 0, kiPadWidthLandscape, 50)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //this line removes the white space of the cell head
    cell.separatorInset = UIEdgeInsetsZero;
    
    [cell addColumns:17 :GRID_CELL_HEIGHT :EVENT_NAME_CELL_LENGTH];
    
    NSString* eventName = [self eventNameForRow:indexPath.row];
    
    UILabel *cellNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, GRID_CELL_HEIGHT)];
    [cellNameLabel setTextAlignment:NSTextAlignmentCenter];
    cellNameLabel.text = eventName;
    cellNameLabel.font = [UIFont defaultFontOfSize:13];
    [cell addSubview:cellNameLabel];
    
    
    //Generating the Buttons
    NSMutableArray* tableButtonArray = [NSMutableArray array];
    
    if(_eventIsAGroup)
    {
        cell.backgroundColor = [JPStyle colorWithHex:@"F6F6F6" alpha:1];
        tableButtonArray = [_groupDataDict objectForKey:eventName];
    }
    else
        tableButtonArray = [_textDataDict objectForKey:eventName];
    
    float currXVal = EVENT_NAME_CELL_LENGTH - 45;
    float totalTagNum =0;
    int i =0;

    for(NSArray* tagArray in tableButtonArray)
    {
        currXVal += 50;
        if([tagArray count] == 0)
            continue;
        
        totalTagNum += [tagArray count];
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(currXVal, 5, 40, 40)];
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderColor = [UIColor orangeColor].CGColor;
        button.layer.borderWidth = 1;
        button.tag = indexPath.row*kTableSections +i;
        button.accessibilityHint = eventName;
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[tagArray count]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tableButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        
        i++;
    }
    
    if(totalTagNum > 0)
    {
        UILabel *totalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(1024 - TOTAL_NUMBER_CELL_LENGTH, 0, TOTAL_NUMBER_CELL_LENGTH, GRID_CELL_HEIGHT)];
        [totalNumberLabel setText:[NSString stringWithFormat:@"%.00f",totalTagNum]];
        [totalNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:totalNumberLabel];
    }
    
    return cell;
}


- (NSString*)eventNameForRow: (NSInteger)row
{
    _eventIsAGroup = NO;
    NSString* eventName = @"";
    
    NSMutableArray* groupNames = [NSMutableArray array];
    if([_selectedGroupButtonNames count] == 0)
    {
        groupNames = [[_groupToTextNames allKeys] mutableCopy];
    }
    else
    {
        groupNames = [_selectedGroupButtonNames mutableCopy];
    }
    
    [groupNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];

    NSInteger accum = -1;
    
    for(int groupNum=0; groupNum<[groupNames count]; groupNum++)
    {
        accum++;
        if(accum == row)
        {
            eventName = groupNames[groupNum];
            _eventIsAGroup = YES;
            break;
        }
        
        NSArray* textNameArray = [_groupToTextNames objectForKey:groupNames[groupNum]];
        for(int i = 0; i<[textNameArray count]; i++)
        {
            accum ++;
            if(accum == row)
            {
                eventName = textNameArray[i];
                _eventIsAGroup = NO;
                break;
            }
        }
        if(accum == row)
            break;
    }
    
    return eventName;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GRID_CELL_HEIGHT;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kiPadWidthLandscape, 40)];
    headerView.backgroundColor = [JPStyle colorWithHex:@"e6e6e6" alpha:1];
    
    UILabel *headerNameLabel = [[UILabel alloc]init];//WithFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, headerView.frame.size.height)];
    [headerNameLabel setFont:[UIFont defaultFontOfSize:17.0]];
    [headerNameLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:headerNameLabel];
    

    [headerNameLabel setFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, headerView.frame.size.height)];
    [headerNameLabel setText:@"Event"];
    
    
    for(int i = 0; i <= kTableSections; i++){
        
        UILabel *timeLabel = [[UILabel alloc]init];
        [timeLabel setText:[NSString stringWithFormat:@"%.2fm", self.startTime + self.timeInterval*i]];
        if(i==kTableSections) {
            [timeLabel setText:[NSString stringWithFormat:@"%.2fm", self.endTime]];
        }
        [timeLabel setFont:[UIFont defaultFontOfSize:11.0]];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [headerView addSubview:timeLabel];
        
        [timeLabel setFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*i - TIME_LABEL_WIDTH/2.0 , 20, TIME_LABEL_WIDTH, headerView.frame.size.height-20)];
    }
    
    UILabel *totalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(930, 0, TOTAL_NUMBER_CELL_LENGTH, headerView.frame.size.height)];
    [totalNumberLabel setText:@"Total"];
    [totalNumberLabel setFont:[UIFont defaultFontOfSize:20.0]];
    [totalNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:totalNumberLabel];

    return headerView;
}


#pragma mark - Text Field Delegate Method
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kDelayTextFieldTag)
    {
        NSScanner* scanner = [NSScanner scannerWithString:textField.text];
        
        BOOL isNumeric = [scanner scanFloat:NULL];
        if(!isNumeric)
        {
            [[[UIAlertView alloc] initWithTitle:@"Enter A Number" message:@"Delay value in seconds should be a number." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            textField.text = @"0";
        }
        
    }
    
}



#pragma mark - Button Callback Methods
- (void)playerButtonPressed: (CustomButton*)button
{
    //Modifying the Button and array of player names
    if(!button.selected)
    {
        button.selected = YES;
        [_selectedPlayerButtonNames addObject:button.titleLabel.text];
    }
    else
    {
        button.selected = NO;
        while([_selectedPlayerButtonNames containsObject:button.titleLabel.text])
        {
            [_selectedPlayerButtonNames removeObject:button.titleLabel.text];
        }
    }
    
    //Reload Model
    [self reloadTagsDictionaryForPlayerFilter];
    [self reloadTableViewDataInfoFromTagsDictionary];
    
    //Reload Table View
    [self.statsTableView reloadData];
}


- (void)reloadTagsDictionaryForPlayerFilter
{
    if([_selectedPlayerButtonNames count] == 0)
    {
        _groupTags = [_originalGroupTags mutableCopy];
        _textTags = [_originalTextTags mutableCopy];
        return;
    }
    
    _groupTags = [NSMutableDictionary dictionary];
    _textTags = [NSMutableDictionary dictionary];
    
    NSArray* groupTagNames = [_originalGroupTags allKeys];
    NSArray* textTagNames = [_originalTextTags allKeys];
    
    for(NSString* groupKey in groupTagNames)
    {
        NSArray* tagsArray = [_originalGroupTags valueForKey:groupKey];
        NSMutableArray* filteredTagsArray = [NSMutableArray array];
        
        for(JPXMLTag* tag in tagsArray)
        {
            NSString* codeName = tag.code;
            
            for(NSString* playerName in _selectedPlayerButtonNames)
            {
                if([playerName isEqual:codeName])
                {
                    [filteredTagsArray addObject:tag];
                }
            }
        }
        
        if([filteredTagsArray count]>0)
            [_groupTags setObject:filteredTagsArray forKey:groupKey];
    }
    
    for(NSString* textKey in textTagNames)
    {
        NSArray* tagsArray = [_originalTextTags valueForKey:textKey];
        NSMutableArray* filteredTagsArray = [NSMutableArray array];
        
        for(JPXMLTag* tag in tagsArray)
        {
            NSString* codeName = tag.code;
            
            for(NSString* playerName in _selectedPlayerButtonNames)
            {
                if([playerName isEqual:codeName])
                {
                    [filteredTagsArray addObject:tag];
                }
            }
        }
        
        if([filteredTagsArray count]>0)
            [_textTags setObject:filteredTagsArray forKey:textKey];
    }
}



- (void)groupButtonPressed: (CustomButton*)button
{
    if(!button.selected)
    {
        button.selected = YES;
        [_selectedGroupButtonNames addObject:button.titleLabel.text];
    }
    else
    {
        button.selected = NO;
        while([_selectedGroupButtonNames containsObject:button.titleLabel.text])
        {
            [_selectedGroupButtonNames removeObject:button.titleLabel.text];
        }
    }
    
    [self.statsTableView reloadData];
}


- (void)tableButtonPressed: (UIButton*)button
{
    NSInteger col = button.tag%kTableSections;
    
    NSArray* tagInfoArrayForRow = [_textDataDict objectForKey:button.accessibilityHint];
    if(!tagInfoArrayForRow)
    {
        tagInfoArrayForRow = [_groupDataDict objectForKey:button.accessibilityHint];
    }
    
    NSArray* selectedTagsArray = nil;
    int accum =-1;
    for(int i=0; i<kTableSections; i++)
    {
        NSArray* tagArray = tagInfoArrayForRow[i];
        if([tagArray count] >0)
        {
            accum++;
        }
        
        if(accum == col)
        {
            selectedTagsArray = tagArray;
            break;
        }
    }
    
    DurationTableViewController * vc = [[DurationTableViewController alloc] initWithStyle:UITableViewStylePlain];
    float delay = [_delayTextField.text floatValue];
    vc.delayInSeconds = delay;
    vc.xmlTags = selectedTagsArray;
    
    //Popover controller
    float popHeight = 100;
    if([selectedTagsArray count]<=1)
        popHeight = 100;
    else if([selectedTagsArray count]<=4)
        popHeight = 100*[selectedTagsArray count];
    else
        popHeight = 400;
    
    self.durationPopController = [[UIPopoverController alloc] initWithContentViewController:vc];
    vc.parentPopover = self.durationPopController;
    self.durationPopController.popoverContentSize = CGSizeMake(320, popHeight);
    
    [self.durationPopController presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}




#pragma mark - Import Tags Sync Delegate Methods

- (void)importTagsSyncDidFinishUploadingTags
{
    _savingView.hidden = YES;
    _progressView.progress = 100;
    _progressView.animate = @0;
    _progressView.type = LDProgressSolid;
}

- (void)importTagsSyncProgressChangedTo: (float)progress
{
    _progressView.progress = progress;
}

#pragma mark - Setters
- (void) setEndTime:(float)endTime
{
    _endTime = endTime;
    self.timeInterval = (endTime - self.startTime) / kTableSections;
    
    [_timeLineInfoButton setTitle:[NSString stringWithFormat:@"Duration: [%.0f, %.0f)",self.startTime,self.endTime] forState:UIControlStateNormal];
}


@end
