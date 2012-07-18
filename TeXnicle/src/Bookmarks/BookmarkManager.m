//
//  BookmarkManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BookmarkManager.h"
#import "Bookmark.h"
#import "FileEntity.h"
#import "ImageAndTextCell.h"
#import "externs.h"

@implementation BookmarkManager

@synthesize delegate;
@synthesize outlineView;
@synthesize jumpToButton;
@synthesize deleteButton;
@synthesize expandAllButton;
@synthesize collapseAllButton;


// Initialise with a delegate
- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate
{
  self = [self initWithNibName:@"BookmarkManager" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
    _currentSelectedBookmark = -1;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleUndoNotification:)
               name:NSUndoManagerDidUndoChangeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(handleBookmarkChangedNotification:)
               name:TPBookmarkDidUpdateNotification
             object:nil];
  }
  return self;
}

// Dealloc and remove self from notifcation center
- (void) dealloc
{
  self.outlineView.delegate = nil;
  self.outlineView.dataSource = nil;
  self.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
  
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:NO];
	[imageAndTextCell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
  [imageAndTextCell setLineBreakMode:NSLineBreakByTruncatingTail];
	[tableColumn setDataCell:imageAndTextCell];	
  [imageAndTextCell release];
}

- (void) handleBookmarkChangedNotification:(NSNotification*)aNote
{
  [self reloadData];
}

- (void) handleUndoNotification:(NSNotification*)aNote
{
  [self reloadData];
}

- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[FileEntity class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[Bookmark class]]) {
    [self jumpToBookmark:item];
  }
}

// Reload the data in the outline view
- (void) reloadData
{
  [self.outlineView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

// Jump to the selected bookmark
- (IBAction)jumpToSelectedBookmark:(id)sender
{
  Bookmark *b = [self selectedBookmark];
  if (b) {    
    [self jumpToBookmark:b];
  }
}

// Returns the currently selected bookmark, or nil
- (Bookmark*)selectedBookmark
{
  NSInteger row = [self.outlineView selectedRow];
  
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[Bookmark class]]) {
    return item;
  }
  return nil;
}

// Delete the selected bookmark
- (IBAction)deleteSelectedBookmark:(id)sender
{
  Bookmark *b = [self selectedBookmark];
  if (b) {    
    FileEntity *file = b.parentFile;
    [[file mutableSetValueForKey:@"bookmarks"] removeObject:b];
    [self reloadData];
    [self didDeleteBookmark];
  }
}

// Jump to previous bookmark
- (IBAction)previousBookmark:(id)sender
{
  NSArray *bookmarks = [self allBookmarks];
  if (_currentSelectedBookmark < 0) {
    if ([bookmarks count] > 0) {
      _currentSelectedBookmark = 0;
    } else {
      return;
    }
  } else {
    _currentSelectedBookmark--;
  }
  
  if (_currentSelectedBookmark < 0) {
    _currentSelectedBookmark = [[self allBookmarks] count]-1;
  }
  
  Bookmark *bookmark = [bookmarks objectAtIndex:_currentSelectedBookmark];
  [self.outlineView expandItem:bookmark.parentFile];
  [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outlineView rowForItem:bookmark]]
                byExtendingSelection:NO];
  
  [self jumpToBookmark:bookmark];
}

// Jump to next bookmark
- (IBAction)nextBookmark:(id)sender
{
  if (_currentSelectedBookmark < 0) {
    if ([[self allBookmarks] count] > 0) {
      _currentSelectedBookmark = 0;
    }
  } else {
    _currentSelectedBookmark++;
  }
  
  if (_currentSelectedBookmark >= [[self allBookmarks] count]) {
    _currentSelectedBookmark = 0;
  }
  
  Bookmark *bookmark = [[self allBookmarks] objectAtIndex:_currentSelectedBookmark];
  [self.outlineView expandItem:bookmark.parentFile];
  [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outlineView rowForItem:bookmark]]
                byExtendingSelection:NO];
  
  [self jumpToBookmark:bookmark];
}

