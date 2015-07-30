//
//  ScrollViewTest.m
//  CWPopupDemo
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "ScrollViewTest.h"

@interface ScrollViewTest ()

@end

@implementation ScrollViewTest
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int buttonNum = 1000;
    int width = 20, height = 20;
    int maxWidth = self.view.frame.size.width-width*2;
    int maxHeight = self.view.frame.size.height-height*2;
    while(buttonNum--){
        UIButton *button = [[UIButton alloc] init];
        /*[button addTarget:self
         action:@selector(aMethod:)
         forControlEvents:UIControlEventTouchUpInside];
         [button setTitle:@"Show View" forState:UIControlStateNormal];*/
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
        button.frame = CGRectMake(arc4random()% maxWidth + width , arc4random()% maxHeight + height, width, height);
        [self.view addSubview:button];
    }
    self.view.backgroundColor = [UIColor blackColor];
    
    //create a rounded rectangle type button
    self.myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //set the button size and position
    self.myButton.frame = CGRectMake(85.0f, 100.0f, 150.0f, 37.0f);
    
    //set the button title for the normal state
    [self.myButton setTitle:@"Press This Button"
                   forState:UIControlStateNormal];
    //set the button title for when the finger is pressing it down
    [self.myButton setTitle:@"Button is Pressed"
                   forState:UIControlStateHighlighted];
    [self.view addSubview:self.myButton];
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
