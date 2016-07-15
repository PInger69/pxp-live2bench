//
//  LoginViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-01-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomButton.h"
#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "sys/socket.h"
#import "netinet/in.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import "UserCenter.h"


#import "EulaModalViewController.h"
#define TOTAL_WIDTH          1024
#define TOTAL_HEIGHT         748




@interface LoginViewController ()

@end

@implementation LoginViewController
{
    UserCenter * _userCenter;
    void            (^_onAccept)(void);
    UIView     * loginBackback;
    EulaModalViewController * eulaModalViewController;
}

@synthesize hasInternet     = _hasInternet;
@synthesize success         = _success;

@synthesize rect;
bool receivedResponse;
@synthesize accountLoginLabel,emailAddressLabel,emailAddressTextField,passwordLabel,passwordTextField,submitButton,goToCalendarButton,goToL2BButton,noInternetLabel,noInternetLoginLabel;
@synthesize loadingView;



UIScrollView *scrollView;

- (id)init
{

    self = [super init];
    if (self) {
        _hasInternet = NO;
        loginBackback = [[UIView alloc]initWithFrame:CGRectMake(0, -100, 1024.0f, 868.0f)];
        [loginBackback setBackgroundColor:[UIColor whiteColor]];
        eulaModalViewController =[[EulaModalViewController alloc]init];
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self setupView];
    }
    return self;
}


