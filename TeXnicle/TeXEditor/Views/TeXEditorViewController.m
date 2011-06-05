//
//  TeXEditorViewController.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"

@implementation TeXEditorViewController

@synthesize textView;
@synthesize delegate;
@synthesize sectionListPopup;
@synthesize unfoldButton;
@synthesize markerButton;

- (id) init
{
  self = [self initWithNibName:@"TeXEditorViewController" bundle:nil];
  if (self) {    
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [sectionListController deactivate];
  self.sectionListPopup = nil;
  self.textView = nil;
  self.unfoldButton = nil;
  self.markerButton = nil;
  self.delegate = nil;
  [super dealloc];
}

#pragma mark -
#pragma Control 

- (void) setString:(NSString*)aString
{
  [self.textView setString:aString];
  [self.textView didChangeText];
  [self.textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0.1];
}

- (void) disableEditor
{
	[self.textView setHidden:YES];
	[[self.textView enclosingScrollView] setHidden:YES];
  [self.sectionListPopup setHidden:YES];
  [self.markerButton setHidden:YES];
  [self.unfoldButton setHidden:YES];
}

- (void) enableEditor
{
	[self.textView setHidden:NO];
	[[self.textView enclosingScrollView] setHidden:NO];
  [self.sectionListPopup setHidden:NO];
  [self.markerButton setHidden:NO];
  [self.unfoldButton setHidden:NO];
}


#pragma mark -
#pragma NSTextView delegate

- (void)textView:(NSTextView *)aTextView clickedOnCell:(id < NSTextAttachmentCell >)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex
{
	NSTextAttachment *att = [[aTextView textStorage] attribute:NSAttachmentAttributeName atIndex:charIndex effectiveRange:NULL];
	
  if ([aTextView respondsToSelector:@selector(unfoldAttachment:atIndex:)]) {
    [aTextView performSelector:@selector(unfoldAttachment:atIndex:) withObject:att withObject:[NSNumber numberWithUnsignedLong:charIndex]];
  }
}


#pragma mark -
#pragma TeXTextView delegate

- (NSArray*)commands
{
//  NSLog(@"Delegate %@", self.delegate);
  return [self.delegate performSelector:@selector(commands)];
}

- (NSArray*)listOfCitations
{
  NSLog(@"Asking %@ for citations", self.delegate);
  return [self.delegate performSelector:@selector(listOfCitations)];
}

- (NSArray*)listOfReferences
{
  return [self.delegate performSelector:@selector(listOfReferences)];
}

- (NSArray*)listOfTeXFilesPrependedWith:(NSString *)prefix
{
  return [self.delegate performSelector:@selector(listOfTeXFilesPrependedWith:) withObject:prefix];
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView
{
	// ask my delegate for an undo manager to use
	if ([[self delegate] respondsToSelector:@selector(currentUndoManager)]) {
		return [delegate performSelector:@selector(currentUndoManager)];
	}
	
	return nil;
}

@end
