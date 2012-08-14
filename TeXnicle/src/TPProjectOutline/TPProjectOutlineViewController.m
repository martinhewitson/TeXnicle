//
//  TPProjectOutlineViewControllerViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 11/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectOutlineViewController.h"
#import "TPSectionTemplate.h"

@interface TPProjectOutlineViewController ()

@property (unsafe_unretained) IBOutlet NSSlider *depthSlider;
@property (unsafe_unretained) IBOutlet NSButton *showDetailsButton;
@property (strong) IBOutlet NSOutlineView *outlineView;
@property (unsafe_unretained) TPSection *currentSection;

@end

@implementation TPProjectOutlineViewController

- (void) dealloc
{
  [self.outlineBuilder performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
  self.outlineView.delegate = nil;
  self.outlineView.dataSource = nil;
  self.outlineView = nil;
  self.delegate = nil;
}

- (id)initWithDelegate:(id<TPProjectOutlineDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPProjectOutlineViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    self.outlineBuilder = [TPOutlineBuilder outlineBuilderWithDelegate:self];
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self setupOutlineBuilder];
  
  NSInteger maxOutlineDepth = [[self.delegate maxOutlineDepth] integerValue];
  if (maxOutlineDepth >= [self.outlineBuilder.templates count]) {
    maxOutlineDepth = [self.outlineBuilder.templates count]-1;
  }
  [self.depthSlider setIntegerValue:maxOutlineDepth];
  self.outlineBuilder.depth = maxOutlineDepth;
  
  [self.outlineView setDoubleAction:@selector(jumpToSelectedResult)];
  [self.outlineView setTarget:self];
  
}

- (void) setupOutlineBuilder
{
  [self.outlineBuilder performSelectorOnMainThread:@selector(buildOutline) withObject:nil waitUntilDone:YES];
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
//  [self.outlineView reloadData];
  [self performSelector:@selector(expandAllSections:) withObject:self afterDelay:2];
  
  [self.outlineBuilder startTimer];  
}

- (void) stop
{
  [self.outlineBuilder stopTimer];
}

#pragma mark -
#pragma mark outline builder delegate

- (id) mainFile
{
  if (self.delegate) {
    return [self.delegate mainFile];
  }
  return nil;
}

- (NSString*) textForFile:(id)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(textForFile:)]) {
    return [self.delegate textForFile:aFile];
  }
  return nil;
}

- (IBAction)changeDetailsState:(id)sender
{
  [self.outlineView reloadData];
}

- (void) didComputeNewSections
{  
  if ([self.outlineBuilder.sections count] > 0) {
    
    id currentFile = nil;
    NSInteger location = NSNotFound;
    
    // find out the selection in the tex editor and
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentFile)] && [self.delegate respondsToSelector:@selector(locationInCurrentEditor)]) {
      currentFile = [self.delegate currentFile];
      location = [self.delegate locationInCurrentEditor];
    }
    
    TPSection *lastSection = nil;
    self.currentSection = nil;
    BOOL didReload = NO;
    for (TPSection *s in self.outlineBuilder.sections) {
      if (s.needsReload) {
        [self.outlineView reloadData];
        s.needsReload = NO;
        didReload = YES;
      }
      
      if (lastSection != nil &&
          lastSection.file == currentFile) {
        
        // if the current file matches, we need to check the index, otherwise we just take the last section
        if (s.file == currentFile) {
          
          if (location > lastSection.startIndex && location < s.startIndex) {
            self.currentSection = lastSection;
          }
          
        } else {
          if (location > lastSection.startIndex) {
            self.currentSection = lastSection;
          }
        }
        
        // edge case for the last section
        if (self.currentSection == nil && s == [self.outlineBuilder.sections lastObject]) {
          if (currentFile == s.file && location > s.startIndex) {
            self.currentSection = s;
          }
        }
      }
      
      lastSection = s;
    }
    
    
    // restore state
    if (didReload) {
      [self performSelector:@selector(restoreExpansionState) withObject:nil afterDelay:0];    
    }
    
    [self.outlineView setNeedsDisplay:YES];
  }
}

