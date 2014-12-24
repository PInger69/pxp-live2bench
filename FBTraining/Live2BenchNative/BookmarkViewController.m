////
//  BookmarkViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BookmarkViewController.h"
#import "AppDelegate.h"
#import "ClipSharePopoverViewController.h"
#import "EdgeSwipeButton.h"
#import "EdgeSwipeEditButtonsView.h"
#import "HeaderBar.h"
#import "CommentingRatingField.h"
#import "RatingInput.h"
#import "JPReorderTableView.h"
#import "JPTripleSwipeCell.h"
#import "UserInterfaceConstants.h"
#import "JPStyle.h"
#import "JPFont.h"
#import "MyClipFilterViewController.h"
#import "TagPopOverContent.h"
#import "SVStatusHUD.h"
//#import "GDFileUploader.h"
#import "DPBFileUploader.h"
#import "NSObject+LBCloudConvenience.h"
#import "CustomAlertView.h"
#import "VideoBarMyClipViewController.h"
#import "FullVideoBarMyClipViewController.h"
#import "TagPopOverContent.h"

#import "FullScreenViewController.h"
#import "ScreenController.h"


#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define LABEL_HEIGHT                 40
#define TABLE_WIDTH                 390
#define COMMENTBOX_HEIGHT           210
#define COMMENTBOX_WIDTH            530//560

@interface BookmarkViewController ()

@end

@implementation BookmarkViewController{
    NSMutableArray                      * tagsWillUploadToDB;
    UIImageView                         * playbackRateBackGuide;
    UIImageView                         * playbackRateForwardGuide;
    UILabel                             * playbackRateBackLabel;
    UILabel                             * playbackRateForwardLabel;
    int                                 totalDBTagNumber;
    int                                 successDBTagNumber;
    BOOL                                isModifyingPlaybackRate;
    BOOL                                isFrameByFrame;
    float                               playbackRateRadius;
    float                               frameByFrameInterval;
    UIImageView                         * teleImage; //for telestration playback

    
    // Richards's new UI Elements
    MyClipFilterViewController          * _filterToolBoxView;
    HeaderBar                           * headerBar;
    CommentingRatingField               * commentingField;
    CustomLabel                         * numTagsLabel;
    VideoBarMyClipViewController        * newVideoControlBar;
    FullVideoBarMyClipViewController    * newFullScreenVideoControlBar;
    FullScreenViewController            * testFullScreen;
    ScreenController                    * externalControlScreen;
}

@synthesize startTime;
@synthesize allTags;
@synthesize typesOfTags;
@synthesize selectedTag;
@synthesize uController;
@synthesize popoverController;
@synthesize mailController;
@synthesize progressLabel;
@synthesize progressBar;
@synthesize progressBarIndex;
@synthesize facebookAccount;
@synthesize _accountStore;
@synthesize selectedCellRowsIndex;
@synthesize responseDataString;
@synthesize errorString;
@synthesize startUploading;
@synthesize uploadFileResponse;
@synthesize uploadFileResponseLabel;
@synthesize allEvents;
@synthesize tagsToDisplay=_tagsToDisplay;
@synthesize videoPlayer;
@synthesize teleButton;
@synthesize teleViewController;
@synthesize playbackRateBackButton;
@synthesize playbackRateForwardButton;
@synthesize fullScreenMode;
@synthesize savingToAlbumArray;
@synthesize notCompatibleArray;
@synthesize errorSavingArray;
@synthesize updateTableViewTimer;

//back from fullscreen, the viewwillappear function will be called twice.will change the value of fullscreenmode when the viewwillappear function was called the second time(viewWillAppearCalled = 2)
int viewWillAppearCalled;

#pragma mark - General Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"My Clip", nil) imageName:@"myClipTab"];
    }
    return self;
}

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        
        [self setMainSectionTab:NSLocalizedString(@"My Clip", nil) imageName:@"myClipTab"];
    }
    externalControlScreen = _appDel.screenController;
    return self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!globals) {
        globals = [Globals instance];
    }
    
    uController = [[UtilitiesController alloc]init];
    //facebook = [[Facebook alloc] initWithAppId:@"144069185765148"];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                //// we recurse here, in order to update buttons and labels
                //[self updateView];
            }];
        }
    }
    
    self.videoPlayer = [[VideoPlayer alloc]init];
    [self.videoPlayer initializeVideoPlayerWithFrame:CGRectMake(1, COMMENTBOX_HEIGHT+LABEL_HEIGHT*3.5, COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
    
    allTags = [[NSMutableArray alloc]init];
    
    //array of file paths
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    fileManager = [NSFileManager defaultManager];
    
    //Find path to accountInformation plist
    NSString *accountInformationPath = [documentsDirectory stringByAppendingPathComponent:@"accountInformation.plist"];
    NSMutableDictionary *accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: accountInformationPath];
    userIdd = [accountInfo objectForKey:@"hid"];
    
    
    [self setupView];
    
    
    typesOfTags = [[NSMutableArray alloc]init];
    tagsDidViewed = [[NSMutableArray alloc]init];
    
    fullScreenMode = FALSE;
    progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 110,200 ,25)];
    [progressLabel setText:@"Processing"];
    [progressLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:progressLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Entering FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Exiting FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDropboxUpload) name:@"Show DB Upload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDropboxUpload) name:@"Stop DB Upload" object:nil];
    
    
    progressBar = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    [progressBar setFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 155,200 ,25)];
    [self.view addSubview:progressBar];

    
    uploadFileResponseLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 180,120 , 25)];
    [uploadFileResponseLabel setText:@"sharing:"];
    [uploadFileResponseLabel setBackgroundColor:[UIColor clearColor]];
    [uploadFileResponseLabel setHidden:TRUE];
    [self.view addSubview:uploadFileResponseLabel];
    
    uploadFileResponse = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(uploadFileResponseLabel.frame)+10, uploadFileResponseLabel.frame.origin.y-5, TABLE_WIDTH+200, 30)];
    [uploadFileResponse setFont:[UIFont systemFontOfSize:15.0f]];
    [uploadFileResponse setBackgroundColor:[UIColor clearColor]];
    [uploadFileResponse setUserInteractionEnabled:FALSE];
    [uploadFileResponse setHidden:TRUE];
    [self.view addSubview:uploadFileResponse];
    
    
    
    // This is for the tag count
    numTagsLabel = [[CustomLabel alloc] init];
    [numTagsLabel setMargin:CGRectMake(0, 5, 0, 5)];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:@"Tags"];
    [numTagsLabel setTextColor:[UIColor whiteColor]];
    [numTagsLabel setBackgroundColor:[UIColor lightGrayColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [self.view addSubview:numTagsLabel];
 
    newVideoControlBar = [[VideoBarMyClipViewController alloc]initWithVideoPlayer:videoPlayer];
    [self.view addSubview:newVideoControlBar.view];
    
    
    testFullScreen = [[FullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
//    [self.view addSubview:testFullScreen.view];
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    [globals.VIDEO_PLAYER_LIST_VIEW pause];
    [globals.VIDEO_PLAYER_LIVE2BENCH pause];
    globals.VIDEO_PLAYER_BOOKMARK = self.videoPlayer;
    

    
    //get all the events information which will be used to display home team, visit team
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"EventsHid.plist"];
    NSMutableArray *eventsData = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
    for (NSDictionary *event in eventsData) {
        
        if (!allEvents) {
            allEvents = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:event, nil] forKeys:[[NSArray alloc]initWithObjects:[event objectForKey:@"name"], nil]];
        }else{
            [allEvents setObject:event forKey:[NSString stringWithFormat:@"%@",[event objectForKey:@"name"]]];
        }
        
    }
    
    if(!_filterToolBoxView)
    {
        _filterToolBoxView = [[MyClipFilterViewController alloc]initWithTagData:globals.BOOKMARK_TAGS];
        [_filterToolBoxView setOrigin:CGPointMake(60, 194)];
        [_filterToolBoxView close:NO]; // is animated
        [_filterToolBoxView onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
        [_filterToolBoxView viewDidAppear:TRUE];
    }
    
    
    globals.IS_IN_BOOKMARK_VIEW = TRUE;
    globals.IS_IN_LIST_VIEW = FALSE;
    globals.IS_IN_CLIP_VIEW = FALSE;
    globals.IS_IN_FIRST_VIEW = FALSE;
    
    if(![self.view.subviews containsObject:self.videoPlayer.view])
    {
        [self.videoPlayer.view setFrame:CGRectMake(1, COMMENTBOX_HEIGHT+LABEL_HEIGHT*3.5, COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
        [self.view addSubview:self.videoPlayer.view];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
        
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
        
    }else{
        //when just enter bookmark view, no video is selected,leave the player screen black
        NSURL *videoURL = [NSURL URLWithString:@""];
        [self.videoPlayer setVideoURL:videoURL];
        [self.videoPlayer setPlayerWithURL:videoURL];
    }
    

    //get all data for bookmark
    [self fetchedData];
    //number of cells which have been viewed
    cellSelectedNumber = 0;
    //if no cell has been viewed (or selected),disable the comment and rating box
    
    commentingField.enabled = NO;
    commentingField.ratingScale.rating = 0;
    [commentingField clear];
    
    fullScreenMode = FALSE;
    //firstTimeStartMoviePlayer = TRUE;
    //set the right play back rate in the case: pause viedo,then switch between full screen and normal screen, then resume to play with proper play back rate
    [updatePlayRateTimer invalidate];
    updatePlayRateTimer = nil;
    updatePlayRateTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(updatePlayRate:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    
    //when new bookmark tag is created, reload the table view
    [updateTableViewTimer invalidate];
    updateTableViewTimer = nil;
    updateTableViewTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTableView:)
                                                        userInfo:nil
                                                         repeats:YES];
    
    
    //if all the new bookmark tags are received from the server or no new bookmark tag is processed, hide the progress bar;Otherwise display the progress bar to indicate the process of loading new bookmark tags
    if (globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO || globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS <1) {
        [progressLabel setHidden:TRUE];
        [progressBar setHidden:TRUE];
    }else{
        [progressLabel setHidden:FALSE];
        [progressBar setHidden:FALSE];
    }
    
    [self.videoPlayer pause];
    
    [self.tableView reloadData];
    
    [newVideoControlBar viewDidAppear:NO];


    
//    [externalControlScreen moveVideoToExternalDisplay:self.videoPlayer];
    

}




-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [numTagsLabel setFrame:CGRectMake(self.tableView.frame.origin.x,
                                      CGRectGetMaxY(self.tableView.frame),
                                      self.tableView.frame.size.width,
                                      21.0f)];
    UIEdgeInsets insets = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets)];
    
    // This was just a test
