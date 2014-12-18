//
//  MemoryBar.m
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "MemoryBar.h"

#define MAX_WIDTH 290
#define MAX_HEIGHT 25


@implementation MemoryBar


static NSArray *sizePrefix;
static NSMutableArray *allBars;


+(void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_UPDATE_MEMORY object:nil]; //#define UPDATE_MEMORY @"update memory" // in common.h
}

+(void)update
{
    NSLog(@"All memory updated");
    if (!allBars || allBars.count ==0) return;
    for(MemoryBar* bar in allBars) {
        [bar update];
    }
}


//TODO add a nottification observer for memory changes


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!sizePrefix) {
            sizePrefix =[[NSArray alloc]initWithObjects:@"b",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB", nil];
            allBars = [[NSMutableArray alloc]init];
            [MemoryBar addNotificationObserver];
        }
        [self setGraphics];
        [allBars addObject:self];
    }
    return self;
}


-(void)setGraphics
{
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
    } else {
        
    }
    
    double fractionFree = (double)totalFreeSpace/(double)totalSpace; // how much space do we have free?
    double fractionFull = (double)1.0-fractionFree;//how much is used
    
    NSString* fractionFullInGB = [self convertBytes:(uint64_t)(totalFreeSpace)];

    totalBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT)];
    [totalBar setBackgroundColor:[UIColor lightGrayColor]];
    [totalBar.layer setCornerRadius:4.0f];
    [self addSubview:totalBar];
    memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalBar.frame.origin.x-100, totalBar.frame.origin.y, 100, MAX_HEIGHT)];
    [memoryLabel setBackgroundColor:[UIColor clearColor]];
    [memoryLabel setText:@"Disk Space :"];
    [memoryLabel setFont:[UIFont defaultFontOfSize:18.0f]];
    [memoryLabel setTextColor:[UIColor darkGrayColor]];
    [self addSubview:memoryLabel];
    
    fullBar = [[UIView alloc]initWithFrame:CGRectMake(0,0, totalBar.frame.size.width * fractionFull, totalBar.frame.size.height)];
    [fullBar setBackgroundColor:self.tintColor];
    [fullBar.layer setCornerRadius:4.0f];
    [self addSubview:fullBar];
    
    float xValue = fractionFree > fractionFull ? fullBar.frame.size.width+5 : fullBar.frame.size.width-totalBar.frame.size.width/2;
    float widthValue = fractionFree > fractionFull ? totalBar.frame.size.width-fullBar.frame.size.width : fullBar.frame.size.width;
    
    fullLabel = [[UILabel alloc] initWithFrame:CGRectMake(xValue, 0, widthValue, MAX_HEIGHT)];

    [fullLabel setBackgroundColor:[UIColor clearColor]];
    [fullLabel setText:[NSString stringWithFormat:@"%.1f%%(%@ free)",(fractionFull)*100.0f,fractionFullInGB]];
    [fullLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:fullLabel];
    
}

-(void)setTintColor:(UIColor *)tintColor {
    //    [fullBar setBackgroundColor:tintColor];
    [super setTintColor:tintColor];
}
- (void)tintColorDidChange {
    [super tintColorDidChange];
    [fullBar setBackgroundColor:self.tintColor];
}

-(NSString*)convertBytes:(uint64_t)size
{
    for (NSString *x in sizePrefix){
        if (size < 1024)
        {
            return [NSString stringWithFormat:@"%llu%@" , size, x ];
        }
        size = size >> 10;
    }
    return @"";
}


-(void)update
{
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
    } else {
        
    }
    
    double fractionFree = (double)totalFreeSpace/(double)totalSpace; // how much space do we have free?
    double fractionFull = (double)1.0-fractionFree;//how much is used

    NSString* fractionFullInGB = [self convertBytes:(uint64_t)(totalFreeSpace)];
    
    fullBar.frame = CGRectMake(0,0, totalBar.frame.size.width * fractionFull, totalBar.frame.size.height);
   
    float xValue = fractionFree > fractionFull ? fullBar.frame.size.width+5 : fullBar.frame.size.width-totalBar.frame.size.width/2;
    float widthValue = fractionFree > fractionFull ? totalBar.frame.size.width-fullBar.frame.size.width : fullBar.frame.size.width;
    
    fullLabel.frame = CGRectMake(xValue, 0, widthValue, MAX_HEIGHT);
    [fullLabel setText:[NSString stringWithFormat:@"%.1f%%(%@ free)",(fractionFull)*100.0f,fractionFullInGB]];

}


@end
