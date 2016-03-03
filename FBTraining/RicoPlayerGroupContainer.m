
//
//  RicoPlayerGroupContainer.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerGroupContainer.h"

// This holds x players and when resized it change the size of all the subviews


@implementation RicoPlayerGroupContainer




-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    for (UIView * subview in self.subviews) {
        [subview setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        [subview.layer removeAllAnimations];
    }
//    self.gridMode = YES;
    [self repositionPlayerViews];
}




- (void)repositionPlayerViews {
    if (![self.subviews count]) return;
    
    if (self.gridMode && self.subviews){
        NSUInteger rows = [self numberOfRowsInGridView:self] ;
        NSUInteger columns = [self numberOfColumnsInGridView:self] ;
        
        
        NSUInteger count =        [self.subviews count];

        
        // add necessary views
//        while (count < rows * columns) {
//            PxpPlayerSingleView *playerView = [[PxpPlayerSingleView alloc] init];
//            [self.playerViews addObject:playerView];
//            [self.containerView addSubview:playerView];
//            
//            [self.delegate playerView:playerView didLoadInGridView:self];
//        }
        
        // update views
        CGFloat width = self.bounds.size.width / columns;
        CGFloat height = self.bounds.size.height / rows;
        
        for (NSUInteger r = 0; r < rows; r++) {
            for (NSUInteger c = 0; c < columns; c++) {
                
                NSUInteger i = (c * rows + r) % (rows * columns);
                if ([self.subviews count]<=i) {
                    return;
                }
                UIView *playerView = self.subviews[i];
                playerView.hidden = NO;
                playerView.frame = CGRectMake(c * width, r * height, width, height);
                NSLog(@"");
//                playerView.player = self.dataSource ? self.context.players[[self.dataSource contextIndexForPlayerGridView:self forRow:r column:c]] : self.context.players.firstObject;
            }
        }
    } else {
        for (UIView * subview in self.subviews) {
            [subview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            //        [subview.layer removeAllAnimations];
        }
   
    }
    

}




- (NSUInteger)numberOfColumnsInGridView:(nonnull UIView *)gridView {
    return MAX(ceil(sqrt(gridView.subviews.count)), 2);
}

- (NSUInteger)numberOfRowsInGridView:(nonnull UIView *)gridView {
    return MAX(ceil(sqrt(gridView.subviews.count)), 2);
}

//- (NSUInteger)contextIndexForPlayerGridView:(nonnull UIView *)gridView forRow:(NSUInteger)row column:(NSUInteger)column {
//    return gridView.subviews.count > 0 ? (column + row * [self numberOfColumnsInGridView:gridView]) % self.context.players.count : 0;
//}



-(void)setGridMode:(BOOL)gridMode
{
    _gridMode = gridMode;
    [self repositionPlayerViews];

}



@end
