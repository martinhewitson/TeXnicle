//
//  TeXEditorViewController.m
//  TeXnicle
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"
#import "TPFoldedCodeSnippet.h"
#import "MHPlaceholderAttachment.h"
#import "TPSyntaxChecker.h"
#import "TPSyntaxError.h"
#import "NSString+LaTeX.h"
#import "OpenDocumentsManager.h"
#import "FileEntity.h"
#import "externs.h"

@implementation TeXEditorViewController

@synthesize textView;
@synthesize delegate;
@synthesize sectionListPopup;
@synthesize unfoldButton;
@synthesize markerButton;
@synthesize errorPopup;
@synthesize isHidden;
@synthesize tableConfigureWindow;
@synthesize errors;
@synthesize checker;
@synthesize syntaxCheckTimer;
@synthesize performSyntaxCheck;
@synthesize errorImage;
@synthesize noErrorImage;
@synthesize checkFailedImage;

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
    self.errorImage = [NSImage imageNamed:@"error"];
    self.noErrorImage = [NSImage imageNamed:@"noerror"];  
    self.checkFailedImage = [NSImage imageNamed:@"checkfailed"];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
//  NSLog(@"Dealloc TeXEditorViewController");
  [self.syntaxCheckTimer invalidate];
  self.syntaxCheckTimer = nil;
  self.errorImage = nil;
  self.noErrorImage = nil;
  self.checkFailedImage = nil;
  self.checker = nil;
  self.textView.delegate = nil;
  [sectionListController deactivate];
  self.delegate = nil;
  [super dealloc];
}

- (void) awakeFromNib
{
  [self disableEditor];
  
  self.checker = [[[TPSyntaxChecker alloc] initWithDelegate:self] autorelease];
  _shouldCheckSyntax = YES; // check at least once
  _checkingSyntax    = NO;
  self.performSyntaxCheck = NO;
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleDocumentChanged:) 
             name:TPOpenDocumentsDidChangeFileNotification
           object:nil];
  
}

#pragma mark -
#pragma Control 

- (void) setupSyntaxChecker
{
  if (self.syntaxCheckTimer) {
    [self.syntaxCheckTimer invalidate];
    [self.syntaxCheckTimer release];
    self.syntaxCheckTimer = nil;
  }
  
  self.syntaxCheckTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                           target:self
                                                         selector:@selector(checkSyntaxTimerFired) 
                                                         userInfo:nil
                                                          repeats:YES];
  
}

- (void) handleDocumentChanged:(NSNotification*)aNote
{
  [self setupSyntaxChecker];
  
  FileEntity *file = [[aNote userInfo] valueForKey:@"file"];
  if ([[file extension] isEqualToString:@"tex"]) {
    _shouldCheckSyntax = YES;
  } else {
    self.errors = nil;
    [self setHasErrors:NO];
    _shouldCheckSyntax = NO;
  }
}

- (void) setString:(NSString*)aString
{
  [self.textView setString:aString];
  [self.textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0.1];
  _shouldCheckSyntax = YES;
  [self setupSyntaxChecker];
}

- (void) disableEditor
{
  [jumpBar setHidden:YES];
  self.isHidden = YES;
	[self.textView setHidden:YES];
	[[self.textView enclosingScrollView] setHidden:YES];
  [self.sectionListPopup setHidden:YES];
  [self.markerButton setHidden:YES];
  [self.unfoldButton setHidden:YES];
  [containerView setNeedsDisplay:YES];
}

- (void) setCheckFailed
{
  [self.errorPopup setImage:self.checkFailedImage];
  self.errors = nil;
}

- (void) setHasErrors:(BOOL)state
{
  if (state) {
    if (![[[self.errorPopup image] name] isEqualToString:@"error"]) {
      [self.errorPopup setImage:errorImage];
    }
  } else {
    if (![[[self.errorPopup image] name] isEqualToString:@"noerror"]) {
      [self.errorPopup setImage:noErrorImage];
    }
  }
}

