//
//  OutlineSectionTagsEditorController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "OutlineSectionTagsEditorController.h"
#import "TPDocumentSectionManager.h"

@interface OutlineSectionTagsEditorController ()

@property (assign) IBOutlet NSTableView *sectionsTableView;
@property (assign) IBOutlet NSTableView *tagsTableView;
@property (assign) IBOutlet NSColorWell *colorWell;

@end

@implementation OutlineSectionTagsEditorController

- (id)init
{
  self = [super initWithNibName:@"OutlineSectionTagsEditorController" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (IBAction)chooseColor:(id)sender
{
  NSColor *color = [self.colorWell color];
  NSString *section = [self selectedSection];
  if (section != nil && color != nil) {
    TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
    [sm setColor:color forName:section];
  }
}

- (IBAction)addTag:(id)sender
{
  NSMutableArray *tags = [[self tagsForSelectedSection] mutableCopy];
  NSString *section = [self selectedSection];
  [tags addObject:[NSString stringWithFormat:@"\\%@_new", section]];
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  [sm setTags:tags forSection:[self selectedSection]];
  [self.tagsTableView reloadData];
}

- (IBAction)removeTag:(id)sender
{
  NSMutableArray *tags = [[self tagsForSelectedSection] mutableCopy];
  NSInteger row = [self.tagsTableView selectedRow];
  if (row >= 0 && row < [tags count]) {
    [tags removeObjectAtIndex:row];
    TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
    [sm setTags:tags forSection:[self selectedSection]];
    [self.tagsTableView reloadData];
  }
}

#pragma mark -
#pragma mark Table Data Source

- (NSArray*) sectionNames
{
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  return sm.sectionNames;
}

- (NSString*) selectedSection
{
  NSInteger row = [self.sectionsTableView selectedRow];
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  if (row >= 0 && row < [sm.templates count]) {
    return [[self sectionNames] objectAtIndex:row];
  }
  
  return nil;
}

- (NSArray*) tagsForSelectedSection
{
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  NSString *section = [self selectedSection];
  if (section != nil) {
    return [sm tagsForSection:section];
  }
  
  return @[];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  
  if (tableView == self.sectionsTableView) {
    return [sm.templates count];
  }
  
  if (tableView == self.tagsTableView) {
    return [[self tagsForSelectedSection] count];
  }
  
  return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.sectionsTableView) {
    NSArray *sections = [self sectionNames];
    if (row >= 0 && row < [sections count]) {
      return sections[row];
    }
  }
  
  if (tableView == self.tagsTableView) {
    NSArray *tags = [self tagsForSelectedSection];
    if (row >= 0 && row < [tags count]) {
      return tags[row];
    }
  }
  
  return nil;
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.tagsTableView) {
    NSMutableArray *tags = [[self tagsForSelectedSection] mutableCopy];
    if (row >= 0 && row < [tags count]) {
      tags[row] = object;
      TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
      [sm setTags:tags forSection:[self selectedSection]];
      [self.tagsTableView reloadData];
    }
  }
}

#pragma mark -
#pragma mark Table delegate

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *table = [notification object];
  if (table == self.sectionsTableView) {
    [self.tagsTableView reloadData];
    [self.tagsTableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    
    // set color well
    NSString *section = [self selectedSection];
    if (section) {
      TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
      NSColor *color = [sm colorForSectionName:section];
      [self.colorWell setColor:color];
    }
    
  }
}


@end
