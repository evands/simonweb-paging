//
//  SimonPeopleViewController.h
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimonFavoritesViewController.h"

@protocol SimonPeopleViewControllerDelegate
- (void)addPIC:(NSString*)inPIC;
@end

@interface SimonPeopleViewController : UIViewController <UITabBarDelegate, SimonFavoritesViewControllerDelegate> {
	IBOutlet UITabBarController *tabBarController;
	
	IBOutlet SimonFavoritesViewController *favoritesViewController;
	
	IBOutlet id<SimonPeopleViewControllerDelegate> delegate;
}

+ (SimonPeopleViewController *)peopleViewController;

@property (nonatomic, assign) id<SimonPeopleViewControllerDelegate> delegate;

@end
