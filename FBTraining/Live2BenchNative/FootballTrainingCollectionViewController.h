//
//  FootballTrainingCollectionViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-08-12.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
//#import "Globals.h"
#import "CustomLabel.h"
#import "BorderButton.h"

@interface FootballTrainingCollectionViewController : UIViewController

@property (nonatomic, strong) NSMutableArray* subtagsArray;
@property (nonatomic, strong) NSString *selectedSubtag;
@property (nonatomic, strong) NSMutableArray* playersArray;
@property (nonatomic, strong) NSMutableArray* selectedPlayers;

- (void)clearSelections;

@end