//    //playing tag from book mark video folder
//    NSString *tagVideoPath = @"http://192.168.3.100/pub/test/list.m3u8";
//    //when play back from ios device storage set "nsurl" by using "fileurlwithpath" instead of "urlwithstring"
//    NSURL *videoURL = [NSURL URLWithString:[tagVideoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    
//    [self.videoPlayer setVideoURL:videoURL];
//    
//    [self.videoPlayer setPlayerWithURL:videoURL];
//    
//    [self.videoPlayer play];
   
//      [testFullScreen viewDidAppear:NO];
}


//initialize comment box and if one tag is selected, the tag details will show in the box too
-(void)setupView{
    [self.view setBackgroundColor:[UIColor whiteColor]];
   
    headerBar = [[HeaderBar alloc]initWithFrame:CGRectMake(0,55,TOTAL_WIDTH, LABEL_HEIGHT)];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];
    
    
    
    commentingField = [[CommentingRatingField alloc]initWithFrame:CGRectMake(1,74, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT+60) title:@"Comment"];
    commentingField.enabled = NO;
    [commentingField onPressRatePerformSelector:@selector(sendRatingNew:) addTarget:self ];
    [commentingField onPressSavePerformSelector:@selector(sendComment2) addTarget:self];
    [commentingField.fieldTitle setHidden:YES];
    [self.view addSubview:commentingField];
    
    
    
    
    //Reorder Table View
    self.tableView = [[JPReorderTableView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentingField.frame) + 5.0f, CGRectGetMaxY(headerBar.frame), self.view.bounds.size.width - CGRectGetMaxX(commentingField.frame) - 30.0f, self.view.bounds.size.width - CGRectGetMaxY(headerBar.frame) - 100.0f) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.reorderDataSource = self;
    self.tableView.reorderDelegate = self;
    [self.view addSubview:self.tableView];
    //////////////////////////////////////////////
    
    self.tableActionButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    [self.tableActionButton setFrame:CGRectMake(kiPadWidthLandscape - 100, 60, 80, 30)];
    self.tableActionButton.titleLabel.font = [UIFont defaultFontOfSize:18];
    [self.tableActionButton setTitle:@"" forState:UIControlStateNormal];
    [self.tableActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.tableActionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.tableActionButton setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateHighlighted];
    [self.tableActionButton setHidden:YES];
    [self.tableActionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: self.tableActionButton];
    
    /////////////////////////////////////////////////////////////////
    //Swipe Edit View with reorder, filter ... functions
    self.edgeSwipeButtons = [[EdgeSwipeEditButtonsView alloc] initWithFrame:CGRectMake(1024-44, 55, 44, 768-55)];
    self.edgeSwipeButtons.delegate = self;
    [self.view addSubview:self.edgeSwipeButtons];
    /////////////////////////////////////////////////////////////////
    
    
}


//used to indicate loading book mark video from server
-(void)updateTableView:(NSTimer*)timer{
    //only when all the book mark tags are received from the server,globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO will be true
    if (!globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO) {
        if (globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED ==0) {
            [progressBar setProgress:0.0];
        }
        [progressLabel setText:@"Processing"];
        [progressLabel setHidden:FALSE];
        [progressBar setHidden:FALSE];
        //when there is a book mark tag received from server, globals.RECEIVED_ONE_BOOKMARK_VIDEO will be true
        if (globals.RECEIVED_ONE_BOOKMARK_VIDEO) {
            //old position of the progressed bar (the blue bar)
            float oldProgressValue = (float)(globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED-1)/(float)globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS;
            //the duration the progress bar will increase when one new book mark tag is received
            float progressDuration = 1.0/(float)globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS;
            //split one progressDuration into 5 parts, then the progress bar will increase slowly instead of jumping
            float updatedProgressValue = oldProgressValue + ((float)progressBarIndex/5.0)*progressDuration;
            [progressBar setProgress:updatedProgressValue];
            progressBarIndex++;
            //if the progress bar finishes one progress duration, reload data for the tableview and reset all the variables
            if (progressBarIndex==6) {
                // [progressLabel setTextAlignment:NSTextAlignmentRight];
                [self fetchedData];
                globals.RECEIVED_ONE_BOOKMARK_VIDEO = FALSE;
                progressBarIndex = 0;
                //if all book mark tags are received from server, then reset all the variables
                if (globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED ==globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS) {
                    [progressLabel setText:@"Done!"];
                    globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO = TRUE;
                    globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED = 0;
                    globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS = 0;
                    
                    NSMutableString *downloadsDoneMessage = [NSMutableString stringWithFormat:@"Finished downloading clips."];
                    UIAlertView *downloadsFinishedAlert;
                    if ([globals.BOOKMARK_QUEUE_FAILED count] > 0){
                        downloadsDoneMessage = [@"Could not be downloaded. Please try it again later."mutableCopy];
                        BOOL didFail = FALSE;
                        for(NSDictionary *dict in globals.BOOKMARK_QUEUE_FAILED){
                            
                            NSString *videoNameStr = [[dict objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[dict objectForKey:@"vidurl"] lastPathComponent]];
                            NSString *videoFilePath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoNameStr]];
                            if (![[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]) {
                                downloadsDoneMessage = [NSMutableString stringWithFormat:@"%@ at %@.\n%@",[[dict objectForKey:@"tag"] objectForKey:@"name"],[[dict objectForKey:@"tag"] objectForKey:@"displaytime"],downloadsDoneMessage];
                                didFail = TRUE;
                            }
                        }
                        
                        if (didFail) {
                            downloadsFinishedAlert = [[CustomAlertView alloc] initWithTitle:@"myplayXplay" message:downloadsDoneMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                            [downloadsFinishedAlert setAccessibilityLabel:@"downloadFailedAlert"];
                            [downloadsFinishedAlert show];
                            //[globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:downloadsFinishedAlert];
                        }
                        
                    } else {
                        //downloadsFinishedAlert = [[UIAlertView alloc] initWithTitle:@"myplayXplay" message:downloadsDoneMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"finished downloading" forKey:@"name"];
                        [globals.TOAST_QUEUE addObject:infoDict];
                    }
                    
                    
                    
                    [progressLabel setHidden:TRUE];
                    [progressBar setHidden:TRUE];
                    //[self performSelector:@selector(hideProgress) withObject: nil afterDelay:5];
                }
            }
        }
    }
}

