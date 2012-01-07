//
//  TPSupportedFilesEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"
#import "TPSupportedFile.h"

@interface TPSupportedFilesEditor : NSViewController <NSUserInterfaceValidations, NSTableViewDataSource, NSTableViewDelegate> {
@private
  NSTableView *tableView;
  HHValidatedButton *addButton;
  HHValidatedButton *removeButton;
}

@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet HHValidatedButton *addButton;
@property (assign) IBOutlet HHValidatedButton *removeButton;


- (IBAction)addFileType:(id)sender;
- (IBAction)removeFileType:(id)sender;
- (TPSupportedFile*)selectedFile;

@end
