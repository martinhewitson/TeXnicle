//
//  TPTeXLogViewController.m
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPTeXLogViewController.h"
#import "TPLogFileItem.h"
#import "ImageAndTextCell.h"
#import "MHStrokedFiledView.h"

NSString * const TPTeXLogViewDidSelectItemNotification = @"TPTeXLogViewDidSelectItemNotification";
NSString * const TPLogfileAvailableNotification = @"TPLogfileAvailableNotification";

@interface TPTeXLogViewController ()

@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSSegmentedControl *selectionControl;
@property (assign) IBOutlet MHStrokedFiledView *toolbarView;
@property (assign) IBOutlet HHValidatedButton *openLogButton;

@property (assign) BOOL showInfos;
@property (assign) BOOL showWarnings;
@property (assign) BOOL showErrors;

@end

@implementation TPTeXLogViewController

- (id) initWithParsedLog:(TPParsedLog*)log delegate:(id<TPTeXLogViewDelegate>)aDelegate
{
  self = [self initWithParsedLog:log];
  if (self) {
    self.delegate = aDelegate;
    self.showInfos = YES;
    self.showWarnings = YES;
    self.showErrors = YES;
  }
  
  return self;
}



- (id) initWithParsedLog:(TPParsedLog*)aLog
{
  self = [super initWithNibName:@"TPTeXLogViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.log = aLog;
  }
  
  return self;
}

- (void) awakeFromNib
{
  NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:NO];
  [imageAndTextCell setLineBreakMode:NSLineBreakByTruncatingTail];
	[tableColumn setDataCell:imageAndTextCell];
  
  NSColor *color1 = [NSColor colorWithDeviceRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
  [self.toolbarView setFillColor:color1];
  
  [self.outlineView setDoubleAction:@selector(handleOutlineViewDoubleClick)];
  [self.outlineView setTarget:self];
  
  NSImage *image = nil;

  // info 0
  image = [NSImage imageNamed:@"log_info_template.icns"];
  [image setTemplate:YES];
  [self.selectionControl setImage:image forSegment:0];

  // warning 1
  image = [NSImage imageNamed:@"log_warning_template.icns"];
  [image setTemplate:YES];
  [self.selectionControl setImage:image forSegment:1];

  // error 2
  image = [NSImage imageNamed:@"log_error_template.icns"];
  [image setTemplate:YES];
  [self.selectionControl setImage:image forSegment:2];
  

  [self updateSelectionControls];
}

- (void) updateSelectionControls
{
  [self.selectionControl setSelected:self.showInfos forSegment:0];
  [self.selectionControl setSelected:self.showWarnings forSegment:1];
  [self.selectionControl setSelected:self.showErrors forSegment:2];
  [self reload];
}

- (IBAction)openLog:(id)sender
{
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:self.log.logpath]) {
    [[NSWorkspace sharedWorkspace] openFile:self.log.logpath];
  } else {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Log file doesn't exist"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"The log file doesn't exist at %@. Maybe you have automatic deleting of auxiliary files activated?", self.log.logpath];
    [alert runModal];
  }
}

- (IBAction)changeSelection:(id)sender
{
  self.showInfos = [self.selectionControl isSelectedForSegment:0];
  self.showWarnings = [self.selectionControl isSelectedForSegment:1];
  self.showErrors = [self.selectionControl isSelectedForSegment:2];
  [self reload];
}

- (void) handleOutlineViewDoubleClick
{
  id item = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
  if ([item isKindOfClass:[TPLogFileItem class]]) {
    if ([self.outlineView isItemExpanded:item]) {
      [self.outlineView.animator collapseItem:item];
    } else {
      [self.outlineView.animator expandItem:item];
    }
  } else {
    [self texlogview:self didSelectLogItem:item];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSDictionary *dict = @{@"item" : item};
    [nc postNotificationName:TPTeXLogViewDidSelectItemNotification object:self userInfo:dict];
  }
  
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.openLogButton) {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.log.logpath]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  return NO;
}

