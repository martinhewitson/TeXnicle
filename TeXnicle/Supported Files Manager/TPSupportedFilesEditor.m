//
//  TPSupportedFilesEditor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPSupportedFilesEditor.h"
#import "TPSupportedFilesManager.h"

@implementation TPSupportedFilesEditor

@synthesize tableView;
@synthesize addButton;
@synthesize removeButton;

- (id)init
{
  self = [super initWithNibName:@"TPSupportedFilesEditor" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  // Add button
  if (anItem == self.addButton) {
    return YES;
  }
  
  // Remove button
  if (anItem == self.removeButton) {
    // Disable if there is no selected file...
    TPSupportedFile *file = [self selectedFile];
    if (file != nil) {
      // ... or if the file is a built-in one.
      if ([file isBuiltIn]) {
        return NO;
      }
    } else {
      return NO;
    }
  }
  
  return YES;
}

// Returns the currently selected file or nil.
- (TPSupportedFile*)selectedFile
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSInteger row = [self.tableView selectedRow];
  if (row >=0 && row < [sfm fileCount]) {
    return [sfm fileAtIndex:row];
  }
  
  return nil;
}

// Adds a new file type
- (IBAction)addFileType:(id)sender
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *newFile = [TPSupportedFile supportedFileWithName:@"New File Type" extension:@"ext"];
  if (newFile) {
    [sfm addSupportedFileType:newFile];
    [self.tableView reloadData];
    NSInteger index = [sfm indexOfFileType:newFile];
    if (index >= 0 && index < [sfm fileCount]) {
      [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
  }
}

// Remove the selected file.
- (IBAction)removeFileType:(id)sender
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *file = [self selectedFile];
  if (file) {
    [sfm removeSupportedFileType:file];
    [self.tableView reloadData];
  }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  return [sfm fileCount];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *file = [sfm fileAtIndex:row];
  
  if ([[tableColumn identifier] isEqualToString:@"ExtensionColumn"]) {
    return file.ext;
  } else if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    return file.name;
  } else if ([[tableColumn identifier] isEqualToString:@"HighlightColumn"]) {
    return [NSNumber numberWithBool:file.syntaxHighlight];
  } else if ([[tableColumn identifier] isEqualToString:@"SpellCheckColumn"]) {
    return [NSNumber numberWithBool:file.spellcheck];
  } else {
    return nil;
  }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *file = [sfm fileAtIndex:row];
  
  if ([[tableColumn identifier] isEqualToString:@"ExtensionColumn"]) {
    file.ext = object;
  } else if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    file.name = object;
  } else if ([[tableColumn identifier] isEqualToString:@"HighlightColumn"]) {
    file.syntaxHighlight = [object boolValue];
  } else if ([[tableColumn identifier] isEqualToString:@"SpellCheckColumn"]) {
    file.spellcheck = [object boolValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TPSupportedFileSpellCheckFlagChangedNotification 
                                                        object:file 
                                                      userInfo:nil];
    
  } else {
    // do nothing
  }
 
  [sfm saveTypes];
}

- (BOOL) tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *file = [sfm fileAtIndex:row];
  if (file.isBuiltIn) {
    return NO;
  }
  
  return YES;
}

- (void) tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  TPSupportedFile *file = [sfm fileAtIndex:row];
  
  if ([[tableColumn identifier] isEqualToString:@"ExtensionColumn"]) {
    if ([file isBuiltIn]) {
      [cell setTextColor:[NSColor disabledControlTextColor]];
    } else {
      [cell setTextColor:[NSColor controlTextColor]];
    }
  } else if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    if ([file isBuiltIn]) {
      [cell setTextColor:[NSColor disabledControlTextColor]];
    } else {
      [cell setTextColor:[NSColor controlTextColor]];
    }
  } else if ([[tableColumn identifier] isEqualToString:@"HighlightColumn"]) {
    if ([file isBuiltIn]) {
      [cell setEnabled:YES];
    } else {
      [cell setEnabled:YES];
    }
  } else if ([[tableColumn identifier] isEqualToString:@"SpellCheckColumn"]) {
    if ([file isBuiltIn]) {
      [cell setEnabled:YES];
    } else {
      [cell setEnabled:YES];
    }
  } else {
  }
  
  
}

@end
