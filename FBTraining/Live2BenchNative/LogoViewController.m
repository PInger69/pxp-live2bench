//
//  LogoViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "LogoViewController.h"
#import "UserSettings.h"
#import "CustomAlertView.h"
#import "ScreenController.h"
#import "EncoderManager.h"
#define LABEL_X              22
#define LABEL_Y             100
#define LABEL_WIDTH         300
#define PADDING              40
#define LABEL_HEIGHT        100
#define IMAGEVIEW_HEIGHT    400

typedef enum : NSUInteger {
    TabHardware,
    TabTagging,
    TabContact,
} WelcomeTabType;

static const NSString * HARDWARE_WEBSITE    = @"http://www.youtube.com/watch?v=GJ2jux5sQRo&feature=c4-overview-vl&list=PLKi5daaUxbXGlOV6E5Sb_FjZdS9tNX34e/";
static const NSString * TAGGING_WEBSITE     = @"http://www.youtube.com/watch?v=1hHVE8Ur-c8&feature=c4-overview-vl&list=PLKi5daaUxbXGlOV6E5Sb_FjZdS9tNX34e/";
static const NSString * HOMEPAGE_WEBSITE    = @"http://www.myplayxplay.com/";




@interface LogoViewController ()

@property (nonatomic, strong) BorderlessButton  * tabContentTitle;
@property (nonatomic, strong) UIImageView       * tabContentImage;
@property (nonatomic, strong) UITextView        * tabContentDescription;
@property (nonatomic, strong) UIView            * contactLeftSide;
@property (nonatomic, strong) IconButton        * tabContentLink;

@end

@implementation LogoViewController

UIToolbar           * welcomeToolBar;
UIView              * tabContentView;
NSDictionary        * tabAttributes;
NSDictionary        * tabSelectAttributes;
ScreenController    * screenTest;
EncoderManager      * encoderManager;
@synthesize mailController;

-(id)initWithAppDelegate:(AppDelegate *)appDel
{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        encoderManager = _appDel.encoderManager;
        [self setMainSectionTab:NSLocalizedString(@"Welcome",nil)  imageName:@"logoTab"];
        settingsViewController = [[EncoderControlsViewController alloc]initWithAppDelegate:appDel];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}


