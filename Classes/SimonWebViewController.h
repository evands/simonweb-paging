//
//  SimonWebViewController.h
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/17/08.
//  Copyright Adium X / Saltatory Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimonFavoritesViewController.h"

#import "Reachability.h"

@interface SimonWebViewController : UIViewController <UITextViewDelegate, SimonFavoritesViewControllerDelegate> {
	IBOutlet UITextField *textField_to;
	IBOutlet UITextField *textField_leftView;

	IBOutlet UIView *view_content;

	IBOutlet UILabel *label_noConnection;

	IBOutlet UIView *view_messaging_portrait;
	IBOutlet UITextView *textView_messaging_portrait;
	IBOutlet UILabel *textField_charsLeft_portrait;
	IBOutlet UIActivityIndicatorView *activityIndicator_portrait;

	IBOutlet UIButton *button_send_portrait;
	
	IBOutlet UIView *view_messaging_landscape;
	IBOutlet UITextView *textView_messaging_landscape;
	IBOutlet UILabel *textField_charsLeft_landscape;
	IBOutlet UIActivityIndicatorView *activityIndicator_landscape;

	IBOutlet UIButton *button_send_landscape;
	
	
	NSMutableData *receivedData;
	
	Reachability *reachability;
	BOOL reachable;
	
	NSString *hostName;
	NSString *pagingPrefix;	
	NSUInteger maxCharacters;
}

- (IBAction)sendPage:(id)sender;

- (void)addPIC:(NSString *)inPIC;

@property (nonatomic, retain) NSString *hostName;
@property (nonatomic, retain) NSString *pagingPrefix;
@property (nonatomic) NSUInteger maxCharacters;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) Reachability *reachability;

- (NSString *)text;
- (void)setText:(NSString *)text;
- (NSString *)to;
- (void)setTo:(NSString *)to;

- (void)reportFailure;
- (void)reportSuccess;

- (UITextView *)textView_messaging;
- (UIActivityIndicatorView *)activityIndicator;

@end

