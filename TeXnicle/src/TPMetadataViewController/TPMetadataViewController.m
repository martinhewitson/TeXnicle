//
//  TPMetadataViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPMetadataViewController.h"
#import "TPMetadataItem.h"
#import "TPMetadataSet.h"
#import "HHValidatedButton.h"
#import "externs.h"

#define kUpdateInterval 1.0


@interface TPMetadataViewController ()

@property (unsafe_unretained) IBOutlet HHValidatedButton *expandAllButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *collapseAllButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *revealButton;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTextField *statusLabel;
@property (unsafe_unretained) IBOutlet NSSearchField *searchField;

@property (strong) NSDate *lastUpdate;

@end

@implementation TPMetadataViewController

- (id)initWithDelegate:(id<TPMetadataViewDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPMetadataItemView" bundle:nil];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    firstView = YES;
    self.sets = [NSMutableArray array];
    self.lastUpdate = nil;
  }
  
  return self;
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  self.outlineView.dataSource = nil;
  self.outlineView.delegate = nil;
  self.outlineView = nil;
  self.revealButton = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.sets removeAllObjects];
  self.sets = nil;
  self.delegate = nil;
}


- (void) awakeFromNib
{
  [self.outlineView setDoubleAction:@selector(outlineViewDoubleClicked)];
  [self.outlineView setTarget:self];
  
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
  
  [[self.statusLabel cell] setBackgroundStyle:NSBackgroundStyleRaised];

  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleMetadataUpdate:)
             name:TPFileMetadataUpdatedNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(handleMetadataDidBeginUpdateNotification:)
             name:TPMetadataManagerDidBeginUpdateNotification
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleMetadataDidEndUpdateNotification:)
             name:TPMetadataManagerDidEndUpdateNotification
           object:nil];
  
}

- (void) handleMetadataDidBeginUpdateNotification:(NSNotification*)aNote
{
  [self.progressIndicator startAnimation:self];
}

- (void) handleMetadataDidEndUpdateNotification:(NSNotification*)aNote
{
  [self.progressIndicator stopAnimation:self];
}

- (void) handleMetadataUpdate:(NSNotification*)aNote
{
  [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.revealButton) {
    NSInteger row = [self.outlineView selectedRow];
    id item = [self.outlineView itemAtRow:row];
    if ([item isKindOfClass:[TPMetadataItem class]] == NO) {
      return NO;
    }
  }
  
  return YES;
}

- (NSArray*)sortedItemsForSet:(TPMetadataSet*)set
{
  NSArray *sortedItems = [set.items sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *sortKey = [a valueForKey:@"sortKey"];
    NSString *first  = [(TPMetadataSet*)a valueForKey:sortKey];
    NSString *second = [(TPMetadataSet*)b valueForKey:sortKey];
    return [first compare:second]==NSOrderedDescending;
  }];
  return sortedItems;
}


- (IBAction)filterDidChange:(id)sender
{
  [self updateFilters];
  [self.outlineView reloadData];
  [self performSelector:@selector(expandAll:) withObject:nil afterDelay:0];
  [self updateStatusLabel];
}

- (void) updateFilters
{
  NSPredicate *predicate = nil;
  NSString *searchString = [self.searchField stringValue];
  if ([searchString length] > 0) {
    predicate = [NSPredicate predicateWithFormat:@"self.string contains[cd] %@", searchString];
  }
  
  for (TPMetadataSet *set in self.sets) {
    set.predicate = predicate;
  }
}

// Expand all error sets
- (IBAction)expandAll:(id)sender
{
  for (id f in self.sets) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all error sets
- (IBAction)collapseAll:(id)sender
{
  for (id f in self.sets) {
    [self.outlineView collapseItem:f];
  }
}

- (IBAction)reveal:(id)sender
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPMetadataItem class]]) {
    [self metadataView:self didSelectItem:item];
  }
}

- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[TPMetadataItem class]]) {
    [self metadataView:self didSelectItem:item];
  }
}


#pragma mark -
#pragma mark OutlineView delegate


#pragma mark -
#pragma mark OutlineView datasource

- (NSArray*)displaySets
{
  NSMutableArray *dsets = [[NSMutableArray alloc] init];
  for (TPMetadataSet *set in self.sets) {
    if ([set.displayItems count] > 0) {
      [dsets addObject:set];
    }
  }

  return dsets;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {
      return [item valueForKey:@"selectedDisplayString"];
    } else {
      return [item valueForKey:@"displayString"];
    }
  } else if ([item isKindOfClass:[TPMetadataItem class]]) {
    return [item valueForKey:@"value"];
  }
  
  return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    TPMetadataSet *set = (TPMetadataSet*)item;
    return [set.displayItems count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return self.displaySets[index];
  }
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    TPMetadataSet *set = (TPMetadataSet*)item;
    return set.displayItems[index];
  }
  
  return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{  
  if (item == nil) {
    return [self.displaySets count];
  }
  
  if ([item isKindOfClass:[TPMetadataSet class]]) {
    TPMetadataSet *set = (TPMetadataSet*)item;
    return [set.displayItems count];
  }
  
  return 0;
}

- (void) updateUI
{
  //NSLog(@"%@: updateUI", self);
  
  [self.sets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSString *first  = [obj1 valueForKey:@"name"];
    NSString *second = [obj2 valueForKey:@"name"];
    return [first compare:second]==NSOrderedDescending;
  }];

  [self.outlineView reloadData];
  [self.outlineView setNeedsDisplay:YES];
  
  if (firstView == YES && [self.sets count] > 0) {
    [self performSelector:@selector(expandAll:) withObject:self afterDelay:0.5];
    firstView = NO;
  }
  
  // and make sure the filter is set
  [self updateFilters];
  
  // update status label
  [self updateStatusLabel];
}

- (void) updateStatusLabel
{
  NSInteger total = 0;
  for (TPMetadataSet *set in self.displaySets) {
    total += [set.items count];
  }
  NSString *message = [NSString stringWithFormat:@"%ld itmes in %ld sets", total, [self.displaySets count]];
  [self.statusLabel setStringValue:message];
}

- (TPMetadataSet*)setForFile:(TPFileMetadata*)aFile
{
  for (TPMetadataSet *set in self.sets) {
    if (set.file == aFile) {
      return set;
    }
  }
  return nil;
}



#pragma mark -
#pragma mark Delegate

- (NSArray*) metadataViewListOfFiles:(TPMetadataViewController *)aViewController
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(metadataViewListOfFiles:)]) {
    return [self.delegate metadataViewListOfFiles:aViewController];
  }
  return @[];
}

- (NSArray*) metadataView:(TPMetadataViewController *)aViewController newItemsForFile:(id)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(metadataView:newItemsForFile:)]) {
    return [self.delegate metadataView:aViewController newItemsForFile:file];
  }
  return nil;
}

- (void) metadataView:(TPMetadataViewController *)aViewController didSelectItem:(id)anItem
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(metadataView:didSelectItem:)]) {
    [self.delegate metadataView:aViewController didSelectItem:anItem];
  }
}




@end