#pragma mark -
#pragma make NSOutlineView Data Source

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  if ([item isKindOfClass:[TPLogFileItem class]]) {
    return YES;
  }
  
  return NO;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isKindOfClass:[TPLogFileItem class]]) {
    TPLogFileItem *litem = (TPLogFileItem*)item;
    return [self itemsForFile:litem] > 0;
  }
  
  return NO;
}

- (NSArray*)filesToInclude
{
  NSMutableArray *files = [NSMutableArray array];
  for (TPLogFileItem *lf in self.log.logfiles) {
    if ([self texlogview:self shouldShowEntriesForFile:lf.fullpath]) {
      if ([[self itemsForFile:lf] count] > 0) {
        [files addObject:lf];
      }
    }
  }
  
  return files;
}

- (NSArray*)itemsForFile:(TPLogFileItem*)file
{
  NSMutableArray *items = [NSMutableArray array];
  if (self.showInfos) {
    [items addObjectsFromArray:[file infos]];
  }
  if (self.showWarnings) {
    [items addObjectsFromArray:[file warnings]];
  }
  if (self.showErrors) {
    [items addObjectsFromArray:[file errors]];
  }
  
  return items;
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [[self filesToInclude] count];
  }
  
  if ([item isKindOfClass:[TPLogFileItem class]]) {
    TPLogFileItem *litem = (TPLogFileItem*)item;
    return [[self itemsForFile:litem] count];
  }
  
  return 0;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    NSArray *logfiles = [self filesToInclude];
    if (index >= 0 && index < [logfiles count]) {
      return logfiles[index];
    }
  }
  
  if ([item isKindOfClass:[TPLogFileItem class]]) {
    TPLogFileItem *litem = (TPLogFileItem*)item;
    NSArray *items = [self itemsForFile:litem];
    if (index >= 0 && index < [items count]) {
      return items[index];
    }
  }
  
  return nil;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if ([self.outlineView isRowSelected:[self.outlineView rowForItem:item]]) {
    return [item valueForKey:@"selectedAttributedString"];
  } else {
    return [item valueForKey:@"attributedString"];
  }
  
  return nil;
}

- (void) reload
{
  [self.outlineView reloadData];
  for (id item in [self filesToInclude]) {
    [self.outlineView expandItem:item];
  }
}

- (void) setLog:(TPParsedLog *)log
{
  _log = log;
  [log generateLogTree];
  [self reload];
}

- (void) outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  
  if (anOutlineView == self.outlineView) {
    if ([cell isMemberOfClass:[ImageAndTextCell class]]) {
      if ([item isKindOfClass:[TPLogItem class]]) {
        TPLogItem *litem = (TPLogItem*)item;
        if (litem.type == TPLogInfo) {
          [cell setImage:[NSImage imageNamed:@"log_info"]];
        } else if (litem.type == TPLogWarning) {
          [cell setImage:[NSImage imageNamed:@"log_warning"]];
        } else if (litem.type == TPLogError) {
          [cell setImage:[NSImage imageNamed:@"log_error"]];
        } else {
          [cell setImage:[NSImage imageNamed:NSImageNameCaution]];
        }
      } else if ([item isKindOfClass:[TPLogFileItem class]]) {
        TPLogFileItem *litem = (TPLogFileItem*)item;
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:[litem.filename pathExtension]];
        [cell setImage:icon];
      }
    }
  }
}

#pragma mark -
#pragma mark Delegate

- (BOOL) texlogview:(TPTeXLogViewController *)logview shouldShowEntriesForFile:(NSString *)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texlogview:shouldShowEntriesForFile:)]) {
    return [self.delegate texlogview:self shouldShowEntriesForFile:aFile];
  }
  
  return YES;
}

- (void)texlogview:(TPTeXLogViewController*)logview didSelectLogItem:(TPLogItem*)aLog
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texlogview:didSelectLogItem:)]) {
    return [self.delegate texlogview:self didSelectLogItem:aLog];
  }
}

@end
