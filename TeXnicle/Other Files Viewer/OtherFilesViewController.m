//
//  OtherFilesViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "OtherFilesViewController.h"
#import "ImageAndTextCell.h"

@interface OtherFilesViewController ()

@end

@implementation OtherFilesViewController

@synthesize delegate;
@synthesize root;
@synthesize tree;
@synthesize outlineView;

- (id)initWithURL:(NSURL*)aURL delegate:(id<OtherFilesViewControllerDelegate>)aDelegate
{
  self = [super initWithNibName:@"OtherFilesViewController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
    self.root = aURL;
    [self populateTree];
  }
  
  return self;
}


- (void) awakeFromNib
{
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:YES];
	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[tableColumn setDataCell:imageAndTextCell];

}

- (void) reloadData
{
  [self.outlineView reloadData];
}


- (void) populateTree
{
  self.tree = [TPSourceDirectory directoryWithParent:nil path:self.root delegate:self];
}

#pragma mark -
#pragma mark TPSourceDirectory delegate

- (BOOL) sourceDirectory:(TPSourceDirectory *)aDirectory shouldIncludeChildItemAtPath:(NSURL *)url
{
  // we ask our delegate if they want this file added to the list
  if (self.delegate && [self.delegate respondsToSelector:@selector(otherFilesViewer:shouldIncludeItemAtPath:)]) {
    return [self.delegate otherFilesViewer:self shouldIncludeItemAtPath:url];
  }
  
  return NO;
}

#pragma mark -
#pragma mark NSOutlineView Data Source

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [self.tree.children count];
  }
  
  if ([item isMemberOfClass:[TPSourceFile class]]) {
    return 0;
  }
  
  return [[item valueForKey:@"children"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if (item == nil) {
		return nil;
	}	
  return [item valueForKey:@"name"];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item == nil) {
		return (self.tree.children)[index];
	}
	if ([item isKindOfClass:[TPSourceFile class]]) {
    return nil;
	}
  id child = [item valueForKey:@"children"][index];
	return child;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isMemberOfClass:[TPSourceFile class]]) {
    return NO;
  }
  
	if ([[item valueForKey:@"children"] count]>0) {
		return YES;
	}
  
	return NO;
}

#pragma mark -
#pragma mark NSOutline View Delegate

- (void)outlineView:(NSOutlineView *)anOutlineView 
		willDisplayCell:(id)cell 
		 forTableColumn:(NSTableColumn *)tableColumn 
							 item:(id)item
{
  
	if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    CGFloat imageSize = 20.0;
    [anOutlineView setRowHeight:imageSize+2.0];
        
    [cell setImageSize:imageSize];
    [cell setTextColor:[NSColor blackColor]];
		
    if ([item isMemberOfClass:[TPSourceDirectory class]]) {
      if ([anOutlineView isItemExpanded:item]) {
        NSString *folderFileType = NSFileTypeForHFSTypeCode(kOpenFolderIcon);
        [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
      } else {
        NSString *folderFileType = NSFileTypeForHFSTypeCode(kGenericFolderIcon);
        [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
      }
    } else if ([item isMemberOfClass:[TPSourceFile class]]) {
      
      NSString *ext = [[item valueForKey:@"path"] pathExtension];
      if (!ext)
        ext = @"";
      
      NSString *title;
      title = [item valueForKey:@"name"];
      [cell setTitle:title];
      
      NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:ext];				
      [cell setImage:icon];						
    }
  }  
	
}


@end
