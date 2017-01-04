
//
//  RicoPlayerGroupContainer.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerGroupContainer.h"
#import "RicoPlayer.h"
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
        
        // update views
        NSUInteger i=0;
        CGFloat width = self.bounds.size.width / columns;
        CGFloat height = self.bounds.size.height / rows;
        
        for (NSUInteger r = 0; r < rows; r++) {
            for (NSUInteger c = 0; c < columns; c++) {
                
                
                        //                i = (c * rows + r) % (rows * columns);
                if (i>=[self.subviews count]) {
                    return;
                }
                
                

                
                UIView *playerView = self.subviews[i];
                
                
                playerView.hidden = NO;
                
                CGFloat x = c * width;
                CGFloat y = r * height;
   
                
                
                playerView.frame = CGRectMake(x ,y , width, height);
//                NSLog(@"%@",NSStringFromCGRect(playerView.frame));
                i = i + 1;
            }
        }
    } else {
        for (UIView * subview in self.subviews) {
            [subview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

                       //        [subview.layer removeAllAnimations];
         
//            NSLog(@"%@",NSStringFromCGRect(subview.frame));
        }
        

    }
    

}


//-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
//        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
//            CGPoint subPoint = [subview convertPoint:point fromView:self];
//            UIView *result = [subview hitTest:subPoint withEvent:event];
//            if (result != nil) {
//                return result;
//            }
//        }
//    }
//    
//    return nil;
//}

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
