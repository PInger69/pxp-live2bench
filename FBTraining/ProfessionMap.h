//
//  ProfessionMap.h
//  Live2BenchNative
//
//  Created by dev on 2015-09-15.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
// This is a singleton class that is a dict, with all data for the specific profession
// like sport or medial.
// storing filter predicates and data that might be needed for UI


@interface ProfessionMap : NSObject

+(NSDictionary*)data;

@end


@interface Profession : NSObject

@property (nonatomic,strong) NSPredicate * filterPredicate;
@property (nonatomic,strong) NSPredicate * visiblePredicate;



-(NSDictionary*)meta;

@end