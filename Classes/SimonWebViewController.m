//
//  SimonWebViewController.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/17/08.
//  Copyright Adium X / Saltatory Software 2008. All rights reserved.
//

#import "SimonWebViewController.h"

@interface SimonWebViewController ()
- (void)textFieldDidChange:(NSNotification *)notification;
@end

@implementation SimonWebViewController

@synthesize receivedData, reachability;
@synthesize hostName, pagingPrefix, maxCharacters;


typedef enum {
	UISimpleInterfaceOrientationPortrait,
	UISimpleInterfaceOrientationLandscape
} UISimpleInterfaceOrientation;

UISimpleInterfaceOrientation simpleInterfaceOrientation(UIInterfaceOrientation interfaceOrientation)
{
	UISimpleInterfaceOrientation simpleOrientation;
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			simpleOrientation = UISimpleInterfaceOrientationPortrait;
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			simpleOrientation = UISimpleInterfaceOrientationLandscape;
			break;
	}
	
	return simpleOrientation;
}


- (UIView *)view_messaging
{
	return (simpleInterfaceOrientation(self.interfaceOrientation) == UISimpleInterfaceOrientationPortrait ?
			view_messaging_portrait :
			view_messaging_landscape);
}

- (UITextView *)textView_messaging
{
	return (simpleInterfaceOrientation(self.interfaceOrientation) == UISimpleInterfaceOrientationPortrait ?
			textView_messaging_portrait :
			textView_messaging_landscape);	
}

- (UILabel *)textField_charsLeft
{
	return (simpleInterfaceOrientation(self.interfaceOrientation) == UISimpleInterfaceOrientationPortrait ?
			textField_charsLeft_portrait :
			textField_charsLeft_landscape);	
}

- (UIButton *)button_send
{
	return (simpleInterfaceOrientation(self.interfaceOrientation) == UISimpleInterfaceOrientationPortrait ?
			button_send_portrait :
			button_send_landscape);	
}


- (UIActivityIndicatorView *)activityIndicator
{
	return (simpleInterfaceOrientation(self.interfaceOrientation) == UISimpleInterfaceOrientationPortrait ?
			activityIndicator_portrait :
			activityIndicator_landscape);
}


- (void)clear:(id)sender
{
	textField_to.text = @"";
	self.textView_messaging.text = @"";	
}

- (void)validateSendButton
{
	self.button_send.enabled = (reachable && self.textView_messaging.text.length && textField_to.text.length);
}

- (void)reachabilityDidChange:(NSNotification *)notification
{
	reachable = (self.reachability.remoteHostStatus != NotReachable);

	label_noConnection.hidden = reachable;
	
	[self validateSendButton];
}

- (void)pressedAddContact:(id)sender
{
	SimonFavoritesViewController *favoritesViewController = [SimonFavoritesViewController favoritesViewController];
	favoritesViewController.delegate = self;
	[self presentModalViewController:[[[UINavigationController alloc] initWithRootViewController:favoritesViewController] autorelease]
							animated:YES];
}

- (void)configureControls
{
	textField_to.leftView = textField_leftView;
	textField_to.leftViewMode = UITextFieldViewModeAlways;

	UIButton *button_add = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[button_add addTarget:self action:@selector(pressedAddContact:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect bounds_add = button_add.bounds;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(bounds_add)+16, CGRectGetHeight(bounds_add))];
    button_add.frame = CGRectMake(8, 0, CGRectGetWidth(bounds_add), CGRectGetHeight(bounds_add));
    [rightView addSubview:button_add];

    textField_to.rightView = rightView;
	textField_to.rightViewMode = UITextFieldViewModeAlways;
	textField_to.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	
	
	textField_to.placeholder = NSLocalizedString(@"Pager #s, separated by spaces", nil);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewArtist?id=289039917"]];
	}
}

