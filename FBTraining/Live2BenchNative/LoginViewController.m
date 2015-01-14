//
//  LoginViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-01-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "LoginViewController.h"
#import "Live2BenchViewController.h"
#import "CalendarViewController.h" //this should be calendar
#import "CustomTabBar.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "UtilitiesController.h"
#import "sys/socket.h"
#import "netinet/in.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import "UserCenter.h"
#define TOTAL_WIDTH          1024
#define TOTAL_HEIGHT         748


@class Live2BenchViewController;
@class CalendarViewController;
@class UtilitiesController;

@interface LoginViewController ()

@end

@implementation LoginViewController
{

    UserCenter * _userCenter;
}

@synthesize live2BenchViewController,uController;
@synthesize calendarViewController;
@synthesize customTabBar;
@synthesize rect;
bool receivedResponse;
@synthesize accountLoginLabel,emailAddressLabel,emailAddressTextField,passwordLabel,passwordTextField,submitButton,goToCalendarButton,goToL2BButton,noInternetLabel,noInternetLoginLabel;
@synthesize loadingView;

UIScrollView *scrollView;

- (id)initWithController:(Live2BenchViewController*)lbv
{
   
    live2BenchViewController=lbv;
    self = [super init];
    if (self) {
        // Custom initialization
        _userCenter = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userCenter;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [live2BenchViewController.tabBarController setSelectedIndex:1];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeAllObjects];
    [CustomAlertView removeAll];
}

- (void)setupView
{
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    bgView.image = [UIImage imageNamed:@"landingBackground"];
//    [self.view addSubview:bgView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:scrollView];
    
    UILabel *pxpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.view.bounds.size.width, 70.0f)];
    [pxpLabel setText:@"myplayXplay"];
    [pxpLabel setFont:[UIFont lightFontOfSize:60.0f]];
    [pxpLabel setTextColor:[UIColor orangeColor]];
    [pxpLabel setTextAlignment:NSTextAlignmentCenter];
    pxpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:pxpLabel];
    
    self.emailAddressTextField = [[LoginTextField alloc] initWithFrame:CGRectMake(70.0f, 350.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    self.emailAddressTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.emailAddressTextField.placeholder = @"Email";
    [self.emailAddressTextField setBackground:[[UIImage imageNamed:@"groupedTop"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)]];
    self.emailAddressTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [scrollView addSubview:self.emailAddressTextField];
    
    self.passwordTextField = [[LoginTextField alloc] initWithFrame:CGRectMake(70.0f, CGRectGetMaxY(self.emailAddressTextField.frame) - 1.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    self.passwordTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.passwordTextField.placeholder = @"Password";
    [self.passwordTextField setBackground:[[UIImage imageNamed:@"groupedBottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)]];
    self.passwordTextField.secureTextEntry = TRUE;
    [scrollView addSubview:self.passwordTextField];
    
    self.submitButton = [CustomButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setTitle:@"Sign In" forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont defaultFontOfSize:30.0f];
    [self.submitButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.submitButton.frame = CGRectMake((self.view.bounds.size.width - 80.0f)/2, CGRectGetMaxY(self.passwordTextField.frame) + 15.0f , 100.0f, 50.0f);
    self.submitButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.submitButton addTarget:self action:@selector(submitAccountInfo:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.submitButton];
    
    noInternetLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 350.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    noInternetLabel.text = @"No internet available, play video from local storage.";
    noInternetLabel.textColor = [UIColor orangeColor];
    noInternetLabel.backgroundColor = [UIColor clearColor];
    noInternetLabel.font = [UIFont defaultFontOfSize:19.0f];
    noInternetLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [noInternetLabel setTextAlignment:NSTextAlignmentCenter];
    [scrollView addSubview:noInternetLabel];
    
    UIImageView *coachPickedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coachPicked"]];
    coachPickedImageView.frame = CGRectMake((self.view.bounds.size.width - 130.0f)/2, self.emailAddressTextField.frame.origin.y - 175.0f, 130.0f, 140.0f);
    coachPickedImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [scrollView addSubview:coachPickedImageView];
    
    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    loadingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    [self.view addSubview:loadingView];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner startAnimating];
    spinner.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    spinner.frame = loadingView.bounds;
    [loadingView addSubview:spinner];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!globals) {
         globals = [Globals instance];
    }
   
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.lVController=self;
    [loadingView setHidden:TRUE];
    uController = [[UtilitiesController alloc] init];
    customTabBar = [[CustomTabBar alloc]init];
    
    emailAddressTextField.delegate = self;
    emailAddressTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.delegate = self;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    
    wifiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(wifiTimerCallback) userInfo:nil repeats:YES];

   }

- (void)wifiTimerCallback
{
    
    if(globals.STOP_TIMERS_FROM_LOGOUT)
    {
        return;
    }
    if([uController hasConnectivity])
    {
        [wifiTimer invalidate];
        wifiTimer = nil;
        [emailAddressLabel setHidden:FALSE];
        [emailAddressTextField setHidden:FALSE];
        [passwordLabel setHidden:FALSE];
        [passwordTextField setHidden:FALSE];
        [submitButton setHidden:FALSE];
        [noInternetLabel setHidden:TRUE];
    }
}
- (void)didReceiveMemoryWarning
{
    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.passwordTextField){
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                                   scrollView.contentInset.left,
                                                   scrollView.contentInset.bottom - 50.0f,
                                                   scrollView.contentInset.right);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.passwordTextField){
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                                   scrollView.contentInset.left,
                                                   scrollView.contentInset.bottom + 50.0f,
                                                   scrollView.contentInset.right);
    }
}


- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardFrame = [self.view.window convertRect:[[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
    CGFloat insetHeight = keyboardFrame.size.height;
    insetHeight -= self.passwordTextField.isFirstResponder ? 50.0f : 0.0f;
    [scrollView setContentSize:self.view.bounds.size];
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, insetHeight, 0)];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [scrollView setContentInset:UIEdgeInsetsZero];
    }];
}


