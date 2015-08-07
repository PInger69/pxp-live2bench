//
//  FakeEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2015-05-11.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FakeEncoder.h"
#import "Encoder.h"
static int fakeCounter;
@implementation FakeEncoder

@synthesize name=_name;
@synthesize encoderManager=_encoderManager;
@synthesize status=_status;
@synthesize statusAsString=_statusAsString;
@synthesize event=_event;
@synthesize allEvents=_allEvents;

+(instancetype)make
{
    
    return [[FakeEncoder alloc]init];
}

+(int)fakeCount
{
    return (!fakeCounter)?0:fakeCounter;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _status = ENCODER_STATUS_READY;
        fakeCounter = (!fakeCounter)?0:fakeCounter+1;
        _name =@"Fake";
    }
    return self;
}


-(id <EncoderProtocol>)makePrimary
{
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagPost:)        name:NOTIF_TAG_POSTED           object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTelePost:)       name:NOTIF_CREATE_TELE_TAG      object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onModTag:)         name:NOTIF_MODIFY_TAG           object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteTag:)      name:NOTIF_DELETE_TAG           object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteEvent:)      name:NOTIF_DELETE_EVENT_SERVER  object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadClip:)   name:NOTIF_EM_DOWNLOAD_CLIP     object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadEvent:)  name:NOTIF_EM_DOWNLOAD_EVENT    object:nil];
    return self;
}

-(id <EncoderProtocol>)removeFromPrimary
{
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_POSTED              object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREATE_TELE_TAG         object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_MODIFY_TAG              object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_TAG              object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_EVENT_SERVER     object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_CLIP        object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_EVENT       object:nil];
    return self;
}

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
}


-(Event*)getEventByName:(NSString *)eventName
{
    return nil;
}
-(void)setBitrate:(double)bitrate
{

}

-(double)bitrate
{

    return .5;
}

-(void)setCameraCount:(NSInteger)cameraCount
{

}


-(NSInteger)cameraCount
{
    return @0;
}

@end

