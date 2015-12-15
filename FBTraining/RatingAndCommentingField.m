//
//  RatingAndCommentingField.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/20.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "RatingAndCommentingField.h"

@interface RatingAndCommentingField () <UITextViewDelegate>

@property (strong, nonatomic) RatingInput *ratingScale;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) UILabel *commentingLabel;
@property (strong, nonatomic) UITextView *commentingArea;

@end

@implementation RatingAndCommentingField


@synthesize enable =_enable;

- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableDictionary *)data
{
    self = [super init];
    if (self) {
        [self.view setFrame:frame];
        self.data = data;
        self.ratingScale = [[RatingInput alloc] initWithFrame:CGRectMake(15, 48, 300, 20)];
        self.ratingScale.rating = [data[@"rating"] integerValue];
//        self.ratingScale.enabled = NO;
        [self.ratingScale onPressRatePerformSelector:@selector(sendRatingNew:) addTarget:self];
        [self.ratingScale.ratingLabel setText:@"Rating:"];
        [self.ratingScale.ratingLabel setTextColor:[UIColor blackColor]];
        self.ratingScale.ratingLabel.adjustsFontSizeToFitWidth = YES;
        [self.ratingScale.ratingLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
 
        
        self.commentingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 62, 100, 50)];
        self.commentingLabel.text = NSLocalizedString(@"Comment:", nil);
        self.commentingLabel.textColor = [UIColor blackColor];
        self.commentingLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [self.view addSubview:self.commentingLabel];
        
        self.commentingArea = [[UITextView alloc] initWithFrame:CGRectMake(122, 68, 400, 80)];
        self.commentingArea.returnKeyType = UIReturnKeyDone;
        self.commentingArea.font = [UIFont systemFontOfSize:18.0f];
        if ([self.data[@"comment"] length] != 0) {
            self.commentingArea.text = self.data[@"comment"];
            self.commentingArea.textColor = [UIColor blackColor];
        }else{
            self.commentingArea.text = NSLocalizedString(@"Please add comment.", nil);
            self.commentingArea.textColor = [UIColor lightGrayColor];
        }
        self.commentingArea.selectable = YES;
        self.commentingArea.delegate = self;
        [self.view addSubview:self.commentingArea];
        _enable = YES;
        
               [self.view addSubview:self.ratingScale];
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = self.data[@"comment"];
    textView.textColor = [UIColor blackColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *comment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([comment length] != 0) {
        self.commentingArea.text = comment;
        self.commentingArea.textColor = [UIColor blackColor];
    } else {
        self.commentingArea.text = NSLocalizedString(@"Please add comment.", nil);
        self.commentingArea.textColor = [UIColor lightGrayColor];
    }
    
    self.data[@"comment"] = comment;
    self.tagUpdate(self.data);
}

-(void)sendRatingNew:(id)sender
{
    NSInteger recievedRating = [(RatingInput *)sender rating];
    [self.data    setValue:[NSString stringWithFormat:@"%li",(long)recievedRating] forKey:@"rating"];
    self.tagUpdate(self.data);
}


-(void)setEnable:(BOOL)enable
{
    if (enable == _enable) return;
    
    [self willChangeValueForKey:@"enable"];
    if (_enable && !enable){
        // to false

        self.commentingLabel.alpha = 0.5;
        self.commentingArea.selectable = NO;
        self.ratingScale.enabled = NO;
    } else if (!_enable && enable){
        // to true

        self.commentingLabel.alpha = 1;
        self.commentingArea.selectable = YES;
        self.ratingScale.enabled = YES;
    }
    _enable = enable;
    [self didChangeValueForKey:@"enable"];
}

-(BOOL)enable
{
    return _enable;
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
