//
//  TPProjectTemplateChooser.h
//  TeXnicle
//
//  Created by Martin Hewitson on 19/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"
#import "TPProjectTemplateListViewController.h"


@class TPProjectTemplate;

@interface TPProjectTemplateManager : NSViewController <NSUserInterfaceValidations, NSTableViewDelegate, NSTableViewDataSource> {
  HHValidatedButton *editButton;
  HHValidatedButton *duplicateButton;
  HHValidatedButton *deleteButton;
  HHValidatedButton *revealButton;
  TPProjectTemplateListViewController *templateListViewController; 
  NSView *templateListContainer;
}

@property (assign) IBOutlet NSView *templateListContainer;
@property (assign) IBOutlet HHValidatedButton *editButton;
@property (assign) IBOutlet HHValidatedButton *duplicateButton;
@property (assign) IBOutlet HHValidatedButton *deleteButton;
@property (assign) IBOutlet HHValidatedButton *revealButton;
@property (retain) TPProjectTemplateListViewController *templateListViewController;

- (IBAction)editSelectedTemplate:(id)sender;
- (IBAction)duplicateSelectedTemplate:(id)sender;
- (IBAction)deleteSelectedTemplate:(id)sender;
- (IBAction)revealSelectedTemplate:(id)sender;
- (void) deleteTemplateAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
