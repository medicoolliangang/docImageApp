//
//  UITableView+ExtendedAnimations.m
//  TableViewExtAnimations
//
//  Created by Алексеев Влад on 08.07.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import "UITableView+ExtendedAnimations.h"
#import <QuartzCore/QuartzCore.h>

#define kUITableViewExtendedAnimationsDuration 0.29f

@implementation UITableView (ExtendedAnimations)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([(__bridge NSString *)context isEqualToString:@"UITableViewExtendedAnimationsContext"]) {
		if ([keyPath isEqualToString:@"superview"] && [change valueForKey:NSKeyValueChangeNewKey] == nil) {
			// cell was removed from superview by animation
			[self addSubview:(UITableViewCell *)object];
			[object removeObserver:self forKeyPath:@"superview"];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)moveMyRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	UITableViewCell *managedCell = [self cellForRowAtIndexPath:fromIndexPath];
	managedCell.backgroundColor = [UIColor clearColor];
	[managedCell addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionNew context:@"UITableViewExtendedAnimationsContext"];
	
	CGRect cellSourceFrame = [self rectForRowAtIndexPath:fromIndexPath];
	CGRect cellTargetFrame;
	if (toIndexPath.row == 0 && toIndexPath.section == 0) {
    cellTargetFrame = CGRectMake(0, 23, cellSourceFrame.size.width, cellSourceFrame.size.height);
  }else
  {
    cellTargetFrame = [self rectForHeaderInSection:toIndexPath.section];
    cellTargetFrame = CGRectMake(cellTargetFrame.origin.x, cellTargetFrame.origin.y+23, cellTargetFrame.size.width, cellTargetFrame.size.height);
  }
  
	id datasource = self.dataSource;
	[datasource tableView:self moveCell:managedCell fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
	
	[self beginUpdates];
	[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:fromIndexPath] withRowAnimation:UITableViewRowAnimationTop];
	[self insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
	[self endUpdates];
	
	UITableViewCell *insertedCell = [self cellForRowAtIndexPath:toIndexPath];
	insertedCell.backgroundColor = [UIColor clearColor];
	CGRect insertedCellTargetRect = [insertedCell frame];
	
	managedCell.alpha = 1.0;
	
	[self bringSubviewToFront:insertedCell];
	[self bringSubviewToFront:managedCell];
	
	[managedCell setFrame:cellSourceFrame];
	[insertedCell setFrame:cellSourceFrame];
	
  [UIView animateWithDuration:kUITableViewExtendedAnimationsDuration animations:^{
    managedCell.alpha = 0;
    
    [managedCell setFrame:cellTargetFrame];
    [insertedCell setFrame:insertedCellTargetRect];
  } completion:^(BOOL finished) {
    if (self.tag == 1000) {
      [datasource reloadMyTableView1];
    }else
    [datasource reloadMyTableView2];
    [managedCell removeObserver:self forKeyPath:@"superview" context:@"UITableViewExtendedAnimationsContext"];
  }];
//	[UIView beginAnimations:@"moveAnimation" context:nil];
//	[UIView setAnimationDuration:kUITableViewExtendedAnimationsDuration];
//	
//	
//	
//	[UIView commitAnimations];
}

- (void)transitRowAtIndexPath:(NSIndexPath *)fromIndexPath toRowIndexPath:(NSIndexPath *)toIndexPath {
	id datasource = self.dataSource;
	
	UITableViewCell *cellTransitionFrom = [self cellForRowAtIndexPath:fromIndexPath];
	
	[self beginUpdates];
	[datasource tableView:self transitionDeletedCellForRowAtIndexPath:fromIndexPath];
	[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:fromIndexPath] withRowAnimation:UITableViewRowAnimationTop];
	[datasource tableView:self transitionInsertedCellForRowAtIndexPath:toIndexPath];
	[self insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationTop];
	[self endUpdates];
	
	UITableViewCell *cellTransitionTo = [self cellForRowAtIndexPath:toIndexPath];
	
	// both cells need to be moved from source cell to destination place
	
	CGRect sourceFrame = cellTransitionFrom.frame;
	sourceFrame.origin.y += sourceFrame.size.height;
	CGRect targetFrame = cellTransitionTo.frame;
	
	// while moving we need to hide cell that we are moving, showing target cell
	
	[self bringSubviewToFront:cellTransitionTo];
	[self bringSubviewToFront:cellTransitionFrom];
	
	cellTransitionFrom.frame = sourceFrame;
	cellTransitionTo.frame = sourceFrame;
	
	[UIView beginAnimations:@"transitionAnimation" context:nil];
	[UIView setAnimationDuration:kUITableViewExtendedAnimationsDuration];
	
	cellTransitionFrom.frame = targetFrame;
	cellTransitionTo.frame = targetFrame;
	
	cellTransitionFrom.alpha = 0.0;
	
	[UIView commitAnimations];
}

- (void)exchangeRowAtIndexPath:(NSIndexPath *)indexPath1 withRowAtIndexPath:(NSIndexPath *)indexPath2 {
	CGRect cell1SourceFrame = [self rectForRowAtIndexPath:indexPath1];
	CGRect cell2SourceFrame = [self rectForRowAtIndexPath:indexPath2];
	
	UITableViewCell *cell1 = [self cellForRowAtIndexPath:indexPath1];
	UITableViewCell *cell2 = [self cellForRowAtIndexPath:indexPath2];
	
	id datasource = self.dataSource;
	[datasource tableView:self
			 exchangeCell:cell1 atIndexPath:indexPath1
				 withCell:cell2 atIndexPath:indexPath2];
	
	[cell1 setFrame:cell2SourceFrame];
	[cell2 setFrame:cell1SourceFrame];
	
	[self bringSubviewToFront:cell1];
	[self bringSubviewToFront:cell2];
	
	[UIView beginAnimations:@"exchangeAnimation" context:nil];
	[UIView setAnimationDuration:kUITableViewExtendedAnimationsDuration];
	
	[cell1 setFrame:cell1SourceFrame];
	[cell2 setFrame:cell2SourceFrame];
	
	[UIView commitAnimations];
}

@end