//get all the bookmark tags from the global bookmark dictionary
- (void)fetchedData
{
    for(int i=0;i<4;i++)
    {
        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];
        [typesOfTags addObject:sectionArray];
    }
    
    //NSMutableArray *allBookmarkTags; // contains the bookmarks that will be displayed after iterating through the global bookmarks
    
    
    hasBeenOrdered=FALSE;
    
    //url for the plist where the ordered array of bookmarks will be stored -- ordered by user
    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    int orderedTagCount = [[NSArray arrayWithContentsOfFile:orderedBookmarkPlist] count];
    
    if(!fileManager)
    {
        fileManager = [NSFileManager defaultManager]; //make sure we have a filemanager
    }
    
    //now grab the bookmark tags from the global dictionary, we need to iterate through and add all of them to an array so we can get the total number of bookmarks in the end
    NSMutableArray *allBMTags = [[NSMutableArray alloc] init]; //temporary array to add the thumb items to
    for(NSDictionary *d in [globals.BOOKMARK_TAGS allValues])
    {
        [allBMTags addObjectsFromArray:[d allValues]];
    }
    //if there is no downloaded tags or the total bookmark tags'count and ordered bookmark tags' count are not equal, and the ordered bookmark plist file exists, we need to delete this file
    if((allBMTags.count == 0 || allBMTags.count != orderedTagCount )&& [fileManager fileExistsAtPath:orderedBookmarkPlist]){
        [fileManager removeItemAtPath:orderedBookmarkPlist error:nil];
    }
    //if ordered bookmark plist file not exist or the total number of bookmark tags are greater than the number of ordered bookmark tags, we need to
    //use the array of all bookmark tags for this view to display
    if(![fileManager fileExistsAtPath:orderedBookmarkPlist])
    {
        allTags = allBMTags;
        
    }else{
        //if the user has ordered and they aren't filtering then grab the ordered list from the plist
        hasBeenOrdered=TRUE;
        allTags =[[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist];
    }
    
    
    //allTags = [allBookmarkTags mutableCopy];
    
    //after adding all of the old bookmarks and the new bookmarks to the array we need to make sure we write the new array of bookmarks in whichever order they are in to the plist
    [allTags writeToFile:orderedBookmarkPlist atomically:TRUE];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for(NSDictionary *tag in allTags){
        if ([tag isKindOfClass:[NSDictionary class]]) {
            if ([tag objectForKey:@"colour"] != nil && [[tag objectForKey:@"type"]integerValue]!=3) {
                //type == 2, line tag,type == 0 normal tag, type == 10, strength tag;if the tag was deleted, type value will be 3 and "deleted" value will be 1
                if([[tag objectForKey:@"type"] intValue]==0||[[tag objectForKey:@"type"] intValue]==100)
                {
                    [tempArray addObject:tag];
                    if(![[typesOfTags objectAtIndex:0] containsObject:[tag  objectForKey:@"name"]])
                    {
                        [[typesOfTags objectAtIndex:0] addObject:[tag  objectForKey:@"name"]];
                    }
                    
                }else if([[tag objectForKey:@"type"] intValue]==10){
                    [tempArray addObject:tag];
                    if(![[typesOfTags objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
                    {
                        [[typesOfTags objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
                    }
                    
                }else{
                    [tempArray addObject:tag];
                    if(![[typesOfTags objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
                    {
                        [[typesOfTags objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
                    }
                }
                
            }
        }
    }
    
    self.tagsToDisplay=[tempArray mutableCopy];
    
    if (self.tagsToDisplay.count > 0) {
        
        [self.tableView reloadData];
    }
    
    
    if ([globals.TAGGED_ATTS_BOOKMARK count] >0){
        if(![self.view.subviews containsObject:_filterToolBoxView.view])
        {
            [_filterToolBoxView.view setAlpha:0.95f];
            [self.view addSubview:_filterToolBoxView.view];
            
        }
        //  [self.view insertSubview:filterToolBoxListViewController.view atIndex:self.view.subviews.count-1];
//        [_filterToolBoxView viewDidAppear:TRUE];
    }
    
}


//return the tag dictionary of each cell
- (NSMutableDictionary*)tagAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tagsToDisplay objectAtIndex:indexPath.row];
}

#pragma mark - Triple Swipe Table Methods

- (void)actionButtonPressed: (UIButton*)button
{
    if(self.tableView.selectionType == JPTripleSwipeCellSelectionLeft)
    {
        [self shareTagsReorderTable:button];
    }
    else if(self.tableView.selectionType == JPTripleSwipeCellSelectionRight)
    {
        [self deleteCells];
    }
}

- (NSInteger)reorderTableView:(JPReorderTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tagsToDisplay count];
}


- (UITableViewCell*)reorderTableView:(JPReorderTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    BookmarkViewCell *cell = (BookmarkViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BookmarkViewCell"];
    
    if(!cell)
        cell = [[BookmarkViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BookmarkViewCell"];
    
    
    NSDictionary *tag = [self tagAtIndexPath:indexPath];
    
    if ([tag isKindOfClass:[NSDictionary class]])
    {
        if ([[tag objectForKey:@"event"] isEqualToString:@"live"]) {
            [cell.eventDate setText:[tag objectForKey:@"event"]];
        }else{
            NSArray *tempArr = [[tag objectForKey:@"event" ] componentsSeparatedByString:@"_"];
            [cell.eventDate setText: [NSString stringWithString:[tempArr objectAtIndex:0] ]];
        }
        
        [cell.eventDate setFont:[UIFont boldSystemFontOfSize:20.f]];
        [cell.tagName setText:[tag objectForKey:@"name"]];
        [cell.tagName setFont:[UIFont boldSystemFontOfSize:20.f]];
        [cell.tagTime setText: [tag objectForKey:@"displaytime"]];
        [cell.tagTime setFont:[UIFont boldSystemFontOfSize:20.f]];
        [cell updateIndexWith:indexPath.row+1];
        //when the tag is viewed, the viewed information is saved in the dictionary:"globals.CURRENT_EVENT_THUMBNAILS".So if repopulate the table view, we should always check the latest tag
        NSMutableDictionary *updatedTag = [[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"] ] objectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
        
        //if the tag does not exist in globals.BOOKMARK_TAGS, donot display it
        if(updatedTag == nil){
            [self.tagsToDisplay removeObject:tag];
            [self.tableView reloadData];
        }
        
    }

    return cell;
}


- (void)reorderTableView:(JPReorderTableView *)tableView selectionTypeChangedTo:(JPTripleSwipeCellSelection)type
{
    if(type == JPTripleSwipeCellSelectionNone)
    {
        isEditingClips = NO;
        self.tableActionButton.hidden = YES;
    }
    else
    {
        isEditingClips = YES;
        self.tableActionButton.hidden = NO;
    }
    
    if(type == JPTripleSwipeCellSelectionLeft)
    {
        [self.tableActionButton setTitle: @"Share" forState:UIControlStateNormal];
    }
    else if(type == JPTripleSwipeCellSelectionRight)
    {
        [self.tableActionButton setTitle: @"Delete" forState:UIControlStateNormal];
    }
}
    
- (void)reorderTableView:(JPReorderTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
        [headerBar setHeaderBarSortType:HBSortNone];
    id object = [self.tagsToDisplay objectAtIndex:sourceIndexPath.row]; //object thats being dragged
    [self.tagsToDisplay removeObjectAtIndex:sourceIndexPath.row];//delete it from where it is
    [self.tagsToDisplay insertObject:object atIndex:destinationIndexPath.row];//add it back to where it should be
    
    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    
    //boring stuff to make sure filemanager actually exists
    if(!fileManager)
    {
        fileManager = [NSFileManager defaultManager];
    }
    if(![fileManager fileExistsAtPath:orderedBookmarkPlist])
    {
        [fileManager createFileAtPath:orderedBookmarkPlist contents:nil attributes:nil];
    }
    
    //need to write here so that we can retain the information if user exits the window or the app
    [self.tagsToDisplay writeToFile:orderedBookmarkPlist atomically:TRUE]; //write to the ordered bookmark plist
}
    

- (void)reorderTableView:(JPReorderTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (teleImage) {
        [teleImage removeFromSuperview];
        teleImage=nil;
    }
    
    if (self.videoPlayer.teleBigView) {
        [self.videoPlayer.teleBigView removeFromSuperview];
        self.videoPlayer.teleBigView=nil;
    }
    
    wasPlayingIndexPath = indexPath;
    
    cellSelectedNumber = 1;
    NSDictionary *data = [self tagAtIndexPath:indexPath];
    selectedTag = [[[globals.BOOKMARK_TAGS objectForKey:[data objectForKey:@"event"]] objectForKey:[NSString stringWithFormat:@"%@",[data objectForKey:@"id"]]]mutableCopy];
    
    if (![globals.TAGS_WERE_SELECTED_BMVIEW containsObject:[selectedTag objectForKey:@"id"]]) {
        [globals.TAGS_WERE_SELECTED_BMVIEW addObject:[selectedTag objectForKey:@"id"]];
    }
    globals.TAG_WAS_SELECTED_BMVIEW = [[selectedTag objectForKey:@"id"]intValue];
    
    
    if([[selectedTag objectForKey:@"type"] intValue]==4)
    {
        //playback telestration
        globals.IS_PLAYBACK_TELE = TRUE;
        
        //reset video url to emtpy string for avplayer
        NSURL *videoURL = [NSURL URLWithString:@""];
        [self.videoPlayer setPlayerWithURL:videoURL];
        
        if(self.videoPlayer.isFullScreen){
            teleImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 1024, 576)];
        }else{
            teleImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.videoPlayer.view.bounds.size.width, self.videoPlayer.view.bounds.size.height)];
        }
        
        //globals.IS_TELE=TRUE;
        
        NSString *teleFilePath;
        teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[selectedTag objectForKey:@"event"],[selectedTag objectForKey:@"id"]] ];
        if (![[NSFileManager defaultManager] fileExistsAtPath:teleFilePath]) {
            teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.jpg",[selectedTag objectForKey:@"event"],[selectedTag objectForKey:@"id"]] ];
        }
        [teleImage setImage:[UIImage imageWithContentsOfFile:teleFilePath]];
        
        self.videoPlayer.teleBigView = teleImage;
        globals.CURRENT_PLAYBACK_TAG = selectedTag;
        [self.videoPlayer.view addSubview:self.videoPlayer.teleBigView];
        
        if (teleButton) {
            teleButton.hidden = TRUE;
        }
        
    }else{
        
        //playing tag from book mark video folder
        NSString *tagVideoPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[selectedTag objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[selectedTag objectForKey:@"id"]]]];
        //when play back from ios device storage set "nsurl" by using "fileurlwithpath" instead of "urlwithstring"
        NSURL *videoURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file://%@",tagVideoPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.videoPlayer setVideoURL:videoURL];
        
        [self.videoPlayer setPlayerWithURL:videoURL];
        
        [self.videoPlayer play];
        
        if (!videoPlayer.timeObserver) {
            [videoPlayer addPlayerItemTimeObserver];
        }
        
    }
    
    currentPlayingTag = [selectedTag copy];
    /*TO DELETE seek controlls
    tagEventName.text = [currentPlayingTag objectForKey:@"name"];
    */
    
#pragma mark Rich2 when an item is selected

    

    commentingField.enabled = YES;
    [commentingField clear];
    commentingField.text = ( [selectedTag objectForKey:@"comment"] ) ? [selectedTag objectForKey:@"comment"] : @"";
    commentingField.ratingScale.rating = [[selectedTag objectForKey:@"rating"]integerValue];

    [newVideoControlBar setTagName:[currentPlayingTag objectForKey:@"name"]];
    if (newFullScreenVideoControlBar)        [newFullScreenVideoControlBar setTagName:[currentPlayingTag objectForKey:@"name"]];

    
    // End for richard added
    
    
    NSString *tag_id = [NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]];
    [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]] setObject:selectedTag forKey:tag_id];
    
    tagId = [selectedTag objectForKey:@"id"];
    
    //play video
    int duration = [[selectedTag objectForKey:@"duration"] integerValue];
    globals.HOME_END_TIME = duration;
    
  /*DELETE
       [slowMoButton setHidden:FALSE];

    [currentSeekBackButton setHidden:FALSE];
    [currentSeekForwardButton setHidden:FALSE];
*/
}

#pragma mark - Reorder Table Related Methods


-(void)deleteCells
{
    
    if ([self.tableView.cellsSelected containsObject:@YES]) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setAccessibilityLabel:@"deletealert"];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:@"Are you sure you want to delete these tags?"];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert show];
    }
    
}


-(void)shareTags: (UIButton*)eButton
{
    if ([self.tableView.cellsSelected containsObject:@YES])
    {
        ClipSharePopoverViewController* popoverContent = [[ClipSharePopoverViewController alloc] init];
        popoverContent.bookmarkViewController = self;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate = self;
        [popoverController setPopoverContentSize:CGSizeMake(300, 200) animated:YES];
        [popoverController presentPopoverFromRect:CGRectMake(eButton.frame.origin.x + self.edgeSwipeButtons.frame.size.width/2.0f, eButton.frame.origin.y, eButton.frame.size.width, eButton.frame.size.height) inView:self.edgeSwipeButtons permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    else
    {
        [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
    }
}



-(void)shareTagsReorderTable: (UIButton*)eButton
{
    if ([self.tableView.cellsSelected containsObject:@YES])
    {
        ClipSharePopoverViewController* popoverContent = [[ClipSharePopoverViewController alloc] init];
        popoverContent.bookmarkViewController = self;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate = self;
        [popoverController setPopoverContentSize:CGSizeMake(300, 200) animated:YES];
        [popoverController presentPopoverFromRect:CGRectMake(eButton.frame.origin.x + self.edgeSwipeButtons.frame.size.width/2.0f, eButton.frame.origin.y, eButton.frame.size.width, eButton.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight|UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
    }
}

    
//after viewing a tag, save it into the tagsDidViewed.plist file
-(void)saveTagsDidViewed:(id)tag
{
    NSString *tagsDidViewedPath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:@"tagsDidViewed.plist"];
    fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: tagsDidViewedPath])
    {
        tagsDidViewedPath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent: [NSString stringWithFormat: @"tagsDidViewed.plist"] ];
    }
    [tag writeToFile:tagsDidViewedPath atomically:YES];
}
    
#pragma mark - Swipe Buttons Methods
- (void)slideFilterBox
{
    
    if(!blurView)
    {
        blurView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height)];
        blurView.backgroundColor = [UIColor colorWithRed:0.f
                                                   green:0.f
                                                    blue:0.f
                                                   alpha:0.7f];
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFilterToolbox)];
        [blurView addGestureRecognizer:tapRec];
        
        blurView.hidden = YES;
    }
    [self.view insertSubview:blurView aboveSubview:newVideoControlBar.view];
    [self.view insertSubview:_filterToolBoxView.view aboveSubview:blurView];
    
    
    blurView.hidden = NO;
    [_filterToolBoxView open:YES]; // Slide filter open
    
    //TODO this is a bug
