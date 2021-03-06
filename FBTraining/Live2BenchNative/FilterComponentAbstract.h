//
//  FilterComponentAbstract.h
//  Live2BenchNative
//
//  Created by dev on 8/5/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//


//#default			= 0
//
//#deleted			= 3 - this one shouldn't happen on tagSet
//#telestration 		= 4
//
//#start o-line     	= 1 - hockey
//#stop o-line     	= 2 - hockey
//#start d-line		= 5 - hockey
//#stop  d-line		= 6 - hockey
//#period start		= 7 - hockey
//#period	stop		= 8 - hockey
//#opp. o-line start 	= 11 - hockey
//#opp. o-line stop 	= 12- hockey
//#opp. d-line start 	= 13- hockey
//#opp. d-line stop 	= 14- hockey
//#strength start 	= 9- hockey
//#strength stop 		= 10- hockey
//
//#half start 		= 17- soccer
//#half stop 			= 18- soccer
//#zone start 		= 15- soccer
//#zone stop 			= 16- soccer
//
//#down start 		= 19- football
//#down stop 			= 20- football
//#quarter start 		= 21- football
//#quarter stop 		= 22- football

#import <UIKit/UIKit.h>
#import "FilterComponent.h"
#import "FilterProcessor.h"

/**
 *  The purpouse of this class is too implememet the linking and responding of 
 *  FilterComponenents
 *
 */
@interface FilterComponentAbstract : UIView
{
//    BOOL invoked;

    NSMutableSet            * selectedTags;
    SEL onSelectSelector;
    id selTarget;
//    id <FilterComponent>       previous;
//    id <FilterComponent>       next;
    NSString                * name;
}

@property (strong,nonatomic) FilterProcessor            * filterP;
@property (strong,nonatomic) id <FilterComponent>       previous;
@property (strong,nonatomic) id <FilterComponent>       next;
@property (assign,nonatomic) BOOL invoked;
@property (strong,nonatomic) NSMutableSet               * selectedTags;

-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target;


/**
 *  This will let the component know where to send the processed data as well as tell it to update
 *
 *  @param nxt component
 */
-(void)nextComponent:(id <FilterComponent>)nxt;

/**
 *  This is so this compoenent know where to get the data to process
 *
 *  @param prev componenet
 */
-(void)previousComponent:(id <FilterComponent>)prev;


/**
 *  This is used by the filter tab to know the name of this component if invoked
 *
 *  @return component name
 */
-(NSString*)getName;

/**
 *  This updates the current componented by telling the filter processor to use the new 
 *  selections of buttons to filter the data. It also tells the next component to update with data after the current one has processed. If this compoenent is the last object in the linked list with will preform the 'onSelectSelector' to update the display
 */
-(void)update;

/**
 *  This is used by the filter tab to know if any of the buttons have been selected
 *
 *  @return isSelected
 */
-(BOOL)isInvoked;


/**
 *  This is for convienience. When the componenet is refreshed 
 *  it will recreate all the buttons. this will re select 
 *  buttons after a refresh
 *
 *  @param allButtons all buttons in compoenente
 *  @param selTag     all the prev selected buttons
 */
-(void)keepSelectionOnRefresh:(NSMutableArray*)allButtons buttonsSelected:(NSMutableSet*)selTag;



@end
