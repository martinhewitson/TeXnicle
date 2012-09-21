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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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

@interface TeXEditorViewController ()

@property (copy) NSString *fileBeingSyntaxChecked;
@property (strong) NSImage *errorImage;
@property (strong) NSImage *noErrorImage;
@property (strong) NSImage *checkFailedImage;
@property (strong) NSTimer *syntaxCheckTimer;
@property (strong) TPSyntaxChecker *checker;
@property (unsafe_unretained) IBOutlet NSPopUpButton *sectionListPopup;
@property (unsafe_unretained) IBOutlet NSButton *markerButton;
@property (unsafe_unretained) IBOutlet NSButton *errorPopup;
@property (unsafe_unretained) IBOutlet NSButton *unfoldButton;

@end

@implementation TeXEditorViewController

- (id) init
{
  self = [self initWithNibName:@"TeXEditorViewController" bundle:nil];
  if (self) {
    self.delegate = nil;
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
    self.delegate = nil;
    self.errorImage = [NSImage imageNamed:@"error"];
    self.noErrorImage = [NSImage imageNamed:@"noerror"];  
    self.checkFailedImage = [NSImage imageNamed:@"checkfailed"];
  }
  
  return self;
}

- (void) tearDown
{
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
  
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self.textView];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self.textView];

  
//  NSLog(@"Tear down %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self stopSyntaxChecker];
  self.checker.delegate = nil;
  
  self.textView.delegate = nil;
  [sectionListController deactivate];
  self.delegate = nil;
  
}

- (void) awakeFromNib
{
  [self disableEditor];
  
  self.checker = [[TPSyntaxChecker alloc] initWithDelegate:self];
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

- (void) stopSyntaxChecker
{
  if (self.syntaxCheckTimer) {
    [self.syntaxCheckTimer invalidate];
    self.syntaxCheckTimer = nil;
  }
}

- (void) setupSyntaxChecker
{
  if (self.syntaxCheckTimer) {
    [self stopSyntaxChecker];
  }
  
  self.syntaxCheckTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                           target:self
                                                         selector:@selector(checkSyntaxTimerFired) 
                                                         userInfo:nil
                                                          repeats:YES];
  
}

- (void) handleDocumentChanged:(NSNotification*)aNote
{
  FileEntity *file = [[aNote userInfo] valueForKey:@"file"];
  if (file == nil) {
    return;
  }
  
  [self setupSyntaxChecker];
  
  
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
  
  if (aString)
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
      [self.errorPopup setImage:_errorImage];
    }
  } else {
    if (![[[self.errorPopup image] name] isEqualToString:@"noerror"]) {
      [self.errorPopup setImage:_noErrorImage];
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
  
  errorMenu = [[NSMenu alloc] initWithTitle:@"Error Menu"];
  
  for (TPSyntaxError *error in self.errors) {
    NSString *title = [NSString stringWithFormat:@"%@: %@", error.line, error.message];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                   action:@selector(jumpToLine:)
                                            keyEquivalent:@""];
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

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)aChecker
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerShouldCheckSyntax:)]){
    BOOL state = [self.delegate syntaxCheckerShouldCheckSyntax:aChecker];
//    NSLog(@"Delegate responded with %d", state);
    return state;
  }
  return NO;
}


- (void) checkSyntaxTimerFired
{
//  NSLog(@"Syntax check timer fired!");
  // no point in syntax checking while the app is not active
  if (![[NSApplication sharedApplication] isActive]) {
//    NSLog(@"  app not active");
    return;
  }
  
  // if we have no delegate that means we are not being used
  // so we shouldn't syntax check
  if (self.delegate == nil) {
//    NSLog(@"  delegate nil");
    // then we are done, so stop the timer
    [self stopSyntaxChecker];
    return;
  }
  
  // ask the delegate what he thinks about this
  if ([self syntaxCheckerShouldCheckSyntax:self.checker] == NO) {
//    NSLog(@"Delegate says no!");
    return;
  }
//  NSLog(@"Delegate says yes!");

  // if we are configured to syntax check, then do it!
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
//  NSLog(@"Already checking syntax? %d", _checkingSyntax);
  if (_shouldCheckSyntax && !_checkingSyntax) {
    _checkingSyntax = YES;
    // write string to tmp file
    NSString *fileToCheck = [self nameOfFileBeingEdited];
//    NSLog(@"Name of file to check %@", fileToCheck);
    if (fileToCheck) {
//      NSString *filename = [NSString stringWithFormat:@"check_%@", fileToCheck];
      NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
      NSString *content = [self.textView string];
      //    NSLog(@"Content length %d", [content length]);
      if ([content length] > 0) {
        if ([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {    
          self.fileBeingSyntaxChecked = path;
//          NSLog(@"Checking path %@", path);
          [self.checker performSelector:@selector(checkSyntaxOfFileAtPath:) withObject:path afterDelay:0];
        } else {
//          NSLog(@"Failed to write %@", path);
        }
      }
    }
  }
}

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker *)checker
{
//  NSLog(@"Checker failed");
  _checkingSyntax = NO;
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  if ([fm fileExistsAtPath:self.fileBeingSyntaxChecked]) {
    if ([fm removeItemAtPath:self.fileBeingSyntaxChecked error:&error] == NO) {
//      NSLog(@"Failed to remove %@", self.fileBeingSyntaxChecked);
    }
  }
  [self setCheckFailed];
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)checker
{
//  NSLog(@"Checker finished");
//  NSLog(@"Got errors %d from %@", [self.checker.errors count], checker);
  
  if ([self.checker.errors count] > 0) {
    [self setHasErrors:YES];
    [self setErrors:self.checker.errors];
  } else {
    [self setHasErrors:NO];
    [self setErrors:nil];
  }
  
  // remove tmp file
  if (self.fileBeingSyntaxChecked) {
//    NSLog(@"Removing %@", self.fileBeingSyntaxChecked);
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.fileBeingSyntaxChecked]) {
      NSError *error = nil;
      if ([fm removeItemAtPath:self.fileBeingSyntaxChecked error:&error] == NO) {
//        NSLog(@"Failed to remove %@", self.fileBeingSyntaxChecked);
      }
    }
  }
  
  // tell delegate
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerDidFinish)]) {
    [self.delegate performSelector:@selector(syntaxCheckerDidFinish)];
  }
  
  _checkingSyntax = NO;
}

#pragma mark -
#pragma mark textview delegate

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
        [aTextView performSelector:@selector(unfoldAttachment:atIndex:) withObject:att withObject:@(charIndex)];
      }
    }
    
    // placeholder cell
    if ([att isKindOfClass:[MHPlaceholderAttachment class]]) {
      [aTextView setSelectedRange:NSMakeRange(charIndex, 1)];
    }
    
  }
  
  
}

- (NSString*) nameOfFileBeingEdited
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(nameOfFileBeingEdited)]) {
    return [self.delegate nameOfFileBeingEdited];
  }
  return nil;
}


#pragma mark -
#pragma mark TeXTextView delegate


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
	if ([self.delegate respondsToSelector:@selector(currentUndoManager)]) {
		return [self.delegate performSelector:@selector(currentUndoManager)];
	}
	
	return nil;
}

-(BOOL)shouldSyntaxHighlightDocument
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    return [self.delegate shouldSyntaxHighlightDocument];
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
  return @[];
}

@end
