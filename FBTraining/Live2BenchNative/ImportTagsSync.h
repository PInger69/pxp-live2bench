//
//  ImportTagsSync.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/16/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Globals, JPXMLTag;
@protocol JPImportTagsSyncDelegate;
@interface ImportTagsSync : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    Globals* globals;
    NSTimer* _sendTagTimer;
    
    NSInteger   _totalTagNum;
    
    NSMutableDictionary* _currentProcessingTag;
    
    BOOL        _started;
    BOOL        _paused;
    

}


//Array of JPXMLTags
@property (nonatomic, strong) NSDictionary* groupXMLTags;
// {"tackle":[{start:25, end:36, code: "Ross", id: 1}, XMLTag(...)], "tag2":[...]}
@property (nonatomic, strong) NSDictionary* textXMLTags;

@property (nonatomic, assign) float delay;

//Array of TagDicts
@property (nonatomic, strong) NSMutableArray* tagDictsArray; //Queue of dictionaries to be sent

@property (nonatomic, strong) id<JPImportTagsSyncDelegate> delegate;
@property (nonatomic, assign) BOOL  isSaving;
@property (atomic, assign) NSInteger uploadedTagNum;
@property (nonatomic, assign) float progress;

- (id)initWithGroupXMLTags: (NSDictionary*)groupTags textXMLTags:(NSDictionary*)textTags delay: (float)delay;
- (id)initWithDelay: (float)delay;

- (NSDictionary*)tagDictWithXMLTag: (JPXMLTag*)tag;

- (void)start;
- (void)pause;



+ (NSString*)timeStringFromSeconds: (float)totSeconds;



@end

@protocol JPImportTagsSyncDelegate <NSObject>

- (void)importTagsSyncDidFinishUploadingTags;
- (void)importTagsSyncProgressChangedTo: (float)progress;



@end