//    if([self.tableView numberOfRowsInSection:0] > 0)
//    {
//        blurView.hidden = NO;
//        [_filterToolBoxView open:YES]; // Slide filter open
//        
//    } else {
//        [self.edgeSwipeButtons deselectButtonAtIndex:1];
//    }
    
}

- (void)dismissFilterToolbox
{
    [_filterToolBoxView close:YES]; // Slide filter close
    blurView.hidden = YES;
    [self.edgeSwipeButtons deselectButtonAtIndex:1];
    
}

#pragma mark - AlertView Delegate
//catch response of deletion alertview adn do thigns with it
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //check if the alert view is for deleting tags or sharing tags to facebook
    if ([alertView.accessibilityLabel isEqualToString:@"deletealert"]) {
        if (buttonIndex == 0)
        {
            NSMutableArray *tempArr = [self.tagsToDisplay mutableCopy];
            // delete the tags and also send the information to the server
            NSMutableArray *selectedCellIndexArr = [self.tableView.selectedRows mutableCopy];
            for (NSNumber *rowNumber in selectedCellIndexArr) {
                
                NSInteger row = [rowNumber integerValue];
                NSMutableDictionary *tag = [tempArr objectAtIndex:row];
                
                // if current playing tag is deleted, stop the video
                if ([[tag objectForKey:@"id"] isEqual:[currentPlayingTag objectForKey:@"id"]]) {
                    [self.videoPlayer pause];
                }
                
                //tempArr will used to update tagsToDisplay array; if you remove obj directly from tagsToDisplay array , [self tagAtIndexPath:indexPath] will have error
                [tempArr removeObject:tag];
                
                
                //remove  the tag marker
                [[[globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%f",[[tag objectForKey:@"id"] doubleValue] ]] markerView] removeFromSuperview];
                
                //delete the tag from the global dictionary of tags
                NSString *tag_id = [NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]];
                
                [tag setObject:@"0" forKey:@"bookmark"];
                //reset tag in global tag dictionary(globals.CURRENT_EVENT_THUMBNAILS)
                //[globals.CURRENT_EVENT_THUMBNAILS setObject:tag forKey:tag_id];
                //delete tag from global book mark tag dictionary (globals.BOOKMARK_TAGS_CURRENT_EVENT)
                if (globals.BOOKMARK_TAGS.count > 0 && [[[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] allKeys] containsObject:tag_id]) {
                    [[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] removeObjectForKey:tag_id];
                }
                //delete the video of the book mark tag
                NSString *tagDataPath;
                if ([[tag objectForKey:@"type"]intValue] != 4) {
                    //path for video
                    tagDataPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[tag objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[tag objectForKey:@"vidurl"] lastPathComponent]]]];
                }else{
                    //path for image
                    NSString *imagePathStr = [NSString stringWithFormat:@"telestration_%@_%@.png",[tag objectForKey:@"event"],[tag objectForKey:@"id"]];
                    
                    tagDataPath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:imagePathStr];
                }
                
                [fileManager removeItemAtPath:tagDataPath error:nil];
                
                //if game no longer has any saved clips in it, remove the game folder TODO
                
                //current absolute time in seconds
                double currentSystemTime = CACurrentMediaTime();
                
                //send the updated information to the server
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"0",@"bookmark",globals.EVENT_NAME,@"event",userIdd,@"user",[tag objectForKey:@"id"],@"id",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime", nil];
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
                NSString *jsonString;
                if (! jsonData) {
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
                
                NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
                
                //callback method and parent view controller reference for the appqueue
                NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
                NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
                NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [globals.APP_QUEUE enqueue:url dict:instObj];
            }
            //[globals.CURRENT_EVENT_THUMBNAILS writeToFile:[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"] atomically:YES];
            
            [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
            
            //update the tagsToDisplay array and reload the table view
            [self.tagsToDisplay removeAllObjects];
            
            if (globals.BOOKMARK_TAGS.count > 0) {
                self.tagsToDisplay = [tempArr mutableCopy];
            }
            
            //make sure we update the ordered bookmarks with the new array (delete cells)
            NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
            
            if(!fileManager)
            {
                fileManager = [NSFileManager defaultManager];
            }
            
            if(![fileManager fileExistsAtPath:orderedBookmarkPlist])
            {
                [fileManager createFileAtPath:orderedBookmarkPlist contents:nil attributes:nil];
            }
            if (self.tagsToDisplay.count > 0) {
                //save the undeleted tags to the plist file
                [self.tagsToDisplay writeToFile:orderedBookmarkPlist atomically:TRUE];
            }else{
                //if all tags deleted, delete the file
                [fileManager removeItemAtPath:orderedBookmarkPlist error:nil];
            }
            [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
            
            [self.tableView reloadData];
            
        }
        else //(buttonIndex == 1)
        {
        }
        [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
        [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
        
    }
    else if ([alertView.accessibilityLabel isEqualToString:@"downloadFailedAlert"]) {
        
        [globals.BOOKMARK_QUEUE_FAILED removeAllObjects];
        [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
    }
}


#pragma mark Richard Methods for commenting and rating
-(void)sendRatingNew:(id)sender
{
    int recievedRating = [(RatingInput *)sender rating];
    [selectedTag    setValue:   [NSString stringWithFormat:@"%i",recievedRating]   forKey:@"rating"];
    
    
    //handle offline mode, save comment information in local storage
    BOOL addToCurrentEventThumbnails = FALSE;
    if ([globals.EVENT_NAME isEqualToString:@"live" ]){
        if ([globals.CURRENT_EVENT_THUMBNAILS count]){
            NSDictionary *tag = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:[[globals.CURRENT_EVENT_THUMBNAILS allKeys] objectAtIndex:0]];
            NSString *liveName = [tag objectForKey:@"event"];
            if ([[selectedTag objectForKey:@"event"] isEqualToString:liveName]){
                addToCurrentEventThumbnails = TRUE;
            }
        }else{
            addToCurrentEventThumbnails = FALSE;
        }
    }
    
    if ([[selectedTag objectForKey:@"event"] isEqualToString:globals.EVENT_NAME]){
        addToCurrentEventThumbnails = TRUE;
    }
    
    if (!addToCurrentEventThumbnails){
        [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]] setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    } else {
        [globals.CURRENT_EVENT_THUMBNAILS setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    }
    
    //if ([[selectedTag objectForKey:@"bookmark"]integerValue] ==1) {
    [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]] setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    // }
    
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",recievedRating+1],@"rating",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[selectedTag objectForKey:@"event"],@"event",userIdd,@"user",tagId,@"id", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString;
    if (jsonData)
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(tagModCallback:)],self, nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:url dict:instObj];
    
    
}

-(void)sendComment2
{
    [commentingField.textField resignFirstResponder];
    NSString *comment = commentingField.textField.text;
    [selectedTag setValue:comment forKey:@"comment"];
    
    BOOL addToCurrentEventThumbnails = FALSE;
    if ([globals.EVENT_NAME isEqualToString:@"live" ]){
        if ([globals.CURRENT_EVENT_THUMBNAILS count]){
            NSDictionary *tag = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:[[globals.CURRENT_EVENT_THUMBNAILS allKeys] objectAtIndex:0]];
            NSString *liveName = [tag objectForKey:@"event"];
            if ([[selectedTag objectForKey:@"event"] isEqualToString:liveName]){
                addToCurrentEventThumbnails = TRUE;
            }
        }
    }
    
    if ([[selectedTag objectForKey:@"event"] isEqualToString:globals.EVENT_NAME]){
        addToCurrentEventThumbnails = TRUE;
    }
    
    if (addToCurrentEventThumbnails){
        [globals.CURRENT_EVENT_THUMBNAILS setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    }
    
    [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]] setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    
    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:comment,@"comment",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[selectedTag objectForKey:@"event"] ,@"event",userIdd,@"user",tagId,@"id", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(tagModCallback:)],self,nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    NSDictionary *instObj  = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:url dict:instObj];
    
    
}

-(void)tagModCallback:(id)newTagInfo
{
    //the updated tag
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:newTagInfo];
    
    //update it in the dictionary
    //note: cannot use newtaginfo objectforkey"id" directly - the value is either integer or string (id) and needs to be converted to nsstring
    
    if ([[dict objectForKey:@"bookmark"]integerValue]==1 && [[dict objectForKey:@"type"]integerValue] != 3) {
        [[globals.BOOKMARK_TAGS objectForKey:[newTagInfo objectForKey:@"event"]] setObject:dict forKey:[NSString stringWithFormat:@"%@",[newTagInfo objectForKey:@"id"]]];
    }
    //save it to file
    // [globals.CURRENT_EVENT_THUMBNAILS writeToFile:[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"] atomically:YES];
    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    
}


/**
 *  This is for detecteing swipes on the video player
 *  maybe this should be on the player it self??
 *  @param gestureRecognizer
 */
-(void)detectSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
//    switch (gestureRecognizer.direction) {
//        case UISwipeGestureRecognizerDirectionLeft:
//            if (!fullScreenMode) {
//                [currentSeekBackButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }else{
//                [currentSeekBackButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//            break;
//        case UISwipeGestureRecognizerDirectionRight:
//            if (!fullScreenMode) {
//                [currentSeekForwardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }else{
//                [currentSeekForwardButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//            break;
//        default:
//            break;
//    }
}

#pragma mark - Richard Sort from headder
-(void)sortFromHeaderBar:(id)sender
{
    HeaderBar * hBar = (HeaderBar *)sender;

    self.tagsToDisplay = [self sortArrayFromHeaderBar:self.tagsToDisplay headerBarState:hBar.headerBarSortType];
    [self.tableView reloadData];
    

    
}

