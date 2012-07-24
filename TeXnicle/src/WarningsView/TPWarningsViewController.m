//
//  TPWarningsViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
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
    firstView = YES;
    self.sets = [NSMutableArray array];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleMetadataUpdate:)
               name:TPFileMetadataWarningsUpdatedNotification
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
  [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
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
  if (newFiles == nil) {
    newFiles = [NSArray array];
  }
  
  // remove any stale files
  NSMutableArray *filesToRemove = [NSMutableArray array];
  for (TPWarningSet *set in self.sets) {
    if ([newFiles containsObject:set.file] == NO) {
      [filesToRemove addObject:set];
    }
  }
  if ([filesToRemove count] > 0) {
    [self.sets removeObjectsInArray:filesToRemove];
  }
  
  // update our files
  for (FileEntity *newFile in newFiles) {
    TPWarningSet *set = [self setForFile:newFile];
    if (set == nil) {
      NSArray *warnings = [self warningsView:self warningsForFile:newFile];
      if (warnings && [warnings count] > 0) {
        set = [[TPWarningSet alloc] initWithFile:newFile errors:warnings];
        [self.sets addObject:set];
        [set release];
      }
    } else {
      // update the errors
      NSArray *newErrors = [self warningsView:self warningsForFile:newFile];
      set.errors = newErrors;
    }
  }
//  NSLog(@"I have now %u sets", [self.files count]);
//  NSLog(@"   updating %@", self.outlineView);
  [self.outlineView reloadData];
  
  if (firstView == YES) {
    [self performSelector:@selector(expandAll:) withObject:self afterDelay:0.5];
    firstView = NO;
  }
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
