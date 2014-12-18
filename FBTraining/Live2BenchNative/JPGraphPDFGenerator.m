//
//  JPGraphPDFGenerator.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "JPGraphPDFGenerator.h"
#import "JPFont.h"
#import "Globals.h"
#import "UserInterfaceConstants.h"

const CGFloat kPdfA4PageWidthLandscape = 842;
const CGFloat kPdfA4PageHeightLandscape = 595;

const NSString* PDF_PATH_COMPONENT_NAME = @"pdfExports";

@implementation JPGraphPDFGenerator


- (void)savePDFWithFileName:(NSString *)name
{
    NSString* pdfExportPath = [self pdfExportPath];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:pdfExportPath])
    {
        [manager createDirectoryAtPath:pdfExportPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString* fullFilePath = [pdfExportPath stringByAppendingPathComponent: name];
    
    CFMutableDictionaryRef pdfDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(pdfDict, kCGPDFContextTitle, CFSTR("Game Zone Graph"));
    CFDictionarySetValue(pdfDict, kCGPDFContextCreator, CFSTR("MyPlayXPlay"));
    
    NSDictionary* pdfDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: @"Game Zone Graph",(__bridge NSString*)kCGPDFContextTitle, @"MyPlayXPlay", (__bridge NSString*) kCGPDFContextCreator, nil];
    
    CGRect pageRect = CGRectMake(0, 0, kPdfA4PageWidthLandscape, kPdfA4PageHeightLandscape); // A4 Size: 8.27'' * 11.69'' * 72pts/in
    UIGraphicsBeginPDFContextToFile(fullFilePath, pageRect, pdfDictionary);
    
    UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    CGContextSetStrokeColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    
    //Drawing the Graph
    [self drawPDFDocumentWithContext:pdfContext];
    
    CGContextDrawPath(pdfContext, kCGPathStroke);
    
    CFRelease(pdfDict);
    UIGraphicsEndPDFContext();
}