-(void)setupView{
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    tabAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                     [UIFont defaultFontOfSize:35.0f], NSFontAttributeName,
                     [UIColor colorWithWhite:0.3f alpha:1.0f], NSForegroundColorAttributeName,
                     nil];
    tabSelectAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIFont defaultFontOfSize:35.0f], NSFontAttributeName,
                           PRIMARY_APP_COLOR, NSForegroundColorAttributeName,
                           nil];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fix.width = 5.0f;
    hardwareTab = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hardware",nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    hardwareTab.tag = 0;
    [hardwareTab setTitleTextAttributes:tabSelectAttributes forState:UIControlStateNormal];
    taggingTab = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Tagging",nil)  style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    taggingTab.tag = 1;
    [taggingTab setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
    contactTab = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Contact Us",nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    contactTab.tag = 2;
    [contactTab setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
    
    ////////////////////////////////////////////
    //Icon Tabs
    dropboxTab = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropboxTabIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showDropbox)];
    dropboxTab.tintColor = [UIColor darkGrayColor];
    dropboxTab.tag = 3;
    
    googleDriveTab = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"googleDrive"] style:UIBarButtonItemStylePlain target:self action:@selector(showGoogleDrive)];
    googleDriveTab.tintColor = [UIColor darkGrayColor];
    googleDriveTab.tag = 4;
    
    settingsTab = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingsButton"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    settingsTab.tag = 5;
    //////////////////////////////////////////////
    
    settingsTab.tintColor = [UIColor darkGrayColor];
    
    welcomeToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - 60.0f, self.view.bounds.size.width, 60.0f)];
    welcomeToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [welcomeToolBar setItems:@[flex, hardwareTab, flex, taggingTab, flex, contactTab, flex/*, dropboxTab,fix,googleDriveTab,fix, settingsTab, fix*/]];
    [self.view addSubview:welcomeToolBar];
    
    tabContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 65.0f, self.view.bounds.size.width, self.view.bounds.size.height - 65.0f - welcomeToolBar.bounds.size.height)];
    tabContentView.tag = 0;
    tabContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tabContentView];
    
    self.tabContentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical_myplayXplay_case"]];
    self.tabContentImage.contentMode = UIViewContentModeBottomRight;
    self.tabContentImage.frame = tabContentView.bounds;
    self.tabContentImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tabContentView addSubview:self.tabContentImage];
    
    self.tabContentTitle = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    self.tabContentTitle.frame = CGRectMake(30.0f, -40.0f, 500.0f, 100.0f);
    [self.tabContentTitle.titleLabel setShadowOffset:CGSizeMake(10.0f, 10.0f)];
    [self.tabContentTitle.titleLabel setShadowColor:[UIColor whiteColor]];
    self.tabContentTitle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.tabContentTitle setTitle:NSLocalizedString(@"Hardware",nil) forState:UIControlStateNormal];
    [self.tabContentTitle setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f)];
    [self.tabContentTitle addTarget:self action:@selector(goToTabLink:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabContentTitle setFont:[UIFont lightFontOfSize:100.0f]];
    [tabContentView addSubview:self.tabContentTitle];
    float descriptionWidth =self.view.bounds.size.width - self.tabContentImage.bounds.size.width ;
    NSLog(@"float for width is %f", descriptionWidth);
    NSLog(@"float for width is %f", self.view.frame.size.width);
    NSLog(@"float for width is %f", self.tabContentImage.frame.size.width);
    
    self.tabContentDescription = [[UITextView alloc] initWithFrame:CGRectMake(self.tabContentTitle.frame.origin.x + 30, CGRectGetMaxY(self.tabContentTitle.frame) + 130.0f, 500, 185.0f)];
    self.tabContentDescription.editable = NO;
    self.tabContentDescription.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    self.tabContentDescription.scrollEnabled = NO;
    NSString *hardwareTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HardwareString" ofType:@"txt"];
    self.tabContentDescription.text = [NSString stringWithContentsOfFile:hardwareTextPath encoding:NSUTF8StringEncoding error:nil];
    [self.tabContentDescription setDataDetectorTypes:UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink];
    [self.tabContentDescription setFont:[UIFont defaultFontOfSize:20.0f]];
    [self.tabContentDescription setTextColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
    [tabContentView addSubview:self.tabContentDescription];
    
    self.contactLeftSide = [[UIView alloc] initWithFrame:CGRectMake(self.tabContentDescription.frame.origin.x, self.tabContentDescription.frame.origin.y, 100.0f, self.tabContentDescription.bounds.size.height)];
    UITextView *contactLabels = [[UITextView alloc] initWithFrame:self.contactLeftSide.bounds];
    contactLabels.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contactLabels.editable = NO;
    contactLabels.backgroundColor = self.tabContentDescription.backgroundColor;
    NSString *contactLabelTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ContactLabelString" ofType:@"txt"];
    contactLabels.text = [NSString stringWithContentsOfFile:contactLabelTextPath encoding:NSUTF8StringEncoding error:nil];
    [contactLabels setFont:[UIFont defaultFontOfSize:20.0f]];
    [contactLabels setTextColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
    [contactLabels setTextAlignment:NSTextAlignmentRight];
    [contactLabels setSelectable:NO];
    [self.contactLeftSide addSubview:contactLabels];
    UIImageView *line = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"fadedDivider"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f)]];
    line.frame = CGRectMake(self.contactLeftSide.bounds.size.width - 1.0f, 0.0f, 1.0f, self.contactLeftSide.bounds.size.height);
    [self.contactLeftSide addSubview:line];
    [self.contactLeftSide setHidden:YES];
    [tabContentView addSubview:self.contactLeftSide];
    
    self.tabContentLink = [IconButton buttonWithType:UIButtonTypeCustom];
    self.tabContentLink.iconLocation = IconRight;
    self.tabContentLink.frame = CGRectMake(self.tabContentDescription.frame.origin.x - 10.0f, tabContentView.bounds.size.height - 90.0f, 180.0f, 30.0f);
    [self.tabContentLink setNeedsDisplay];
    //self.tabContentLink.backgroundColor = [UIColor grayColor];
    self.tabContentLink.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.tabContentLink addTarget:self action:@selector(goToTabLink:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabContentLink setImage:[[UIImage imageNamed:@"youtube"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.tabContentLink setImage:[UIImage imageNamed:@"youtubeSelect"] forState:UIControlStateHighlighted];
    //self.tabContentLink.titleLabel.backgroundColor = [UIColor blueColor];
    [self.tabContentLink setTitle:NSLocalizedString(@"Learn more",nil) forState:UIControlStateNormal];
    [self.tabContentLink setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.tabContentLink.adjustsImageWhenHighlighted = NO;
    [tabContentView addSubview:self.tabContentLink];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSettings) name:@"hideSettings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSettings:) name:@"showSettings" object:nil];
    
    [self.view bringSubviewToFront:welcomeToolBar];
}


-(UIView*)makeHardware
{
    
    return nil;
}

-(void)selectTab:(UIBarButtonItem*)tab{
    
    if (tabContentView.tag == tab.tag){
        return;
    }
    
    for (UIBarButtonItem *item in welcomeToolBar.items){
        [item setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
    }
    [tab setTitleTextAttributes:tabSelectAttributes forState:UIControlStateNormal];
    tabContentView.tag = tab.tag;
    
    [UIView animateWithDuration:0.3f animations:^{
        tabContentView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        switch (tab.tag) {
            case 0:
            {
                [self.tabContentImage setImage:[UIImage imageNamed:@"vertical_myplayXplay_case"]];
                [self.tabContentImage setHidden:NO];
                [self.tabContentTitle setTitle:NSLocalizedString(@"Hardware",nil) forState:UIControlStateNormal];
                NSString *hardwareTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HardwareString" ofType:@"txt"];
                [self.tabContentDescription setText:[NSString stringWithContentsOfFile:hardwareTextPath encoding:NSUTF8StringEncoding error:nil]];
                if (!self.contactLeftSide.hidden)
                {
                    [self.tabContentDescription setFrame:CGRectMake(self.tabContentDescription.frame.origin.x - 100.0f, self.tabContentDescription.frame.origin.y, self.tabContentDescription.bounds.size.width, self.tabContentDescription.bounds.size.height)];
                    [self.contactLeftSide setHidden:YES];
                }
                [self.tabContentLink setHidden:NO];
            }
                break;
            case 1:
            {
                [self.tabContentImage setImage:[UIImage imageNamed:@"myplayXplay_tagging"]];
                [self.tabContentImage setHidden:NO];
                [self.tabContentTitle setTitle:NSLocalizedString(@"Tagging",nil) forState:UIControlStateNormal];
                NSString *taggingTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaggingString" ofType:@"txt"];
                [self.tabContentDescription setText:[NSString stringWithContentsOfFile:taggingTextPath encoding:NSUTF8StringEncoding error:nil]];
                if (!self.contactLeftSide.hidden)
                {
                    [self.tabContentDescription setFrame:CGRectMake(self.tabContentDescription.frame.origin.x - 100.0f, self.tabContentDescription.frame.origin.y, self.tabContentDescription.bounds.size.width, self.tabContentDescription.bounds.size.height)];
                    [self.contactLeftSide setHidden:YES];
                }
                [self.tabContentLink setHidden:NO];
            }
                break;
            case 2:
            {
                [self.tabContentImage setImage:[UIImage imageNamed:@"myplayXplay_phonecall"]];
                [self.tabContentTitle setTitle:NSLocalizedString(@"Contact Us",nil)  forState:UIControlStateNormal];
                NSString *contactTextPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ContactString" ofType:@"txt"];
                [self.tabContentDescription setText:[NSString stringWithContentsOfFile:contactTextPath encoding:NSUTF8StringEncoding error:nil]];
                if (self.contactLeftSide.hidden)
                {
                    [self.tabContentDescription setFrame:CGRectMake(self.tabContentDescription.frame.origin.x + 100.0f, self.tabContentDescription.frame.origin.y, self.tabContentDescription.bounds.size.width, self.tabContentDescription.bounds.size.height)];
                    [self.contactLeftSide setHidden:NO];
                }
                [self.tabContentLink setHidden:YES];
            }
                break;
            default:
                break;
        }
        [self animateContentViewIn];
    }];
}

-(void)animateContentViewIn
{
    [UIView animateWithDuration:0.3f animations:^{
        tabContentView.alpha = 1.0f;
    }];
}

-(void)goToTabLink:(id)sender
{
    NSString * site;
    switch (tabContentView.tag) {
        case 0:
            site = [HARDWARE_WEBSITE copy];
            break;
        case 1:
            site = [TAGGING_WEBSITE copy];
            break;
        case 2:
            site = [HARDWARE_WEBSITE copy];
            break;
    }
    if (site) [[UIApplication sharedApplication] openURL:[NSURL URLWithString: site ]];
}

//-(void)goToHardwareWebsite:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/watch?v=GJ2jux5sQRo&feature=c4-overview-vl&list=PLKi5daaUxbXGlOV6E5Sb_FjZdS9tNX34e/"]];
//}
//
//-(void)goToTaggingWebsite:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/watch?v=1hHVE8Ur-c8&feature=c4-overview-vl&list=PLKi5daaUxbXGlOV6E5Sb_FjZdS9tNX34e/"]];
//}
//
//-(void)goToHomepage:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.myplayxplay.com/"]];
//}

-(void)sendEmail{
    
    mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@""];
    [mailController setToRecipients:[NSArray arrayWithObject:@"avocatec@gmail.com"]];
    [mailController setMessageBody:@"" isHTML:NO];
    
    if (mailController){
        [self presentViewController:mailController animated:YES completion:nil];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSent:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)showSettings:(id)sender
{
    //    if (!self.tapBehindGesture){
    //        self.tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
    //        self.tapBehindGesture.numberOfTapsRequired = 1;
    //        self.tapBehindGesture.cancelsTouchesInView = NO;
    //        self.tapBehindGesture.delegate = self;
    //    }
    //
    //
    //    [self.view.window addGestureRecognizer:self.tapBehindGesture];
    //if the settings view controller already initialized,DONNOT reinitialize it
    
    // TODO Move up to view did load
    if (!settingsViewController) {
        settingsViewController = [[EncoderControlsViewController alloc]initWithAppDelegate:_appDel];
    }
    
    [settingsTab setImage:[UIImage imageNamed:@"settingsButtonSelect"]];
    
    [self.tabBarController presentViewController:settingsViewController animated:YES completion:^{
        
        [settingsTab setImage:[UIImage imageNamed:@"settingsButton"]];
    }];
    
}
//
//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    return YES;
//}

//-(void)tapBehindDetected:(UITapGestureRecognizer*)sender
//{
//
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        CGPoint location = [sender locationInView:nil];
//        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
//        {
//            if (self.presentedViewController && ![globals.HOME_POP isPopoverVisible] && ![globals.AWAY_POP isPopoverVisible] && ![globals.LEAGUE_POP isPopoverVisible]){
//                [self hideSettings];
//            }
//        }
//    }
//}


-(void)hideSettings
{
    if (self.tabBarController.presentedViewController){
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
    //    [self.view.window removeGestureRecognizer:self.tapBehindGesture];
    [settingsTab setImage:[UIImage imageNamed:@"settingsButton"]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(settingsViewController.view.frame.origin.x >= 0)
    {
        [self hideSettings];
    }
    
    [CustomAlertView removeAll];
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    
    
}

@end
