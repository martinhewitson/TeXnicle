//
//  TPPasteTableConfigureWindowController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 18/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPPasteTableConfigureWindowController : NSWindowController {
@private
  NSTextField *customSeparatorField;
  NSMatrix *separatorMatrix;
}

@property (assign) IBOutlet NSTextField *customSeparatorField;
@property (assign) IBOutlet NSMatrix *separatorMatrix;

- (IBAction)selectNewSeparator:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (NSString*)separator;

@end
