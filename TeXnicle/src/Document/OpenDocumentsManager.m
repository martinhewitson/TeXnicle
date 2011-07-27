//
//  OpenDocumentsManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
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

- (void) awakeFromNib
{
	openDocuments = [[NSMutableArray alloc] init];
	standaloneWindows = [[NSMutableArray alloc] init];
	
	[tabBar setStyleNamed:@"TPMetal"];
	[tabBar setOrientation:PSMTabBarHorizontalOrientation];
	[tabBar setAutomaticallyAnimates:YES];
	[tabBar setCanCloseOnlyTab:YES];
	[tabBar setHideForSingleTab:NO];
	
	isOpening = NO;
	
	[self disableTextView];
	
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

- (void) closeCurrentTab
{
	FileEntity *selectedDoc = [[tabView selectedTabViewItem] identifier];
	[self removeDocument:selectedDoc];	
}

- (void) removeDocument:(FileEntity*)aDoc
{
	if (![openDocuments containsObject:aDoc]) {
//    NSLog(@"Doc %@ is not open", aDoc);
		return;
	}
	
//	NSLog(@"Removing %@", [aDoc valueForKey:@"name"]);
	NSInteger index = [self indexOfDocumentWithFile:aDoc];
	if (index >= 0) {
//		NSLog(@"Removing tab at index %ld", index);
		
		
		// remove the tab		
		[self.texEditorViewController.textView updateEditorRuler];
		[openDocuments removeObject:aDoc];
		[tabView removeTabViewItem:[tabView tabViewItemAtIndex:index]];
	} else {
		[openDocuments removeObject:aDoc];
	}

	[self performSelector:@selector(updateDoc) withObject:self afterDelay:0.0];
	
//	NSLog(@"Current doc: %@", [currentDoc valueForKey:@"name"]);
	
	[self.texEditorViewController.textView setNeedsDisplay:YES];
	
	id cd = [[tabView selectedTabViewItem] identifier];
	[self setCurrentDoc:cd];
	
	// remove from the standalone windows if it's there
	DocWindowController *docToRemove = nil;
	for (DocWindowController *win in standaloneWindows) {
		if ([win file] == aDoc) {
			docToRemove = win;
		}
	}

	if (docToRemove) {
		[docToRemove close];
		[standaloneWindows removeObject:docToRemove];
	}
	
}


- (void) standaloneWindowForFile:(FileEntity*)aFile
{
	DocWindowController *newDoc = [[DocWindowController alloc] initWithFile:aFile document:delegate];
	[newDoc showWindow:self];
	[[newDoc window] makeKeyAndOrderFront:self];
	[standaloneWindows addObject:newDoc];
	[newDoc release];
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
		NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:aDoc] ;
		[newItem setLabel:[aDoc valueForKey:@"shortName"]];    
		[tabView addTabViewItem:newItem];
		[tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
		[self setCurrentDoc:aDoc];
		[newItem release];
		[self enableTextView];
    [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument)];
	}	else {
		NSTabViewItem *tab = [tabView tabViewItemAtIndex:fileIndex];
		[tabView selectTabViewItem:tab];
		[self setCurrentDoc:[tab identifier]];		
		[self enableTextView];
	}
	
	[self.texEditorViewController.textView setNeedsDisplay:YES];
}

- (void)updateDoc
{
	id doc = [currentDoc document];		
	if (doc) {
		if ([doc isKindOfClass:[FileDocument class]]) {
			NSTextContainer *textContainer = [doc textContainer];
			if (textContainer) {
//				NSLog(@"TextView: %@", textView);
				//NSLog(@"Setting up text container.. %@", textContainer);
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
        //				NSLog(@"Did set text container");
			}			
		}
	} else {
//		NSLog(@"Doc is nil");
	}
}

- (void) selectTabForFile:(FileEntity*)aFile
{
	NSInteger index = [self indexOfDocumentWithFile:aFile];
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
//	NSLog(@"Removed %@", [file valueForKey:@"name"]);
	
	
	// Set another file if possible
	FileEntity *nextFile = [openDocuments lastObject];
//	NSLog(@"Next file %@", [nextFile valueForKey:@"name"]);
	if (nextFile && nextFile != file) {
		[self setCurrentDoc:nextFile];
	} else {
		[self setCurrentDoc:nil];
		[self disableTextView];
	}
	
	
	//[self removeObject:[tabViewItem identifier]];
	//NSLog(@"Managing %d docs", [[self arrangedObjects] count]);
}

- (void) setCursorAndScrollPositionForCurrentDoc
{
//	if (isOpening)
//		return;
	
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

- (void) saveCursorAndScrollPosition
{	
//	NSLog(@"Saving cursor and scroll position");
	if (isOpening)
		return;
	
	if (!currentDoc)
		return;
	
	NSRect vr = [self.texEditorViewController.textView visibleRect];
//	NSLog(@"Visible rect: %@", NSStringFromRect(vr));
	if (!NSEqualSizes(vr.size, NSZeroSize)) {
		[currentDoc setPrimitiveValue:NSStringFromRect(vr) forKey:@"visibleRect"];
		// store cursor position
		NSRange r = [self.texEditorViewController.textView selectedRange];
		[currentDoc setPrimitiveValue:NSStringFromRange(r) forKey:@"cursor"];
	}
}


- (void) commitStatus
{
	for (FileEntity *file in openDocuments) {
		[file setValue:[NSNumber numberWithBool:YES] forKey:@"wasOpen"];
	}
	
	
//	NSLog(@"%@", [[projectDocument project] valueForKey:@"selected"]);
	
	if (currentDoc) {
		ProjectEntity *project = [currentDoc valueForKey:@"project"];
		if (project) {
			[project setValue:currentDoc forKey:@"selected"];
		}
	} else {
		[[delegate project] setValue:nil forKey:@"selected"];
	}
	
	[self saveCursorAndScrollPosition];
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
	return YES;
}

- (void) disableTextView
{
//  NSLog(@"Disable text view %@", self.texEditorViewController.textView);
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
