//
//  SimonFavoritesViewController.h
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimonFavoritesViewControllerDelegate
- (void)addPIC:(NSString*)inPIC;
@end

@interface SimonFavoritesViewController : UIViewController <UITableViewDelegate> {
	NSMutableArray *favorites;
	
	IBOutlet UITableView *tableView;
	
	IBOutlet id<SimonFavoritesViewControllerDelegate> delegate;
	
	IBOutlet UIView *view_editingToolbar;
}

+ (SimonFavoritesViewController *)favoritesViewController;

- (IBAction)abc:(id)sender;

@property (nonatomic, retain) NSMutableArray *favorites;
@property (nonatomic, assign) id<SimonFavoritesViewControllerDelegate> delegate;

@end
