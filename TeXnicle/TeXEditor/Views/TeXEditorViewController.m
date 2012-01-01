//
//  TeXEditorViewController.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"
#import "TPFoldedCodeSnippet.h"
#import "MHPlaceholderAttachment.h"

@implementation TeXEditorViewController

@synthesize textView;
@synthesize delegate;
@synthesize sectionListPopup;
@synthesize unfoldButton;
@synthesize markerButton;
@synthesize isHidden;

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
//  NSLog(@"Dealloc TeXEditorViewController");
  self.textView.delegate = nil;
  [sectionListController deactivate];
  self.delegate = nil;
  [super dealloc];
}

- (void) awakeFromNib
{
  [self disableEditor];
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
  [jumpBar setHidden:YES];
  self.isHidden = YES;
	[self.textView setHidden:YES];
	[[self.textView enclosingScrollView] setHidden:YES];
  [self.sectionListPopup setHidden:YES];
  [self.markerButton setHidden:YES];
  [self.unfoldButton setHidden:YES];
  [containerView setNeedsDisplay:YES];
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

- (void) enableJumpBar
{
  [jumpBar setHidden:NO];
  NSRect fr = [scrollView frame];
  NSRect jr = [jumpBar bounds];
  [scrollView setFrame:NSMakeRect(fr.origin.x, fr.origin.y, fr.size.width, fr.size.height-jr.size.height)];
}

- (void) disableJumpBar
{  
  [jumpBar setHidden:YES];
  NSRect fr = [scrollView frame];
  NSRect jr = [jumpBar bounds];
  [scrollView setFrame:NSMakeRect(fr.origin.x, fr.origin.y, fr.size.width, fr.size.height+jr.size.height)];
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

#pragma mark -
#pragma NSTextView delegate

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
      
      //    [[aTextView layoutManager] addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor blueColor] forCharacterRange:NSMakeRange(charIndex, 1)];
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