// Expand all bookmarks
- (IBAction)expandAll:(id)sender
{
  for (FileEntity *f in [self files]) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all bookmarks
- (IBAction)collapseAll:(id)sender
{
  for (FileEntity *f in [self files]) {
    [self.outlineView collapseItem:f];
  }
}

// Validate menu items
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
//  NSLog(@"Bookmark manager validateMenuItem");
  NSInteger tag = [menuItem tag];
  
  // delete bookmark
  if (tag == 406020) {
    if ([self selectedBookmark]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // jump to bookmark
  if (tag == 406030) {
    if ([self selectedBookmark]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // jump to previous bookmark
  if (tag == 406040) {
    if ([[self allBookmarks] count]>0) {
      return YES;
    }
  }
  
  // jump to next bookmark
  if (tag == 406050) {
    if ([[self allBookmarks] count]>0) {
      return YES;
    }
  }
  
  return [super validateMenuItem:menuItem];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{  
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  
  if (anItem == self.jumpToButton) {
    if (![item isKindOfClass:[Bookmark class]]) {
      return NO;
    }
  }
  if (anItem == self.deleteButton) {
    if (![item isKindOfClass:[Bookmark class]]) {
      return NO;
    }
  }
  
  if (anItem == self.expandAllButton) {
    if ([[self files] count] == 0) {
      return NO;
    }
  }
  
  if (anItem == self.collapseAllButton) {
    if ([[self files] count] == 0) {
      return NO;
    }
  }
  
  return YES;
}

#pragma mark -
#pragma mark BookmarkManager Delegate

// Returns an array of bookmarks for the given project by asking the delegate
- (NSArray*)bookmarksForProject
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForProject)]) {
    NSArray *bookmarks = [self.delegate bookmarksForProject];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayString != nil"];
    return [bookmarks filteredArrayUsingPredicate:predicate];
  }
  return [NSArray array];
}

// Ask the delegate to jump to the given bookmark
- (void) jumpToBookmark:(Bookmark*)aBookmark
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(jumpToBookmark:)]) {
    [self.delegate jumpToBookmark:aBookmark];
  }  
}

// Inform the delegate we did delete a bookmark
- (void) didDeleteBookmark
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteBookmark)]) {
    [self.delegate didDeleteBookmark];
  }
}

#pragma mark -
#pragma mark outline view delegate

// Select a bookmark with a given line number
- (void)selectBookmarkForLinenumber:(NSInteger)aLinenumber
{
  Bookmark *bookmark = nil;
  for (Bookmark *b in [self allBookmarks]) {
    if ([b.linenumber integerValue] == aLinenumber) {
      bookmark = b;
      break;
    }
  }
  
  if (bookmark) {
    [self.outlineView expandItem:bookmark.parentFile];
    [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outlineView rowForItem:bookmark]]
                  byExtendingSelection:NO];
    
    [self jumpToBookmark:bookmark];    
  }
  
}

- (void) outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  if (anOutlineView == self.outlineView) {
    if ([cell isMemberOfClass:[ImageAndTextCell class]]) {
      if ([item isKindOfClass:[FileEntity class]]) {
        [cell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
      } else if ([item isKindOfClass:[Bookmark class]]) {
        [cell setImage:[NSImage imageNamed:@"bookmark"]];
      }
    }
  }
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if ([item isKindOfClass:[FileEntity class]]) {
    return YES;
  }
  return NO;
}

#pragma mark -
#pragma mark outline view datasource

// Returns the bookmarks for a given file entity
- (NSArray*)bookmarksForFile:(FileEntity*)aFile
{
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"linenumber" ascending:YES]];
  return [[aFile.bookmarks allObjects] sortedArrayUsingDescriptors:descriptors];
}

// Returns an array of all bookmarks for all files.
- (NSArray*)allBookmarks
{
  NSMutableArray *bookmarks = [NSMutableArray array];
  for (FileEntity *f in [self files]) {
    [bookmarks addObjectsFromArray:[self bookmarksForFile:f]];
  }
  return bookmarks;
}

// Returns an array of all files by scanning through all bookmarks for this project
- (NSArray*)files
{
  NSArray *bookmarks = [self bookmarksForProject];
  NSMutableArray *files = [NSMutableArray array];
  for (Bookmark *b in bookmarks) {
    if (![files containsObject:b.parentFile]) {
      [files addObject:b.parentFile];
    }
  }
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
  return [files sortedArrayUsingDescriptors:descriptors];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isKindOfClass:[FileEntity class]]) {
    FileEntity *file = (FileEntity*)item;
    if ([[file bookmarks] count]>0) {
      return YES;
    }
  }
  
  return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  // nil
  if (item == nil) {
    return [[self files] count];
  }
  
  // file
  if ([item isKindOfClass:[FileEntity class]]) {
    FileEntity *file = (FileEntity*)item;
    return [[[file bookmarks] allObjects] count];
  }
  
  // bookmark
  return 0;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  // nil
  if (item == nil) {
    return [[self files] objectAtIndex:index];
  }
  
  // file
  if ([item isKindOfClass:[FileEntity class]]) {
    FileEntity *file = (FileEntity*)item;
    return [[self bookmarksForFile:file] objectAtIndex:index];
  }
  
  // bookmark
  return nil;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  // file
  if ([item isKindOfClass:[FileEntity class]]) {
    return [item valueForKey:@"shortName"];
  }
  
  // bookmark
  if ([item isKindOfClass:[Bookmark class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
      return [item valueForKey:@"selectedDisplayString"];
    } else {
      return [item valueForKey:@"displayString"];
    }
  }
  
  return nil;
}


@end
