//
//  PopoverViewController.h
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-27.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PopoverDelegate <NSObject>

-(void)sendNotificationWithName: (NSString *) notificationName;

@end


@interface PopoverViewController : UIViewController

@property id <PopoverDelegate> theButtonViewManager;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (assign, nonatomic) CGSize gap;

- (instancetype)initWithArray:(NSArray *)info andSelectInfo:(NSArray *)selectedPlayers andFrame: (CGRect)frame withGap: (CGSize) gap;

@end
