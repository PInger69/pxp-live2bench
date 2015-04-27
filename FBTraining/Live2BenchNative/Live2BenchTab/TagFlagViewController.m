//
//  TagFlagViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "TagFlagViewController.h"
#import "Utility.h"
#import "Tag.h"
#import "PxpVideoPlayerProtocol.h"



// this is what manages all the little colored notches in the player bar
@implementation TagFlagViewController
{
    BOOL        isCreatingAllTagMarkers;
    int         updateTagmarkerCounter;

    UIViewController <PxpVideoPlayerProtocol> * videoPlayer;
    NSTimer     *adjustTagTimer;
}


@synthesize tagEventName            = _tagEventName;
@synthesize background              = _background;
@synthesize currentPositionMarker   = _currentPositionMarker;

-(id)initWithFrame:(CGRect)frame videoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aVideoPlayer;
{
    self = [super init];
    if (self) {
        //        globals                         = [Globals instance]; // EEEEEWWWww
        videoPlayer                     = aVideoPlayer;
        tagMarkerLeadObjDict            = [[NSMutableDictionary alloc]init];
        //tagMarkerObjDict                = [[NSMutableDictionary alloc]init];
        _background                     = [[UIView alloc]initWithFrame:frame];
        self.view                       = _background;
        self.view.layer.borderWidth     = 1;
        _tagEventName.layer.borderWidth = 1;
        [_background setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [_background setUserInteractionEnabled:FALSE];
        [_background setClipsToBounds:FALSE];
        
        
        _currentPositionMarker    = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,20,20)];
        [_currentPositionMarker setImage:[UIImage imageNamed:@"ortri.png"]];
        [self.view addSubview:_currentPositionMarker];
        
        self.arrayOfAllTags = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagReceived:) name: NOTIF_TAG_RECEIVED object:nil];
        
        
    }
    return self;
}

-(void)createTagMarkers
{
    isCreatingAllTagMarkers = TRUE;
    
    adjustTagTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
        
        if(eventTags){
            self.arrayOfAllTags = [NSMutableArray arrayWithArray: eventTags];
        }
    }}];
    
    /*self.arrayOfAllTags = @[@{@"time":@5, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"},
                            @{@"time":@10, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"},
                            @{@"time":@15, @"type":@99, @"colour" : [UIColor greenColor], @"id" : @"test1"},
                            @{@"time":@1600, @"type":@99, @"colour" : [UIColor redColor], @"id" : @"test1"},
                            @{@"time":@1054, @"type":@99, @"colour" : [UIColor blueColor], @"id" : @"test1"},
                            @{@"time":@16, @"type":@99, @"colour" : [UIColor purpleColor], @"id" : @"test1"},
                            @{@"time":@20, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"} ];*/
    
    /*tagMarkerLeadObjDict =[NSMutableDictionary dictionaryWithDictionary:
     
     @{@"tag1" : @{@"time":@5, @"type":@99, @"colour" :[UIColor orangeColor], @"id" : @"test1"},
     @"tag2" : @{@"time":@10, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"},
     @"tag3" : @{@"time":@15, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"},
     @"tag4" : @{@"time":@20, @"type":@99, @"colour" : [UIColor orangeColor], @"id" : @"test1"},} ];*/
    //NSString *color;
    //float tagTime;
    //NSMutableDictionary *UIColourDict;
    //UIColor *tagColour;
    
    for(Tag *oneTag in self.arrayOfAllTags){
        //if the tag was deleted(type == 3) or type == 8 , don't create marker
        //if  ( YES){//[oneTag objectForKey:@"time"] && [[oneTag objectForKey:@"type"]integerValue]!=3 && [[oneTag objectForKey:@"type"]integerValue]!=8 && [[oneTag objectForKey:@"type"]integerValue]!=18 && [[oneTag objectForKey:@"type"]integerValue]!=22 && !([[oneTag objectForKey:@"type"]integerValue]&1)) {
        //UIColor *color = [Utility colorWithHexString: [oneTag objectForKey:@"colour"]];
        
        /*if ([UIColourDict count] == 0){
         tagColour = [Utility colorWithHexString:color];
         UIColourDict = [NSMutableDictionary dictionaryWithObject:tagColour forKey:color];
         } else {
         if (![UIColourDict objectForKey:color]){
         tagColour = [Utility colorWithHexString:color];
         [UIColourDict setObject:tagColour forKey:color];
         }
         }*/
        
        //tagColour = [UIColourDict objectForKey:color];
        float tagTime = oneTag.time;
        
        //create tag marker for this tag
        //isCreatingAllTagMarkers = FALSE;
        [self markTagAtTime:tagTime colour: [Utility colorWithHexString:oneTag.colour]tagID:[NSString stringWithFormat:@"%d",oneTag.uniqueID]];
        //isCreatingAllTagMarkers = FALSE;
        //}
    }
    
    //NSLog(@"tagMarkerLeadObjDict: %@, videoplayer.duration: %f",tagMarkerLeadObjDict,videoPlayer.duration);
    //go through all the tag marker leads and create all the tag maker views
    //[self createAllTagmarkerViews];
    
}

