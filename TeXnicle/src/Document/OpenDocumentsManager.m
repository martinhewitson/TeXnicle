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

- (id) init
{
  self = [super init];
  if (self) {
    self.openDocuments = [[NSMutableArray alloc] init];
    self.standaloneWindows = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) awakeFromNib
{
	[self setup];
}

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

- (void) setup
{
	[self.tabBar setStyleNamed:@"TPMetal"];
	[self.tabBar setOrientation:PSMTabBarHorizontalOrientation];
	[self.tabBar setAutomaticallyAnimates:YES];
	[self.tabBar setCanCloseOnlyTab:YES];
	[self.tabBar setHideForSingleTab:NO];
	
	_isOpening = NO;
		
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(handleDocumentRenamed:)
						 name:TPDocumentWasRenamed
					 object:nil];
	
	self.currentDoc = nil;
}

- (void) tearDown
{
  //  NSLog(@"Tear down %@", self);
  
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  self.delegate = nil;
  
  self.tabView.delegate = nil;
  self.tabView = nil;

  self.imageViewerController = nil;
  self.imageViewContainer = nil;
  
  self.texEditorViewController = nil;
  self.currentDoc = nil;

  self.tabBar.delegate = nil;
  self.tabBar.partnerView = nil;
  self.tabBar = nil;
  
  self.navigationButtonsView = nil;
  
  
}

- (void) handleDocumentRenamed:(NSNotification*)aNote
{
//	NSLog(@"Document was renamed!");
//	NSLog(@"User info %@", [aNote userInfo]);
	id item = [[aNote userInfo] valueForKey:@"document"];
	[self refreshTabForDocument:item];
	[self.texEditorViewController.textView colorVisibleText];
}


- (void) refreshTabForDocument:(FileEntity*)aDoc
{
	NSArray *tabs = [self.tabView tabViewItems];
	for (NSTabViewItem *tab in tabs) {
		if ([tab identifier] == aDoc) {
			[tab setLabel:[aDoc valueForKey:@"shortName"]];
		}
	}	
}


- (void)closeAllTabs
{
  NSArray *openFiles = [NSArray arrayWithArray:self.openDocuments];
  for (FileEntity *file in openFiles) {
    [self removeTabForDoc:file];
  }
  [self performSelectorOnMainThread:@selector(disableEditors) withObject:nil waitUntilDone:YES];
}

- (void) disableEditors
{
  [self enableImageView:NO];
  [self disableTextView];
}

- (void) closeCurrentTab
{
  [self.tabView removeTabViewItem:[self.tabView selectedTabViewItem]];
}

- (void) removeDocument:(FileEntity*)aDoc
{
	if (![self.openDocuments containsObject:aDoc]) {
		return;
	}
	
  [self removeTabForDoc:aDoc];
}

- (void) removeTabForDoc:(FileEntity*)aDoc
{
  NSInteger index = [self.tabView indexOfTabViewItemWithIdentifier:aDoc];
  if (index >= 0 && index < [[self.tabView tabViewItems] count]) {
    NSTabViewItem *item = [self tabViewItemAtIndex:index];
    if (item != nil) {
      [self.tabView removeTabViewItem:item];
    }
  }
}

- (void) standaloneWindowForFile:(FileEntity*)aFile
{
	DocWindowController *newDoc = [[DocWindowController alloc] initWithFile:aFile document:(id)self.delegate];
	[newDoc showWindow:self];
	[[newDoc window] makeKeyAndOrderFront:self];
	[self.standaloneWindows addObject:newDoc];
}

- (void) addAndSelectDocument:(FileEntity*)aDoc
{
  [self addDocument:aDoc select:YES];
}

