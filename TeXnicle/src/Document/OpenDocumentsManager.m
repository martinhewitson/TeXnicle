//
//  OpenDocumentsManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "OpenDocumentsManager.h"

#import "FileEntity.h"
#import "externs.h"
#import "FileDocument.h"
#import "NSString+CharacterSize.h"
#import "DocWindowController.h"

@implementation OpenDocumentsManager

@synthesize currentDoc;
@synthesize isOpening;
@synthesize delegate;
@synthesize tabView;
@synthesize texEditorViewController;
@synthesize imageViewerController;
@synthesize imageViewContainer;

- (void) awakeFromNib
{
	openDocuments = [[NSMutableArray alloc] init];
	standaloneWindows = [[NSMutableArray alloc] init];
	
  //  @"Aqua" @"Unified" @"Adium" @"TPMetal"
	[tabBar setStyleNamed:@"TPMetal"];
	[tabBar setOrientation:PSMTabBarHorizontalOrientation];
	[tabBar setAutomaticallyAnimates:YES];
	[tabBar setCanCloseOnlyTab:YES];
	[tabBar setHideForSingleTab:NO];
	
	isOpening = NO;
	
//  [self enableImageView:NO];
//	[self disableTextView];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(handleDocumentRenamed:)
						 name:TPDocumentWasRenamed
					 object:nil];
	
	currentDoc = nil;
	
}

- (void) handleDocumentRenamed:(NSNotification*)aNote
{
//	NSLog(@"Document was renamed!");
//	NSLog(@"User info %@", [aNote userInfo]);
	id item = [[aNote userInfo] valueForKey:@"document"];
	[self refreshTabForDocument:item];
	[self.texEditorViewController.textView colorVisibleText];
}

- (void) dealloc
{
	[openDocuments release];
	[standaloneWindows release];
	[super dealloc];
}

- (void) refreshTabForDocument:(FileEntity*)aDoc
{
	NSArray *tabs = [tabView tabViewItems];
	for (NSTabViewItem *tab in tabs) {
		if ([tab identifier] == aDoc) {
			[tab setLabel:[aDoc valueForKey:@"shortName"]];
		}
	}	
}


- (void)closeAllTabs
{
  NSArray *openFiles = [NSArray arrayWithArray:openDocuments];
  for (FileEntity *file in openFiles) {
    NSTabViewItem *item = [tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:file]];
    [tabView removeTabViewItem:item];
  }
  [self performSelector:@selector(disableEditors) withObject:nil afterDelay:0];
}

- (void) disableEditors
{
  [self enableImageView:NO];
  [self disableTextView];
}

- (void) closeCurrentTab
{
  [tabView removeTabViewItem:[tabView selectedTabViewItem]];
}

- (void) removeDocument:(FileEntity*)aDoc
{
	if (![openDocuments containsObject:aDoc]) {
		return;
	}
	
  NSTabViewItem *item = [tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:aDoc]];
  [tabView removeTabViewItem:item];  
}


- (void) standaloneWindowForFile:(FileEntity*)aFile
{
	DocWindowController *newDoc = [[DocWindowController alloc] initWithFile:aFile document:(id)delegate];
	[newDoc showWindow:self];
	[[newDoc window] makeKeyAndOrderFront:self];
	[standaloneWindows addObject:newDoc];
	[newDoc release];
}

- (NSArray*)standaloneWindows
{
  return standaloneWindows;
}

- (void) addDocument:(FileEntity*)aDoc
{	
	if (!openDocuments)
		return;
	
	if (!standaloneWindows)
		return;
	
//	NSLog(@"Managing %ld docs", [openDocuments count]);
//	NSLog(@"Opening %@", [aDoc valueForKey:@"name"]);

	NSInteger fileIndex = [self indexOfDocumentWithFile:aDoc];
//	NSLog(@"Index %d", fileIndex);
	if (fileIndex < 0) {
		if (![aDoc document]) {
			return;
		}
    if (![[aDoc document] textStorage]) {
			return;
		}
		if (![aDoc existsOnDisk]) {
			return;
		}
		
		// load this file from disk
		[aDoc reloadFromDisk];
		[openDocuments addObject:aDoc];
		NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:aDoc];
		[newItem setLabel:[aDoc valueForKey:@"shortName"]];    
		[tabView addTabViewItem:newItem];
		[tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
		[newItem release];
	}	else {
		NSTabViewItem *tab = [tabView tabViewItemAtIndex:fileIndex];
		[tabView selectTabViewItem:tab];
	}
	
  if ([aDoc isText]) {
    [self.texEditorViewController.textView setNeedsDisplay:YES];
  }
}