- (void)setupView
{

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:scrollView];
    
    UILabel *pxpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.view.bounds.size.width, 70.0f)];
    [pxpLabel setText:NSLocalizedString(@"myplayXplay",nil)];
    [pxpLabel setFont:[UIFont lightFontOfSize:60.0f]];
    [pxpLabel setTextColor:PRIMARY_APP_COLOR];
    [pxpLabel setTextAlignment:NSTextAlignmentCenter];
    pxpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:pxpLabel];
    
    self.emailAddressTextField = [[LoginTextField alloc] initWithFrame:CGRectMake(70.0f, 335.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    self.emailAddressTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.emailAddressTextField.placeholder = NSLocalizedString(@"Email",nil);
    [self.emailAddressTextField setBackground:[[UIImage imageNamed:@"groupedTop"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)]];
    [self.emailAddressTextField setBorderStyle:UITextBorderStyleRoundedRect];
    self.emailAddressTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [scrollView addSubview:self.emailAddressTextField];
    
    self.passwordTextField = [[LoginTextField alloc] initWithFrame:CGRectMake(70.0f, CGRectGetMaxY(self.emailAddressTextField.frame) + 15.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    self.passwordTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.passwordTextField.placeholder = NSLocalizedString(@"Password",nil);
    [self.passwordTextField setBackground:[[UIImage imageNamed:@"groupedBottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)]];
    [self.passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    self.passwordTextField.secureTextEntry = TRUE;
    [scrollView addSubview:self.passwordTextField];
    
    self.emailAddressTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.submitButton = [CustomButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setTitle:NSLocalizedString(@"Sign In",nil) forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont defaultFontOfSize:30.0f];
    [self.submitButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    self.submitButton.frame = CGRectMake((self.view.bounds.size.width - 100.0f)/2, CGRectGetMaxY(self.passwordTextField.frame) + 15.0f , 100.0f, 50.0f);
    self.submitButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.submitButton addTarget:self action:@selector(submitAccountInfo:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.submitButton];
    
    noInternetLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 350.0f, self.view.bounds.size.width - 140.0f, 50.0f)];
    noInternetLabel.text = NSLocalizedString(@"No internet available, play video from local storage.",nil);
    noInternetLabel.textColor = PRIMARY_APP_COLOR;
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
    
    [accountLoginLabel          setHidden:TRUE];
    [emailAddressLabel          setHidden:TRUE];
    [emailAddressTextField      setHidden:TRUE];
    [passwordLabel              setHidden:TRUE];
    [passwordTextField          setHidden:TRUE];
    [submitButton               setHidden:TRUE];
    [noInternetLoginLabel       setHidden:TRUE];
    [noInternetLabel            setHidden:TRUE];
    [goToCalendarButton         setHidden:TRUE];
    [goToL2BButton              setHidden:TRUE];
    
    [loadingView addSubview:spinner];
    [loadingView setHidden:TRUE];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onResponce:) name:NOTIF_CREDENTIALS_VERIFY_RESULT object:nil]; // ask
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setFrame:CGRectMake(0, 0, 350.0f, 768.0f)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    


    emailAddressTextField.delegate      = self;
    emailAddressTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.delegate          = self;
    passwordTextField.returnKeyType     = UIReturnKeyDone;

}


-(void)onCompleteAccept:(void(^)(void))onAccept
{
    _onAccept = onAccept;
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
//    CGRect keyboardFrame = [self.view.window convertRect:[[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
//    CGFloat insetHeight = keyboardFrame.size.height;
//    insetHeight -= self.passwordTextField.isFirstResponder ? 100.0f : 100.0f;
//    [scrollView setContentSize:self.view.bounds.size];
    //[scrollView setContentInset:UIEdgeInsetsMake(0, 0, 180, 0)];
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.origin.y = scrollFrame.origin.y - 50;
    [scrollView setFrame: scrollFrame];
//    
//    CGRect selfFrame = self.view.frame;
//    selfFrame.origin.y = selfFrame.origin.y - 180;
//    [self.view setFrame: selfFrame];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        CGRect scrollFrame = scrollView.frame;
        scrollFrame.origin.y = scrollFrame.origin.y + 50;
        [scrollView setFrame: scrollFrame];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self submitAccountInfo: self.submitButton];
    //[self checkRun:nil];
    return YES;
}

//- (BOOL)textFiledShouldReturn:(UITextField*)textfield {
//    return YES;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:loginBackback];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (loginBackback.superview)[loginBackback removeFromSuperview];
}

//required for magic. Or to dismiss the keyboard when we try to submit username and password
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}


////send account information to server
- (void)submitAccountInfo:(id)sender {

    NSString * userInput         = emailAddressTextField.text;
    NSString * passwordInput     = passwordTextField.text;
    [passwordTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [loadingView setHidden:false];
    NSMutableDictionary *loginData = [[NSMutableDictionary alloc] initWithDictionary: @{@"user":userInput,@"password":passwordInput}];
    [[UserCenter getInstance] verifyGet: loginData timeStamp:GET_NOW_TIME];
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_TO_VERIFY object:nil userInfo:@{@"user":userInput,@"password":passwordInput}];
    
}



-(void)onResponce:(NSNotification *)note
{
    BOOL success = [[note.userInfo objectForKey:@"success"]boolValue];

    if (success) {
        self.success = YES;
        
        [submitButton setUserInteractionEnabled:NO];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
        [noInternetLabel setHidden:YES];

    } else {
        [noInternetLabel setHidden:NO];
        [noInternetLabel setText:[note.userInfo objectForKey:@"msg"]];
        // fail try again
        // show incorrect
        // clear list
    }
    [loadingView setHidden:YES];
    

}



-(BOOL)hasInternet
{
    return _hasInternet;
}

-(void)setHasInternet:(BOOL)hasInternet
{
    _hasInternet = hasInternet;
    [accountLoginLabel          setHidden:TRUE];
    [emailAddressLabel          setHidden:TRUE];
    [emailAddressTextField      setHidden:TRUE];
    [passwordLabel              setHidden:TRUE];
    [passwordTextField          setHidden:TRUE];
    [submitButton               setHidden:TRUE];
    [noInternetLoginLabel       setHidden:TRUE];
    [noInternetLabel            setHidden:TRUE];
    [goToCalendarButton         setHidden:TRUE];
    [goToL2BButton              setHidden:TRUE];
    
    if(_hasInternet)
    {
        [emailAddressLabel      setHidden:FALSE];
        [emailAddressTextField  setHidden:FALSE];
        [passwordLabel          setHidden:FALSE];
        [passwordTextField      setHidden:FALSE];
        [submitButton           setHidden:FALSE];
        [noInternetLabel        setHidden:TRUE];
        
    }
    else
    {
        [noInternetLabel setText:NSLocalizedString(@"Please Connect to the Internet",nil)];
        [noInternetLabel setHidden:FALSE];
    }



}


-(void)dealloc
{
     [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

@end
