//
//  TPEnginesEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPEngineManager.h"
#import "HHValidatedButton.h"

@interface TPEnginesEditor : NSViewController <NSUserInterfaceValidations, NSTableViewDataSource, NSTableViewDelegate, TPEngineManagerDelegate> {
@private
  TPEngineManager *engineManager;
  NSTableView *tableView;
  HHValidatedButton *editButton;
  HHValidatedButton *duplicateButton;
  HHValidatedButton *addEngineButton;
  HHValidatedButton *deleteButton;
  HHValidatedButton *revealButton;
}

@property (retain) TPEngineManager *engineManager;
@property (assign) IBOutlet NSTableView *tableView;

@property (assign) IBOutlet HHValidatedButton *editButton;
@property (assign) IBOutlet HHValidatedButton *duplicateButton;
@property (assign) IBOutlet HHValidatedButton *addEngineButton;
@property (assign) IBOutlet HHValidatedButton *deleteButton;
@property (assign) IBOutlet HHValidatedButton *revealButton;

- (TPEngine*)selectedEngine;
- (TPEngine*)engineAtRow:(NSInteger)aRow;

- (IBAction)editSelectedEngine:(id)sender;
- (IBAction)duplicateSelectedEngine:(id)sender;
- (IBAction)newEngine:(id)sender;
- (IBAction)deleteSelectedEngine:(id)sender;
- (IBAction)revealSelectedEngine:(id)sender;

- (void) selectEngineNamed:(NSString*)aName;


@end
