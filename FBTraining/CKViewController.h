

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
@interface CKViewController : UIViewController
@property(nonatomic, weak) CKCalendarView *calendar;
@property (strong, nonatomic) NSMutableArray *arrayOfAllData;

-(void)setFrame: (CGRect)frame;

@end