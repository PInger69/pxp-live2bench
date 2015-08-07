//
//  PxpPlayerGridView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PxpPlayerSingleView.h"

@class PxpPlayerGridView;

/// @author Nicholas Cvitak
@protocol PxpPlayerGridViewDataSource

/// Provides the number of rows the grid view should present.
- (NSUInteger)numberOfRowsInGridView:(nonnull PxpPlayerGridView *)gridView;

/// Provides the number of columns the grid view should present.
- (NSUInteger)numberOfColumnsInGridView:(nonnull PxpPlayerGridView *)gridView;

/// Provides the index of the player to grab from the grid view's player's context at the specified row and column.
- (NSUInteger)contextIndexForPlayerGridView:(nonnull PxpPlayerGridView *)gridView forRow:(NSUInteger)row column:(NSUInteger)column;

@end

/// @author Nicholas Cvitak
@protocol PxpPlayerGridViewDelegate

/// Invoked when a new player view is loaded into the grid view.
- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didLoadInGridView:(nonnull PxpPlayerGridView *)gridView;

/// Invoked when a player view is unloaded from the grid view.
- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didUnloadInGridView:(nonnull PxpPlayerGridView *)gridView;

@end

/**
 * @breif A view capable of displaying multiple PxpPlayers in a grid format.
 * @author Nicholas Cvitak
 */
@interface PxpPlayerGridView : PxpPlayerView

/// The data source of the grid view.
@property (weak, nonatomic, nullable) id<PxpPlayerGridViewDataSource> dataSource;

/// The delegate of the grid view.
@property (weak, nonatomic, nullable) id<PxpPlayerGridViewDelegate> delegate;

/// reloads the data of the grid view.
- (void)reloadData;

@end