- (void)setupViewerForDoc:(FileEntity*)aDoc
{
  if ([aDoc isImage]) {
    [self enableImageView:YES];      
  } else if ([[aDoc valueForKey:@"isText"] boolValue]) {
    [self enableTextView];
    [self enableImageView:NO];
  } else {
    [self enableImageView:YES];
  }
}

- (void)updateDoc
{
  if ([currentDoc isImage]) {
    [self enableImageView:YES];
  } else if ([currentDoc valueForKey:@"isText"]) {
    id doc = [currentDoc document];		
    if (doc) {
      if ([doc isKindOfClass:[FileDocument class]]) {
        NSTextContainer *textContainer = [doc textContainer];
        if (textContainer) {
          //				NSLog(@"TextView: %@", textView);
//          NSLog(@"Setting up text container.. %@", textContainer);
          // apply user preferences to textContainer size
          int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
          int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
          if (wrapStyle == TPSoftWrap) {
            CGFloat scale = [NSString averageCharacterWidthForCurrentFont];
            [textContainer setContainerSize:NSMakeSize(scale*wrapAt, 1e7)];
          }	else if (wrapStyle == TPNoWrap) {
            [textContainer setContainerSize:NSMakeSize(1e7, 1e7)];
          } else {
            // set large size - hard wrap is handled in the textview
            [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
          }
          [self.texEditorViewController.textView stopObservingTextStorage];
//          [self.texEditorViewController.textView replaceTextContainer:textContainer];
          [textContainer setTextView:self.texEditorViewController.textView];
          [self.texEditorViewController.textView observeTextStorage];
          [self.texEditorViewController.textView setNeedsDisplay:YES];
          [self enableTextView];
          [self.texEditorViewController.textView setUpRuler];
          [self.texEditorViewController.textView setNeedsDisplay:YES];
          [self.texEditorViewController.textView applyFontAndColor];
          [self selectTabForFile:currentDoc];
          [self.texEditorViewController.textView performSelector:@selector(colorVisibleText) 
                                                      withObject:nil 
                                                      afterDelay:0];
          [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument)
                                                      withObject:nil
                                                      afterDelay:0.5];
//          NSLog(@"Did set text container");
          [self enableImageView:NO];
        }
      } // end doc document is correct class
    } // end doc is nil
  } else {
    [self enableImageView:YES];
  }
}


- (void) selectTabForFile:(FileEntity*)aFile
{
  if (aFile == nil) {
    return;
  }
	NSInteger index = [self indexOfDocumentWithFile:aFile];
  if (index < 0) {
    return;
  }
	NSTabViewItem *item = [tabView tabViewItemAtIndex:index];
	[tabView selectTabViewItem:item];
}

- (NSInteger) indexOfDocumentWithFile:(FileEntity*)aFile
{
	for (FileEntity *oDoc in openDocuments) {
		if (oDoc == aFile) {
			return [openDocuments indexOfObject:oDoc];
		}
	}

	return -1;
}

- (void) setCurrentDoc:(FileEntity *)aDoc
{
	if (currentDoc == aDoc) 
		return;
	
//	NSLog(@"Switching to document %@", [aDoc valueForKey:@"name"]);
	currentDoc = aDoc;
  
  // increase active state for this doc
  [currentDoc increaseActiveCount];
  
  // and decrease for all others
  for (FileEntity *doc in openDocuments) {
    if (doc != currentDoc) {
      [doc decreaseActiveCount];
    }
  }
		
	[self updateDoc];
  // tell project tree to select this item
  [self.delegate openDocumentsManager:self didSelectFile:aDoc];
}

- (FileEntity*) currentDoc
{
	return currentDoc;
}

- (NSInteger) count
{
	return [openDocuments count];
}

#pragma mark -
#pragma mark  TabView Delegate


- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self saveCursorAndScrollPosition];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self setCurrentDoc:[tabViewItem identifier]];
	[self setCursorAndScrollPositionForCurrentDoc];
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem;
{
//	NSLog(@"Should close tab for %@", [currentDoc name]);
	[self saveCursorAndScrollPosition];
	return YES;
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
	
	// commit the changes to the entity's content
	FileEntity *file = [tabViewItem identifier];
	[file updateFromTextStorage];
	[openDocuments removeObject:file];
  [file setValue:[NSNumber numberWithBool:NO] forKey:@"wasOpen"];
//	NSLog(@"Removed %@", [file valueForKey:@"name"]);
	
	
	// Set another file if this is the selected one and if possible
  if (file == currentDoc) {
    FileEntity *nextFile = [openDocuments lastObject];
    //	NSLog(@"Next file %@", [nextFile valueForKey:@"name"]);
    if (nextFile && nextFile != file) {
      [self setCurrentDoc:nextFile];
    } else {
      [file.project setNilValueForKey:@"selected"];
      [self setCurrentDoc:nil];
      [self enableImageView:NO];
      [self disableTextView];
    }
  }	
	
	//[self removeObject:[tabViewItem identifier]];
}

