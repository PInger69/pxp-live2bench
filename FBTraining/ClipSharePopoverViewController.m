//
//  ClipSharePopoverViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ClipSharePopoverViewController.h"

#import "CustomButton.h"

@interface ClipSharePopoverViewController ()

@end

@implementation ClipSharePopoverViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *popoverView = [[UIView alloc] init];
    CustomButton *mailButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [mailButton setImage:[UIImage imageNamed:@"mail.png"] forState:UIControlStateNormal];
    [mailButton setImage:[UIImage imageNamed:@"mailselected.png"] forState:UIControlStateHighlighted];
    [mailButton setFrame:CGRectMake(10, 10, 60, 60)];
    [mailButton addTarget:self.bookmarkViewController action:@selector(emailTags) forControlEvents:UIControlEventTouchUpInside];
    UILabel *mailButtonLabel = [[UILabel alloc]initWithFrame:CGRectMake(mailButton.frame.origin.x, mailButton.frame.origin.y+mailButton.frame.size.height+5, mailButton.frame.size.width, 20)];
    [mailButtonLabel setText:@"Mail"];
    [mailButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [mailButtonLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [mailButtonLabel setBackgroundColor:[UIColor clearColor]];
    [popoverView addSubview:mailButton];
    [popoverView addSubview:mailButtonLabel];
    
    CustomButton *facebookButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"facebookselected"] forState:UIControlStateHighlighted];
    [facebookButton setFrame:CGRectMake(mailButton.frame.origin.x + mailButton.frame.size.width+20, mailButton.frame.origin.y, 65, 60)];
    [facebookButton addTarget:self.bookmarkViewController action:@selector(facebookShare) forControlEvents:UIControlEventTouchUpInside];
    UILabel *facebookButtonLabel = [[UILabel alloc]initWithFrame:CGRectMake(facebookButton.frame.origin.x, facebookButton.frame.origin.y+facebookButton.frame.size.height+5, facebookButton.frame.size.width, 20)];
    [facebookButtonLabel setText:@"Facebook"];
    [facebookButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [facebookButtonLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [facebookButtonLabel setBackgroundColor:[UIColor clearColor]];
    [popoverView addSubview:facebookButton];
    [popoverView addSubview:facebookButtonLabel];
    
    CustomButton *saveToPhotosAlbumButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [saveToPhotosAlbumButton setImage:[UIImage imageNamed:@"saveToAlbum"] forState:UIControlStateNormal];
    [saveToPhotosAlbumButton setImage:[UIImage imageNamed:@"saveToAlbumSelected"] forState:UIControlStateHighlighted];
    [saveToPhotosAlbumButton setFrame:CGRectMake(facebookButton.frame.origin.x + facebookButton.frame.size.width+20, facebookButton.frame.origin.y, 65, 60)];
    [saveToPhotosAlbumButton addTarget:self.bookmarkViewController action:@selector(saveVideoToPhotosAlbum) forControlEvents:UIControlEventTouchUpInside];
    UILabel *saveToPAButtonLabel = [[UILabel alloc]initWithFrame:CGRectMake(saveToPhotosAlbumButton.frame.origin.x, saveToPhotosAlbumButton.frame.origin.y+saveToPhotosAlbumButton.frame.size.height+5, saveToPhotosAlbumButton.frame.size.width, 20)];
    [saveToPAButtonLabel setText:@"Album"];
    [saveToPAButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [saveToPAButtonLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [saveToPAButtonLabel setBackgroundColor:[UIColor clearColor]];
    [popoverView addSubview:saveToPhotosAlbumButton];
    [popoverView addSubview:saveToPAButtonLabel];
    
    
    CustomButton *dropBoxButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [dropBoxButton setImage:[UIImage imageNamed:@"dropboxico"] forState:UIControlStateNormal];
    [dropBoxButton setImage:[UIImage imageNamed:@"dropboxicoSel"] forState:UIControlStateHighlighted];
    [dropBoxButton setFrame:CGRectMake(mailButton.frame.origin.x, mailButton.frame.origin.y+mailButton.bounds.size.height+30, 60, 60)];
    [dropBoxButton addTarget:self.bookmarkViewController action:@selector(sendVideoToDropbox:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *dropBoxButtonLabel = [[UILabel alloc]initWithFrame:CGRectMake(dropBoxButton.frame.origin.x, dropBoxButton.frame.origin.y+dropBoxButton.frame.size.height+5, dropBoxButton.frame.size.width, 20)];
    [dropBoxButtonLabel setText:@"Dropbox"];
    [dropBoxButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [dropBoxButtonLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [saveToPAButtonLabel setBackgroundColor:[UIColor clearColor]];
    [popoverView addSubview:dropBoxButton];
    [popoverView addSubview:dropBoxButtonLabel];
    
    CustomButton *twitterButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter.jpeg"] forState:UIControlStateNormal];
    [twitterButton setFrame:CGRectMake(facebookButton.frame.origin.x + facebookButton.frame.size.width+20, facebookButton.frame.origin.y, 60, 60)];
    [twitterButton addTarget:self.bookmarkViewController action:@selector(twitterShare) forControlEvents:UIControlEventTouchUpInside];
    UILabel *twitterButtonLabel = [[UILabel alloc]initWithFrame:CGRectMake(twitterButton.frame.origin.x, twitterButton.frame.origin.y+twitterButton.frame.size.height+5, twitterButton.frame.size.width, 20)];
    [twitterButtonLabel setText:@"twitter"];
    [twitterButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [twitterButtonLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [twitterButtonLabel setBackgroundColor:[UIColor clearColor]];
    //[popoverView addSubview:twitterButton];
    //[popoverView addSubview:twitterButtonLabel];
    
    
    self.view = popoverView;
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
