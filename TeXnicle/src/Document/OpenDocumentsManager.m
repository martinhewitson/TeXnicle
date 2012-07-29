//
//  OpenDocumentsManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "OpenDocumentsManager.h"

#import "FileEntity.h"
#import "externs.h"
#import "FileDocument.h"
#import "NSString+CharacterSize.h"
#import "DocWindowController.h"

NSString * const TPOpenDocumentsDidChangeFileNotification = @"TPOpenDocumentsDidChangeFileNotification";
NSString * const TPOpenDocumentsDidAddFileNotification = @"TPOpenDocumentsDidAddFileNotification";

@implementation OpenDocumentsManager

@synthesize currentDoc;
@synthesize isOpening;
@synthesize delegate;
@synthesize tabView;
@synthesize texEditorViewController;
@synthesize imageViewerController;
@synthesize imageViewContainer;
@synthesize navigationButtonsView;

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

- (void) cleanUp
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
  self.tabView.delegate = nil;
  tabBar.delegate = nil;
  tabBar.partnerView = nil;
}

- (void) dealloc
{
  [self cleanUp];
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
}

- (NSArray*)standaloneWindows
{
  return standaloneWindows;
}

- (void) addAndSelectDocument:(FileEntity*)aDoc
{
  [self addDocument:aDoc select:YES];
}