- (void)about:(id)sender
{
#ifdef SIMONWEB_UVA
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Simon Web UVA for iPhone", nil)
								 message:NSLocalizedString(@"Created by Evan Schoenberg, Emory School of Medicine Class of 2009, Tulane Ophthalmology Residency Class of 2013.\n\nPlease check out my other medical applications on the App Store!", nil)
								delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"App Store", nil), nil] autorelease] show];	
#else
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Simon Web for iPhone", nil)
								 message:NSLocalizedString(@"Created by Evan Schoenberg, Emory School of Medicine Class of 2009, Tulane Ophthalmology Residency Class of 2013.\n\nPlease check out my other medical applications on the App Store!", nil)
								delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"App Store", nil), nil] autorelease] show];	
#endif	
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	/* Load paging information */
	self.hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PagingHostName"];
	self.pagingPrefix = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PagingPrefix"];
	self.maxCharacters = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PagingMaxCharacters"] intValue];
	
	[self configureControls];

	self.view_messaging.frame = view_content.bounds;
	[view_content addSubview:self.view_messaging];

	[textField_to becomeFirstResponder];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self
																			action:@selector(clear:)] autorelease];
	
	UIView *barButtonItemView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,20,16)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonItemView] autorelease];

	UIButton *infoLightButtonType = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoLightButtonType.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
	[infoLightButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
	infoLightButtonType.backgroundColor = [UIColor clearColor];
	[infoLightButtonType addTarget:self action:@selector(about:) forControlEvents:UIControlEventTouchDown];
	[self.navigationItem.rightBarButtonItem.customView addSubview:infoLightButtonType];

	self.button_send.enabled = NO;
	label_noConnection.hidden = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityDidChange:)
												 name:@"kNetworkReachabilityChangedNotification"
											   object:nil];
	self.reachability = [Reachability sharedReachability];
	self.reachability.hostName = self.hostName;
	self.reachability.networkStatusNotificationsEnabled = YES;
	[self reachabilityDidChange:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textFieldDidChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField_to];

	[self textViewDidChange:self.textView_messaging];
}

- (NSString *)text
{
	return self.textView_messaging.text;	
}

- (void)setText:(NSString *)text
{
	self.textView_messaging.text = text;
	[self textViewDidChange:self.textView_messaging];
}

- (NSString *)to
{
	return textField_to.text;	
}

- (void)setTo:(NSString *)to
{
	textField_to.text = to;
	[self textFieldDidChange:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text rangeOfString:@"|"].location != NSNotFound)
		return NO;
	else
		return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	int left = self.maxCharacters - self.textView_messaging.text.length;
	self.textField_charsLeft.text = (left >= 0 ?
								[NSString stringWithFormat:@"%i Left", left] :
								[NSString stringWithFormat:@"%i Too Long", -left]);
	self.textField_charsLeft.textColor = (left >= 0 ? [UIColor blackColor] : [UIColor redColor]);

	[self validateSendButton];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
	[self validateSendButton];	
}

- (void)addPIC:(NSString *)inPIC
{
	if (inPIC) {
		textField_to.text = [NSString stringWithFormat:@"%@%@%@",
							 textField_to.text, (textField_to.text.length ? @" " : @""), inPIC];
		
		[self.textView_messaging becomeFirstResponder];
	}
}

- (void)restoreSendButton
{
	[self.activityIndicator stopAnimating];
	[self.button_send setTitle:@"Send" forState:UIControlStateNormal];	
}

