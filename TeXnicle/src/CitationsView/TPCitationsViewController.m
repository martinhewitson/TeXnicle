//
//  TPCitationsViewController.m
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

#import "TPCitationsViewController.h"
#import "externs.h"
#import "TPCitationSet.h"
#import "BibliographyEntry.h"
#import "TPCitation.h"

@interface TPCitationsViewController ()

@end

@implementation TPCitationsViewController

@synthesize revealButton;
@synthesize delegate;
@synthesize outlineView;
@synthesize sets;


- (id)initWithDelegate:(id<TPCitationsViewDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPCitationsViewController" bundle:nil];
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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.revealButton) {
    NSInteger row = [self.outlineView selectedRow];
    id item = [self.outlineView itemAtRow:row];
    if ([item isKindOfClass:[TPCitation class]] == NO) {
      return NO;
    }
  }
  
  return YES;
}

// Expand all error sets
- (IBAction)expandAll:(id)sender
{
  for (TPCitationSet *f in [self sets]) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all error sets
- (IBAction)collapseAll:(id)sender
{
  for (TPCitationSet *f in [self sets]) {
    [self.outlineView collapseItem:f];
  }
}

- (IBAction)reveal:(id)sender
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPCitation class]]) {
    [self citationsView:self didSelectCitation:item];
  }
}

- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPCitationSet class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[TPCitation class]]) {
    [self citationsView:self didSelectCitation:item];
  }
}


#pragma mark -
#pragma mark OutlineView datasource

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPCitationSet class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{  
  if ([item isKindOfClass:[TPCitationSet class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
      return [item valueForKey:@"selectedDisplayString"];
    } else {
      return [item valueForKey:@"displayString"];
    }
  } else if ([item isKindOfClass:[TPCitation class]]) {
    return [[item valueForKey:@"entry"] attributedString];
  }
  
  return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPCitationSet class]]) {
    TPCitationSet *set = (TPCitationSet*)item;
    return [set.citations count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [[self sortedSets] objectAtIndex:index];
  }
  if ([item isKindOfClass:[TPCitationSet class]]) {
    TPCitationSet *set = (TPCitationSet*)item;
    return [set.citations objectAtIndex:index];
  }
  
  return nil;  
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [[self sortedSets] count];
  }
  
  if ([item isKindOfClass:[TPCitationSet class]]) {
    TPCitationSet *set = (TPCitationSet*)item;
    return [set.citations count];
  }
  
  return 0;
}

- (NSArray*)sortedSets
{
  NSArray *sortedItems = [self.sets sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *first  = [(TPCitationSet*)a valueForKey:@"name"];
    NSString *second = [(TPCitationSet*)b valueForKey:@"name"];
    return [first compare:second]==NSOrderedDescending;
  }];
  return sortedItems;
}

- (void) updateUI
{
  NSArray *newFiles = [self citationsViewlistOfFiles:self];
  
  // remove any stale files
  NSMutableArray *filesToRemove = [NSMutableArray array];
  for (TPCitationSet *set in self.sets) {
    if ([newFiles containsObject:set.file] == NO) {
      [filesToRemove addObject:set];
    }
  }
  [self.sets removeObjectsInArray:filesToRemove];
  
  // update our files
  for (FileEntity *newFile in newFiles) {
    TPCitationSet *set = [self setForFile:newFile];
    if (set == nil) {
      set = [[[TPCitationSet alloc] initWithFile:newFile bibliographyArray:[self citationsView:self citationsForFile:newFile]] autorelease];
      [self.sets addObject:set];
    } else {
      // update the citations
      NSArray *newCitations = [self citationsView:self citationsForFile:newFile];
      [set setCitationsFromBibliographyArray:newCitations];
    }
  }
  //  NSLog(@"I have now %u sets", [self.files count]);
  //  NSLog(@"   updating %@", self.outlineView);
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (TPCitationSet*)setForFile:(FileEntity*)aFile
{
  for (TPCitationSet *set in self.sets) {
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


- (NSArray*) citationsViewlistOfFiles:(TPCitationsViewController *)aView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(citationsViewlistOfFiles:)]) {
    return [self.delegate citationsViewlistOfFiles:aView];
  }
  return [NSArray array];
}

- (NSArray*) citationsView:(TPCitationsViewController *)aView citationsForFile:(id)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(citationsView:citationsForFile:)]) {
    return [self.delegate citationsView:aView citationsForFile:file];
  }
  return nil;
}

- (void) citationsView:(TPCitationsViewController *)aView didSelectCitation:(id)aCitation
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(citationsView:didSelectCitation:)]) {
    [self.delegate citationsView:aView didSelectCitation:aCitation];
  }
}

@end