- (void)drawPDFDocumentWithContext: (CGContextRef)context
{
    //setup
    CGRect pageRect = CGRectMake(0, 0, kPdfA4PageWidthLandscape, kPdfA4PageHeightLandscape);
    //Drawing the Title
    Globals* globals = [Globals instance];
    
    NSString* eventTitle = globals.HUMAN_READABLE_EVENT_NAME;
    
    [eventTitle drawAtPoint:CGPointMake(20, 20) withAttributes:@{NSFontAttributeName: [UIFont fontWithName:[JPFont defaultBoldFont] size:15]}];
    
    [@"MyPlayXPlay Zone Graph" drawAtPoint:CGPointMake(20, 45) withAttributes:@{NSFontAttributeName: [UIFont fontWithName:[JPFont defaultBoldFont] size:15]}];
    
    CGFloat eventDuration = [self.dataSource eventDuration]; //in Seconds
    NSUInteger dataPoints = [self.dataSource numberOfDataPointsInGraphView:nil];
    if(eventDuration < 1 || dataPoints == 0)
    {
        return;
    }
    
    
    //Drawing the Graph
    // Drawing code

    CGFloat graphHeight = 250;
    CGFloat graphTopOffset = 60;
    CGFloat horizontalIncrement = 3;
    CGFloat horizontalOffset = 100;
    CGFloat verticalIncrement = graphHeight / 100.0f;
    
    
    //Drawing Graph Lines
    JPZonePoint firstpt = [self.dataSource graphView:nil zonePointForPointNumber:0];
    CGFloat cartesianY = firstpt.zone * verticalIncrement;
    
    CGContextMoveToPoint(context, horizontalOffset, graphTopOffset + (graphHeight - cartesianY));
    
    JPZonePoint points[dataPoints+1]; //Extra Point when event ends
    points[0] = firstpt;
    int i = 0;
    int row = 0;
    
    //New Page Graph Location
    CGFloat lineHorizontalOffset = horizontalOffset;
    CGFloat currHorizontalPoint = lineHorizontalOffset;
    CGFloat currTopOffset = graphTopOffset;
    
//    cartesianY = 50 * verticalIncrement;
//    CGFloat pointHeight = currTopOffset + (graphHeight - cartesianY);
    CGFloat cutOffHeight = -1;
    
    while(i<dataPoints)
    {
        //Setting up parameters for Each PDf Page
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 2);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        while(i<dataPoints && currTopOffset <= graphTopOffset + graphHeight + 31)
        {
            //Drawing Dependant axis labels
            NSDictionary* axisLabelAttributes = @{NSFontAttributeName: [UIFont fontWithName:[JPFont defaultFont] size:18]};
            [@"OZone" drawAtPoint:CGPointMake(20, currTopOffset-8 + 16.6666*verticalIncrement) withAttributes:axisLabelAttributes];
            [@"NZone" drawAtPoint:CGPointMake(20, currTopOffset-8 + 50*verticalIncrement) withAttributes:axisLabelAttributes];
            [@"DZone" drawAtPoint:CGPointMake(20, currTopOffset-8 + 83.3333*verticalIncrement) withAttributes:axisLabelAttributes];
            
            while(currHorizontalPoint < kPdfA4PageWidthLandscape && i<dataPoints)
            {
                i++;
                
                JPZonePoint zonePoint;
                if(i == dataPoints) //last point just copies previous point
                {
                    JPZonePoint lastZonePoint = [self.dataSource graphView:nil zonePointForPointNumber:i-1];
                    zonePoint = JPZonePointMake(eventDuration, lastZonePoint.zone);
                }
                else{
                    zonePoint = [self.dataSource graphView:nil zonePointForPointNumber:i];
                }

                points[i] = zonePoint;
                
                currHorizontalPoint = lineHorizontalOffset + horizontalIncrement* zonePoint.minute;
                
                cartesianY = zonePoint.zone * verticalIncrement;
                CGFloat pointHeight = currTopOffset + (graphHeight - cartesianY);
                
                CGContextAddLineToPoint(context, currHorizontalPoint, pointHeight);
                
            }
            CGContextDrawPath(context, kCGPathStroke);
            
            if(i==dataPoints)
                break;
            
            currTopOffset += graphHeight + 30;
            
            JPZonePoint lastZonePoint = points[i];

            CGFloat cutOffDist = horizontalIncrement* lastZonePoint.minute - (row+1)*(kPdfA4PageWidthLandscape-horizontalOffset);
            
            lineHorizontalOffset = horizontalOffset - horizontalIncrement* lastZonePoint.minute + cutOffDist;
            currHorizontalPoint = horizontalOffset;
            
            i--;
            JPZonePoint secLastZonePoint = points[i];
            CGFloat secLastCartesianY = secLastZonePoint.zone * verticalIncrement;
            CGFloat secLastPointHeight = currTopOffset + (graphHeight - secLastCartesianY);
            
            CGFloat lastCartesianY = lastZonePoint.zone * verticalIncrement;
            CGFloat lastPointHeight = currTopOffset + (graphHeight - lastCartesianY);
            
            CGFloat horizDistSecLastToLast = horizontalIncrement* (lastZonePoint.minute - secLastZonePoint.minute);
            CGFloat percentageNotCutOff = 1 - cutOffDist / horizDistSecLastToLast;
            
            cutOffHeight = (lastPointHeight-secLastPointHeight)*percentageNotCutOff + secLastPointHeight;
            
            CGContextMoveToPoint(context, currHorizontalPoint, cutOffHeight);
            
            row++;
        }
        
        if(i==dataPoints)
            break;

        UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
        context = UIGraphicsGetCurrentContext();
        
        //New Page Graph Location
        currTopOffset = graphTopOffset;
        //When cutOffHeight was calculated, currTopOffset is not set yet, adjust for the discrepancy
        CGContextMoveToPoint(context, currHorizontalPoint, cutOffHeight - 2*(graphHeight+30));
        
    }
}


- (void)deletePDFWithFileName:(NSString *)name
{
    NSString* pdfExportPath = [self pdfExportPath];
    NSString* fullPath = [pdfExportPath stringByAppendingPathComponent:name];
    
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    
    if(error)
        NSLog(@"Delete PDF Error: %@", error.localizedDescription);
    
}





- (NSString*)pdfExportPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* partialPath = [paths objectAtIndex:0];
    NSString* pdfExportPath = [partialPath stringByAppendingPathComponent:@"pdfExports"];
    
    return pdfExportPath;
}


@end