- (void)reportSuccess
{
	[[[[UIAlertView alloc]  initWithTitle:NSLocalizedString(@"Page sent", nil)
								  message:NSLocalizedString(@"Your page was sent succesfully.", nil)
								 delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
	[self restoreSendButton];
}

- (void)reportFailure
{
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Page not sent", nil)
								 message:NSLocalizedString(@"Your page was not sent because an error occurred. Please try again.", nil)
								delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];	
	[self restoreSendButton];	
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self reportFailure];
	[connection release];
	self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([[[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease] rangeOfString:@"Successfully Queued"].location != NSNotFound) {
		[self reportSuccess];
	} else {
		[self reportFailure];
	}
	[connection release];
	self.receivedData = nil;
}

- (IBAction)sendPage:(id)sender
{
	NSMutableArray *targets = [[textField_to.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]] mutableCopy];
	for (int i = 0; i < targets.count; i++) {
		NSString *target = [targets objectAtIndex:i];
		if (target.length == 0) {
			[targets removeObjectAtIndex:i];
			i--;
			continue;
		}

		target = [target stringByReplacingOccurrencesOfString:@"-" withString:@""];
		target = [target stringByReplacingOccurrencesOfString:@"(" withString:@""];
		target = [target stringByReplacingOccurrencesOfString:@")" withString:@""];
		target = [target stringByReplacingOccurrencesOfString:@"." withString:@""];
		
		if ([target stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0) {
			[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Page not sent", nil)
										 message:NSLocalizedString(@"PIC numbers must be composed only of numbers.", nil)
										delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];	
			return;
		}
		NSString *targetWithA = [[targets objectAtIndex:i] stringByAppendingString:@"A"];
		[targets replaceObjectAtIndex:i
						   withObject:targetWithA];
	}

	NSString *message = [self.textView_messaging.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *page_list = [targets componentsJoinedByString:@","];
		
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:
								  [NSString stringWithFormat:
								   [self.pagingPrefix stringByAppendingString:@"web_page_confirm.send_page_sub?page_list=%@&message_text=%@"],
								   page_list,message]]];

	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		self.receivedData = [NSMutableData data];
		
		
		[sender setTitle:@"" forState:UIControlStateNormal];
		[self.activityIndicator startAnimating];
		
		
	} else {
		// inform the user that the download could not be made
		[self reportFailure];
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)synchronizeFrom:(UISimpleInterfaceOrientation)fromInterfaceOrientation to:(UISimpleInterfaceOrientation)toInterfaceOrientation
{
	if (fromInterfaceOrientation != toInterfaceOrientation) {
		if (fromInterfaceOrientation == UISimpleInterfaceOrientationPortrait) {
			textView_messaging_landscape.text = textView_messaging_portrait.text;
			button_send_landscape.enabled = button_send_portrait.enabled;
			textField_charsLeft_landscape.text = textField_charsLeft_portrait.text;
			
			if (activityIndicator_portrait.isAnimating) {
				[activityIndicator_landscape startAnimating];
				[button_send_landscape setTitle:@"" forState:UIControlStateNormal];	
			} else {
				[activityIndicator_landscape stopAnimating];
				[button_send_landscape setTitle:@"Send" forState:UIControlStateNormal];	
			}

		} else {
			textView_messaging_portrait.text = textView_messaging_landscape.text;
			button_send_portrait.enabled = button_send_landscape.enabled;
			textField_charsLeft_portrait.text = textField_charsLeft_landscape.text;
			
			if (activityIndicator_landscape.isAnimating) {
				[activityIndicator_portrait startAnimating];
				[button_send_portrait setTitle:@"" forState:UIControlStateNormal];	
			} else {
				[activityIndicator_portrait stopAnimating];
				[button_send_portrait setTitle:@"Send" forState:UIControlStateNormal];	
			}
		}
	}
}

- (void)swapViewsFrom:(UISimpleInterfaceOrientation)fromInterfaceOrientation to:(UISimpleInterfaceOrientation)toInterfaceOrientation
{
	if (fromInterfaceOrientation != toInterfaceOrientation) {
		[[view_content subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

		UIView *newView = (toInterfaceOrientation == UISimpleInterfaceOrientationPortrait ?
						   view_messaging_portrait :
						   view_messaging_landscape);

		newView.frame = view_content.bounds;
		[view_content addSubview:newView];
	}	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self synchronizeFrom:simpleInterfaceOrientation(self.interfaceOrientation)
					   to:simpleInterfaceOrientation(toInterfaceOrientation)];
	
	[self swapViewsFrom:simpleInterfaceOrientation(self.interfaceOrientation)
					 to:simpleInterfaceOrientation(toInterfaceOrientation)];
}

- (void)willAnimateFirstHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

@end
