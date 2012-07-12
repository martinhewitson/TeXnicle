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
  [self.outlineBuilder buildOutline];
  [self performSelector:@selector(expandAllSections:) withObject:self afterDelay:0];
  
  [self.outlineBuilder startTimer];
  
  NSInteger maxOutlineDepth = [[self.delegate maxOutlineDepth] integerValue];
  if (maxOutlineDepth >= [self.outlineBuilder.templates count]) {
    maxOutlineDepth = [self.outlineBuilder.templates count]-1;
  }
  [self.depthSlider setIntegerValue:maxOutlineDepth];
  self.outlineBuilder.depth = maxOutlineDepth;
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
  if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    
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
  } else if ([[tableColumn identifier] isEqualToString:@"FileColumn"]) {
    NSString *name = [[item valueForKey:@"file"] valueForKey:@"name"];
    NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:name] autorelease];     
    NSColor *color;
    if ([anOutlineView isRowSelected:[anOutlineView rowForItem:item]]) {
      color = [NSColor alternateSelectedControlTextColor];
    } else {
      color = [NSColor darkGrayColor];    
    }
    [att addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [att length])];
    return att;
  } else if ([[tableColumn identifier] isEqualToString:@"TypeColumn"]) {
    NSString *name = [[item valueForKey:@"type"] valueForKey:@"name"];
    NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:name] autorelease];     
    
    NSColor *color;
    if ([anOutlineView isRowSelected:[anOutlineView rowForItem:item]]) {
      color = [NSColor alternateSelectedControlTextColor];
    } else {
      color = [NSColor colorWithDeviceRed:0.2 green:0.6 blue:0.2 alpha:1.0];    
    }
    [att addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [att length])];
    
    return att;
  } else {
    return nil;
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
  [self performSelector:@selector(expandAllSections:) withObject:self afterDelay:0];
}



@end
