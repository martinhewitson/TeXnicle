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

@implementation BookmarkManager

@synthesize delegate;
@synthesize outlineView;

- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate
{
  self = [self initWithNibName:@"BookmarkManager" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
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

- (void)awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
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

#pragma mark -
#pragma mark outline view delegate

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

- (NSArray*)files
{
  NSArray *bookmarks = [self bookmarksForProject];
  NSMutableArray *files = [NSMutableArray array];
  for (Bookmark *b in bookmarks) {
    if (![files containsObject:b.parentFile]) {
      [files addObject:b.parentFile];
    }
  }
  return files;
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
    return [item valueForKey:@"description"];
  }
  
  return nil;
}


@end
