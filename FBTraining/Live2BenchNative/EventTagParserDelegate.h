//
//  EventTagParser.h
//  StatsImportXML
//
//  Created by Si Te Feng on 7/4/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventTagParserDelegate : NSObject <NSXMLParserDelegate>
{
    BOOL        _collectingChar;
    NSString*   _currentString;
    
    BOOL        _parsingTag;
    NSString*   _currentTagTitle;
    BOOL        _parsingLabelTag;
    
    BOOL        _parsingCode;
    
}


@property (nonatomic, strong) NSMutableArray* tagDicts; //array of dictionaries with tagInfo

@property (nonatomic, strong) NSMutableArray* codeColors; //Array of dictionaries

- (BOOL)parseDocumentWithURL: (NSURL*)url;




@end