- (void) enableEditor
{
  [self.view setHidden:NO];
  [jumpBar setHidden:NO];
  self.isHidden = NO;
	[self.textView setHidden:NO];
	[[self.textView enclosingScrollView] setHidden:NO];
  [self.sectionListPopup setHidden:NO];
  [self.markerButton setHidden:NO];
  [self.unfoldButton setHidden:NO];
}

- (void) showJumpBar
{
  [jumpBar setHidden:NO];
  NSRect fr = [scrollView frame];
  NSRect jr = [jumpBar bounds];
  [scrollView setFrame:NSMakeRect(fr.origin.x, fr.origin.y, fr.size.width, fr.size.height-jr.size.height)];
}

- (void) hideJumpBar
{  
  NSRect fr = [scrollView frame];
  NSRect jr = [jumpBar bounds];
  [jumpBar setHidden:YES];
  [scrollView setFrame:NSMakeRect(fr.origin.x, fr.origin.y, fr.size.width, fr.size.height+jr.size.height)];
}

- (void) enableJumpBar
{
  [self.sectionListPopup setEnabled:YES]; 
  [self.markerButton setEnabled:YES];
  [self.unfoldButton setEnabled:YES];
}

- (void)disableJumpBar
{
  [self.sectionListPopup setEnabled:NO]; 
  [self.markerButton setEnabled:NO];
  [self.unfoldButton setEnabled:NO];
}

- (void) hide
{
  [containerView setHidden:YES];
  self.isHidden = YES;
}

- (BOOL) textViewHasSelection
{
  NSRange r = [self.textView selectedRange];
  return r.length > 0;
}

- (NSString*)selectedText
{
  NSString *string = [self.textView string];
  NSRange r = [self.textView selectedRange];
  if (r.location < [string length] && r.length > 0) {
    return [[self.textView string] substringWithRange:r];
  }
  return nil;
}

- (IBAction)showErrorMenu:(id)sender
{
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
	
  // populate menu with errors
  if (errorMenu) {
    [errorMenu release];
  }
  
  errorMenu = [[NSMenu alloc] initWithTitle:@"Error Menu"];
  
  for (TPSyntaxError *error in self.errors) {
    NSString *title = [NSString stringWithFormat:@"%@: %@", error.line, error.message];
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title
                                                   action:@selector(jumpToLine:)
                                            keyEquivalent:@""] autorelease];
    [item setAttributedTitle:[error attributedString]];
    [item setTarget:self];
    [item setRepresentedObject:error];
    [errorMenu addItem:item];
  }
	
	[NSMenu popUpContextMenu:errorMenu withEvent:event forView:(NSButton *)sender];  
}

- (void)jumpToLine:(NSMenuItem*)anItem
{
  TPSyntaxError *error = (TPSyntaxError*)[anItem representedObject];
  
  [self.textView goToLineWithNumber:error.line];
  
}

#pragma mark -
#pragma mark syntax checking

- (void) checkSyntaxTimerFired
{
  if (![NSApp isActive]) {
    return;
  }

  if (self.performSyntaxCheck) {
    [self checkSyntax:self];
  }
}

