//
//  PopoverViewController.m
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-27.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *buttonNameArray;
@end

@implementation PopoverViewController

- (instancetype)initWithArray:(NSArray *)info andSelectInfo:(NSArray *)selectedPlayers andFrame: (CGRect)frame withGap:(CGSize)gap
{
    if (self = [super init]) {
        self.players = [[NSMutableArray alloc]init];
        self.selectedPlayers = [NSMutableArray arrayWithArray:selectedPlayers];
        self.buttonNameArray = info;
        self.view.frame = frame;

        self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
        
        self.gap = gap;
        CGSize gap = self.gap;
        if(!gap.height && !gap.width){
            gap.height = 8;
            gap.width = 8;
        }
        
        CGSize cellSize = CGSizeMake(([self longestStringSize:info] + 10) , 30);
        if (cellSize.width< 40.0){
            cellSize.width = 40.0;
        }

        int amountOfButtonsInRow = floor(self.view.bounds.size.width / (cellSize.width + gap.width) );
        if((amountOfButtonsInRow*(cellSize.width + gap.width) + gap.width) > self.view.bounds.size.width ){
            --amountOfButtonsInRow;
        }
        
        float leftoverSpace =self.view.bounds.size.width - (amountOfButtonsInRow*(cellSize.width + gap.width) + gap.width);
        float gapAddingSpace = leftoverSpace/(amountOfButtonsInRow + 1);
        gap.width += gapAddingSpace;
        

        int amountOfRows = (int)ceil(([info count] / (float)amountOfButtonsInRow));

        self.scrollView.contentSize = CGSizeMake(frame.size.width, (30 + gap.height)*amountOfRows +8);
        self.view = self.scrollView;
        
        


        for (int i = 0; i < [info count]; i++) {
            CGRect frame = CGRectMake(((i%amountOfButtonsInRow)*cellSize.width) + (i%amountOfButtonsInRow + 1)* gap.width, ((i/amountOfButtonsInRow) + 1)*gap.height + (i/amountOfButtonsInRow)*30, cellSize.width, 30);
            
            UIButton *buttonForPlayer = [[UIButton alloc]initWithFrame:frame];
            
            [self.scrollView addSubview:buttonForPlayer];
            [buttonForPlayer setTitle:info[i] forState:UIControlStateNormal];
            if([self.selectedPlayers[i]  isEqual: @YES]){
                [buttonForPlayer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                buttonForPlayer.backgroundColor = PRIMARY_APP_COLOR;
            }else{
                [buttonForPlayer setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                buttonForPlayer.backgroundColor = [UIColor whiteColor];
                
            }

            [buttonForPlayer.layer setBorderWidth:1.0f];
            [buttonForPlayer.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
            [buttonForPlayer.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            [buttonForPlayer addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
            //[buttonForPlayer addTarget:self action:@selector(buttonIsHeld:) forControlEvents:UIControlEventTouchDown];
            [self.players addObject:buttonForPlayer];
        }
        

        self.gap = gap;
    }
    return self;
}


-(CGFloat)longestStringSize: (NSArray *)infoArray{
    
    CGFloat longestSize = 0;
    for (int i=0; i < infoArray.count; ++i) {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
        NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                         NSForegroundColorAttributeName: [UIColor blackColor]};
        CGSize textSize = [infoArray[i] sizeWithAttributes:userAttributes];
        CGFloat width = textSize.width;
        
        if(width > longestSize){
            longestSize = width;
        }
        
    }
    return longestSize;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



# pragma mark - User Interaction

-(void)buttonPressed:(UIButton *)sender{
    int index = (int)[self.players indexOfObject:sender];
    if ([sender.backgroundColor isEqual:[UIColor whiteColor]]){
        sender.backgroundColor = PRIMARY_APP_COLOR;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.selectedPlayers[index] = @YES;
        
    }else{
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        self.selectedPlayers[index] = @NO;
    }
    [self.theButtonViewManager sendNotificationWithName:sender.titleLabel.text];
    
}

/*-(void)buttonIsHeld: (UIButton *)sender{
    int index = (int)[self.players indexOfObject:sender];
    if ([sender.backgroundColor isEqual:[UIColor whiteColor]]){
        sender.backgroundColor = PRIMARY_APP_COLOR;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.selectedPlayers[index] = @YES;
    
    }else{
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        self.selectedPlayers[index] = @NO;
    }
}*/



@end
