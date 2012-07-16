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

@end

@implementation TPProjectOutlineViewController

@synthesize outlineBuilder;
@synthesize delegate;
@synthesize outlineView;
@synthesize showDetailsButton;
@synthesize depthSlider;

- (void) dealloc
{
  self.outlineView.delegate = nil;
  self.outlineView.dataSource = nil;
  [self.outlineBuilder stopTimer];
  self.outlineBuilder = nil;
  [super dealloc];
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
  if (self.delegate) {
    return [self.delegate textForFile:aFile];
  }
  return nil;
}

- (void) didComputeNewSections
{ 
  [self.outlineView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (BOOL) shouldGenerateOutline
{
  if (self.delegate) {
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

#pragma mark -
#pragma mark OutlineView datasource

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  NSArray *children = [self.outlineBuilder childrenOfSection:item];
  return [children objectAtIndex:index];
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
  [self performSelector:@selector(expandAllSections:) withObject:self afterDelay:0.1];
}



@end