- (BOOL)textFiledShouldReturn:(UITextField*)textfield {
    return YES;
}

- (void)goToFirstView:(id)sender {
    
    //refresh the tag names based on new plist
//    [live2BenchViewController populateTagNames];
//    [live2BenchViewController createTagButtons];

    [self dismissViewControllerAnimated:NO completion:NULL];
    //go to logo view page
    //[live2BenchViewController.tabBarController setSelectedIndex:0];
    //[customTabBar selectTab:0];
}

- (void)goToCalendarView:(id)sender {
    
    //refresh the tag names based on new plist
    if ([uController hasConnectivity]==NO) {
        [live2BenchViewController populateTagNames];
        [live2BenchViewController createTagButtons];
    }
    [self dismissViewControllerAnimated:NO completion:NULL];
    [live2BenchViewController.tabBarController setSelectedIndex:2];
    [customTabBar selectTab:1];
   
    
}

- (NSString *)stringToSha1:(NSString *)hashkey{
    
    // Using UTF8Encoding
    const char *s = [hashkey cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, keyData.length, digest);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest
                                 length:CC_SHA1_DIGEST_LENGTH];
    // description converts to hex but puts <> around it and spaces every 4bytes
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    // hash is now a string with just the 40char hash value in it
    
    return hash;    
}

