//
//  SimonFavoritesViewController.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import "SimonFavoritesViewController.h"
#import "SimonFavoriteEditorViewController.h"
#import "DetailCell.h"

@implementation SimonFavoritesViewController

@synthesize favorites, delegate;

+ (SimonFavoritesViewController *)favoritesViewController
{
	return [[[self alloc] initWithNibName:@"FavoritesView" bundle:nil] autorelease];
}

- (void)reloadData
{
	self.favorites = [[[[NSUserDefaults standardUserDefaults] arrayForKey:@"Favorites"] mutableCopy] autorelease];
	if (!self.favorites)
		self.favorites = [NSMutableArray array];
	[tableView reloadData];
}

- (void)favoritesDidChange:(NSNotification *)notification
{
	[self reloadData];
}

- (void)edit:(id)sender
{
	[self setEditing:YES animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(favoritesDidChange:) name:@"FavoritesDidChange" object:nil];
	
	self.title = NSLocalizedString(@"Contacts", nil);
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites
																  tag:0] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
																			   style:UIBarButtonItemStylePlain
																			  target:self
																			  action:@selector(edit:)] autorelease];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
																			   style:UIBarButtonItemStyleDone
																			  target:self
																			  action:@selector(done:)] autorelease];
	self.view.backgroundColor = [UIColor redColor];

	[self reloadData];
}

- (void)didSelectPerson:(NSDictionary *)dict
{
	if (dict) 
		[self.delegate addPIC:[dict objectForKey:@"PIC"]];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)done:(id)sender
{
	if (self.editing)
		self.editing = NO;
	else
		[self didSelectPerson:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[[NSUserDefaults standardUserDefaults] setObject:self.favorites
											  forKey:@"Favorites"];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // The number of sections is based on the number of items in the data property list.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // The number of rows in each section depends on the number of sub-items in each item in the data property list. 
    NSInteger count = self.favorites.count;
    // If we're in editing mode, we add a placeholder row for creating new items.
    if (self.editing) count++;
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    if (cell == nil) {
        cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
        cell.hidesAccessoryWhenEditing = NO;
    }
    // The DetailCell has two modes of display - either a type/name pair or a prompt for creating a new item of a type
    // The type derives from the section, the name from the item.
	
	if (indexPath.row < self.favorites.count) {
		NSDictionary *favorite = [self.favorites objectAtIndex:indexPath.row];
		cell.type.text = [favorite valueForKey:@"PIC"];
		cell.name.text = [favorite valueForKey:@"Name"];
		cell.promptMode = NO;
		
	} else {
		cell.prompt.text = [NSString stringWithFormat:@"Add new contact"];
		cell.promptMode = YES;
	}

    return cell;
}

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return (self.editing) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already 
    // existing content. Existing content can be deleted.

	if (indexPath.row < self.favorites.count)
		return UITableViewCellEditingStyleDelete;
	else		
		return UITableViewCellEditingStyleInsert;
}

- (void)add:(id)sender
{
	SimonFavoriteEditorViewController *controller = [SimonFavoriteEditorViewController controller];
	[self.navigationController pushViewController:controller animated:YES];	
}

// Called after selection. In editing mode, this will navigate to a new view controller.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        // Don't maintain the selection. We will navigate to a new view so there's no reason to keep the selection here.
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

		SimonFavoriteEditorViewController *controller = [SimonFavoriteEditorViewController controller];
		
		if (indexPath.row < self.favorites.count) {
			// The row selected is one with existing content, so that content will be edited.
			controller.originalItem = [self.favorites objectAtIndex:indexPath.row];
		}

		[self.navigationController pushViewController:controller animated:YES];

    } else {
		[self didSelectPerson:[self.favorites objectAtIndex:indexPath.row]];
    }
}

#pragma mark Editing

// Set the editing state of the view controller. We pass this down to the table view and also modify the content
// of the table to insert a placeholder row for adding content when in editing mode.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    // Calculate the index paths for all of the placeholder rows based on the number of items in each section.
    NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.favorites.count inSection:0]];
    [tableView beginUpdates];
    [tableView setEditing:editing animated:YES];
    if (editing) {
        // Show the placeholder rows
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    } else {
        // Hide the placeholder rows.
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
	
	if (editing) {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																								target:self action:@selector(add:)] autorelease];
	} else {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
																				   style:UIBarButtonItemStylePlain
																				  target:self
																				  action:@selector(edit:)] autorelease];
	}
	
	if (editing)
		self.navigationItem.titleView = view_editingToolbar;
	else
		self.navigationItem.titleView = nil;
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.favorites removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		SimonFavoriteEditorViewController *controller = [SimonFavoriteEditorViewController controller];

		// The row selected is a placeholder for adding content. The editor should create a new item.
		controller.editingItem = nil;
		
		[self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark Row reordering

// Determine whether a given row is eligible for reordering or not. In this app, all rows except the placeholders for
// new content are eligible, so the test is just the index path row against the number of items in the content.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Don't allow the placeholder to be moved.
    return (indexPath.row < self.favorites.count);
}

// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath {

	if (toIndexPath.row < self.favorites.count) {
		id item = [[self.favorites objectAtIndex:fromIndexPath.row] retain];
		[self.favorites removeObject:item];
		[self.favorites insertObject:item atIndex:toIndexPath.row];
		[item release];
	}
}

NSComparisonResult favoritesSort(NSDictionary *favorite1, NSDictionary *favorite2, void *context)
{
	NSCharacterSet *wsChars = [NSCharacterSet whitespaceCharacterSet];

	NSString *name1 = [[favorite1 valueForKey:@"Name"] stringByTrimmingCharactersInSet:wsChars];
	NSString *name2 = [[favorite2 valueForKey:@"Name"] stringByTrimmingCharactersInSet:wsChars];
	
	NSArray *comp1 = [name1 componentsSeparatedByString:@" "];
	NSArray *comp2 = [name2 componentsSeparatedByString:@" "];
	
	if (comp1.count == 1 && comp2.count > 1) {
		return NSOrderedAscending;
	} else if (comp2.count == 1 && comp1.count > 1) {
		return NSOrderedDescending;
	} else {
		return [[comp1 lastObject] caseInsensitiveCompare:[comp2 lastObject]];
	}
}
								 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self.favorites sortUsingFunction:favoritesSort context:NULL];
		[[NSUserDefaults standardUserDefaults] setObject:self.favorites
												  forKey:@"Favorites"];
		[tableView reloadData];
	}
}

- (IBAction)abc:(id)sender
{
	[[[[UIAlertView alloc] initWithTitle:@"Alphabetize Contacts?" 
							   message:@"This can not be undone. Your contacts will be sorted in alphabetical order."
							  delegate:self
					 cancelButtonTitle:@"Cancel"
					 otherButtonTitles:@"Sort", nil] autorelease] show];
}

#pragma mark -

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	self.favorites = nil;
    [super dealloc];
}


@end