-(NSMutableArray*)sortArrayFromHeaderBar:(NSMutableArray*)toSort headerBarState:(HBSortType) sortType
{
    
    NSSortDescriptor *sorter;
    //Fields are from HeaderBar.h
    if(sortType & TIME_FIELD){
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"displaytime"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(compare:)];
        
    } else if (sortType & DATE_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"event"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
        
    }  else if (sortType & NAME_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"name"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
    } else {
        return toSort;
    }
    
    return [NSMutableArray arrayWithArray:[toSort sortedArrayUsingDescriptors:@[sorter]]];
}
    
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //pause video and remove the time observer
    [videoPlayer pause];
    if (videoPlayer.timeObserver) {
        [videoPlayer removePlayerItemTimeObserver];
    }
    
    //if it was in fullscreen mode, exit from fullscreen
    if (videoPlayer.isFullScreen) {
        [videoPlayer exitFullScreen];
    }
    
    globals.SHOW_TOASTS = TRUE;
    globals.IS_IN_BOOKMARK_VIEW = FALSE;
    //we will remove the filtertoolbox to deallocate mem -- makes sure app does not freeze up
    [_filterToolBoxView.view removeFromSuperview];
    _filterToolBoxView=nil;
    
    
    [blurView removeFromSuperview];
    blurView=nil;
    [self.edgeSwipeButtons deselectButtonAtIndex:1];
    
    [typesOfTags removeAllObjects];
    
    currentPlayingTag = nil;
    [updatePlayRateTimer invalidate];
    updatePlayRateTimer = nil;
    [updateTableViewTimer invalidate];
    updateTableViewTimer = nil;

    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeAllObjects];
    
    //Edge Swipe Buttons
    [self.edgeSwipeButtons deselectAllButtons];
    
}

/*TO DELETE
-(void)receiveFilteredArray:(NSArray*)filteredArray
{
    NSMutableArray *tempArr;
    
    
    ///we have to check to see if the list has been reordered
    
    //check to make sure filemanager exists
    if(!fileManager)
    {
        fileManager = [NSFileManager defaultManager];
    }
    
    //create teh path to the reordered bookmarks plist
    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    
    //now grab the bookmark tags from the global dictionary, we need to iterate through and add all of them to an array so we can get the total number of bookmarks in the end
    NSMutableArray *a = [[NSMutableArray alloc] init]; //temporary array to add the thumb items to
    for(NSDictionary *d in [globals.BOOKMARK_TAGS allValues])
    {
        [a addObjectsFromArray:[d allValues]];
    }
    
    int orderedTagCount = [[NSArray arrayWithContentsOfFile:orderedBookmarkPlist] count];
    //if the user is filtering or or there is no ordered bookmarks then just display the filtered array. If however there is an ordered list and the user is not filtering, then use the
    //ordered list
    if(filteredArray.count < a.count || ![fileManager fileExistsAtPath:orderedBookmarkPlist] || a.count > orderedTagCount)
    {
        tempArr = [filteredArray mutableCopy];
    }else{
        //if all bookmark tags count is smaller than the odered bookmark tags, replace the ordered bookmark tags
        if (a.count < orderedTagCount && [fileManager fileExistsAtPath:orderedBookmarkPlist]) {
            [a writeToFile:orderedBookmarkPlist atomically:YES];
            tempArr = a;
        }else{
            tempArr =[[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist];
        }
        
        
    }
    self.tagsToDisplay = [tempArr mutableCopy];
    
    [self.tableView reloadData];
}
*/

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //make sure the movieplayer is stoped before going to otherviews, otherwise the app will crash
    [self.videoPlayer pause];
    [videoControlBar removeFromSuperview];
    [allTags removeAllObjects];
    globals.IS_IN_BOOKMARK_VIEW = FALSE;
    
}
    
-(void)checkFullScreen
{
    
    

    if (self.videoPlayer.isFullScreen && !fullScreenMode) {
        fullScreenMode = TRUE;
        [self willEnterFullScreen];
//        [self.view addSubview:testFullScreen.view];
        
//        [testFullScreen. view insertSubview:videoPlayer.view atIndex:0];
    }else if(!self.videoPlayer.isFullScreen && fullScreenMode ){
        [self willExitFullscreen];
        [self performSelector:@selector(didExitFullscreen) withObject:nil afterDelay:0.1];
        fullScreenMode = FALSE;
        [self.view insertSubview:videoPlayer.view belowSubview:newVideoControlBar.view];
//        [testFullScreen.view removeFromSuperview];
    }

}
    
-(void)willEnterFullScreen
{
    [self.videoPlayer setIsFullScreen:YES];
    
    ///going to bring the tabbar controller to the front now, we want to have access to it at all times, including fullscreen mode
    UIView *fullScreenView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    //iterate through all the views in teh fullscreen (the tabs are there, just hidden away
    for(id tBar in fullScreenView.subviews)
    {
        //if the view is a subclass of type tabbarbutton, then we will bring it to the front
        if([tBar isKindOfClass:[TabBarButton class]])
        {
            [fullScreenView bringSubviewToFront:tBar];
        }
    }
    [self createAllFullScreenSubviews];
    if (externalControlScreen.view){
        [fullScreenView addSubview:[externalControlScreen buildDebugPanel:self.videoPlayer]];
    }
}

    
-(void)willExitFullscreen
{
    [self removeAllFullScreenSubviews];
}

-(void)didExitFullscreen
{
    [self.view bringSubviewToFront: blurView];
}
    
    
#pragma mark - Play Rate Controlls
-(void)showPlaybackRateControls
{
    if (playbackRateBackButton){
        [playbackRateBackButton removeFromSuperview];
        playbackRateBackButton = nil;
        [playbackRateBackGuide removeFromSuperview];
        playbackRateBackGuide = nil;
        [playbackRateBackLabel removeFromSuperview];
        playbackRateBackLabel = nil;
    }
    if (playbackRateForwardButton){
        [playbackRateForwardButton removeFromSuperview];
        playbackRateForwardButton = nil;
        [playbackRateForwardGuide removeFromSuperview];
        playbackRateForwardGuide = nil;
        [playbackRateForwardLabel removeFromSuperview];
        playbackRateForwardLabel = nil;
    }
    
    //Playback rate controls
    playbackRateBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateBackButton setFrame:CGRectMake(165, 585, 70.0f, 70.0f)];
    [playbackRateBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackButton setTag:0];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackButton];
    
    playbackRateBackGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackBack"]];
    [playbackRateBackGuide setFrame:CGRectMake(playbackRateBackButton.frame.origin.x - 148, playbackRateBackButton.frame.origin.y - 146, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateBackGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackGuide setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateBackGuide belowSubview:playbackRateBackButton];
    
    playbackRateBackLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, 60.0f, 30.0f)];
    [playbackRateBackLabel setText:@"-2fps"];
    [playbackRateBackLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateBackLabel.layer setCornerRadius:4.0f];
    [playbackRateBackLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateBackLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackLabel];
    
    playbackRateForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
    [playbackRateForwardButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardButton setTag:1];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForward"] forState:UIControlStateNormal];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateHighlighted];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateSelected];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardButton];
    
    playbackRateForwardGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackForward"]];
    [playbackRateForwardGuide setFrame:CGRectMake(playbackRateForwardButton.superview.bounds.size.width - playbackRateBackGuide.bounds.size.width - (playbackRateBackButton.frame.origin.x - 148), playbackRateBackGuide.frame.origin.y, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateForwardGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardGuide setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateForwardGuide belowSubview:playbackRateForwardButton];
    
    playbackRateForwardLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateBackLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    [playbackRateForwardLabel setText:@"2fps"];
    [playbackRateForwardLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateForwardLabel.layer setCornerRadius:4.0f];
    [playbackRateForwardLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateForwardLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardLabel];
}

-(void)playbackRateButtonDown:(id)sender
{
    isModifyingPlaybackRate = YES;
    
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:1.0f];
            //            [self.overlayLeftViewController.view setAlpha:0.0f];
            [playbackRateBackLabel setAlpha:1.0f];
        }];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:1.0f];
            //            [self.overlayRightViewController.view setAlpha:0.0f];
            [playbackRateForwardLabel setAlpha:1.0f];
        }];
    }
    globals.PLAYBACK_SPEED = 0.0;
    [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
}
    
-(void)playbackRateButtonUp:(id)sender
{
    isModifyingPlaybackRate = NO;
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:0.0f];
            //            [self.overlayLeftViewController.view setAlpha:1.0f];
            [playbackRateBackButton setFrame:CGRectMake(165, 535, 70.0f, 70.0f)];
            [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
            [playbackRateBackLabel setAlpha:0.0f];
        }];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:0.0f];
            //            [self.overlayRightViewController.view setAlpha:1.0f];
            [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
            [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateForwardLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
            [playbackRateForwardLabel setAlpha:0.0f];
            
        }];
    }
    globals.PLAYBACK_SPEED = 0.0;
    [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
}
    
-(void)playbackRateButtonDrag:(id)sender forEvent:(UIEvent*)event
{
    UIButton* button = sender;
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint touchPoint = [touch locationInView:button.superview];
    CGPoint buttonPosition = [self coordForPosition:touchPoint onGuide:[button tag]];
    [button setCenter:buttonPosition];
    if ([button tag] == 0) {
        [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(button.frame), button.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
        if (isFrameByFrame) {
            [playbackRateBackLabel setText:[NSString stringWithFormat:@"-%.0fps",1/frameByFrameInterval]];
        } else {
            [playbackRateBackLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
        }
    } else if ([button tag] == 1){
        [playbackRateForwardLabel setFrame:CGRectMake(button.frame.origin.x - playbackRateForwardLabel.bounds.size.width, button.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
        if (isFrameByFrame) {
            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.0ffps",1/frameByFrameInterval]];
        } else {
            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
        }
    }
    if (videoPlayer.avPlayer.rate != globals.PLAYBACK_SPEED) {
        videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
    }
}

-(CGPoint)coordForPosition:(CGPoint)point onGuide:(int)tag
{
    float yPos = 0.0f;
    float xPos = 0.0f;
    CGPoint guidePivot;
    float theta = 0.0f;
    float degrees = 0.0f;
    playbackRateRadius = 118.0f + playbackRateBackButton.bounds.size.width/2;
    if (tag == 0){
        guidePivot = CGPointMake(playbackRateBackGuide.frame.origin.x + 30.0f, CGRectGetMaxY(playbackRateBackGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, point.x - guidePivot.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:FALSE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:FALSE];
        } else {
            isFrameByFrame = NO;
            if (degrees >= increment*2 && degrees < increment*3){
                globals.PLAYBACK_SPEED = 0.25f;
            } else if (degrees >= increment*3 && degrees < increment*4){
                globals.PLAYBACK_SPEED = 0.5f;
            } else if (degrees >= increment*4 && degrees < increment*5){
                globals.PLAYBACK_SPEED = 1.0f;
            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
                globals.PLAYBACK_SPEED = 2.0f;
            } else if (degrees >= (increment*6 - 3)){
                globals.PLAYBACK_SPEED = 4.0f;
            }
        }
        globals.PLAYBACK_SPEED = -globals.PLAYBACK_SPEED;
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos += guidePivot.x;
    } else if (tag == 1){
        guidePivot = CGPointMake(CGRectGetMaxX(playbackRateForwardGuide.frame) - 30.0f, CGRectGetMaxY(playbackRateForwardGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, guidePivot.x - point.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:TRUE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:TRUE];
        } else {
            isFrameByFrame = NO;
            if (degrees >= increment*2 && degrees < increment*3){
                globals.PLAYBACK_SPEED = 0.25f;
            } else if (degrees >= increment*3 && degrees < increment*4){
                globals.PLAYBACK_SPEED = 0.5f;
            } else if (degrees >= increment*4 && degrees < increment*5){
                globals.PLAYBACK_SPEED = 1.0f;
            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
                globals.PLAYBACK_SPEED = 2.0f;
            } else if (degrees >= (increment*6 - 3)){
                globals.PLAYBACK_SPEED = 4.0f;
            }
        }
        
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos -= guidePivot.x;
        xPos = -xPos;
    }
    return CGPointMake(xPos, yPos);
}
    
- (void)startFrameByFrameScrollingAtInterval:(float)interval goingForward:(BOOL)forward
{
    frameByFrameInterval = interval;
    if (isFrameByFrame) {
        return;
    } else {
        isFrameByFrame = YES;
    }
    if (forward){
        [self frameByFrameForward];
    } else {
        [self frameByFrameBackward];
    }
    
}

- (void)frameByFrameForward
{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameForward) userInfo:nil repeats:NO];
    }
}

- (void)frameByFrameBackward
{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:-1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameBackward) userInfo:nil repeats:NO];
    }
}
    
