//
//  RatingAndCommentingField.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/20.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "RatingAndCommentingField.h"

@interface RatingAndCommentingField ()

@property (strong, nonatomic) UIViewController *tool;
@property (nonatomic, copy) void(^tagUpdate)(NSMutableDictionary *tag);

@end

@implementation RatingAndCommentingField

- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableDictionary *)data
{
    self = [super init];
    if (self) {
        [self.view setFrame:frame];
        self.data = data;
        self.ratingScale = [[RatingInput alloc] initWithFrame:CGRectMake(15, 48, 300, 50)];
        self.ratingScale.rating = [data[@"rating"] integerValue];
        [self.ratingScale onPressRatePerformSelector:@selector(sendRatingNew:) addTarget:self];
        [self.ratingScale.ratingLabel setText:@"Rating:"];
        [self.ratingScale.ratingLabel setTextColor:[UIColor blackColor]];
        [self.ratingScale.ratingLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [self.view addSubview:self.ratingScale];
        
        self.commentingButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 65, 100, 50)];
        [self.commentingButton setTitle:@"Comment:" forState:UIControlStateNormal];
        [self.commentingButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.commentingButton setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [self.commentingButton addTarget:self action:@selector(showCommentEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.commentingButton];
        
        self.commentingField = [[CommentingField alloc] initWithFrame:CGRectMake(5, 5, 300, 200)];
        //[self.commentingField onPressSavePerformSelector:@selector(sendComment:) addTarget:self];
        //self.commentingField.title = @"";
        self.tool = [[UIViewController alloc] init];
        [self.tool.view addSubview:self.commentingField];
        self.commentingPop = [[UIPopoverController alloc] initWithContentViewController:self.tool];
        [self.commentingPop setPopoverContentSize:CGSizeMake(310, 210) animated:YES];
        self.commentingField.context = @"MyClip";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendComment:) name:[NSString stringWithFormat:@"Save in %@", self.commentingField.context] object:nil];
        
    
        self.commentingArea = [[UITextView alloc] initWithFrame:CGRectMake(124, 71, 200, 80)];
        [self.commentingArea setFont:[UIFont systemFontOfSize:18.0f]];
        //[self.commentingArea setBackgroundColor:[UIColor blackColor]];
        if ([self.data[@"comment"] isEqualToString:@" "]) {
            [self.commentingArea setText:self.data[@"comment"]];
            [self.commentingArea setTextColor:[UIColor blackColor]];
        }else{
            [self.commentingArea setText:@"Please add comment."];
            [self.commentingArea setTextColor:[UIColor lightGrayColor]];
        }
        self.commentingArea.selectable = NO;
        [self.view addSubview:self.commentingArea];
        
        self.tagUpdate = ^(NSMutableDictionary *tag){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIF_TAG_UPDATE" object:nil userInfo:tag];
        };
    }
    return self;
}

-(void)sendRatingNew:(id)sender
{
    int recievedRating = [(RatingInput *)sender rating];
    [self.data    setValue:[NSString stringWithFormat:@"%i",recievedRating] forKey:@"rating"];
    self.tagUpdate(self.data);
}

-(void)sendComment:(id)sender
{
    [self.commentingField.textField resignFirstResponder];
    NSString *comment = self.commentingField.textField.text;
    [self.data    setObject:comment forKey:@"comment"];
    [self.commentingArea setText:comment];
    [self.commentingArea setTextColor:[UIColor blackColor]];
    if ([comment isEqualToString:@""]) {
        [self.commentingArea setText:@"Please add comment."];
        [self.commentingArea setTextColor:[UIColor lightGrayColor]];
    }
    self.tagUpdate(self.data);
}


-(void)showCommentEdit:(id)sender
{
    
    [self.commentingField setText:self.data[@"comment"]];
    
    [self.commentingPop presentPopoverFromRect:self.commentingButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