-(void)cleanTagMarkers
{
    //for(UIView *markerView in self.tagSetView.subviews){
    for(UIView *markerView in self.view.subviews){
        if ([markerView.accessibilityLabel isEqualToString:@"marker"]) {
            [markerView removeFromSuperview];
        }
    }
    
    //[globals.TAG_MARKER_OBJ_DICT removeAllObjects];
    [tagMarkerLeadObjDict removeAllObjects];
}


//create tag marker views for all the tags
/*-(void)createAllTagmarkerViews{
 NSLog(@"create all tag marker views!");
 //create the tag marker view for each lead tagmarker in the dictionary: tagMarkerLeadObjDict
 for(NSMutableDictionary *leadDict in [tagMarkerLeadObjDict allValues]){
 //NSLog(@"creating tagmarker view for lead tag!!!!!!!");
 TagMarker *mark = [leadDict objectForKey:@"lead"];
 if (mark.markerView) {
 [mark.markerView removeFromSuperview];
 mark.markerView = nil;
 }
 mark.markerView = [[UIView alloc]initWithFrame:CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f)];
 [mark.markerView setAccessibilityLabel:@"marker"];
 //mark.marker.frame = CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f);
 [_background insertSubview:mark.markerView belowSubview:self.tagEventName];
 int numMarks = [[leadDict objectForKey:@"colorArr"]count];
 NSArray *tempColorArr = [leadDict objectForKey:@"colorArr"];
 //create subviews according to the color array saved in the lead dictionary
 if (numMarks != 1){
 for (int i = 0; i < numMarks; i++)
 {
 UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0, i*(40.0f/numMarks), 5.0f, 40.0f/numMarks)];
 [colorView setBackgroundColor:[tempColorArr objectAtIndex:i]];
 [mark.markerView addSubview:colorView];
 }
 }else{
 [mark.markerView setBackgroundColor:mark.color];
 }
 }
 
 isCreatingAllTagMarkers = FALSE;
 }*/




//generate TagMarker object when we receive a new tag from syncme callback
-(TagMarker*)markTagAtTime:(float)time colour:(UIColor*)color tagID:(NSString*)tagID{
    Float64 liveTime = ([videoPlayer durationInSeconds] );// / 60);//MAX(globals.PLAYABLE_DURATION, videoPlayer.duration);
    // Float64 liveTime = 200.0;
    //NSLog(@"videoPlayer: %@,self.videoPlayer.duration: %f, globals.PLAYABLE_DURATION: %f, time: %f",videoPlayer,self.videoPlayer.duration,globals.PLAYABLE_DURATION,time);
    if(liveTime < 1 || time > liveTime){
        return nil;
    }
    
    float xValue = [self xValueForTime:time atLiveTime:liveTime];
    //make sure the marker is in the right range
    if(xValue > 596.f)
    {
        xValue= 596.f;
    }
    
    TagMarker *tMarker = [[TagMarker alloc] initWithXValue:xValue tagColour:color tagTime:time tagId:tagID];//initWithXValue:xValue name:name time:time tagId:tagID];
    
    tMarker.markerView.backgroundColor = color;
    //tMarker.marker.backgroundColor = color;
    //[tMarker.marker setAccessibilityIdentifier:@"tagMarker"];
    
    //    [globals.TAG_MARKER_OBJ_DICT setObject:tMarker forKey:tagID];
    [self adjustTagFrames:xValue color:color tMarker:tMarker];
    //[tMarker.markerView setFrame:CGRectMake(tMarker.xValue, 0.0f, 5.0f, 40.0f)];
    [self.view addSubview:tMarker.markerView];
    
    return tMarker;
}



