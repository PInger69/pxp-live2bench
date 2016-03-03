//
//  DebugOutput.h
//  Live2BenchNative
//
//  Created by dev on 2016-01-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugOutput : UITextView
+(DebugOutput *)getInstance;
-(void)addLine:(NSString*)text line:(NSInteger)lineNum;

@end
