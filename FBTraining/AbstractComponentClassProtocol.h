//
//  AbstractComponentClassProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

@protocol AbstractComponentClassProtocol <NSObject>

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic) NSString *componentType;
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSArray *positionArray;
@property (strong, nonatomic)NSDictionary *dataDictionary;
@property (assign, nonatomic) CGRect frame;
@property (weak, nonatomic) UIView *parentView;
@property (nonatomic) BOOL selectable;

-(instancetype)initWithDataDictionary: (NSDictionary *)dataDictionary andPlistDictionary: (NSDictionary *)plistDictionary;
-(void)removeFromSuperview;
@optional
-(void)notificationAction: (id) notificationValue;
@end