-(void)createAllFullScreenSubviews
{

    
    // Richard
    newFullScreenVideoControlBar = [[FullVideoBarMyClipViewController alloc]initWithVideoPlayer:videoPlayer];
    [newFullScreenVideoControlBar viewDidAppear:NO];
    [newFullScreenVideoControlBar onPressNextPrevPerformSelector:@selector(playNextOrPreTag:) addTarget:self];
    [newFullScreenVideoControlBar setTagName:[currentPlayingTag objectForKey:@"name"]];
    
    if ([[currentPlayingTag objectForKey:@"type"]intValue] != 4) {
        //show telestration button
        [self showTeleButton];
        [self showPlaybackRateControls];
    }
    
    // Richard
       [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:newFullScreenVideoControlBar.view];
}


/**
 *  This will play the next tag in the tableview based of the button's tag value
 *
 *  @param sender button
 */
-(void)playNextOrPreTag:(id)sender
{
    NSInteger * buttonTagValue  = ((UIButton*)sender).tag;
    int         nextIndex       = wasPlayingIndexPath.row + (int)buttonTagValue;
    if(nextIndex > self.tagsToDisplay.count -1 || nextIndex <0){
        return;
    }

    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:nextIndex inSection:wasPlayingIndexPath.section];
    [self reorderTableView:self.tableView didSelectRowAtIndexPath:nextPath];
}

-(void)showTeleButton
{
    if (teleButton) {
        [teleButton removeFromSuperview];
        teleButton = nil;
    }
    teleButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [teleButton setFrame:CGRectMake(939.0f, 585.0f, 64.0f, 64.0f)];
    [teleButton setContentMode:UIViewContentModeScaleAspectFill];
    [teleButton setImage:[UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [teleButton setImage:[UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    //teleButton.transform=CGAffineTransformMakeRotation(M_PI/2);
    [teleButton addTarget:self action:@selector(initTele:) forControlEvents:UIControlEventTouchUpInside];
    //need to be modified later
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:teleButton];
}


//create telestration screen
-(void)initTele:(id)sender
{
    [self.videoPlayer pause];
    [self hideFullScreenOverlayButtons];
   
    CMTime currentCMTime            = self.videoPlayer.avPlayer.currentTime;
    globals.TELE_TIME               = (float)[self roundValue:CMTimeGetSeconds(currentCMTime)];
    ////////NSLog(@"initTele tele time %f, current time %f",globals.TELE_TIME,CMTimeGetSeconds(currentCMTime));
    teleViewController              = [[TeleViewController alloc] initWithController:self];
    [teleViewController.view setFrame:CGRectMake(0, 10, 1024, 768)];
    self.videoPlayer.playerFrame    = CGRectMake(0, 0, 1024, 748);
    [self.teleButton setHidden:TRUE];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.teleViewController.view];
   
}

/**
 *  This method is used byt the teleViewController
 */
-(void)hideFullScreenOverlayButtons
{
    [playbackRateBackButton setHidden:TRUE];
    [playbackRateBackLabel setHidden:TRUE];
    [playbackRateBackGuide setHidden:TRUE];
    [playbackRateForwardButton setHidden:TRUE];
    [playbackRateForwardLabel setHidden:TRUE];
    [playbackRateForwardGuide setHidden:TRUE];

    [newFullScreenVideoControlBar.view setHidden:YES]; // Richard
}


/**
 *  This method is used byt the teleViewController
 */
-(void)showFullScreenOverlayButtons
{
    [playbackRateBackButton setHidden:FALSE];
    [playbackRateBackLabel setHidden:FALSE];
    [playbackRateBackGuide setHidden:FALSE];
    [playbackRateForwardButton setHidden:FALSE];
    [playbackRateForwardLabel setHidden:FALSE];
    [playbackRateForwardGuide setHidden:FALSE];
    
    [newFullScreenVideoControlBar.view setHidden:NO]; // Richard
}

-(int)roundValue:(float)numberToRound
{
    numberToRound = numberToRound;
    if (self.videoPlayer.duration - numberToRound < 2) {
        return (int)numberToRound;
    }
    
    return  (int)(numberToRound + 0.5);
    
}

-(void)removeAllFullScreenSubviews
{

    [teleButton removeFromSuperview];
    [playbackRateBackButton removeFromSuperview];
    [playbackRateBackLabel removeFromSuperview];
    [playbackRateBackGuide removeFromSuperview];
    [playbackRateForwardButton removeFromSuperview];
    [playbackRateForwardLabel removeFromSuperview];
    [playbackRateForwardGuide removeFromSuperview];
    // Richard
    [newFullScreenVideoControlBar.view removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([commentTextView isFirstResponder] && [touch view] != commentTextView) {
//        [commentTextView resignFirstResponder];
//    }
    [super touchesBegan:touches withEvent:event];
}

-(void)updatePlayRate:(NSTimer*)timer
{
    //if(self.moviePlayer.playbackState != MPMoviePlaybackStatePaused)
    
    
}

// IS this dead?
//press the cell for more than 2 seconds, pop up the details of the tag and the event
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!fullScreenMode){
        BookmarkViewCell *cell;
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            
            CGPoint p = [gestureRecognizer locationInView:self.tableView];
//                CGPoint q = [gestureRecognizer locationInView:self.view];
            
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
            if (indexPath == nil) {
                return;
            }

            [self reorderTableView:self.tableView didSelectRowAtIndexPath:indexPath];
            cell = (BookmarkViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            NSDictionary *data = [self tagAtIndexPath:indexPath];
            
            //show popover view to show the tag's details information,ie: event date,event time, home/visit teams, league, tag name and tag time
            
            UIViewController* popoverContent = [[UIViewController alloc] init];
            UIView *popoverView = [[UIView alloc] init];
            popoverView.backgroundColor = [UIColor whiteColor];
            UITextView *tagDetailsView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, 340, 280)];
            if([[data objectForKey:@"event" ] isEqualToString:@"live"])
            {
                return;
            }
            NSArray *tempArr = [[data objectForKey:@"event" ] componentsSeparatedByString:@"_"];
            NSString *eventDate =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
            NSArray *tempTime = [[NSString stringWithFormat:@"%@",[tempArr objectAtIndex:1]]componentsSeparatedByString:@"-"] ;
            NSString *eventTime = [NSString stringWithFormat:@"%@ : %@ : %@",[tempTime objectAtIndex:0],[tempTime objectAtIndex:1],[tempTime objectAtIndex:2]];
            
            NSDictionary *teamInfo = [[allEvents objectForKey:[data objectForKey:@"event"]] copy];
            NSString *homeTeam;
            NSString *visitTeam;
            NSString *leagueName;
            if (teamInfo){
                homeTeam = [teamInfo objectForKey:@"homeTeam"];
                visitTeam = [teamInfo objectForKey:@"visitTeam"];
                leagueName = [teamInfo objectForKey:@"league"];
            } else {
                homeTeam = [data objectForKey:@"homeTeam"];
                visitTeam = [data objectForKey:@"visitTeam"];
                leagueName = @"";
            }
            
            [tagDetailsView setText:[NSString stringWithFormat:@"event date: %@ \nevent time: %@ \nhome team: %@ \nvisit team: %@ \nleague: %@\ntag name: %@ \ntag time: %@",eventDate,eventTime,homeTeam,visitTeam,leagueName,[data objectForKey:@"name"],           [data objectForKey:@"displaytime"]]];
            [tagDetailsView setFont:[UIFont boldSystemFontOfSize:18.f]];
            [tagDetailsView setUserInteractionEnabled:FALSE];
            [popoverView addSubview:tagDetailsView];
            popoverContent.view = popoverView;
            popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
            [popoverController setPopoverContentSize:CGSizeMake(300, 220) animated:YES];
            //pop over the view based on the cell's position
            [popoverController presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            [[self.tableView cellForRowAtIndexPath:wasPlayingIndexPath] setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
            //            }
            wasPlayingIndexPath = indexPath;
        }

        [videoPlayer play];
    }
}

#pragma mark - Richard Filtering
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    MyClipFilterViewController * checkFilter = (MyClipFilterViewController *)filter;
    
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    NSMutableArray *tempArr;
    
    
    ///we have to check to see if the list has been reordered
    
    //check to make sure filemanager exists
    if(!fileManager)
    {
        fileManager = [NSFileManager defaultManager];
    }
    
    //create teh path to the reordered bookmarks plist
    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    
    //now grab the bookmark tags from the global dictionary, we need to iterate through and add all of them to an array so we can get the total number of bookmarks in the end
    NSMutableArray *a = [[NSMutableArray alloc] init]; //temporary array to add the thumb items to
    for(NSDictionary *d in [globals.BOOKMARK_TAGS allValues])
    {
        [a addObjectsFromArray:[d allValues]];
    }
    
    int orderedTagCount = [[NSArray arrayWithContentsOfFile:orderedBookmarkPlist] count];
    //if the user is filtering or or there is no ordered bookmarks then just display the filtered array. If however there is an ordered list and the user is not filtering, then use the
    //ordered list
    if(filteredArray.count < a.count || ![fileManager fileExistsAtPath:orderedBookmarkPlist] || a.count > orderedTagCount)
    {
        tempArr = [filteredArray mutableCopy];
    }else{
        //if all bookmark tags count is smaller than the odered bookmark tags, replace the ordered bookmark tags
        if (a.count < orderedTagCount && [fileManager fileExistsAtPath:orderedBookmarkPlist]) {
            [a writeToFile:orderedBookmarkPlist atomically:YES];
            tempArr = a;
        }else{
            tempArr =[[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist];
        }
        
        
    }
    
    // Added the ability to sor the array from headerbar
    self.tagsToDisplay = [self sortArrayFromHeaderBar:[tempArr mutableCopy] headerBarState:headerBar.headerBarSortType];
    
    [self.tableView reloadData];
    

}
    
    

    
#pragma mark - Popover
    
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
}

/**
 *  This is the info button when its tapped
 *
 *  @param jpTable   TableView
 *  @param indexPath indexPath of tag
 */
-(void)reorderTableView:(JPReorderTableView*)jpTable accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath == nil)  return;

    BookmarkViewCell    * cell              = (BookmarkViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary        * data              = [self tagAtIndexPath:indexPath];
    UIViewController    * popoverContent    = [[UIViewController alloc] init];
    popoverContent.view                     = [[TagPopOverContent alloc]initWithData:data frame:CGRectMake(0,0,280, 210)];
    popoverController                       = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    [popoverController setPopoverContentSize:CGSizeMake(300, 220) animated:YES];

    [popoverController presentPopoverFromRect:cell.bounds
                                       inView:cell
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];

}