- (IBAction)checkSyntax:(id)sender
{  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if (![[defaults valueForKey:TPCheckSyntax] boolValue]) {
    self.errors = nil;
    [self setHasErrors:NO];
    [self.errorPopup setEnabled:NO];
    return;
  } else {
    [self.errorPopup setEnabled:YES];
  }
  
//  NSLog(@"Should check syntax? %d", _shouldCheckSyntax);
  if (_shouldCheckSyntax && !_checkingSyntax) {
    _checkingSyntax = YES;
    // write string to tmp file
    NSString *path = [[[NSString pathForTemporaryFileWithPrefix:@"tmp"] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"texnicle_syntax_check.tex"];
    NSString *content = [self.textView string];
//    NSLog(@"Content length %d", [content length]);
    if ([content length] > 0) {
      if ([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {    
        [self.checker performSelector:@selector(checkSyntaxOfFileAtPath:) withObject:path afterDelay:0];
      }
    }
  }
}

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker *)checker
{
  _checkingSyntax = NO;
  [self setCheckFailed];
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)checker
{
//  NSLog(@"Got errors %d from %@", [self.checker.errors count], checker);
  
  if ([self.checker.errors count] > 0) {
    [self setHasErrors:YES];
    [self setErrors:self.checker.errors];
  } else {
    [self setHasErrors:NO];
    [self setErrors:nil];
  }
  
  _checkingSyntax = NO;
}

#pragma mark -
#pragma NSTextView delegate

-(void)textView:(TeXTextView*)aTextView didCommandClickAtLine:(NSInteger)lineNumber column:(NSInteger)column
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didCommandClickAtLine:column:)]) {
    [self.delegate textView:aTextView didCommandClickAtLine:lineNumber column:column];
  }
}

- (void)textView:(NSTextView *)aTextView clickedOnCell:(id < NSTextAttachmentCell >)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex
{
	NSTextAttachment *att = [[aTextView textStorage] attribute:NSAttachmentAttributeName atIndex:charIndex effectiveRange:NULL];
  if (att != nil) {
    
    // code folded cells
    if ([att respondsToSelector:@selector(object)] && [att isKindOfClass:[TPFoldedCodeSnippet class]]) {
      if ([aTextView respondsToSelector:@selector(unfoldAttachment:atIndex:)]) {
        [aTextView performSelector:@selector(unfoldAttachment:atIndex:) withObject:att withObject:[NSNumber numberWithUnsignedLong:charIndex]];
      }
    }
    
    // placeholder cell
    if ([att isKindOfClass:[MHPlaceholderAttachment class]]) {
      [aTextView setSelectedRange:NSMakeRange(charIndex, 1)];
    }
    
  }
  
  
}


#pragma mark -
#pragma TeXTextView delegate

-(NSString*)fileExtension
{
  return [self.delegate performSelector:@selector(fileExtension)];
}

-(id)project
{
  return [self.delegate performSelector:@selector(project)];
}

- (NSArray*)commands
{
//  NSLog(@"Delegate %@", self.delegate);
  return [self.delegate performSelector:@selector(commands)];
}

- (NSArray*)listOfCitations
{
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

-(NSArray*)listOfCommands
{
  return [self.delegate performSelector:@selector(listOfCommands)];
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView
{
	// ask my delegate for an undo manager to use
	if ([[self delegate] respondsToSelector:@selector(currentUndoManager)]) {
		return [delegate performSelector:@selector(currentUndoManager)];
	}
	
	return nil;
}

-(BOOL)shouldSyntaxHighlightDocument
{
  if ([[self delegate] respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    return [[self delegate] shouldSyntaxHighlightDocument];
  }
  return NO;
}

-(NSArray*)bookmarksForCurrentFileInLineRange:(NSRange)aRange
{  
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForCurrentFileInLineRange:)]) {
    return [self.delegate bookmarksForCurrentFileInLineRange:aRange];
  }
  
  return nil;
}

- (NSArray*)commandsBeginningWithPrefix:(NSString*)prefix
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(commandsBeginningWithPrefix:)]) {
    return [self.delegate commandsBeginningWithPrefix:prefix];
  }
  return nil;
}

-(NSString*)codeForCommand:(NSString*)command
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(codeForCommand:)]) {
    NSString *code = [self.delegate codeForCommand:command];
    return code;
  }
  return nil;
}

#pragma mark -
#pragma mark Section List Delegate

- (NSArray*)bookmarksForCurrentFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForCurrentFile)]) {
    return [self.delegate bookmarksForCurrentFile];
  }
  return [NSArray array];
}

@end
