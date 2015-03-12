//
//  ClipViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "thumbnailCell.h"
#import "Live2BenchViewController.h"
#import "FilterToolboxViewController.h"
#import "CustomTabBar.h"    
#import "UtilitiesController.h"
#import "SDWebImage/UIImageView+WebCache.h"
//#import "Globals.h"
#import "CustomButton.h"
#import "ClipCornerView.h"
#import "EdgeSwipeEditButtonsView.h"
#import "UIColor+Expanded.h"


@class Live2BenchViewController;
@class FilterToolboxViewController;
@class CustomTabBar;
@class thumbnailCell;
@class UtilitiesController;

@interface ClipViewController : CustomTabViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate, EdgeSwipeButtonDelegate>
{
//    Globals *globals;
    UIScrollView *breadCrumbsView;
    UtilitiesController *uController;
    UICollectionView *_collectionView; //collection view for displaying thumbnails in clip view
    CustomTabBar *customTab;
    
    //array of four sub-arrays; [array of normal tags;array of other tags with even type value(not player tags nor strength tags);array of strength tags;array of player tags]
    //this array will be used for creating filter buttons in filter tool box
    NSMutableArray *typesOfTags;
    
    FilterToolboxViewController *_filterToolBoxView;
    NSMutableArray *_tagsToDisplay; //array of tags which will display in clip view
    UIView *filterContainer; //uiview used for filter tool box view position and detecting swipe gestrue for the filter view
    NSMutableArray *thumbRatingArray; //array of uiviews(star shape) for tag rating
    //NSString *thumbWasSelected; //tag id of the tag which was just reviewing; used to highlight this tag
    //NSMutableArray *thumbsWasSelectedArray; //array of tags which have been reviewed; used to change these tags's thumbnails to light pink
    NSMutableArray *downloadedThumbnailImages;
    //AppQueue *appQueue;
    
    
    UILabel *filterBreadCrumbs;
    BOOL isEditingClips;
    NSMutableArray *arrayToBeDeleted;
    NSMutableArray *downloadedTagIds; //array of downloaded Tags'id
    CustomButton  *buttonFromCellToDelete; //copy of the thumbnail delete button which is pressed
}


//this method will be called once a filter action completes and pass the filtered tag array as a parameter 
-(void)receiveFilteredArray:(NSArray*)filteredArray;


//return an array of tags which are sorted by time
-(NSMutableArray*)sortArrayByTime:(NSMutableArray*)arr;

@property (nonatomic,strong) NSMutableArray *tagsToDisplay; // THIS IS WHAT YOU ADD TO THE SHOW UP ON SCREEN
@property (nonatomic,strong) NSMutableArray *typesOfTags;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *thumbRatingArray;


//if this boolean value is true, donot call the "reloadData" 
@property (nonatomic)BOOL thumbnailsLoaded;

@property (nonatomic, strong) EdgeSwipeEditButtonsView* edgeSwipeButtons;
@property (nonatomic, strong) UIView* blurView;



@end
