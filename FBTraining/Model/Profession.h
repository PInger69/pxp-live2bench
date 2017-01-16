//
//  Profession.h
//  Live2BenchNative
//
//  Moved from the ProfessionMap file by BC Holmes on 2017-01-09.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag;
@class ListViewCell;
@class thumbnailCell;


@interface Profession : NSObject

@property (nonatomic,strong) NSPredicate * filterPredicate;  // This is for tags that will be used in the filtering process
@property (nonatomic,strong) NSPredicate * invisiblePredicate; // Tags that were used in the process but should not be displayed in counts or in filters
@property (nonatomic,strong) NSString   * telestrationTagName;
@property (copy, nonatomic)     void(^onClipViewCellStyle)(thumbnailCell* cellToStyle,Tag* tagForData); // this is used in ClipView to mod the sell style based of sport
@property (copy, nonatomic)     void(^onListViewCellStyle)(ListViewCell* cellToStyle,Tag* tagForData); // this is used in ListView to mod the sell style based of sport

@property (nonatomic)   Class   bottomViewControllerClass;
@property (nonatomic)   Class   filterTabClass;

@end
