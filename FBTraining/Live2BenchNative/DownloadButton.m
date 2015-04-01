//
//  DownloadButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-10-04.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "DownloadButton.h"

@implementation DownloadButton
{
    BOOL downloadCancelled;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setState:DBDefault];
    }
    return self;
}

-(void) setDownloadItem:(DownloadItem *)downloadItem{
    [_downloadItem addOnProgressBlock:nil];
    
    if (_downloadItem) {
        [_downloadItem removeObserver:self forKeyPath:@"status"];
    }

    _downloadItem = downloadItem;
    downloadCancelled = NO;
    
    if (downloadItem) {
        [downloadItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        __block DownloadButton *weakself = self;
        [_downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
            weakself.progress = progress;
            [weakself setNeedsDisplay];
            weakself.enabled = NO;
        }];
        self.enabled = NO;
        self.progress = 0.001;
        [self setNeedsDisplay];
        if (downloadItem.status == DownloadItemStatusError) {
            downloadCancelled = YES;
        }
    }else{
        self.enabled = YES;
        self.progress = 0;
        [self setNeedsDisplay];
    }
}

- (void)setState:(DBDownloadState)state
{
    //    switch (state) {
    //        case 1:
    //        {
    //            NSURL *url = [[NSBundle mainBundle] URLForResource:@"downloading" withExtension:@"gif"];
    //            [self setImage:[UIImage animatedImageWithAnimatedGIFURL:url] forState:UIControlStateNormal];
    //            [self setAccessibilityValue:@"bookmarkDownloadingPNG"];
    //        }
    //            break;
    //        case 2:
    //        {
    //            [self setImage:[UIImage imageNamed:@"download_selected"] forState:UIControlStateNormal];
    //            [self setAccessibilityValue:@"bookmarkSelectedPNG"];
    //        }
    //            break;
    //        case 0:
    //        default:
    //        {
    //            [self setImage:[UIImage imageNamed:@"download_unselected"] forState:UIControlStateNormal];
    //            [self setAccessibilityValue:@"bookmarkUnselectedPNG"];
    //        }
    //            break;
    //    }
}



 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     if(self.progress == 1.0){
         self.hidden = YES;
     }
     
     CGContextRef currentContext = UIGraphicsGetCurrentContext();
     
     UIBezierPath *path = [[UIBezierPath alloc]init];
     
     [path moveToPoint:CGPointMake(7, 1)];
     [path addLineToPoint:CGPointMake(23, 1)];
     [path addLineToPoint:CGPointMake(23, 11)];
     [path addLineToPoint:CGPointMake(30, 11)];
     [path addLineToPoint:CGPointMake(15, 25)];
     [path addLineToPoint:CGPointMake(0, 11)];
     [path addLineToPoint:CGPointMake(7, 11)];
     [path addLineToPoint:CGPointMake(7, 1)];
     
     UIBezierPath *boxPath = [[UIBezierPath alloc] init];
     
     [boxPath moveToPoint:CGPointMake(0, 28)];
     [boxPath addLineToPoint:CGPointMake(29, 28)];
     [boxPath addLineToPoint:CGPointMake(29, 32)];
     [boxPath addLineToPoint:CGPointMake(1, 32)];
     [boxPath addLineToPoint:CGPointMake(1, 28)];
     
     
     path.lineWidth = 1.0;
     boxPath.lineWidth = 2.0;
     [[UIColor orangeColor] setStroke];
     
     if (self.highlighted || self.progress) {
         [[UIColor orangeColor] setFill];
     }else{
         [[UIColor whiteColor] setFill];
     }
     
     
     [path fill];
     [path stroke];
     [boxPath stroke];
     [[UIColor whiteColor]setFill];
     [boxPath fill];

     UIBezierPath *downloadPath = [[UIBezierPath alloc] init];
     
     [downloadPath moveToPoint:CGPointMake(0, 30)];
     [downloadPath addLineToPoint:CGPointMake(30*self.progress, 30)];
     downloadPath.lineWidth = 4.0;
     [downloadPath stroke];
     
     
     if (downloadCancelled) {
         UIBezierPath *cancelPath = [UIBezierPath bezierPath];
         [cancelPath moveToPoint: CGPointMake(3, 3)];
         [cancelPath addLineToPoint: CGPointMake(27, 27)];
         [cancelPath moveToPoint:CGPointMake(27, 3)];
         [cancelPath addLineToPoint: CGPointMake(3, 27)];
         
         cancelPath.lineCapStyle = kCGLineCapRound;
         cancelPath.lineWidth = 2.0;
         
         [[UIColor redColor] setStroke];
         
         [cancelPath stroke];
     }
     
     CGContextSaveGState(currentContext);
     //UIView *backgroundView = [[UIView alloc]initWithFrame:self.frame];
     

 
 }

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    switch (self.downloadItem.status) {
        case DownloadItemStatusIOError:
        case DownloadItemStatusCancel:
        case DownloadItemStatusError:
            downloadCancelled = YES;
            [self setNeedsDisplay];
            break;
            
        default:
            break;
    }
}

@end
