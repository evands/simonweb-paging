//
//  SatellinkViewController.m
//  SimonWeb
//
//  Created by Evan Schoenberg on 8/23/09.
//  Copyright 2009 Evan Schoenberg. All rights reserved.
//

#import "SatellinkViewController.h"


@implementation SatellinkViewController

/*
 <FORM name=SendPage action=http://secure.satellink.net/cgi-bin/sendpage.pl method=post>
 <INPUT type=hidden value=" Sun Dec 11 19:56:22 EST 2005" name=browserDate>

 EEE MMM dd	HH:mm:ss zzz yyyy
 
 <INPUT maxLength=14 size=20 name=did>
 <TEXTAREA name=message rows=6 wrap=hard cols=35></TEXTAREA>

 <INPUT type=submit value=SendPage>

 </FORM>
 */

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSLog(@"Loaded");
	self.title = @"Vandy Paging";
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Received %@",
		  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);

	
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [self.receivedData  setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self reportFailure];
	[connection release];
	self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"%@",
		  [[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease]);

	if ([[[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease] 
		 rangeOfString:@"was queued for delivery"].location != NSNotFound) {
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
		
		NSMutableCharacterSet *characterSet = [[[NSCharacterSet decimalDigitCharacterSet] mutableCopy] autorelease];
		[characterSet addCharactersInString:@"-"];
		if ([target stringByTrimmingCharactersInSet:characterSet].length > 0) {
			[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Page not sent", nil)
										 message:NSLocalizedString(@"Pager numbers must be composed only of numbers.", nil)
										delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];	
			return;
		}
	}
	
	NSString *message = [self.textView_messaging.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];


	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @" EEE MMM dd	HH:mm:ss zzz yyyy";
	NSString *browserDate = [formatter stringFromDate:[NSDate date]];
	browserDate = [browserDate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
	
	BOOL success = YES;
	for (NSString *target in targets) {		
		NSString *post = [NSString stringWithFormat:@"browserDate=%@&did=%@&message=%@",
						  browserDate,target,message];
		NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
		NSString *postLength = [NSString stringWithFormat:@"%d", postData.length];
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:self.pagingPrefix]];
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];

		NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (theConnection) {
			self.receivedData = [NSMutableData data];			
		} else {
			success = NO;
		}
	}
	
	if (success) {
		[sender setTitle:@"" forState:UIControlStateNormal];
		[self.activityIndicator startAnimating];
	} else {
		// inform the user that the download could not be made
		[self reportFailure];
	}
}

- (void)about:(id)sender
{
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Vandy Paging for iPhone", nil)
								 message:NSLocalizedString(@"Vandy Paging for iPhone was created by Evan Schoenberg, Emory School of Medicine Class of 2009, Tulane Ophthalmology Residency Class of 2013. Please check out my other medical applications on the App Store!", nil)
								delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"App Store", nil), nil] autorelease] show];	
	
}

@end
