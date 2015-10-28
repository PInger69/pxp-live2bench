//
//  ParseModuleDefault.m
//  Live2BenchNative
//
//  Created by dev on 2015-10-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ParseModuleDefault.h"

@implementation ParseModuleDefault





// This is the very first  conversion and check of the jason
-(NSDictionary *)jsonToDict:(NSData *)data
{

    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if ([results[@"success"]intValue] == 0) {
        PXPLog(@"JSON returned from server but success was 0");
    }
    return results;
}


-(void)parse:(NSData*)data mode:(ParseMode)mode for:(Encoder*)encoder
{
    NSDictionary * parsedData = [self jsonToDict:data];
    
    switch (mode) {
        case ParseModeVersionCheck:
            [self versionCheck:parsedData encoder:encoder];
            break;
            
        default:
            break;
    }


}



-(void)versionCheck:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    encoder.version = (NSString *)[dict objectForKey:@"version"] ;
    PXPLog(@"%@ is version %@",encoder.name ,encoder.version);
}









@end
