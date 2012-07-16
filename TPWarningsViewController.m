//
//  TPWarningsViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPWarningsViewController.h"
#import "FileEntity.h"
#import "FileEntity+Warnings.h"
#import "externs.h"
#import "TPSyntaxError.h"
#import "TPWarningSet.h"

@interface TPWarningsViewController ()

@end

@implementation TPWarningsViewController

@synthesize revealButton;
@synthesize delegate;
@synthesize outlineView;
@synthesize sets;

- (id) initWithDelegate:(id<TPWarningsViewDelegate>)aDelegate 
{
  self = [super initWithNibName:@"TPWarningsViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    
    self.sets = [NSMutableArray array];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleMetadataUpdate:)
               name:TPFileMetadataUpdatedNotification
             object:nil];
    
  }
  
  return self;
}

- (void) dealloc
{
  self.sets = nil;
  [super dealloc];
}

- (void) awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
  
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (void) handleMetadataUpdate:(NSNotification*)aNote
{
  NSDictionary *dict = [aNote userInfo];
  
  [self updateUI];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.revealButton) {
    NSInteger row = [self.outlineView selectedRow];
    id item = [self.outlineView itemAtRow:row];
    if ([item isKindOfClass:[TPSyntaxError class]] == NO) {
      return NO;
    }
  }
  
  return YES;
}

// Expand all error sets
- (IBAction)expandAll:(id)sender
{
  for (TPWarningSet *f in [self sets]) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all error sets
- (IBAction)collapseAll:(id)sender
{
  for (TPWarningSet *f in [self sets]) {
    [self.outlineView collapseItem:f];
  }
}

- (IBAction)reveal:(id)sender
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPSyntaxError class]]) {
    [self warningsView:self didSelectError:item];
  }
}

- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPWarningSet class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[TPSyntaxError class]]) {
    [self warningsView:self didSelectError:item];
  }
}

#pragma mark -
#pragma mark OutlineView datasource

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPWarningSet class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{  
  if ([item isKindOfClass:[TPWarningSet class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
      return [item valueForKey:@"selectedDisplayString"];
    } else {
      return [item valueForKey:@"displayString"];
    }
  } else if ([item isKindOfClass:[TPSyntaxError class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
      return [item valueForKey:@"selectedAttributedString"];
    } else {
      return [item valueForKey:@"attributedString"];
    }
  }
  
  return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPWarningSet class]]) {
    TPWarningSet *set = (TPWarningSet*)item;
    return [set.errors count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [[self sortedWarningSets] objectAtIndex:index];
  }
  if ([item isKindOfClass:[TPWarningSet class]]) {
    TPWarningSet *set = (TPWarningSet*)item;
    return [set.errors objectAtIndex:index];
  }
  
  return nil;  
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [[self sortedWarningSets] count];
  }
  
  if ([item isKindOfClass:[TPWarningSet class]]) {
    TPWarningSet *set = (TPWarningSet*)item;
    return [set.errors count];
  }
  
  return 0;
}

- (NSArray*)sortedWarningSets
{
  NSArray *sortedItems = [self.sets sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *first  = [(TPWarningSet*)a valueForKey:@"name"];
    NSString *second = [(TPWarningSet*)b valueForKey:@"name"];
    return [first compare:second]==NSOrderedDescending;
  }];
  return sortedItems;
}

- (void) updateUI
{
  NSArray *newFiles = [self warningsViewlistOfFiles:self];
  
  // remove any stale files
  NSMutableArray *filesToRemove = [NSMutableArray array];
  for (TPWarningSet *set in self.sets) {
    if ([newFiles containsObject:set.file] == NO) {
      [filesToRemove addObject:set];
    }
  }
  [self.sets removeObjectsInArray:filesToRemove];
  
  // update our files
  for (FileEntity *newFile in newFiles) {
    TPWarningSet *set = [self setForFile:newFile];
    if (set == nil) {
      set = [[[TPWarningSet alloc] initWithFile:newFile errors:[self warningsView:self warningsForFile:newFile]] autorelease];
      [self.sets addObject:set];
    } else {
      // update the errors
      NSArray *newErrors = [self warningsView:self warningsForFile:newFile];
      set.errors = newErrors;
    }
  }
//  NSLog(@"I have now %u sets", [self.files count]);
//  NSLog(@"   updating %@", self.outlineView);
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (TPWarningSet*)setForFile:(FileEntity*)aFile
{
  for (TPWarningSet *set in self.sets) {
    if (set.file == aFile) {
      return set;
    }
  }
  return nil;
}

#pragma mark -
#pragma mark OutlineView delegate



#pragma mark -
#pragma mark Delegate

- (NSArray*) warningsViewlistOfFiles:(TPWarningsViewController *)warningsView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(warningsViewlistOfFiles:)]) {
    return [self.delegate warningsViewlistOfFiles:warningsView];
  }
  return [NSArray array];
}

- (NSArray*) warningsView:(TPWarningsViewController *)warningsView warningsForFile:(id)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(warningsView:warningsForFile:)]) {
    return [self.delegate warningsView:warningsView warningsForFile:file];
  }
  
  return nil;
}

- (void) warningsView:(TPWarningsViewController*)warningsView didSelectError:(TPSyntaxError*)anError
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(warningsView:didSelectError:)]) {
    [self.delegate warningsView:self didSelectError:anError];
  }
}

@end
