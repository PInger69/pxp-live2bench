//
//  ContentViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HockeyBottomViewController.h"
//#import "Globals.h"
#import "playerCell.h"
#import "BorderButton.h"

@class HockeyBottomViewController;
@interface ContentViewController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
{
    IBOutlet UIScrollView *scrollView;
    NSMutableDictionary *_gameItems;
    NSMutableArray *_selectedNumbers;
    HockeyBottomViewController *BVController;
    NSInteger currentIndex;
    NSMutableArray *currentLine;
    NSMutableDictionary *playerMap;
    int numberOfPlayersAllowed;
//    Globals *globals;
}
@property NSMutableArray *currentLine;
@property NSMutableArray *selectedNumbers;
@property NSMutableDictionary *gameItems;
@property IBOutlet UICollectionView *collectionView;
@property NSMutableDictionary *playerMap;

- (id)initWithIndex:(NSInteger)i side:(NSString*)whichSide;


@end