-(void)refreshUI
{

    [accountLoginLabel setHidden:TRUE];
    [emailAddressLabel setHidden:TRUE];
    [emailAddressTextField setHidden:TRUE];
    [passwordLabel setHidden:TRUE];
    [passwordTextField setHidden:TRUE];
    [submitButton setHidden:TRUE];
    [noInternetLoginLabel setHidden:TRUE];
    [noInternetLabel setHidden:TRUE];
    [goToCalendarButton setHidden:TRUE];
    [goToL2BButton setHidden:TRUE];
    
   

    if(globals.IS_LOGGED_IN)
    {
        if([uController hasConnectivity])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            //            [accountLoginLabel setHidden:TRUE];
            //            [emailAddressLabel setHidden:TRUE];
            //            [emailAddressTextField setHidden:TRUE];
            //            [passwordLabel setHidden:TRUE];
            //            [passwordTextField setHidden:TRUE];
            //            [submitButton setHidden:TRUE];
            //            [noInternetLoginLabel setHidden:TRUE];
            [noInternetLabel setText:@"No internet available, play video from local storage."];
            [noInternetLabel setHidden:FALSE];
            [goToCalendarButton setHidden:FALSE];
            //            [goToL2BButton setHidden:TRUE];
            
        }
    }else{
        if([uController hasConnectivity])
        {
            [emailAddressLabel setHidden:FALSE];
            [emailAddressTextField setHidden:FALSE];
            [passwordLabel setHidden:FALSE];
            [passwordTextField setHidden:FALSE];
            [submitButton setHidden:FALSE];
            [noInternetLabel setHidden:TRUE];
            
        }
        else
        {
            //            [accountLoginLabel setHidden:TRUE];
            //            [emailAddressLabel setHidden:TRUE];
            //            [emailAddressTextField setHidden:TRUE];
            //            [passwordLabel setHidden:TRUE];
            //            [passwordTextField setHidden:TRUE];
            //            [submitButton setHidden:TRUE];
            //            [noInternetLoginLabel setHidden:TRUE];
            [noInternetLabel setText:@"Please Connect to Internet"];
            [noInternetLabel setHidden:FALSE];
            //            [goToCalendarButton setHidden:TRUE];
            //            [goToL2BButton setHidden:TRUE];
        }
    }
    
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [self refreshUI];
    [super viewWillAppear:animated];
}

//Hash encryptment
-(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

//send account information (email, password,devicename etc.) to the server
-(void)sendUserInfo:(NSString *)pData live2BenchViewController:(Live2BenchViewController*)lbv{
    //empty the queue before adding the login request; otherwise if there are other requests stalls in the queue, there might be a huge delay for sending the log in request
    if (globals.APP_QUEUE.queue.count > 1) {
        id LastRequest = [globals.APP_QUEUE.queue objectAtIndex:0];
        [globals.APP_QUEUE.queue removeAllObjects];
        [globals.APP_QUEUE.queue addObject:LastRequest];
    }
    
    live2BenchViewController = lbv;
    //appQueue = [[AppQueue alloc] init];
    //get post data
    NSData *postData = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength = [NSString stringWithFormat:@"%d",[postData length]];
    request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/activate/ajax"]]];
    
    //create post request
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:postData];
    
    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(saveAuthorizationData:)],self, nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:request dict:instObj];
    
    [passwordTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [submitButton setUserInteractionEnabled:NO];

//        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:globals.SPINNERVIEW];
    receivedResponse = NO;
    [self performSelector:@selector(didReceiveResponse) withObject: nil afterDelay:5];
    

}

//required for magic. Or to dismiss the keyboard when we try to submit username and password
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void) didReceiveResponse
{
    
    [globals.SPINNERVIEW removeFromSuperview];
    if (!receivedResponse){
    CustomAlertView *alert = [[CustomAlertView alloc]
                          initWithTitle: @"Could not log in."
                          message: @"Please check your internet connection"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    }
    [loadingView setHidden:TRUE];
    [submitButton setUserInteractionEnabled:YES];
}

-(void)populateTagButtonsPlist:(NSDictionary*)jsonDictionary
{
    NSArray *tagNames = [jsonDictionary objectForKey:@"tagbuttons"];
   

    NSString *path = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"TagButtons.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path])
    {
        path = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent: [NSString stringWithFormat: @"TagButtons.plist"] ];
    }
    fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *plistData;
    if ([fileManager fileExistsAtPath:path]&& !tagNames) {
        
        //plistData = [[NSMutableArray alloc]initWithContentsOfFile:path];
        
    }else if ([fileManager fileExistsAtPath: path] && tagNames ){
        
        [fileManager removeItemAtPath:path error:NULL];
        
        plistData = [[NSMutableArray alloc] init];
        //initialise dictionary
        for(NSDictionary *tNames in tagNames){
            NSString *name = [tNames objectForKey:@"name"];
            NSString *position = [tNames objectForKey:@"position"];
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            
            [data setObject:[NSString stringWithString:name] forKey:@"name"];
            [data setObject:[NSString stringWithString:position] forKey:@"side"];
            
            [plistData addObject:data];
        }
        [plistData writeToFile: path atomically:YES];
    }else{
        
        plistData = [[NSMutableArray alloc] init];
        //initialise dictionary
        for(NSDictionary *tNames in tagNames){
            NSString *name = [tNames objectForKey:@"name"];
            NSString *position = [tNames objectForKey:@"position"];
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            
            [data setObject:[NSString stringWithString:name] forKey:@"name"];
            [data setObject:[NSString stringWithString:position] forKey:@"side"];
            
            [plistData addObject:data];
        }
         [plistData writeToFile: path atomically:YES];
    }
    

}

