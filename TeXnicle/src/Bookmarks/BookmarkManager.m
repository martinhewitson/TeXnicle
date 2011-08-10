//
//  BookmarkManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "BookmarkManager.h"
#import "Bookmark.h"
#import "FileEntity.h"
#import "ImageAndTextCell.h"


@implementation BookmarkManager

@synthesize delegate;
@synthesize outlineView;
@synthesize jumpToButton;
@synthesize deleteButton;
@synthesize expandAllButton;
@synthesize collapseAllButton;

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
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
  
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:NO];
	[imageAndTextCell setImage:[NSImage imageNamed:@"TeXnicle_Doc"]];
  [imageAndTextCell setLineBreakMode:NSLineBreakByTruncatingTail];
	[tableColumn setDataCell:imageAndTextCell];	
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


- (void) reloadData
{
  [self.outlineView reloadData];
}

- (IBAction)jumpToSelectedBookmark:(id)sender
{
  Bookmark *b = [self selectedBookmark];
  if (b) {    
    [self jumpToBookmark:b];
  }
}

- (Bookmark*)selectedBookmark
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[Bookmark class]]) {
    return item;
  }
  return nil;
}

- (void)deleteSelectedBookmark:(id)sender
{
  Bookmark *b = [self selectedBookmark];
  if (b) {    
    FileEntity *file = b.parentFile;
    [[file mutableSetValueForKey:@"bookmarks"] removeObject:b];
    [self reloadData];
    [self didDeleteBookmark];
  }
}

- (IBAction)previousBookmark:(id)sender
{
  if (_currentSelectedBookmark < 0) {
    if ([[self allBookmarks] count] > 0) {
      _currentSelectedBookmark = 0;
    }
  } else {
    _currentSelectedBookmark--;
  }
  
  if (_currentSelectedBookmark < 0) {
    _currentSelectedBookmark = [[self allBookmarks] count]-1;
  }
  
  Bookmark *bookmark = [[self allBookmarks] objectAtIndex:_currentSelectedBookmark];
  [self.outlineView expandItem:bookmark.parentFile];
  [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outlineView rowForItem:bookmark]]
                byExtendingSelection:NO];
  
  [self jumpToBookmark:bookmark];
}

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

- (IBAction)expandAll:(id)sender
{
  for (FileEntity *f in [self files]) {
    [self.outlineView expandItem:f];
  }
}

- (IBAction)collapseAll:(id)sender
{
  for (FileEntity *f in [self files]) {
    [self.outlineView collapseItem:f];
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  
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
  
  return NO;
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

- (NSArray*)bookmarksForProject
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForProject)]) {
    return [self.delegate bookmarksForProject];
  }
  return [NSArray array];
}

- (void) jumpToBookmark:(Bookmark*)aBookmark
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(jumpToBookmark:)]) {
    [self.delegate jumpToBookmark:aBookmark];
  }  
}

- (void) didDeleteBookmark
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteBookmark)]) {
    [self.delegate didDeleteBookmark];
  }
}

#pragma mark -
#pragma mark outline view delegate

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

- (NSArray*)bookmarksForFile:(FileEntity*)aFile
{
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"linenumber" ascending:YES]];
  return [[aFile.bookmarks allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray*)allBookmarks
{
  NSMutableArray *bookmarks = [NSMutableArray array];
  for (FileEntity *f in [self files]) {
    [bookmarks addObjectsFromArray:[self bookmarksForFile:f]];
  }
  return bookmarks;
}

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