//adjust tagmarkers according to x pixel difference of all the tag markers and colours
//@tagMarkerLeadObjDict: is a dictionary of dictionaries. The key value is the lead tagmarker's xValue, the object value is a dictionary
//which contains an object:lead tagmarker and array of different colours of all the tag markers which follow the lead tagmarker
- (void)adjustTagFrames:(float)xValue color:(UIColor *)color tMarker:(TagMarker *)tMarker {
    
    
    if (!tagMarkerLeadObjDict) {
        tagMarkerLeadObjDict = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *markerDict;
    for(NSString *leadXValue in [tagMarkerLeadObjDict allKeys]){
        //if the pixel difference of tMarker's xValue and the leadXValue is smaller or equal to 7, tMarker will follow the current lead tagmarker
        if (fabs([leadXValue floatValue] - xValue) <= 7) {
            tMarker.leadTag = [[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"lead"];
            if (![[[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"colorArr"] containsObject:color]) {
                [[[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"colorArr"] addObject:color];
            }
            //get the lead marker for current tag
            markerDict = [tagMarkerLeadObjDict objectForKey:leadXValue];
            break;
        }
    }
    
    //if tMarker is not close to any of the existing lead tagmarkers, set itself as its lead tagmarker and added it the "tagMarkerLeadObjDict" dictionary
    if (!tMarker.leadTag) {
        tMarker.leadTag = tMarker;
        markerDict = [[NSMutableDictionary alloc]init];
        [markerDict setObject:[[NSMutableArray alloc]initWithObjects:color, nil] forKey:@"colorArr"];
        //TagMarker *lead = tMarker;
        [markerDict setObject:tMarker forKey:@"lead"];
        [markerDict setObject:[NSString stringWithFormat:@"%f",tMarker.tagTime] forKey:@"leadTime"];
        [tagMarkerLeadObjDict setObject:markerDict forKey:[NSString stringWithFormat:@"%f",tMarker.xValue]];
    }
    
    //If the createTagMarkers method is called, just return. Will create all the tag marker views after pass all the tags to tagMarkerLeadObjDict.
    /*if (isCreatingAllTagMarkers) {
     return;
     }*/
    
    //create the tag marker view for each lead tagmarker in the dictionary: tagMarkerLeadObjDict
    //for(NSMutableDictionary *leadDict in [tagMarkerLeadObjDict allValues]){
    
    
    //NSLog(@"Create tag marker for a new tag!");
    //create the tagmarker view for the current new generated tag
    TagMarker *mark = [markerDict objectForKey:@"lead"];
    
    [mark.markerView setFrame:CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f)];
    [mark.markerView setAccessibilityLabel:@"marker"];
    //mark.marker.frame = CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f);
    [self.view insertSubview:mark.markerView belowSubview:self.tagEventName];
    int numMarks = [[markerDict objectForKey:@"colorArr"]count];
    NSArray *tempColorArr = [markerDict objectForKey:@"colorArr"];
    //create subviews according to the color array saved in the lead dictionary
    if (numMarks != 1){
        
        //add new subviews for the marker view according to the colour
        for (int i = 0; i < numMarks; i++)
        {
            UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0, i*(40.0f/numMarks), 5.0f, 40.0f/numMarks)];
            [colorView setBackgroundColor:[tempColorArr objectAtIndex:i]];
            [mark.markerView addSubview:colorView];
        }
    }else{
        [mark.markerView setBackgroundColor:mark.color];
    }
    
    
}


//-(UILabel*)_buildLabel:(CGRect)frame
//{
//    UILabel * lab =[[UILabel alloc] initWithFrame:frame];
//    [lab setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
//    lab.layer.borderColor      = PRIMARY_APP_COLOR.CGColor;
//    lab.layer.borderWidth      = 1;
//    [lab setTextColor:PRIMARY_APP_COLOR];
//    [lab setText:@"Event Name"];
//    [lab setTextAlignment:NSTextAlignmentCenter];
//    [lab setAlpha:1.0f];
////    [lab setHidden:TRUE]; //the label won't show up in live mode
//    return lab;
//}

/**
 *  Update the tagMarker Positions based off player length
 *
 *  @param liveTime  MAX(globals.PLAYABLE_DURATION, videoPlayer.duration);
 */
-(void)update
{
    double liveTime = ([videoPlayer durationInSeconds] / 60);//MAX(globals.PLAYABLE_DURATION, videoPlayer.duration);
    
    if (tagMarkerLeadObjDict.count < 1 ) {
        //if just start playing back an old event, the duration of the video might be 0. In this case no tag markers will be created.
        //Here, we check if there is no tag markers but there is tags for the current event, call the createTagMarkers method to generate all the tag markers
        //        if (globals.CURRENT_EVENT_THUMBNAILS.count > 0) {
        //            [self cleanTagMarkers];
        //            [self createTagMarkers];
        //        }
        
    }else{
        updateTagmarkerCounter++;
        //if the user stays in the live2bench view for more than half a minute, recreate of all the lead tagmarker views;
        //else just update the positions of the tagmarkers;
        if (updateTagmarkerCounter > 30) {
            //clean tag markers
            [self cleanTagMarkers];
            //recreate tag markers
            [self createTagMarkers];
            updateTagmarkerCounter = 0;
        }else{
            //update tagmarker position
            //            float liveTime = MAX(globals.PLAYABLE_DURATION, videoPlayer.duration);
            
            if (liveTime > 0) {
                NSArray *tempArr = [tagMarkerLeadObjDict allKeys];
                //update the lead tagmarkers according to the current video duration
                for(NSString *leadXValue in tempArr){
                    NSMutableDictionary *leadDict = [[tagMarkerLeadObjDict objectForKey:leadXValue] mutableCopy];
                    float newXValue = [self xValueForTime:[[leadDict objectForKey:@"leadTime"]doubleValue] atLiveTime:liveTime];
                    if(newXValue > self.view.frame.size.width)
                    {
                        newXValue = self.view.frame.size.width;
                    }
                    TagMarker *lead = [leadDict objectForKey:@"lead"];
                    lead.xValue = newXValue;
                    CGRect oldLeadMarkerFrame = lead.markerView.frame;
                    [lead.markerView setFrame:CGRectMake(newXValue, oldLeadMarkerFrame.origin.y, oldLeadMarkerFrame.size.width, oldLeadMarkerFrame.size.height)];
                    
                    //if the xValue changed, update the lead tagmarker dictionary: tagMarkerLeadObjDict
                    if ([leadXValue floatValue] != newXValue) {
                        [tagMarkerLeadObjDict removeObjectForKey:leadXValue];
                        [tagMarkerLeadObjDict setObject:leadDict forKey:[NSString stringWithFormat:@"%f",newXValue]];
                    }
                }
            }
            
        }
    }
    /*
     //if a tag is playing currently, update the position of the currentPlayingEventMarker(small orange triangle) according to the lead tagmarker's position
     if (globals.IS_LOOP_MODE) {
     
     //NOTE: [NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] is very important for a key value of a dictionary, otherwise currentPlayingTagMarker will be nil value
     TagMarker *currentPlayingTagMarker = [globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]]];
     CGRect oldFrame = self.currentPlayingEventMarker.frame;
     [self.currentPlayingEventMarker setFrame:CGRectMake(currentPlayingTagMarker.leadTag.xValue -7, oldFrame.origin.y,oldFrame.size.width, oldFrame.size.height)];
     self.currentPlayingEventMarker.hidden = FALSE;
     //                break;
     //            }
     //        }
     }
     
     
     */
    
}


-(void)viewDidAppear:(BOOL)animated
{
    
    [_currentPositionMarker setFrame:CGRectMake(0,_background.frame.size.height,20,20)];
    _currentPositionMarker.center = CGPointMake(0,_background.frame.size.height+10);
    
    // TODO draw this with vector
    
    
    [_currentPositionMarker setTintColor:[UIColor redColor]];
    //        [currentPositionMarker setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [_currentPositionMarker setHighlighted:YES];
    [_background addSubview:_tagEventName];
    [_background addSubview:currentPositionMarker];
    
    [super viewDidAppear:animated];
    //self.view.backgroundColor = [UIColor blueColor];
}


- (double)xValueForTime:(double)time atLiveTime:(double)liveTime{
    return (time/liveTime)*470 + 126.0f;
}

-(void) tagReceived: (NSNotification *)notification{
    if( notification.userInfo){
        [self.arrayOfAllTags addObject:notification.userInfo];
    }
    
}
//- (BOOL)colour:(UIColor*)colour alreadyExistsInMarkerArray:(NSArray*)array
//{
//    for (TagMarker *mark in array){
//        if ([mark.color isEqualToColor:colour])
//            return TRUE;
//    }
//    return FALSE;
//}

-(void) dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}
@end

