//
//  SimonFavoriteEditorViewController.h
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/18/08.
//  Copyright 2008 Adium X / Saltatory Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SimonFavoriteEditorViewController : UIViewController {
	NSMutableDictionary *editingItem;
	NSDictionary *originalItem;

	IBOutlet UITextField *textField_name;
	IBOutlet UITextField *textField_PIC;
}

+ (SimonFavoriteEditorViewController *)controller;
@property (nonatomic, retain) NSDictionary *originalItem;
@property (nonatomic, retain) NSMutableDictionary *editingItem;

- (IBAction)done:(id)sender;
- (IBAction)next:(id)sender;
@end
