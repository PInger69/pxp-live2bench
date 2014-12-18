//
//  AppQueue.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-31.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"


@class Live2BenchViewController;
@class Globals;
@interface AppQueue : NSObject <UIAlertViewDelegate>
{
    NSMutableData *responseData;
    NSMutableArray *queue;
    NSTimer *timer;
    int countE;
    int countR;
    int timerCount;
    SEL selector;
    NSURLRequest *urlRequest;
    int waitingTime;
    NSURLConnection* connection;
}

@property NSMutableArray *queue;
@property (nonatomic,strong) Globals *globals;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSURLRequest *urlRequest;
@property (nonatomic)int waitingTime;
@property (nonatomic)int tagNumbersFromSyncme;
@property (nonatomic,strong)NSURLConnection* connection;
@property (nonatomic,strong)CustomAlertView *errorAlert;
@property (nonatomic)int errorCounter;


-(id) dequeue;
-(void) enqueue:(id)anObject dict:(NSDictionary*)instanceObj;
-(id) peek:(int)index;
-(id) peekHead;
-(id) peekTail;
-(BOOL) empty;
- (NSString *) URLEncodedString_ch:(NSString*)input;
-(void)cancelConnection;
@end