/**
 *  This is a getter that returnds the tages To Be displayed 
 *  check this
 *
 *  @return tags in the tableview
 */
-(NSMutableArray *)tagsToDisplay
{
    return _tagsToDisplay;
}

-(void)setTagsToDisplay:(NSMutableArray *)newToDisplay
{
    _tagsToDisplay = newToDisplay;
    // update tag display
    int tagCount = [_tagsToDisplay count];
    NSString * tagPlur = (tagCount==1)?@"Tag":@"Tags";
    UIEdgeInsets insets = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets)];
    
    
    [numTagsLabel setText:[NSString stringWithFormat:@"%d %@   ",tagCount,tagPlur ]];
    [numTagsLabel setNeedsDisplay];
    
    UIEdgeInsets insets2 = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets2)];
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sharing Methods

//send clip to dropbox
-(void)sendVideoToDropbox:(id)sender
{
    DBSession* dropboxSession = [[DBSession alloc] initWithAppKey:kDropboxAppKey appSecret:kDropboxAppSecret root:kDropboxAppRoot];
    [DBSession setSharedSession:dropboxSession];
    
    if(![dropboxSession isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        return;
    }
    
    _DPBUploader = [[DPBFileUploader alloc] initWithSession:dropboxSession];
    _DPBUploader.expectedUploadNum = [self.tableView.selectedRows count];
    
    for(NSNumber* rowNum in self.tableView.selectedRows)
    {
        NSInteger selectedRow = [rowNum integerValue];
        NSDictionary* tag = [self.tagsToDisplay objectAtIndex:selectedRow];
        
        NSString* fileName = [self cloudFileNameWithTag:tag];
        NSData* fileData = [self cloudFileDataWithTag:tag];
        
        [_DPBUploader uploadFileAsyncWithFileName:fileName data:fileData destPath:[self dropboxTodayFolderPath]];
    }
    
    [popoverController dismissPopoverAnimated:YES];
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
}

#pragma mark Google Drive Share

- (void)googleDriveShare
{
    _currentSharingMethod = 0;
    
    [self uploadToGoogleDrive];
    
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
    
    [popoverController dismissPopoverAnimated:YES];
    isEditingClips= NO;
    
}

//just upload to google drive, do not change iPad interface
- (void)uploadToGoogleDrive
{
    NSArray *selectedCellArr = self.tableView.selectedRows;
    
    if (selectedCellArr.count == 0) {
        [popoverController dismissPopoverAnimated:YES];
        isEditingClips = NO;
        return;
    }
//    
//    if(!_GDUploader)
//    {
//        _GDUploader = [[GDFileUploader alloc] initWithDriveService:nil];
//        _GDUploader.delegate = self;
//    }
//    
//    _GDUploader.exepectedFileNumber = selectedCellArr.count;
//    
    for (NSNumber* rowNum in selectedCellArr) {
        
        NSDictionary *dict = [self.tagsToDisplay objectAtIndex:[rowNum integerValue]];
        NSMutableDictionary *tag = [dict mutableCopy];
        
        NSString* mimeType = @"video/mp4";
        
        //tele
        if ([[tag objectForKey:@"type"]intValue] == 4) {
            mimeType = @"image/png";
        }
        
        NSData* fileData = [self cloudFileDataWithTag:tag];
        
        NSString* fileName = [self cloudFileNameWithTag:tag];
        
//        [_GDUploader uploadFileWithName:fileName data:fileData MIMEType:mimeType];
        
    }
}

- (NSString*)cloudFileNameWithTag: (NSDictionary*)tag
{
    NSString* type = @"mp4";
    
    NSString* eventName = [NSString stringWithFormat:@"[%@ vs %@](%@)", [tag objectForKey:@"homeTeam"], [tag objectForKey:@"visitTeam"], [[tag objectForKey:@"event"] substringToIndex:10]];
    NSString* fileName = [NSString stringWithFormat:@"My Clip Video: %@.%@", eventName, type];
    return fileName;
}

- (NSData*)cloudFileDataWithTag: (NSDictionary*)tag
{
    NSString *tagPath = nil;
    //video file
    if ([[tag objectForKey:@"type"]intValue] != 4)
    {
        tagPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[tag objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[tag objectForKey:@"id"]]]];
    }
    else //tele
    {
        tagPath =[globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[tag objectForKey:@"event"],[tag objectForKey:@"id"]]];
    }
    
    return [NSData dataWithContentsOfFile:tagPath];
    
}


#pragma mark Save To Album

//save the video to the device's photos album
-(void)saveVideoToPhotosAlbum{
    
    savingToAlbumArray = [NSMutableArray array];
    
    for(NSNumber* rowNum in self.tableView.selectedRows)
    {
        NSInteger selectedRow = [rowNum integerValue];
        NSDictionary* tag = [self.tagsToDisplay objectAtIndex:selectedRow];
        [savingToAlbumArray addObject:tag];
    }
    
    if (savingToAlbumArray.count>0) {
        [self saveFile:[savingToAlbumArray objectAtIndex:0]];
    }
    [popoverController dismissPopoverAnimated:YES];
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
}


//save one video each time
-(void)saveFile:(NSDictionary *)tag{
    
    if ([[tag objectForKey:@"type"]intValue] != 4) {
        //video file
        NSString *tagVideoPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[tag objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[tag objectForKey:@"id"]]]];
        //if couldSave is FALSE, this video is not compatible to save
        BOOL couldSave = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tagVideoPath);
        
        if (couldSave) {
            UISaveVideoAtPathToSavedPhotosAlbum(tagVideoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else{
            
            if (!notCompatibleArray) {
                notCompatibleArray = [NSMutableArray arrayWithObject:tag];
            }else{
                [notCompatibleArray addObject:tag];
            }
            
            if(savingToAlbumArray.count == 1){
                //got all tags info which are not compatible for saving
                NSString *notCompatibleMsg = [self getNotCompatibleMsg];
                
                //got all tags info which are failed by error
                NSString *errorFailedMsg;
                if (errorSavingArray.count > 0) {
                    errorFailedMsg = [self getFailedErrorMsg];
                }
                
                NSString *alertMsg;
                if (!errorFailedMsg) {
                    alertMsg = notCompatibleMsg;
                }else{
                    alertMsg = [NSString stringWithFormat:@"%@\n%@",notCompatibleMsg,errorFailedMsg];
                }
                
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setTitle:@"myplayXplay"];
                [alert setMessage:alertMsg];
                [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
                [alert addButtonWithTitle:@"OK"];
                //[alert addButtonWithTitle:@"CANCEL"];
                [alert setAccessibilityValue:@"saveToPhotosError"];
                [alert show];
                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
                savingToAlbumArray = nil;
                notCompatibleArray = nil;
                errorSavingArray = nil;
                
            }else{
                [savingToAlbumArray removeObjectAtIndex:0];
                //if the savingToAlbumArray is not empty, save the next video
                if (savingToAlbumArray.count > 0) {
                    [self saveFile:[[savingToAlbumArray objectAtIndex:0]objectForKey:@"tag" ]];
                }else{
                    
                }
                
            }
            
        }
        
    }else{
        //telestration image file
        NSString *teleImagePath =[globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[tag objectForKey:@"event"],[tag objectForKey:@"id"]]];
        UIImage *telestrationImage = [UIImage imageWithContentsOfFile:teleImagePath];
        //save telestration to local photo album
        UIImageWriteToSavedPhotosAlbum(telestrationImage, nil, nil, nil);
        
        [savingToAlbumArray removeObjectAtIndex:0];
        //if the savingToAlbumArray is not empty, save the next video
        if (savingToAlbumArray.count > 0) {
            [self saveFile:[[savingToAlbumArray objectAtIndex:0]objectForKey:@"tag" ]];
        }else{
            //show alert view if there is any error or show the finishing toast
            [self saveFileToPhotoAlbumCallback];
        }
        
    }
    
    
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo: (void *)contextInfo{
    
    if (error) {
        
        if (!errorSavingArray) {
            errorSavingArray = [NSMutableArray arrayWithObject:[savingToAlbumArray objectAtIndex:0]];
        }else{
            [errorSavingArray addObject:[savingToAlbumArray objectAtIndex:0]];
        }
        
        //all the selected tags have sent to save to the photo album
        if (savingToAlbumArray.count == 1) {
            
            //got all tags info which are not compatible for saving
            NSString *notCompatibleMsg;
            if (notCompatibleArray.count > 0) {
                notCompatibleMsg = [self getNotCompatibleMsg];
            }
            
            //got all tags info which are failed by error
            NSString *errorFailedMsg = [self getFailedErrorMsg];
            
            NSString *alertMsg;
            if (!notCompatibleMsg) {
                alertMsg = errorFailedMsg;
            }else{
                alertMsg = [NSString stringWithFormat:@"%@\n%@",notCompatibleMsg,errorFailedMsg];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"myplayXplay"];
            [alert setMessage:alertMsg];
            [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
            [alert addButtonWithTitle:@"OK"];
            //[alert addButtonWithTitle:@"CANCEL"];
            [alert setAccessibilityValue:@"saveToPhotosError"];
            [alert show];
            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            savingToAlbumArray = nil;
            notCompatibleArray = nil;
            errorSavingArray = nil;
        }else{
            [savingToAlbumArray removeObjectAtIndex:0];
            [self saveFile:[[savingToAlbumArray objectAtIndex:0] objectForKey:@"tag"]];
        }
        
        
    }else{
        
        [savingToAlbumArray removeObjectAtIndex:0];
        if (savingToAlbumArray.count > 0) {
            
            [self saveFile:[[savingToAlbumArray objectAtIndex:0] objectForKey:@"tag"]];
            
        }else{
            //show alert view if there is any error or show the finishing toast
            [self saveFileToPhotoAlbumCallback];
        }
        
    }
}

-(void)saveFileToPhotoAlbumCallback{
    
    if (notCompatibleArray.count> 0 || errorSavingArray.count >0) {
        //got all tags info which are not compatible for saving
        NSString *notCompatibleMsg;
        if (notCompatibleArray.count > 0) {
            notCompatibleMsg = [self getNotCompatibleMsg];
        }
        
        
        //got all tags info which are failed by error
        NSString *errorFailedMsg;
        if (errorSavingArray.count > 0) {
            errorFailedMsg = [self getFailedErrorMsg];
        }
        
        NSString *alertMsg;
        if (!notCompatibleMsg && errorFailedMsg) {
            alertMsg = errorFailedMsg;
        }else if(!errorFailedMsg && notCompatibleMsg){
            alertMsg = notCompatibleMsg;
        }else if (notCompatibleMsg && errorFailedMsg){
            alertMsg = [NSString stringWithFormat:@"%@\n%@",notCompatibleMsg,errorFailedMsg];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:alertMsg];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"OK"];
        //[alert addButtonWithTitle:@"CANCEL"];
        [alert show];
        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    }else{
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"SaveToAlbum success" forKey:@"name"];
        [globals.TOAST_QUEUE addObject:infoDict];
    }
    
    savingToAlbumArray = nil;
    notCompatibleArray = nil;
    errorSavingArray = nil;
}