- (BOOL) shouldGenerateOutline
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    return [self.delegate shouldGenerateOutline];
  }

  return NO;
}

- (void) setOutlineDepth:(NSInteger)depth
{
  [self.depthSlider setIntegerValue:depth];
  self.outlineBuilder.depth = depth;
}

#pragma mark -
#pragma mark OutlineView delegate

- (void) restoreExpansionState
{
  for (TPSection *s in self.outlineBuilder.sections) {
    switch (s.expansionState) {
      case TPOutlineExpansionStateCollapse:
        [self.outlineView collapseItem:s];
        break;
      case TPOutlineExpansionStateExpanded:
        [self.outlineView expandItem:s];
        break;
      case TPOutlineExpansionStateUnknown:
        [self.outlineView expandItem:s];
        break;
      default:
        break;
    }
  }
}

- (void) outlineViewItemDidCollapse:(NSNotification *)notification
{
  TPSection *section = [[notification userInfo] valueForKey:@"NSObject"];
  if (section) {
    section.expansionState = TPOutlineExpansionStateCollapse;
  }
}

- (void) outlineViewItemDidExpand:(NSNotification *)notification
{
  TPSection *section = [[notification userInfo] valueForKey:@"NSObject"];
  if (section) {
    section.expansionState = TPOutlineExpansionStateExpanded;
  }
}


- (void) outlineViewSelectionDidChange:(NSNotification *)notification
{
  [self jumpToSelectedResult];
}

- (void) jumpToSelectedResult
{
  TPSection *section = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(highlightSearchResult:withRange:inFile:)]) {
    [self.delegate highlightSearchResult:section.name
                               withRange:NSMakeRange(section.startIndex+[section.type.name length]+2, [section.name length] )
                                  inFile:section.file];
    
  }
}

- (void) outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  if (self.currentSection == item) {
    NSMutableAttributedString *title = [[cell objectValue] mutableCopy];
    [title addAttribute:NSUnderlineStyleAttributeName value:@YES range:NSMakeRange(0, [title length])];
    [cell setObjectValue:title];
  }
}

#pragma mark -
#pragma mark OutlineView datasource

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  NSArray *children = [self.outlineBuilder childrenOfSection:item];
  return children[index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  NSArray *children = [self.outlineBuilder childrenOfSection:item];
  return [children count] > 0;
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  NSArray *children = [self.outlineBuilder childrenOfSection:item];
  return [children count];
}

- (id) outlineView:(NSOutlineView *)anOutlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  
  BOOL showDetails = NO;
  if ([self.showDetailsButton state] == NSOnState) {
    showDetails = YES;
  }
  
  if ([anOutlineView isRowSelected:[anOutlineView rowForItem:item]]) {
    if (showDetails) {
      return [item valueForKey:@"selectedDisplayNameWithDetails"];
    } else {
      return [item valueForKey:@"selectedDisplayName"];
    }
  } else {
    if (showDetails) {
      return [item valueForKey:@"displayNameWithDetails"];
    } else {
      return [item valueForKey:@"displayName"];
    }
  }
}

// Expand all sections
- (IBAction) expandAllSections:(id) sender
{
  for (TPSection *s in self.outlineBuilder.sections) {
    [self.outlineView expandItem:s];
  }
}

// Collapse all sections
- (IBAction) collapseAllSections:(id)sender
{
  for (TPSection *s in self.outlineBuilder.sections) {
    [self.outlineView collapseItem:s];
  }
}

- (IBAction) maxOutlineDepthChanged:(id)sender
{
  NSInteger maxOutlineDepth = [sender integerValue];
  [self.delegate didSetMaxOutlineDepthTo:maxOutlineDepth];
  self.outlineBuilder.depth = maxOutlineDepth;
  [self.outlineBuilder buildOutline];
  [self restoreExpansionState];
}



@end
