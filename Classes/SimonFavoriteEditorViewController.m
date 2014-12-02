//
//  SimonFavoriteEditorViewController.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import "SimonFavoriteEditorViewController.h"


@implementation SimonFavoriteEditorViewController

@synthesize editingItem, originalItem;

+ (SimonFavoriteEditorViewController *)controller
{
	NSString *nibName;
#ifdef SIMONWEB_VANDY
	nibName = @"FavoriteEditorVandy";
#else
	nibName = @"FavoriteEditor";
#endif

	return [[[self alloc] initWithNibName:nibName bundle:nil] autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

- (void)cancel:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	if (textField_name.text.length &&
		textField_PIC.text.length) {
		NSMutableArray *favorites = [[[[NSUserDefaults standardUserDefaults] arrayForKey:@"Favorites"] mutableCopy] autorelease];
		if (!favorites) favorites = [NSMutableArray array];
		
		if (!self.editingItem) {
			self.editingItem = [NSMutableDictionary dictionary];
		}

		[self.editingItem setObject:textField_name.text
		 forKey:@"Name"];
		[self.editingItem setObject:textField_PIC.text
		 forKey:@"PIC"];

		if (self.originalItem) {
			[favorites replaceObjectAtIndex:[favorites indexOfObject:self.originalItem]
								 withObject:self.editingItem];
		} else {
			[favorites addObject:self.editingItem];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:favorites
												  forKey:@"Favorites"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FavoritesDidChange" object:nil];
	}

	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender
{
	if (sender == textField_name)
		[textField_PIC becomeFirstResponder];
	else
		 [self done:sender];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.editingItem = [[self.originalItem mutableCopy] autorelease];
	
	self.title = (editingItem ? NSLocalizedString(@"Edit Contact", nil) : NSLocalizedString(@"Add Contact", nil));
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(cancel:)] autorelease];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(done:)] autorelease];

	textField_name.text = [editingItem objectForKey:@"Name"] ? [editingItem objectForKey:@"Name"] : @"";
	textField_PIC.text = [editingItem objectForKey:@"PIC"] ? [editingItem objectForKey:@"PIC"] : @"";
	[textField_name becomeFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	self.editingItem = nil;
	self.originalItem = nil;

    [super dealloc];
}


@end
