//
//  TagFlagViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagMarker.h"
#import "VideoPlayer.h"

@interface TagFlagViewController : UIViewController
{
    NSMutableDictionary     * tagMarkerLeadObjDict;
    //NSMutableDictionary     * tagMarkerObjDict;
    
    TagMarker              * tagMarker; //object indicates the tag position in the total time duration
    NSMutableArray          * tagMarkerArray; //array of tagmarker objects; used for shifting the positions of all the tagmarkers
    NSMutableSet           * tagTimesColoured; //array of tag times; used for tagmarker's position
    
    
    UIImageView             * currentPositionMarker;
    
}

@property (strong,nonatomic) NSMutableArray * arrayOfAllTags;
@property (strong,nonatomic) UILabel        * tagEventName;
@property (strong,nonatomic) UIView         * background;
@property (strong,nonatomic) UIImageView    * currentPositionMarker;

-(id)initWithFrame:(CGRect)frame videoPlayer:(VideoPlayer*)aVideoPlayer;

-(void)createTagMarkers;


-(void)cleanTagMarkers;

-(void)update;


@end