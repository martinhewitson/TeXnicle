//
//  TPNewCommandsViewController.m
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

#import "TPNewCommandsViewController.h"
#import "externs.h"
#import "TPCommandSet.h"
#import "TPNewCommand.h"


@interface TPNewCommandsViewController ()

@end

@implementation TPNewCommandsViewController

@synthesize revealButton;
@synthesize delegate;
@synthesize outlineView;
@synthesize sets;


- (id)initWithDelegate:(id<TPNewCommandsViewDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPNewCommandsViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    firstView = YES;
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
  [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.revealButton) {
    NSInteger row = [self.outlineView selectedRow];
    id item = [self.outlineView itemAtRow:row];
    if ([item isKindOfClass:[TPNewCommand class]] == NO) {
      return NO;
    }
  }
  
  return YES;
}

// Expand all error sets
- (IBAction)expandAll:(id)sender
{
  for (TPCommandSet *f in [self sets]) {
    [self.outlineView expandItem:f];
  }
}

// Collapse all error sets
- (IBAction)collapseAll:(id)sender
{
  for (TPCommandSet *f in [self sets]) {
    [self.outlineView collapseItem:f];
  }
}

- (IBAction)reveal:(id)sender
{
  NSInteger row = [self.outlineView selectedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPNewCommand class]]) {
    [self commandsView:self didSelectNewCommand:item];
  }
}

- (void) outlineViewDoubleClicked
{
  NSInteger row = [self.outlineView clickedRow];
  id item = [self.outlineView itemAtRow:row];
  if ([item isKindOfClass:[TPCommandSet class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView collapseItem:item];
    } else {
      [self.outlineView expandItem:item];
    }
  } else if ([item isKindOfClass:[TPNewCommand class]]) {
    [self commandsView:self didSelectNewCommand:item];
  }
}


#pragma mark -
#pragma mark OutlineView datasource

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPCommandSet class]]) {
    return YES;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{  
  if ([item isKindOfClass:[TPCommandSet class]]) {
    if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {    
      return [item valueForKey:@"selectedDisplayString"];
    } else {
      return [item valueForKey:@"displayString"];
    }
  } else if ([item isKindOfClass:[TPNewCommand class]]) {
    return [item valueForKey:@"argument"];
  }
  
  return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil) {
    return NO;
  }
  
  if ([item isKindOfClass:[TPCommandSet class]]) {
    TPCommandSet *set = (TPCommandSet*)item;
    return [set.commands count] > 0;
  }
  
  return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return [[self sortedSets] objectAtIndex:index];
  }
  if ([item isKindOfClass:[TPCommandSet class]]) {
    TPCommandSet *set = (TPCommandSet*)item;
    return [[self sortedCommandsForSet:set] objectAtIndex:index];
  }
  
  return nil;  
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [[self sortedSets] count];
  }
  
  if ([item isKindOfClass:[TPCommandSet class]]) {
    TPCommandSet *set = (TPCommandSet*)item;
    return [set.commands count];
  }
  
  return 0;
}

- (NSArray*)sortedSets
{
  NSArray *sortedItems = [self.sets sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *first  = [(TPCommandSet*)a valueForKey:@"name"];
    NSString *second = [(TPCommandSet*)b valueForKey:@"name"];
    return [first compare:second]==NSOrderedDescending;
  }];
  return sortedItems;
}

- (NSArray*)sortedCommandsForSet:(TPCommandSet*)set
{
  NSArray *sortedItems = [set.commands sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSString *first  = [(TPCommandSet*)a valueForKey:@"argument"];
    NSString *second = [(TPCommandSet*)b valueForKey:@"argument"];
    return [first compare:second]==NSOrderedDescending;
  }];
  return sortedItems;
}


- (void) updateUI
{
  NSArray *files = [self commandsViewlistOfFiles:self];
  if (files == nil) {
    files = [NSArray array];
  }
  
  // remove any stale files
  NSMutableArray *filesToRemove = [NSMutableArray array];
  for (TPCommandSet *set in self.sets) {
    if ([files containsObject:set.file] == NO) {
      [filesToRemove addObject:set];
    }
  }
  [self.sets removeObjectsInArray:filesToRemove];
  
  // update our files
  for (FileEntity *file in files) {
    TPCommandSet *set = [self setForFile:file];
    if (set == nil) {
      NSArray *commands = [self commandsView:self newCommandsForFile:file];
      if (commands && [commands count] > 0) {
        set = [[TPCommandSet alloc] initWithFile:file commandArray:commands];
        [self.sets addObject:set];
        [set release];
      }
    } else {
      // update the commands
      NSArray *commands = [self commandsView:self newCommandsForFile:file];
      for (TPNewCommand *command in commands) {
        command.file = file;
      }
      set.commands = commands;
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

- (TPCommandSet*)setForFile:(FileEntity*)aFile
{
  for (TPCommandSet *set in self.sets) {
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


- (NSArray*) commandsViewlistOfFiles:(TPNewCommandsViewController *)aView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(commandsViewlistOfFiles:)]) {
    return [self.delegate commandsViewlistOfFiles:aView];
  }
  return [NSArray array];
}

- (NSArray*) commandsView:(TPNewCommandsViewController *)aView newCommandsForFile:(id)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(commandsView:newCommandsForFile:)]) {
    return [self.delegate commandsView:aView newCommandsForFile:file];
  }
  return nil;
}

- (void) commandsView:(TPNewCommandsViewController *)aView didSelectNewCommand:(id)aCommand
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(commandsView:didSelectNewCommand:)]) {
    [self.delegate commandsView:aView didSelectNewCommand:aCommand];
  }
}


@end
