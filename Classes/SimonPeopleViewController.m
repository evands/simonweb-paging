//
//  SimonPeopleViewController.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import "SimonPeopleViewController.h"

@implementation SimonPeopleViewController

@synthesize delegate;

+ (SimonPeopleViewController *)peopleViewController
{
	return [[[self alloc] initWithNibName:@"PeopleSelector" bundle:nil] autorelease];
}

- (void)didSelectPerson:(NSDictionary *)dict
{
	if (dict) 
		[self.delegate addPIC:[dict objectForKey:@"PIC"]];
	
	[self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	SimonFavoritesViewController *favorites = [SimonFavoritesViewController favoritesViewController];
	favorites.delegate = self;

	UINavigationController *favoritesNavController = [[[UINavigationController alloc] initWithRootViewController:favorites] autorelease];

	/*
	 tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
	 tabBarController.viewControllers =
	 [NSArray arrayWithObjects:favoritesNavController, nil];
	
	 tabBarController.view.frame = self.view.bounds;
	[self.view addSubview:tabBarController.view];
	*/

	favoritesNavController.view.frame = self.view.bounds;
	[self.view addSubview:favoritesNavController.view];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [super dealloc];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	[[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	if ([tabBar.items indexOfObject:item] == 0) {
		/* Favorites */
		[self.view addSubview:favoritesViewController.view];
	} else {
		/* Search */
//		[self.view addSubview:view_search];
	}
}

@end
