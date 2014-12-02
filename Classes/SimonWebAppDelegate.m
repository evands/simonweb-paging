//
//  SimonWebAppDelegate.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/17/08.
//  Copyright Adium X / Saltatory Software 2008. All rights reserved.
//

#import "SimonWebAppDelegate.h"
#import "SimonWebViewController.h"

@implementation SimonWebAppDelegate

@synthesize window;
@synthesize viewController;

#define RESTORE_VERSION_STRING [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]
#define KEY_PreviousSavedStateVersionString @"PreviousSavedStateVersionString"
#define KEY_SavedText @"SavedText"
#define KEY_SavedTo @"SavedTo"

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Configure and show the window
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:KEY_PreviousSavedStateVersionString] isEqualToString:RESTORE_VERSION_STRING]) {
		[viewController setText:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_SavedText]];
		[viewController setTo:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_SavedTo]];

	} else {
		NSLog(@"Skipping state restore because %@ != %@", [[NSUserDefaults standardUserDefaults] stringForKey:KEY_PreviousSavedStateVersionString], RESTORE_VERSION_STRING);
	}	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults] setObject:viewController.text
											  forKey:KEY_SavedText];
	[[NSUserDefaults standardUserDefaults] setObject:viewController.to
											  forKey:KEY_SavedTo];

	[[NSUserDefaults standardUserDefaults] setObject:RESTORE_VERSION_STRING
											  forKey:KEY_PreviousSavedStateVersionString];
	
	//Ensure the data is written before we quit
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
