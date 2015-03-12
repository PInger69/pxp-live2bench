//
//  FilterComponent.h
//  Live2BenchNative
//
//  Created by dev on 7/29/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  This Protocal outlines all the methods that will be used in a filter componenet.
 */
@protocol FilterComponent <NSObject>


/**
 *  This will taking a Array of tags that needs to be filtered
 *
 *  @param list Tag Array
 */
-(void)inputArray:(NSArray*)list;

/**
 *  This is the output Array of filtered Tags
 *
 *  @return Tag Array
 */
-(NSArray*)refinedList;

-(void)populate:(NSArray *)list;

-(void)update;

-(void)nextComponent:(id)nxt;

-(void)previousComponent:(id)prev;

-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target;

-(void)deselectAll;
-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey;
-(NSString*)getName;
-(BOOL)isInvoked;
@end