//return a string of all the tags' info which are not compatible for saving
-(NSString*)getNotCompatibleMsg{
    
    NSMutableString *notCompatibleMsg = [@"Tags Not Compatible for Saving: \n" mutableCopy];
    
    for(NSDictionary *data in notCompatibleArray){
        NSDictionary *tag = [data objectForKey:@"tag"];
        NSArray *tempArr = [[tag objectForKey:@"event" ] componentsSeparatedByString:@"_"];
        NSString *eventDate =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
        NSArray *tempTime = [[NSString stringWithFormat:@"%@",[tempArr objectAtIndex:1]]componentsSeparatedByString:@"-"] ;
        NSString *eventTime = [NSString stringWithFormat:@"%@ : %@ : %@",[tempTime objectAtIndex:0],[tempTime objectAtIndex:1],[tempTime objectAtIndex:2]];
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@\n",eventDate,eventTime,[tag objectForKey:@"name"]];
        [notCompatibleMsg appendString:msg];
    }
    
    return notCompatibleMsg;
}

//return a string of all the tags' info which are failed saving to the photos album
-(NSString*)getFailedErrorMsg{
    
    NSMutableString *errorFailedMsg = [@"Tags Failed With Error: \n" mutableCopy];
    for(NSDictionary *data in errorSavingArray){
        NSDictionary *tag = [data objectForKey:@"tag"];
        NSArray *tempArr = [[tag objectForKey:@"event" ] componentsSeparatedByString:@"_"];
        NSString *eventDate =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
        NSArray *tempTime = [[NSString stringWithFormat:@"%@",[tempArr objectAtIndex:1]]componentsSeparatedByString:@"-"] ;
        NSString *eventTime = [NSString stringWithFormat:@"%@ : %@ : %@",[tempTime objectAtIndex:0],[tempTime objectAtIndex:1],[tempTime objectAtIndex:2]];
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@\n",eventDate,eventTime,[tag objectForKey:@"name"]];
        [errorFailedMsg appendString:msg];
    }
    return errorFailedMsg;
}


#pragma mark Email Tags
-(void)emailTags{
    
    if (!globals.HAS_CLOUD) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"Please connect the internet before sending an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [popoverController dismissPopoverAnimated:YES];
    NSString *videoName;
    NSString *emailBody = @"";
    self.mailController = [[MFMailComposeViewController alloc] init];
    self.mailController.mailComposeDelegate = self;
    int length = 0;
    int i = 0;
    
    NSArray *selectedCellArr = self.tableView.selectedRows;
    for (NSNumber* rowNum in selectedCellArr) {
        
        NSDictionary *dict = [self.tagsToDisplay objectAtIndex:[rowNum integerValue]];
        NSMutableDictionary *tag = [dict mutableCopy];
        
        NSString *mimeType;
        if([[tag objectForKey:@"type"]intValue] !=4)
        {
            mimeType=@"video/mp4";
            videoName = [[tag objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[tag objectForKey:@"vidurl"] lastPathComponent]];
        }else{
            mimeType=@"image/png";
            videoName = [NSString stringWithFormat:@"telestration_%@_%@.png",[tag objectForKey:@"event"],[tag objectForKey:@"id"]];
        }
        
        if([[tag objectForKey:@"event" ] isEqualToString:@"live"])
        {
            return;
        }
        
        NSMutableString *formattedInfo;
        NSArray *tempArr = [[tag objectForKey:@"event" ] componentsSeparatedByString:@"_"];
        NSString *eventTime = [[tempArr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"-" withString:@":"];
        
        if ([tag objectForKey:@"homeTeam"] && [tag objectForKey:@"visitTeam"]){
            formattedInfo = [NSMutableString stringWithFormat:@"Tag: %@\nEvent date: %@ \nEvent Time: %@ \nTag Time: %@ \nHome: %@ \nVisiting: %@ \n", [tag objectForKey:@"name"],[tempArr objectAtIndex:0],eventTime,[tag objectForKey:@"displaytime"], [tag objectForKey:@"homeTeam"], [tag objectForKey:@"visitTeam"]];
        } else {
            NSDictionary *teamInfo = [[allEvents objectForKey:[tag objectForKey:@"event"]] copy];
            NSString *homeTeam = [teamInfo objectForKey:@"homeTeam"];
            NSString *visitTeam = [teamInfo objectForKey:@"visitTeam"];
            
            if (homeTeam && visitTeam ){
                formattedInfo = [NSMutableString stringWithFormat:@"Tag: %@\nEvent date: %@ \nEvent Time: %@ \nTag Time: %@ \nHome: %@ \nVisiting: %@ \n", [tag objectForKey:@"name"],[tempArr objectAtIndex:0],eventTime,[tag objectForKey:@"displaytime"], homeTeam, visitTeam];
            } else {
                formattedInfo = [NSMutableString stringWithFormat:@"Tag: %@\nEvent date: %@ \nEvent Time: %@ \nTag Time: %@ \n", [tag objectForKey:@"name"],[tempArr objectAtIndex:0],eventTime,[tag objectForKey:@"displaytime"]];
            }
        }
        
        if ([[tag objectForKey:@"comment"] length]>0){
            [formattedInfo appendFormat:@"Comment: %@ \n",[tag objectForKey:@"comment"]];
        }
        int rating = [[tag objectForKey:@"rating"] integerValue];
        if (rating != 0){
            [formattedInfo appendFormat:@"Rating: %@/5 \n",[tag objectForKey:@"rating"]];
        }
        NSError *error;
        
        
        NSString *dataPath;
        if([[tag objectForKey:@"type"]intValue] !=4)
        {
            dataPath=[globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoName]] ;
        }else{
            dataPath=[globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoName]] ;
            
        }
        
        //NSDataReadingMappedIfSafe:A hint indicating the file should be mapped into virtual memory, if possible and safe.
        NSData *myData = [NSData dataWithContentsOfFile:dataPath options:NSDataReadingMappedIfSafe error:&error];
        [self.mailController addAttachmentData:myData mimeType:@"video/mp4" fileName:videoName];
        emailBody  = [NSString stringWithFormat:@"%@ \n%@ ",emailBody,formattedInfo];
        
        length = length + [myData length];
        i++;
        //if the attachment size if too large, will cause low memory warning; temporarily attachment limit 20M
        if ((float)length/1048576.0 > 20) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"myplayXplay"
                                  message: @"Message size exceeds the maximum size allowed by the server."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            return;
        }
    }
    [self.mailController setSubject:@""];
    [self.mailController setMessageBody:@"" isHTML:NO];
    [self.mailController setMessageBody:emailBody isHTML:NO];
    
    if (self.mailController){
        [self presentViewController:self.mailController animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if(result == MFMailComposeResultFailed)
    {
        NSString *msg = @"Mail failed. Please select less tags and try it again later.";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
}


#pragma mark Facebook Methods
- (void)facebookShare
{
    [self socialShareWithMethod:1];
}


#pragma mark Twitter Share
-(void)twitterShare
{
    [self socialShareWithMethod:2];
}

- (void)socialShareWithMethod: (NSInteger)service
{
    if(_currentSharingMethod > 0)
        return;
    
    NSArray* methodStrings = @[@"None", @"Facebook", @"Twitter"];
    
//    if(!_GDUploader)
//    {
//        _GDUploader = [[GDFileUploader alloc] initWithDriveService:nil];
//        _GDUploader.delegate = self;
//    }
//    
//    if(![_GDUploader isAuthorized])
//    {
//        [[[UIAlertView alloc] initWithTitle:@"Cannot Share" message:[NSString stringWithFormat:@"You must also be linked to Google Drive in order to share the video link(s) on %@",methodStrings[service]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
//        return;
//    }
    
    _currentSharingMethod = service;
    [self uploadToGoogleDrive];
    
    [popoverController dismissPopoverAnimated:YES];
    [self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
    
}

#pragma mark - Google Drive (GD) file uploader Delegate

- (void)fileUploader:(GDFileUploader *)uploader didFinishUploadingFileWithName:(NSString *)fileName isSuccessful:(BOOL)success
{
    if(!success || _currentSharingMethod==0)
        return;
    
    SLComposeViewController* viewController =[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if(_currentSharingMethod == 1)
        viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [viewController setTitle:@"Clips from myplayXplay"];
    
    NSMutableString* description = [NSMutableString stringWithString:@"Checkout These Tagged Clips: \n"];
    
//    for(GTLDriveFile* file in uploader.uploadedGTLFiles)
//    {
//        NSString* videoLink = file.embedLink;
//        [description appendString:file.title];
//        [viewController addURL:[NSURL URLWithString:videoLink]];
//    }
//    
    [viewController setInitialText: description];
    
    [self presentViewController:viewController animated:YES completion:nil];
    
    _currentSharingMethod = 0;
}

// Check these methods, they should be implimented as per protocal, but are not used
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
