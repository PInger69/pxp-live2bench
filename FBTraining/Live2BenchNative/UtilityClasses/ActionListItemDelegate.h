//
//  ActionListItemDelegate.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ActionListItem;
// this is to set simple
@protocol ActionListItemDelegate <NSObject>


@required

-(void)onSuccess:(id <ActionListItem>)actionListItem;

@optional
-(void)onFail:(id <ActionListItem>)actionListItem;

@end