- (void) addDocument:(FileEntity*)aDoc select:(BOOL)selectTab
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
		
    // if the file has a document, we don't need to reload from disk
    if ([aDoc document] == nil) {
      // load this file from disk
      [aDoc reloadFromDisk];
		}
    
    [openDocuments addObject:aDoc];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:currentDoc, @"file", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TPOpenDocumentsDidAddFileNotification
                                                        object:self
                                                      userInfo:dictionary];
    
		NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:aDoc];
		[newItem setLabel:[aDoc valueForKey:@"shortName"]];    
    [tabView addTabViewItem:newItem];
    if (selectTab) {
      [tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
    }
    
    
	}	else {
    NSInteger index = [tabView indexOfTabViewItemWithIdentifier:aDoc];
		NSTabViewItem *tab = [tabView tabViewItemAtIndex:index];
		[tabView selectTabViewItem:tab];
	}
	
  if ([[aDoc isText] boolValue]) {
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
//  NSLog(@"Update doc for doc %@: is text? %d", currentDoc, [[currentDoc valueForKey:@"isText"] boolValue]);
  
  if ([currentDoc isImage]) {
    [self enableImageView:YES];
  } else if ([[currentDoc valueForKey:@"isText"] boolValue]) {
    id doc = [currentDoc document];		
    if (doc) {
      if ([doc isKindOfClass:[FileDocument class]]) {
//        NSLog(@"Setting doc %@", doc);
        NSTextContainer *textContainer = [doc textContainer];
        if (textContainer) {
//          NSLog(@"TextView: %@", self.texEditorViewController.textView);
//          NSLog(@"Setting up text container.. %@", textContainer);
          // apply user preferences to textContainer size
          int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
          int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
          if (wrapStyle == TPSoftWrap) {
            CGFloat scale = [NSString averageCharacterWidthForCurrentFont];
            [textContainer setContainerSize:NSMakeSize(scale*wrapAt, LargeTextHeight)];
          }	else if (wrapStyle == TPNoWrap) {
            [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
          } else {
            // set large size - hard wrap is handled in the textview
            [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
          }
          [self.texEditorViewController.textView stopObservingTextStorage];
//          [self.texEditorViewController.textView replaceTextContainer:textContainer];
          
          // clear the text view from all other document text containers
          for (FileEntity *file in openDocuments) {
            if (file != currentDoc) {
              if ([[file valueForKey:@"isText"] boolValue]) {
                id filedoc = [file document];		
                if (filedoc) {
                  if ([filedoc isKindOfClass:[FileDocument class]]) {
//                    NSLog(@"Clearing textview from %@", [file name]);
                    NSTextContainer *tc = [filedoc textContainer];
                    [tc setTextView:nil];
//                    NSLog(@"  Container %@, Textview %@", tc, [tc textView]);
                  }
                }
              }
            }
          }
          
          [textContainer setTextView:self.texEditorViewController.textView];
//          NSLog(@"Set textview for %@", [currentDoc name]);
//          NSLog(@"  Container %@, Textview %@", textContainer, [textContainer textView]);
          [self.texEditorViewController.textView observeTextStorage];
          [self enableTextView];
          [self.texEditorViewController.textView setUpRuler];
          [self.texEditorViewController.textView setNeedsDisplay:YES];
          if ([[self.tabView selectedTabViewItem] identifier] != currentDoc) {
            [self selectTabForFile:currentDoc];
          }
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
  if (![aFile existsOnDisk]) {
    return;
  }
  if (aFile == nil) {
    return;
  }
	NSInteger index = [tabView indexOfTabViewItemWithIdentifier:aFile];
  if (index < 0) {
    return;
  }
	NSTabViewItem *item = [tabView tabViewItemAtIndex:index];
  if ([tabView selectedTabViewItem] != item) {
    [tabView selectTabViewItem:item];
  }
}

- (FileEntity*)fileAtIndex:(NSInteger*)index
{
  return [openDocuments objectAtIndex:index];
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
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:currentDoc, @"file", nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPOpenDocumentsDidChangeFileNotification
                                                      object:self
                                                    userInfo:dictionary];
  
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
  if (currentDoc != [tabViewItem identifier]) {
    [self setCurrentDoc:[tabViewItem identifier]];
    [self setCursorAndScrollPositionForCurrentDoc];
  }
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
  [file setValue:[NSNumber numberWithInteger:-1] forKey:@"wasOpen"];
//  [file setValue:[NSNumber numberWithBool:NO] forKey:@"wasOpen"];
//	NSLog(@"Removed %@", [file valueForKey:@"name"]);
	
	
	// Set another file if this is the selected one and if possible
  if (file == currentDoc) {
    NSTabViewItem *tabItem = [[tabView tabViewItems] lastObject];
    
    FileEntity *nextFile = [tabItem identifier];
    //	NSLog(@"Next file %@", [nextFile valueForKey:@"name"]);
    if (nextFile && nextFile != file) {
      [self setCurrentDoc:nextFile];
    } else {
      file.project.selected = nil;
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
	if ([[currentDoc isText] boolValue]) {
    [[self.texEditorViewController.textView layoutManager] ensureLayoutForTextContainer:[self.texEditorViewController.textView textContainer]];
    
    // reset cursor position
    NSString *sr = [currentDoc valueForKey:@"cursor"];
    if (sr) {
      if (![sr isEqual:@""]) {
        NSRange range = NSRangeFromString(sr);
        if (range.location + range.length < [[self.texEditorViewController.textView string] length]) {
          //				NSLog(@"Trying to set range %@", NSStringFromRange(range));
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

  if ([[currentDoc isText] boolValue]) {
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
//  NSLog(@"Committing document status...");
  NSInteger count = 0;
	for (FileEntity *file in openDocuments) {
    NSInteger pos = [self.tabView indexOfTabViewItemWithIdentifier:file];
		[file setValue:[NSNumber numberWithInteger:pos] forKey:@"wasOpen"];
//		[file setValue:[NSNumber numberWithBool:YES] forKey:@"wasOpen"];
    count++;
	}
	
	for (DocWindowController *newDoc in standaloneWindows) {
    [[newDoc window] setDocumentEdited:NO];
  }
  	
	if (currentDoc != nil) {
		ProjectEntity *project = [currentDoc valueForKey:@"project"];
		if (project != nil) {
			[project setValue:currentDoc forKey:@"selected"];
		}
	} else {
		ProjectEntity *project = [delegate project];
    project.selected = nil;
	}
	
	[self saveCursorAndScrollPosition];
//  NSLog(@"Status Commit Done.");
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
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:[currentDoc pathOnDisk]];
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
  [self.navigationButtonsView setHidden:YES];
  [self.delegate performSelector:@selector(clearTabHistory)];
}

- (void) enableTextView
{
  [self.navigationButtonsView setHidden:NO];
  [tabBackground setHidden:NO];
	[tabView setHidden:NO];
	[tabBar setHidden:NO];
  [self.texEditorViewController enableEditor];
  [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument)];
  
//  [[self.texEditorViewController.textView window] makeFirstResponder:self.texEditorViewController.textView];
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
