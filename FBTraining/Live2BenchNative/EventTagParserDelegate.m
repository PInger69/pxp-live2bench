//
//  EventTagParser.m
//  StatsImportXML
//
//  Created by Si Te Feng on 7/4/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "EventTagParserDelegate.h"

@implementation EventTagParserDelegate

- (BOOL)parseDocumentWithURL: (NSURL*)url
{
    if (url == nil)
        return NO;
    
    // this is the parsing machine
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    // this class will handle the events
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    // now parse the document
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Parsing error[%@]: %@", [xmlparser parserError].localizedDescription, [xmlparser parserError]);
    
    return ok;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.tagDicts = [NSMutableArray array];
    self.codeColors = [NSMutableArray array];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqual:@"instance"])
    {
        _parsingTag = YES;
        NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithObject:@0 forKey:@"ID"];
        [self.tagDicts addObject:newDict];
    }
    else if([elementName isEqual:@"row"])
    {
        _parsingCode = YES;
        NSMutableDictionary* codeDict = [NSMutableDictionary dictionary];
        [self.codeColors addObject:codeDict];
    }
    else {
        _currentTagTitle = elementName;
        if(_parsingTag)
        {
            if([elementName isEqual:@"label"])
            {
                _parsingLabelTag = YES;
                NSMutableDictionary* dict = [self.tagDicts lastObject];
                
                NSMutableArray* newLabelArray = [dict objectForKey:@"labels"];
                if(!newLabelArray)
                    newLabelArray = [NSMutableArray array];
                
                NSMutableDictionary* labelDict = [NSMutableDictionary dictionary];
                [newLabelArray addObject:labelDict];
                [dict setObject:newLabelArray forKey:@"labels"];
            }
            else
            {
                [self startCollectingCharacters];
            }
        }
        else if(_parsingCode)
        {
            [self startCollectingCharacters];
        }
    }
    
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(_collectingChar)
    {
        if(_parsingTag)
        {
            if(_parsingLabelTag)
            {
                NSMutableDictionary* currentTagDict = [self.tagDicts lastObject];
                NSMutableArray* currentLabelArray = [currentTagDict objectForKey:@"labels"];
                NSMutableDictionary* currentLabelDict = [currentLabelArray lastObject];
                
                if(!currentLabelDict)
                {
                    currentLabelDict = [NSMutableDictionary dictionary];
                    [currentLabelArray addObject:currentLabelDict];
                }
                
                [currentLabelDict setObject:string forKey:_currentTagTitle];

            }
            else
            {
                NSMutableDictionary* currentDict = [self.tagDicts lastObject];
                [currentDict setObject:string forKey:_currentTagTitle];
            }
        }
        else
        {
            NSMutableDictionary* currentDict = [self.codeColors lastObject];
            [currentDict setObject:string forKey:_currentTagTitle];
        }
    }
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if([elementName isEqual:@"instance"])
    {
        _parsingTag = NO;
    }
    else if([elementName isEqual:@"row"])
    {
        _parsingCode = NO;
    }
    else
    {
        [self endCollectingCharacters];
        if([elementName isEqual:@"label"])
            _parsingLabelTag = NO;
    }
}


- (void)startCollectingCharacters
{
    _collectingChar = YES;
}


- (void)endCollectingCharacters
{
    _collectingChar = NO;
}


// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}



@end
