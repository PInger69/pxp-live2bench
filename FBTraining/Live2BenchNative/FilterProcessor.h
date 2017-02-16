//
//  FilterProcessor.h
//  Live2BenchNative
//
//  Created by dev on 7/14/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterProcessor : NSObject
{
    NSArray     * unfilteredList;
    NSArray     * filteredList;
    NSString    * (^filterBlock)(NSDictionary*tag);
    NSString    * myType;
}


/**
 *  This is a filter class that handles the business logic to filtering
 *  by taking in a list and comparing it to a NSSet to create a new list or
 *
 *  @param key to find a prop in the tag dic if not filterblock is set
 *
 *  @return instance
 */
-(id)initWithTagKey:(NSString*)key;


/**
 *  Main input for this class
 *
 *  @param list of tags from previous component
 */
-(void)inputArray:(NSArray*)list;


/**
 *  updates filtered list based of selected buttons in the component
 *
 *  @param filters selected buttons names
 */
-(void)updateWith:(NSSet*)filters;


/**
 *  This updates by taking the unfiltered list and evaluates the tags based of the list of predicate whitch relates to the
 *  buttons that were selected during the FilterComponenent
 *
 *  @param predicates Selected Filtering
 */
-(void)updateWithPredicate:(NSArray*)predicates;

/**
 *  This is used for special filtering such as combining teams or just getting 
 *  Date from event in the tag
 *
 *  @param blk filtering
 */
-(void)setFilterBlock:(NSString* (^)(NSDictionary*))blk;


/**
 *  get the filtered list
 *
 *  @return what the doge didn't finish
 */
-(NSArray*)processedList;


@end
