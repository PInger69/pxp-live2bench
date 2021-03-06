/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLAnalyticsColumn.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Google Analytics API (analytics/v3)
// Description:
//   View and manage your Google Analytics data
// Documentation:
//   https://developers.google.com/analytics/
// Classes:
//   GTLAnalyticsColumn (0 custom class methods, 3 custom properties)
//   GTLAnalyticsColumnAttributes (0 custom class methods, 0 custom properties)

#import "GTLAnalyticsColumn.h"

// ----------------------------------------------------------------------------
//
//   GTLAnalyticsColumn
//

@implementation GTLAnalyticsColumn
@dynamic attributes, identifier, kind;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"analytics#column"];
}

@end


// ----------------------------------------------------------------------------
//
//   GTLAnalyticsColumnAttributes
//

@implementation GTLAnalyticsColumnAttributes

+ (Class)classForAdditionalProperties {
  return [NSString class];
}

@end
