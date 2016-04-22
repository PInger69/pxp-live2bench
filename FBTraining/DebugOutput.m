//
//  DebugOutput.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DebugOutput.h"

@interface DebugOutput ()
@property (atomic,strong) NSTimer * timer;
@property (atomic,strong) NSMutableArray * lines;
@end


static DebugOutput * _instance;

@implementation DebugOutput

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timer          = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loop) userInfo:nil repeats:YES];
        self.lines          = [NSMutableArray new];
        for (NSInteger i = 0 ; i <10;i++) {
            
            [self.lines addObject:@""];
        }
        self.layer.borderWidth = 1;
        self.userInteractionEnabled = NO;

    }
    return self;
}


+ (void)initialize
{
    _instance = [DebugOutput new];
}

+(DebugOutput *)getInstance
{
    return _instance;
}

-(void)addLine:(NSString*)text line:(NSInteger)lineNum
{
    if (lineNum> 10 || lineNum <0) {
        return;
    }
    
    self.lines[lineNum]   = text;

}

-(void)loop
{
    NSMutableString * txt =  [NSMutableString new];
    
    for (NSInteger i = 0 ; i <[self.lines count];i++) {
        [txt appendFormat:@"%@\n",self.lines[i] ];
    }
    
    self.text = txt;
}


@end