- (void) addDocument:(FileEntity*)aDoc select:(BOOL)selectTab
{	
	if (!self.openDocuments)
		return;
	
	if (!self.standaloneWindows)
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
        
    [self.openDocuments addObject:aDoc];
    NSDictionary *dictionary = @{@"file": aDoc};
    [[NSNotificationCenter defaultCenter] postNotificationName:TPOpenDocumentsDidAddFileNotification
                                                        object:self
                                                      userInfo:dictionary];
    
		NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:aDoc];
		[newItem setLabel:[aDoc valueForKey:@"shortName"]];    
    [self.tabView addTabViewItem:newItem];
    if (selectTab) {
      [self.tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
    }
    
    
	}	else {
    NSInteger index = [self.tabView indexOfTabViewItemWithIdentifier:aDoc];
		NSTabViewItem *tab = [self tabViewItemAtIndex:index];
    if (tab != nil) {
      [self.tabView selectTabViewItem:tab];
    }
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
  
  if ([self.currentDoc isImage]) {
    [self enableImageView:YES];
  } else if ([[self.currentDoc valueForKey:@"isText"] boolValue]) {
    id doc = [self.currentDoc document];		
    if (doc) {
      if ([doc isKindOfClass:[FileDocument class]]) {
//        NSLog(@"Setting doc %@", doc);
        NSTextContainer *textContainer = [doc textContainer];
        if (textContainer) {
//          NSLog(@"TextView: %@", self.texEditorViewController.textView);
//          NSLog(@"Setting up text container.. %@", textContainer);
          
          [self.texEditorViewController.textView stopObservingTextStorage];
          
          // clear the text view from all other document text containers
          for (FileEntity *file in self.openDocuments) {
            if (file != self.currentDoc) {
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
                    
          [self.texEditorViewController.textView performSelectorOnMainThread:@selector(setWrapStyle) withObject:nil waitUntilDone:YES];
          
          [self.texEditorViewController.textView observeTextStorage];
          [self enableTextView];
          [self.texEditorViewController.textView setUpRuler];
          [self.texEditorViewController.textView setNeedsDisplay:YES];
          if ([[self.tabView selectedTabViewItem] identifier] != self.currentDoc) {
            [self selectTabForFile:self.currentDoc];
          }
          
          [self.texEditorViewController.textView performSelectorOnMainThread:@selector(colorVisibleText)
                                                                  withObject:nil
                                                               waitUntilDone:YES];
          
          [self.texEditorViewController.textView performSelectorOnMainThread:@selector(colorWholeDocument)
                                                                  withObject:nil
                                                               waitUntilDone:NO];
//          NSLog(@"Did set text container");
          [self enableImageView:NO];
        }
      } // end doc document is correct class
    } // end doc is nil
  } else {
    [self enableImageView:YES];
  }
}

- (NSTabViewItem *) tabViewItemAtIndex:(NSInteger)index
{
  if (index >=0 && index < [[self.tabView tabViewItems] count]) {
    return [self.tabView tabViewItemAtIndex:index];
  }
  
  return nil;
}

- (void) selectTabForFile:(FileEntity*)aFile
{
  if (![aFile existsOnDisk]) {
    return;
  }
  if (aFile == nil) {
    return;
  }
	NSInteger index = [self.tabView indexOfTabViewItemWithIdentifier:aFile];
  if (index < 0) {
    return;
  }
	NSTabViewItem *item = [self tabViewItemAtIndex:index];
  if (item != nil) {
    if ([self.tabView selectedTabViewItem] != item) {
      [self.tabView selectTabViewItem:item];
    }
  }
}

- (FileEntity*)fileAtIndex:(NSInteger)index
{
  return self.openDocuments[index];
}

- (NSInteger) indexOfDocumentWithFile:(FileEntity*)aFile
{
	for (FileEntity *oDoc in self.openDocuments) {
		if (oDoc == aFile) {
			return [self.openDocuments indexOfObject:oDoc];
		}
	}

	return -1;
}

- (void) setCurrentDoc:(FileEntity *)aDoc
{
	if (_currentDoc == aDoc)
		return;
	
//	NSLog(@"Switching to document %@", [aDoc valueForKey:@"name"]);
	_currentDoc = aDoc;
  
  if (_currentDoc != nil) {
    NSDictionary *dictionary = @{@"file": _currentDoc};
    [[NSNotificationCenter defaultCenter] postNotificationName:TPOpenDocumentsDidChangeFileNotification
                                                        object:self
                                                      userInfo:dictionary];
  }
  
  // increase active state for this doc
  [_currentDoc increaseActiveCount];
  _currentDoc.isSelected = YES;
  
  // and decrease for all others
  for (FileEntity *doc in self.openDocuments) {
    if (doc != _currentDoc) {
      [doc decreaseActiveCount];
      doc.isSelected = NO;
    }
  }
		
	[self updateDoc];
  // tell project tree to select this item
  [self.delegate openDocumentsManager:self didSelectFile:aDoc];
}

- (NSInteger) count
{
	return [self.openDocuments count];
}

#pragma mark -
#pragma mark  TabView Delegate


- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self saveCursorAndScrollPosition];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{  
  if (self.currentDoc != [tabViewItem identifier]) {
    [self setCurrentDoc:[tabViewItem identifier]];
    [self setCursorAndScrollPositionForCurrentDoc];
    [self.texEditorViewController.textView applyFontAndColor:NO];
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
	[self.openDocuments removeObject:file];
  [file setValue:@-1 forKey:@"wasOpen"];
//  [file setValue:[NSNumber numberWithBool:NO] forKey:@"wasOpen"];
//	NSLog(@"Removed %@", [file valueForKey:@"name"]);
	
	
	// Set another file if this is the selected one and if possible
  if (file == self.currentDoc) {
    NSTabViewItem *tabItem = [[self.tabView tabViewItems] lastObject];
    
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
	if ([[self.currentDoc isText] boolValue]) {
    [[self.texEditorViewController.textView layoutManager] ensureLayoutForTextContainer:[self.texEditorViewController.textView textContainer]];
    
    // reset cursor position
    NSString *sr = [self.currentDoc valueForKey:@"cursor"];
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
    sr = [self.currentDoc valueForKey:@"visibleRect"];
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
	if (self.isOpening)
		return;
	
	if (!self.currentDoc)
		return;

  if ([[self.currentDoc isText] boolValue]) {
    NSRect vr = [self.texEditorViewController.textView visibleRect];
    //	NSLog(@"Visible rect: %@", NSStringFromRect(vr));
    if (!NSEqualSizes(vr.size, NSZeroSize)) {
      [self.currentDoc setPrimitiveValue:NSStringFromRect(vr) forKey:@"visibleRect"];
      // store cursor position
      NSRange r = [self.texEditorViewController.textView selectedRange];
      [self.currentDoc setPrimitiveValue:NSStringFromRange(r) forKey:@"cursor"];
    }
  }
}


- (void) commitStatus
{
//  NSLog(@"Committing document status...");
  NSInteger count = 0;
	for (FileEntity *file in self.openDocuments) {
    NSInteger pos = [self.tabView indexOfTabViewItemWithIdentifier:file];
		[file setValue:@(pos) forKey:@"wasOpen"];
//		[file setValue:[NSNumber numberWithBool:YES] forKey:@"wasOpen"];
    count++;
	}
	
	for (DocWindowController *newDoc in self.standaloneWindows) {
    [[newDoc window] setDocumentEdited:NO];
  }
  	
	if (self.currentDoc != nil) {
		ProjectEntity *project = [self.currentDoc valueForKey:@"project"];
		if (project != nil) {
			[project setValue:self.currentDoc forKey:@"selected"];
		}
	} else {
		ProjectEntity *project = [self.delegate project];
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
    if ([self.currentDoc isImage]) {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:[self.currentDoc pathOnDisk]];
      [self.imageViewerController setImage:image atPath:[self.currentDoc pathOnDisk]];
      [self.imageViewerController enable];
    } else {
      NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:[self.currentDoc extension]];
      [self.imageViewerController setImage:image atPath:[self.currentDoc pathOnDisk]];
      [self.imageViewerController enable];
    }
    [self.texEditorViewController hide];
    [self.tabBackground setHidden:NO];
    [self.tabView setHidden:NO];
    [self.tabBar setHidden:NO];
  } else {
    [self.texEditorViewController enableEditor];
    [self.imageViewerController.view removeFromSuperview];
    [self.imageViewerController disable];
  }
}

- (void) disableTextView
{
  [self.texEditorViewController disableEditor];
	[self.tabView setHidden:YES];
	[self.tabBar setHidden:YES];
	[self.tabBackground setHidden:YES];
  [self.navigationButtonsView setHidden:YES];
  [self.delegate performSelector:@selector(clearTabHistory)];
}

- (void) enableTextView
{
  [self.navigationButtonsView setHidden:NO];
  [self.tabBackground setHidden:NO];
	[self.tabView setHidden:NO];
	[self.tabBar setHidden:NO];
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