- (void) setCursorAndScrollPositionForCurrentDoc
{
//	if (isOpening)
//		return;
	if ([currentDoc isText]) {
    [[self.texEditorViewController.textView layoutManager] ensureLayoutForTextContainer:[self.texEditorViewController.textView textContainer]];
    
    // reset cursor position
    NSString *sr = [currentDoc valueForKey:@"cursor"];
    if (sr) {
      if (![sr isEqual:@""]) {
        NSRange range = NSRangeFromString(sr);
        if (range.location + range.length < [[self.texEditorViewController.textView string] length]) {
          //				NSLog(@"Trying to set range %@", NSStringFromRange(range));
          //        [textView performSelector:@selector(selectRange:) withObject:[NSValue valueWithRange:range] afterDelay:0.0];
          [self.texEditorViewController.textView setSelectedRange:range];
        }
      }
    }
    // reset the visible rect
    sr = [currentDoc valueForKey:@"visibleRect"];
    if (sr) {
      if (![sr isEqual:@""]) {
        NSRect r = NSRectFromString(sr);
        //      NSLog(@"Setting visible rect: %@", NSStringFromRect(r));
        //      [textView performSelector:@selector(scrollToRect:) withObject:[NSValue valueWithRect:r] afterDelay:0.0];
        [self.texEditorViewController.textView scrollRectToVisible:r];
      }
    }
  }
  
}

- (void) saveCursorAndScrollPosition
{	
//	NSLog(@"Saving cursor and scroll position");
	if (isOpening)
		return;
	
	if (!currentDoc)
		return;

  if ([currentDoc isText]) {
    NSRect vr = [self.texEditorViewController.textView visibleRect];
    //	NSLog(@"Visible rect: %@", NSStringFromRect(vr));
    if (!NSEqualSizes(vr.size, NSZeroSize)) {
      [currentDoc setPrimitiveValue:NSStringFromRect(vr) forKey:@"visibleRect"];
      // store cursor position
      NSRange r = [self.texEditorViewController.textView selectedRange];
      [currentDoc setPrimitiveValue:NSStringFromRange(r) forKey:@"cursor"];
    }
  }
}


- (void) commitStatus
{
	for (FileEntity *file in openDocuments) {
		[file setValue:[NSNumber numberWithBool:YES] forKey:@"wasOpen"];
	}
	
	for (DocWindowController *newDoc in standaloneWindows) {
    [[newDoc window] setDocumentEdited:NO];
  }
  
//	NSLog(@"%@", [[projectDocument project] valueForKey:@"selected"]);
	
	if (currentDoc) {
		ProjectEntity *project = [currentDoc valueForKey:@"project"];
		if (project) {
			[project setValue:currentDoc forKey:@"selected"];
		}
	} else {
		[[delegate project] setNilValueForKey:@"selected"];
	}
	
	[self saveCursorAndScrollPosition];
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
	return YES;
}

- (void) disableImageView
{
  [self enableImageView:NO];
}

- (void)enableImageView:(BOOL)state
{
  if (state) {
    if (![[self.imageViewContainer subviews] containsObject:self.imageViewerController.view]) {
      [self.imageViewContainer addSubview:self.imageViewerController.view];
    }        
    if ([currentDoc isImage]) {
      NSImage *image = [[[NSImage alloc] initWithContentsOfFile:[currentDoc pathOnDisk]] autorelease];
      [self.imageViewerController setImage:image atPath:[currentDoc pathOnDisk]];
      [self.imageViewerController enable];
    } else {
      NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:[currentDoc extension]];
      [self.imageViewerController setImage:image atPath:[currentDoc pathOnDisk]];
      [self.imageViewerController enable];
    }
    [self.texEditorViewController hide];
    [tabBackground setHidden:NO];
    [tabView setHidden:NO];
    [tabBar setHidden:NO];
  } else {
    [self.texEditorViewController enableEditor];
    [self.imageViewerController.view removeFromSuperview];
    [self.imageViewerController disable];
  }
}

- (void) disableTextView
{
  [self.texEditorViewController disableEditor];
	[tabView setHidden:YES];
	[tabBar setHidden:YES];
	[tabBackground setHidden:YES];
}

- (void) enableTextView
{
  [tabBackground setHidden:NO];
	[tabView setHidden:NO];
	[tabBar setHidden:NO];
  [self.texEditorViewController enableEditor];
  [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument)];
}


#pragma mark -
#pragma mark Delegate methods
				

-(ProjectEntity*)project
{
  if ([self.delegate respondsToSelector:@selector(project)]) {
    return [self.delegate performSelector:@selector(project)];
  }
  return nil;
}


@end
