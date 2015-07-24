//
//  AbstractBottomViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-16.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "AbstractBottomViewController.h"
#import "Tag.h"


@interface AbstractBottomViewController ()

@end

@implementation AbstractBottomViewController

- (nonnull instancetype)init {
    return [super init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)postTag:(NSDictionary*)tagDic{
    //float time = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:tagDic];
}

-(void)modifyTag:(Tag*)tag{
    //float time = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);
    //tag.time = time;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG  object:nil userInfo:[tag makeTagData]];
}

-(void)deleteTag:(Tag*)tag{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
}

-(void)clear{
    [self.view removeFromSuperview];
}

- (void)update {
    
}

- (void)postTagsAtBeginning {
    
}

- (nonnull NSString *)currentPeriod {
    return @"";
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
