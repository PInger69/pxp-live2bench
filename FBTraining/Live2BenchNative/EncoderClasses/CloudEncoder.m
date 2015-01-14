//
//  CloudEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CloudEncoder.h"
#import "EncoderCommand.h"
#import <objc/runtime.h>
#import "Utility.h"
#import "EncoderManager.h"

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]


// catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory

@interface NSURLConnection (Context)

@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSString        * connectionType;

-(NSNumber*)timeStamp;
-(void)setTimeStamp:(NSNumber*)time;

@end

@implementation NSURLConnection (Context)

@dynamic timeStamp;
@dynamic cumulatedData;
@dynamic connectionType;

-(void)setTimeStamp:(NSNumber*)time
{
    objc_setAssociatedObject(self, @selector(timeStamp), time,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber*)timeStamp
{
    return (NSNumber*)objc_getAssociatedObject(self,@selector(timeStamp));
}


-(void)setCumulatedData:(NSMutableData*)data
{
    objc_setAssociatedObject(self, @selector(cumulatedData), data,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableData*)cumulatedData
{
    return (NSMutableData*)objc_getAssociatedObject(self,@selector(cumulatedData));
}


-(void)setConnectionType:(NSString*)type
{
    objc_setAssociatedObject(self, @selector(connectionType), type,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)connectionType
{
    return (NSString*)objc_getAssociatedObject(self,@selector(connectionType));
}


@end


/**
 *  This will manage connection and avaiability with its encoder
 *  Note: Look in to "sendAsynchronousRequest:queue:completionHandler:"
 *  This might be the correct way to Request
 */


@interface Command : NSObject

@property (nonatomic)           SEL                 selector;
@property (nonatomic)           id                  target;
@property (nonatomic,assign)    int                 priority;
@property (nonatomic,assign)    float               timeOut;
@property (nonatomic,strong)    NSMutableDictionary * tagData;
//@property (nonatomic)           void                * context;
@property (nonatomic)           NSNumber            * timeStamp;

@end

@implementation Command

@end



// END HELPER CLASSS





@implementation CloudEncoder







-(void)test
{
    [self issueCommand:CE_TAG_NAMES_GET priority:99 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];

}


-(void)tagNamesGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString *deviceName        = [[UIDevice currentDevice] name];
    NSString *UUID              = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSString *deviceType        = [Utility stringToSha1: @"tablet"];
    NSString *emailAddress      = [Utility stringToSha1: @"hockey"];
    NSString *password          = [Utility sha256HashFor: [@"hockey" stringByAppendingString: @"azucar"]];
    NSString *pData             = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceType,emailAddress,password,deviceName,UUID];
    
    NSData *postData            = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:postData];
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/activate/ajax"]]];
    
    
//    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    urlRequest = request;
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teamsget",self.ipAddress]  ];

    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CE_TAG_NAMES_GET;
    encoderConnection.timeStamp             = aTimeStamp;
    
    
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_NAMES_FROM_CLOUD object:self];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString    * connectionType   = connection.connectionType;
    NSData      * finishedData     = connection.cumulatedData;
    
    if ([connectionType isEqualToString: CE_TAG_NAMES_GET]){
        [self tagNamesResponce: finishedData];
    }
    [super connectionDidFinishLoading:connection];
    
}


-(void)tagNamesResponce:(NSData *)data
{

    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([[jsonDict objectForKey:@"success"]integerValue]){
        NSDictionary * tagnames = [jsonDict objectForKey:@"tagnames"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_NAMES_FROM_CLOUD object:self userInfo:tagnames];
    }
    
    
}


@end