-(void)saveAuthorizationData:(id)json{
    [globals.SPINNERVIEW removeFromSuperview];
    [submitButton setUserInteractionEnabled:YES];
    receivedResponse = YES;
    NSDictionary *jsonDictionary = json;
    userDictionary = [[NSDictionary alloc]initWithDictionary:jsonDictionary];

    isSuccess = [[jsonDictionary objectForKey:@"success"] intValue ];
    if(isSuccess == 1){

      
        [self populateTagButtonsPlist:jsonDictionary];
        NSString *accountInfoPath = globals.ACCOUNT_PLIST_PATH;

//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if (![fileManager fileExistsAtPath: accountInfoPath])
//        {
//            accountInfoPath = globals.ACCOUNT_PLIST_PATH;
//        }
//        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *data;
        
        if ([fileManager fileExistsAtPath: accountInfoPath])
        {
            [fileManager removeItemAtPath:accountInfoPath error:NULL];
        }
        data = [[NSMutableDictionary alloc] init];
        
        //save data to accountinfo plist
        //To insert the data into the plist
        
        for(NSString *field in globals.ACCOUNT_FIELDS)
        {
            [data setObject:[jsonDictionary objectForKey:field] forKey:field];
        }
        [data writeToFile: accountInfoPath atomically:YES];

        globals.IS_LOGGED_IN=TRUE;
        
        globals.ACCOUNT_INFO=data;
        if(!globals.IS_EULA )
        {
            EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]initWithController:self];
            [eulaViewController setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:eulaViewController animated:YES completion:nil];
        }
       
        globals.STOP_TIMERS_FROM_LOGOUT=FALSE;
        if(globals.HAS_CLOUD)
        {
            [uController sync2Cloud];
        }
        //[uController getAllGameTags];
    }else{
      responseMsg=[jsonDictionary objectForKey:@"msg"];
        CustomAlertView *alert = [[CustomAlertView alloc]
                              initWithTitle: @"Error"
                              message: responseMsg
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
//        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        [loadingView setHidden:TRUE];
    }
    
}

-(void)presentEula
{
    
}

//send account information to server
- (void)submitAccountInfo:(id)sender {
    NSString *deviceType = [self stringToSha1: @"tablet"];
    //encrypt email/password
    
    if(!emailAddressTextField.text || !passwordTextField.text)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Please enter an email and password"
                              message: responseMsg
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;

    }
    emailAddress = [self stringToSha1: emailAddressTextField.text];
    password = [self sha256HashFor: [passwordTextField.text stringByAppendingString: @"azucar"]];
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    //NSString *deviceInformation = [self platformString];
    NSString *pData = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceType,emailAddress,password,deviceName,UUID];
    [loadingView setHidden:FALSE];
    [self sendUserInfo:pData live2BenchViewController:live2BenchViewController];

    [loadingView setHidden:false];
}



/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    //[textField resignFirstResponder];
    [submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

@end
