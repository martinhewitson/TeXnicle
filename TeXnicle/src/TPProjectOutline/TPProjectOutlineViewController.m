//
//  TPProjectOutlineViewControllerViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 11/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectOutlineViewController.h"
#import "TPSectionTemplate.h"
#import "ImageAndTextCell.h"
#import "TPDocumentSectionManager.h"
#import "TPThemeManager.h"
#import "TPFileMetadata.h"
#import "externs.h"

@interface TPProjectOutlineViewController ()

@property (unsafe_unretained) IBOutlet NSSlider *depthSlider;
@property (unsafe_unretained) IBOutlet NSButton *showDetailsButton;
@property (strong) IBOutlet NSOutlineView *outlineView;
@property (unsafe_unretained) TPSection *currentSection;

@property (strong) NSMutableArray *sections;
@property (weak) IBOutlet NSButton *focusButton;

@end

@implementation TPProjectOutlineViewController

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
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

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  self.outlineView.delegate = nil;
  self.outlineView.dataSource = nil;
  self.outlineView = nil;
  self.delegate = nil;
  self.showDetailsButton = nil;
  self.currentSection = nil;
  
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
  [self.view removeFromSuperview];
  self.delegate = nil;
  [self.outlineBuilder tearDown];
  self.outlineBuilder = nil;
}

- (void) awakeFromNib
{
  // apply our custom ImageAndTextCell for rendering the first column's cells
//	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
//	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
//	[imageAndTextCell setEditable:NO];
//	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
//	[tableColumn setDataCell:imageAndTextCell];

  
  [self setupOutlineBuilder];
  TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  
  NSInteger maxOutlineDepth = [[self.delegate maxOutlineDepth] integerValue];
  if (maxOutlineDepth >= [sm.templates count]) {
    maxOutlineDepth = [sm.templates count]-1;
  }
  [self.depthSlider setIntegerValue:maxOutlineDepth];
  self.outlineBuilder.depth = maxOutlineDepth;
  
  [self.outlineView setDoubleAction:@selector(jumpToSelectedResult)];
  [self.outlineView setTarget:self];
  
  [self setupOutlineView];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleThemeDidChangeNotification:)
             name:TPThemeSelectionChangedNotification
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleNavigatorFontChangedNotification:)
             name:TPThemeNavigatorFontChangedNotification
           object:nil];
  
  
  // figure out if we are in a standalone editor
  id mainfile = [self mainFile];
  if (mainfile && [mainfile isKindOfClass:[TPFileMetadata class]]) {
    // then this is a project editor
    [self.focusButton setHidden:NO];
  } else {
    // then this is a standalone editor
    [self.focusButton setHidden:YES];
  }
}

- (void) handleNavigatorFontChangedNotification:(NSNotification*)aNote
{
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"A Big Test String" attributes:@{NSFontAttributeName : font}];
  NSSize s = [att size];
  [self.outlineView setRowHeight:s.height];
  //NSLog(@"Font changed");
  [self.outlineView reloadData];
  [self.outlineView setNeedsDisplay:YES];
}

- (void) handleThemeDidChangeNotification:(NSNotification*)aNote
{
  [self setupOutlineView];
}

- (void) setupOutlineView
{
  
  TPTheme *theme = [TPThemeManager currentTheme];
  [self.outlineView setBackgroundColor:theme.outlineBackgroundColor];
  
}

- (void) setupOutlineBuilder
{
  [self.outlineBuilder startTimer];  
}

- (void) start
{
  [self.outlineBuilder startTimer];
}

- (void) stop
{
  [self.outlineBuilder stopTimer];
}

- (IBAction)changeFocusState:(id)sender
{
  [self expandAllSections:sender];
}

#pragma mark -
#pragma mark outline builder delegate


- (BOOL) shouldFocusOnFile
{
  return [self.focusButton state] == NSOnState;
}

- (NSArray*) allMetadataFiles
{
  if (self.delegate) {
    return [self.delegate allMetadataFiles];
  }
  return @[];
}

- (id) mainFile
{
  if (self.delegate) {
    return [self.delegate mainFile];
  }
  return nil;
}

- (id) focusFile
{
  if (self.delegate) {
    return [self.delegate focusFile];
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
  self.sections = [NSMutableArray array];
  for (TPSection *s in self.outlineBuilder.sections) {
    [self.sections addObject:s];
  }  
  
  //  NSLog(@"Received sections %@", self.sections);
  
  if ([self.sections count] > 0) {
    
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
    for (TPSection *s in self.sections) {
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
        if (self.currentSection == nil && s == [self.sections lastObject]) {
          if (currentFile == s.file && location > s.startIndex) {
            self.currentSection = s;
          }
        }
      }
      
      lastSection = s;
    }
    
    [self.outlineView reloadData];
        
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
  NSArray *sections = self.sections;
  for (TPSection *s in sections) {
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
    NSRange range = NSMakeRange(section.startIndex, [section.name length]);
    [self.delegate highlightSearchResult:section.name
                               withRange:range
                                  inFile:section.file];
    
    if ([self.delegate respondsToSelector:@selector(syncPDFToRange:)]) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      if ([[defaults valueForKey:TPSyncPDFAfterOutlineSelection] boolValue]) {
        [self.delegate syncPDFToRange:range];
      }
    }
    
  }
}

- (void) outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  TPTheme *theme = [TPThemeManager currentTheme];
  [cell setBackgroundColor:theme.outlineBackgroundColor];
  
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
  NSArray *children = [self childrenOfSection:item];
  //NSLog(@"Children of %@: %@", item, children);
  return children[index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  NSArray *children = [self childrenOfSection:item];
  return [children count] > 0;
}

- (NSArray*) childrenOfSection:(id)parent
{
  NSMutableArray *children = [NSMutableArray array];
  NSArray *sections = self.sections;
  for (TPSection *s in sections) {
    if (s.parent == parent) {
      [children addObject:s];
    }
  }  
  
  return [NSArray arrayWithArray:children];
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  NSArray *children = [self childrenOfSection:item];
  //NSLog(@"Number of children of %@: %ld", item, [children count]);
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
  NSArray *sections = self.sections;
  for (TPSection *s in sections) {
    [self.outlineView expandItem:s];
  }
}

// Collapse all sections
- (IBAction) collapseAllSections:(id)sender
{
  NSArray *sections = self.sections;
  for (TPSection *s in sections) {
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
