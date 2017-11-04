//
//  TeXTextView.m
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

#import "TeXTextView.h"
#import "TPLibraryController.h"
#import "NSArray+Color.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "NSAttributedString+CodeFolding.h"
#import "NSAttributedString+Placeholders.h"
#import "NSString+Comparisons.h"
#import "NSString+CharacterSize.h"
#import "NSString+Reformatting.h"

#import "MHEditorRuler.h"
#import "MHCodeFolder.h"
#import "TeXColoringEngine.h"
#import "TPPopupListWindowController.h"
#import "TPFoldedCodeSnippet.h"
#import "NSString+RelativePath.h"
#import "NSString+WordRanges.h"
#import "NSArray_Extensions.h"

#import "NSDictionary+TeXnicle.h"
#import "NSString+LaTeX.h"
#import "NSAttributedString+LineNumbers.h"
#import "KSPathUtilities.h"

#import "MHLineNumber.h"
#import "NSString+FileTypes.h"

#import "TPPasteTableConfigureWindowController.h"

#import "MHPlaceholderAttachment.h"
#import "MHFileReader.h"
#import "BibliographyEntry.h"

#import "TPLabel.h"
#import "FileEntity.h"
#import "externs.h"
#import "TeXEditorViewController.h"
#import "FileDocument.h"
#import "NSColor+Lightness.h"

#import "TPRegularExpression.h"
#import "TPThemeManager.h"

#define LargeTextWidth  1e7
#define LargeTextHeight 1e7
#define kMaxZoom 42
#define kFontWrapScaleCorrection 1.07
#define kRulerUpdateInterval 0.2

NSString * const TELineNumberClickedNotification = @"TELineNumberClickedNotification";
NSString * const TEDidFoldUnfoldTextNotification = @"TEDidFoldUnfoldTextNotification";

@interface TeXTextView ()

@property (strong) TPPasteTableConfigureWindowController *pasteConfigController;
@property (assign) NSInteger zoomFactor;
@property (strong) NSTimer *highlightingTimer;
@property (strong) MHEditorRuler *editorRuler;
@property (strong) NSColor *lineHighlightColor;
@property (strong) NSMutableArray *syntaxHighlightTags;
@property (assign) BOOL shiftKeyOn;
@property (strong) NSMutableArray *commandList;
@property (strong) NSMutableArray *wordHighlightRanges;
@property (strong) MHTableConfigureController *tableConfigureController;
@property (assign) CGFloat averageCharacterWidth;

@property (strong) NSDate *lastRulerUpdate;
@property (assign) BOOL rulerUpdateQueued;

@property (assign) NSInteger currentWrapStyle;
@property (assign) NSInteger currentWrapAt;

@property (strong) NSTextFinder *textFinder;

@property (strong) NSColor *documentEditorBackgroundColor;
@property (strong) NSColor *documentEditorMarginColor;
@property (strong) NSColor *currentLineColor;
@property (assign) BOOL highlightCurrentLine;

@property (assign) NSRange lastVisiblerange;
@property (assign) NSRange currentLineRange;
@property (assign) NSRect currentLineRect;

@property (assign) NSInteger wrapStyle;
@property (assign) NSInteger wrapAt;

@end

@implementation TeXTextView

- (id) initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container
{
  self = [super initWithFrame:frameRect textContainer:container];
  if (self) {
    didSetup = NO;
  }
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.editorRuler.clientView = nil;
  self.tableConfigureController.delegate = nil;
  self.delegate = nil;
  [self stopObserving];
}

- (void) awakeFromNib
{
//  NSLog(@"TextView awakeFromNib");
  
  self.zoomFactor = 0;
  
	newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
	whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
  
  if (didSetup == NO) {
    self.averageCharacterWidth = [NSString averageCharacterWidthForFont:[self font]];
    [self defaultSetup];
    [self setUpRuler];
    [self setupLists];
    
    [self setSmartInsertDeleteEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setContinuousSpellCheckingEnabled:NO];
    
    self.coloringEngine = [TeXColoringEngine coloringEngineWithTextView:self];
    
    [self applyFontAndColor:YES];
    [self updateThemeSettings];

    didSetup = YES;
  }
}



// Do the default setup for the text view.
- (void) defaultSetup
{
  if ([self respondsToSelector:@selector(setUsesFindBar:)]) {
    self.textFinder = [[NSTextFinder alloc] init];
//    [self.textFinder setClient:self];
//    [self.textFinder setFindBarContainer:[self enclosingScrollView]];
//    [self setUsesFindBar:YES];
//    [self setIncrementalSearchingEnabled:YES];
    [self setupTextFinder];
  } else {
    [self setUsesFindPanel:YES];
  }
  
  [self setTextContainerInset:NSMakeSize(5.0, 5.0)];
  
  [self setAllowsUndo:YES];
  [self setAllowsDocumentBackgroundColorChange:YES];
  [self setAutomaticDashSubstitutionEnabled:NO];
  [self setAutomaticDataDetectionEnabled:NO];
  [self setAutomaticTextReplacementEnabled:NO];
  [self setAutomaticQuoteSubstitutionEnabled:NO];
  
  // set color for line highlighting
  self.lineHighlightColor = [[self backgroundColor] shadowWithLevel:0.1];
  
	[[self layoutManager] setAllowsNonContiguousLayout:NO];
  [self turnOffWrapping];
  [self observePreferences];
  
  // set font and color
  
  // basic text
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  
  NSFont *font = theme.editorFont;
  NSColor *color = theme.documentTextColor;
  
  [[self textStorage] setFont:font];
  [[self textStorage] setForegroundColor:color];
  [self setFont:font];
  [self setTextColor:color];
  [self setTypingAttributes:[NSDictionary currentTypingAttributes]];
  
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(handleSelectionChanged:)
						 name:NSTextViewDidChangeSelectionNotification
					 object:self];
  
  [[[self enclosingScrollView] contentView] setPostsBoundsChangedNotifications:YES];
  [nc addObserver:self
         selector:@selector(handleFrameChangeNotification:)
             name:NSViewBoundsDidChangeNotification 
           object:[[self enclosingScrollView] contentView]];
  
  [nc addObserver:self
         selector:@selector(handleThemeChangedNotification:)
             name:TPThemeSelectionChangedNotification
           object:nil];
  
}


- (void) setUpRuler
{
  self.editorRuler = [MHEditorRuler editorRulerWithTextView:self];
  
  [[self layoutManager] ensureLayoutForTextContainer:[self textContainer]];
	
	NSScrollView *scrollView = [self enclosingScrollView];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[scrollView contentView] setAutoresizesSubviews:YES];
	[scrollView setVerticalRulerView:self.editorRuler];
	[scrollView setHasHorizontalRuler:NO];
	[scrollView setHasVerticalRuler:YES];
	[scrollView setRulersVisible:YES];
}

//- (void) performTextFinderAction:(id)sender
//{
//  [self.textFinder setClient:self];
//  [super performTextFinderAction:sender];
//}

- (void)setTextStorage:(NSTextStorage*)textStorage
{
  // update layout so that the findbar gets the correct notifications and the search works
  [self noteStringWillChange];
  
  // stop observations
  [self stopObservingTextStorage];
  
  // now change the text in the textview
  [self.layoutManager replaceTextStorage:textStorage];
  
  // string has changed
  [self noteStringDidChange];

  [self performSelectorOnMainThread:@selector(setWrapStyle) withObject:nil waitUntilDone:YES];
  [self observeTextStorage];
  
  [(TeXEditorViewController*)self.delegate performSelector:@selector(didChangeTextStorage) withObject:nil afterDelay:0.1];
  
  
  
}


- (void)setupTextFinder
{
//  NSLog(@"Setup finder");
//  self.textFinder = [[NSTextFinder alloc] init];
  [self.textFinder setClient:self];
  [self.textFinder setFindBarContainer:[self enclosingScrollView]];
  [self setUsesFindBar:YES];
  [self setIncrementalSearchingEnabled:YES];
//  NSLog(@"  finder client %@", self.textFinder.client);
//  NSLog(@"  finder findbar container %@", self.textFinder.findBarContainer);
}

- (void) noteStringWillChange
{
//  NSLog(@"Updating string for text finder %@", self.textFinder);
//  [self.textFinder cancelFindIndicator];
  [self setIncrementalSearchingEnabled:NO];
  [self.textFinder noteClientStringWillChange];
//  [self.textFinder performAction:NSTextFinderActionHideFindInterface];
}

- (void) noteStringDidChange
{
  [self setIncrementalSearchingEnabled:YES];
//  [self.textFinder findIndicatorNeedsUpdate];
}


- (void) setupLists
{
  // build the command list
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Commands" ofType:@"plist"];
	NSDictionary *commmandDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
  path = [[NSBundle mainBundle] pathForResource:@"ContextCommands" ofType:@"plist"];
	NSDictionary *contextCommandDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	self.commandList = [[NSMutableArray alloc] init];
	[self.commandList addObjectsFromArray:[commmandDict valueForKey:@"Commands"]];
	[self.commandList addObjectsFromArray:[contextCommandDict valueForKey:@"Commands"]];
}

-(void) turnOffWrapping
{
	NSTextContainer*	textContainer = [self textContainer];
	NSScrollView*		scrollView = [self enclosingScrollView];
	
	// Make sure we can see right edge of line:
	[scrollView setHasHorizontalScroller:YES];
	
	// Make text container so wide it won't wrap:
	[textContainer setContainerSize: NSMakeSize(LargeTextWidth, LargeTextHeight)];
	[textContainer setWidthTracksTextView:NO];
	[textContainer setHeightTracksTextView:NO];
	
	// Make sure text view is wide enough:
	[self setMaxSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
	[self setHorizontallyResizable:YES];
	[self setVerticallyResizable:YES];
  
  [self setWrapStyle];
}


#pragma mark -
#pragma mark Go to methods

- (IBAction) gotoLine:(id)sender
{
	[goToLineController showGoToSheet:[self window]];
}

-(void)	goToCharacter: (NSInteger)charNum
{
	[self goToRangeFrom: charNum toChar: charNum +1];
}


-(void) goToRangeFrom:(NSInteger)startCh toChar:(NSInteger)endCh
{
	NSRange theRange = { 0, 0 };
	
	theRange.location = startCh -1;
	theRange.length = endCh -startCh;
	
	if( startCh == 0 || startCh > [[self string] length] )
		return;
	
	[self scrollRangeToVisible: theRange];
	[self setSelectedRange: theRange];
}

-(void)	goToLineWithNumber:(NSNumber*)targetLineNumber
{
  [self goToLine:[targetLineNumber integerValue]];
}

-(void)	goToLine:(NSInteger)targetLineNumber
{
  NSString *text = [self string];
  NSInteger lineNumber = 0;
  NSInteger idx = 0;
  NSRange lineRange;
  NSInteger lineCount;
  NSAttributedString *attributedString = [self attributedString];
  BOOL foundLinenumber = NO;
  NSAttributedString *attLine;
  do
  {
    // get the range of the current line
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    // Get an attributed version of this line
    attLine = [attributedString attributedSubstringFromRange:lineRange];
    // Get a line count for this line of text.
    lineCount = [NSAttributedString lineCountForLine:attLine];
    lineNumber += lineCount;
    if (targetLineNumber == lineNumber) {
      foundLinenumber = YES;
      break;
    }
    // move on to the next line
		idx = NSMaxRange(lineRange);
  }
  while (idx < [text length]);
  
  // did we find something?
	if (foundLinenumber) {
    [self scrollRangeToVisible: lineRange];
    [self setSelectedRange:lineRange];
  } else {
    // did the user ask for a line number greater than the document length?
    if (targetLineNumber < lineNumber) {
      // didn't find a line number, this shouldn't happen
      NSString *format = [NSString stringWithFormat:@"Line number %ld not found in text", targetLineNumber];
      [NSException raise:@"Line number not found" format:format, targetLineNumber];
    } else {
      // tell the user the line number is too high
      NSAlert *alert = [NSAlert alertWithMessageText:@"Document length exceeded." defaultButton:@"OK"
                                     alternateButton:nil otherButton:nil informativeTextWithFormat:@"Requested line %ld is greater than the number of lines in the document", targetLineNumber];
      [alert runModal];
    }
  }
}



#pragma mark -
#pragma mark Control

- (IBAction)presentJumpBar:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(presentJumpBar:)]) {
    [self.delegate performSelector:@selector(presentJumpBar:) withObject:self];
  }
}

// Comment out the selected text.
- (IBAction)commentSelection:(id)sender
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
  
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];
	// Get a mutable string for this range
	NSInteger inserted = 0;
  NSMutableString *newString = [NSMutableString string];
	[newString appendString:[str substringWithRange:r]];
  
  NSString *commentString = [NSString stringWithFormat:@"%c", [self.coloringEngine commentCharacter]];
  
  [newString insertString:commentString atIndex:0];
  inserted++;
  
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
      [newString insertString:commentString atIndex:ll+1];
      inserted++;
		}
	}
  
  if (inserted == 0)
    return;
  
  if ([self shouldChangeTextInRange:r replacementString:newString]) {
    [self replaceCharactersInRange:r withString:newString];
    [self didChangeText];
  }
  
//	[self setSelectedRange:r];
//	[self delete:self];
//	[self insertText:newString];
	
	NSInteger len = selRange.length+inserted-1;
	
  if (len<0)
    len = 0;
  [self setSelectedRange:NSMakeRange(selRange.location+1,len)];
	
  // color visible text
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
}

// Uncomment the selected text
- (IBAction)uncommentSelection:(id)sender
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
  
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];
	// Get a mutable string for this range
	NSMutableString *newString = [NSMutableString string];
	[newString appendString:[str substringWithRange:r]];
  
  // find first non-whitespace character
  NSInteger start = 0;
  while (start < [newString length]) {
    if (![whitespaceCharacterSet characterIsMember:[newString characterAtIndex:start]]) {
      break;
    }
    start++;
  }
  
  unichar commentChar = [self.coloringEngine commentCharacter];
	
  int inserted = 0;
	if ([newString characterAtIndex:start]==commentChar) {
    
    [newString replaceCharactersInRange:NSMakeRange(start, 1) withString:@""];
    inserted--;
    
	}
  
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
      
      start = ll+1;
      while (start < [newString length]) {
        if (![whitespaceCharacterSet characterIsMember:[newString characterAtIndex:start]]) {
          break;
        }
        start++;
      }
      if (start < [newString length]) {
        if ([newString characterAtIndex:start] == commentChar) {
          [newString replaceCharactersInRange:NSMakeRange(start, 1) withString:@""];
          inserted--;
        }
      }
		}
	}
	
  if (inserted == 0)
    return;
  
  if ([self shouldChangeTextInRange:r replacementString:newString]) {
    [self replaceCharactersInRange:r withString:newString];
    [self didChangeText];
  }
  
//	[self setSelectedRange:r];
//	[self delete:self];
//	[self insertText:newString];
	NSInteger len = selRange.length+inserted+1;
	
  if (len<0)
    len = 0;
  [self setSelectedRange:NSMakeRange(selRange.location-1,len)];
	
  // color visible text
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
}

- (IBAction)toggleCommentForParagraph:(id)sender
{
  [self selectParagraph:self];
  [self performSelector:@selector(toggleCommentForSelection:) withObject:self afterDelay:0];
}

// Toggle the commented out state for the current selection
- (IBAction) toggleCommentForSelection:(id)sender
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
  unichar commentChar = [self.coloringEngine commentCharacter];
  
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];
  
  // fix the range in case we don't start the paragraph at a comment
  
	// Get a mutable string for this range
	NSMutableString *newString = [NSMutableString string];
  NSString *substring = [str substringWithRange:r];
	[newString appendString:substring];
  // look for first non-whitespace character
  NSInteger move = 0;
  NSInteger start = 0;
  while (start < [newString length]) {
    if (![whitespaceCharacterSet characterIsMember:[newString characterAtIndex:start]]) {
      break;
    }
    start++;
  }
	if (start < [newString length] && [newString characterAtIndex:start]==commentChar) {
    
    // remove all comment chars
    while([newString characterAtIndex:start]==commentChar) {
      [newString replaceCharactersInRange:NSMakeRange(start, 1) withString:@""];
      move--;
    }
    
	} else {
		[newString insertString:[NSString stringWithFormat:@"%c", commentChar] atIndex:0];
		move++;
	}
  
	NSInteger inserted = 0;
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
      
      // look forward on the first line for the first non-whitespace character
      start = ll+1;
      while (start < [newString length]) {
        if (![whitespaceCharacterSet characterIsMember:[newString characterAtIndex:start]]) {
          break;
        }
        start++;
      }
      
			if (start < [newString length] && [newString characterAtIndex:start] == commentChar) {
        while([newString characterAtIndex:start]==commentChar) {
          [newString replaceCharactersInRange:NSMakeRange(start, 1) withString:@""];
          inserted--;
        }
			} else {
				[newString insertString:[NSString stringWithFormat:@"%c", commentChar] atIndex:ll+1];
				inserted++;
			}
		}
	}
  
  if ([self shouldChangeTextInRange:r replacementString:newString]) {
    [self replaceCharactersInRange:r withString:newString];
    [self didChangeText];
  }
  
	NSInteger len = selRange.length+inserted;
	
  if (len<0)
    len = 0;
  [self setSelectedRange:NSMakeRange(selRange.location+move,len)];
	
  // color visible text
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
	
	return;
}


- (IBAction) toggleControlCharacters:(id)sender
{
  [[self layoutManager] setShowsControlCharacters:![[self layoutManager] showsControlCharacters]];
}

- (IBAction) toggleInvisibleCharacters:(id)sender
{
  [[self layoutManager] setShowsInvisibleCharacters:![[self layoutManager] showsInvisibleCharacters]];
}

- (IBAction)zoomIn:(id)sender
{
  self.zoomFactor += 2;
  if (self.zoomFactor > kMaxZoom) {
    self.zoomFactor = kMaxZoom;
  }
  
  [self applyFontAndColor:YES];
}

- (IBAction)zoomOut:(id)sender
{
  self.zoomFactor -= 2;
  if (self.zoomFactor < 0) {
    self.zoomFactor = 0;
  }
  
  [self applyFontAndColor:YES];
}

#pragma mark -
#pragma mark LaTeX Formatting

- (void) formatSelectionWithCommand:(NSString*)command
{
  NSRange sel = [self selectedRange];
  if (sel.length>0) {
    NSString *text = [[self string] substringWithRange:sel];
    NSString *newString = [NSString stringWithFormat:@"\\%@{%@}", command, text];
    if ([self shouldChangeTextInRange:sel replacementString:newString]) {
      [self replaceCharactersInRange:sel withString:newString];
      [self didChangeText];
    }
  } else {
    
    // check if we have whitespace before
    NSString *prepad = @"";
    NSString *postpad = @"";
    if (sel.location > 0) {
      unichar c = [self.string characterAtIndex:sel.location-1];
      if ([whitespaceCharacterSet characterIsMember:c] == NO &&
          [newLineCharacterSet characterIsMember:c] == NO) {
        prepad = @" ";
      }
    }
    
    if (NSMaxRange(sel) < [self.string length]-1) {
      unichar c = [self.string characterAtIndex:NSMaxRange(sel)];
      if ([whitespaceCharacterSet characterIsMember:c] == NO &&
          [newLineCharacterSet characterIsMember:c] == NO) {
        postpad = @" ";
      }
    }
    
    NSString *newString = [NSString stringWithFormat:@"%@\\%@{}%@", prepad, command, postpad];
    if ([self shouldChangeTextInRange:sel replacementString:newString]) {
      [self replaceCharactersInRange:sel withString:newString];
      [self didChangeText];
    }
    sel = [self selectedRange];
    NSRange newSel = NSMakeRange(sel.location-1-postpad.length, 0);
    [self setSelectedRange:newSel];
  }
}

- (IBAction)latexFormatBold:(id)sender
{
  [self formatSelectionWithCommand:@"textbf"];
}

- (IBAction)latexFormatItalic:(id)sender
{
  [self formatSelectionWithCommand:@"textit"];
}

- (IBAction)latexFormatSmallCaps:(id)sender
{
  [self formatSelectionWithCommand:@"textsc"];
}

- (IBAction)latexFormatRoman:(id)sender
{
  [self formatSelectionWithCommand:@"textrm"];
}

- (IBAction)latexFormatTypewritter:(id)sender
{
  [self formatSelectionWithCommand:@"texttt"];
}

- (IBAction)latexFormatSansSerif:(id)sender
{
  [self formatSelectionWithCommand:@"textsf"];
}

- (IBAction)latexFormatSlanted:(id)sender
{
  [self formatSelectionWithCommand:@"textsl"];
}

- (IBAction)latexFormatEmphasized:(id)sender
{
  [self formatSelectionWithCommand:@"emph"];
}

- (IBAction)latexFormatUnderline:(id)sender
{
  [self formatSelectionWithCommand:@"underline"];
}

- (IBAction)latexFormatFootnote:(id)sender
{
  [self formatSelectionWithCommand:@"footnote"];
}

- (IBAction)latexFormatEscapeUnderscore:(id)sender
{
  NSRange sel = [self selectedRange];
  if (sel.length>0) {
    NSString *text = [[self string] substringWithRange:sel];
    NSString *newString = [text stringByReplacingOccurrencesOfString:@"_" withString:@"\\_"];
    if ([self shouldChangeTextInRange:sel replacementString:newString]) {
      [self replaceCharactersInRange:sel withString:newString];
      [self didChangeText];
    }
  }

}

#pragma mark -
#pragma mark Syntax highlighting

- (NSArray*)bookmarksForLineRange:(NSRange)aRange
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForCurrentFileInLineRange:)]) {
    id<TeXTextViewDelegate> d = (id<TeXTextViewDelegate>)self.delegate;
    return [d bookmarksForCurrentFileInLineRange:aRange];
  }
  return @[];
}


- (void) resetLineNumbers
{
  [self.editorRuler resetLineNumbers];
//  [self setNeedsDisplay:YES];
}

- (void) colorWholeDocument
{
  //  NSLog(@"Color whole doc: delegate %@", self.delegate);
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    if (![self.delegate performSelector:@selector(shouldSyntaxHighlightDocument)]) {
      return;
    }
  }
  //  NSLog(@"Coloring whole document");
  if (self.coloringEngine) {
    [self.coloringEngine colorTextView:self
                           textStorage:[self textStorage]
                         layoutManager:[self layoutManager]
                               inRange:NSMakeRange(0, [[self string] length])];
    [self setNeedsDisplay:YES];
  }
}

- (void) applyCurrentTextColorToLine
{
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSRange pRange = [self rangeForCurrentLine];
  NSColor *color = theme.documentTextColor;
  [[self textStorage] addAttribute:NSForegroundColorAttributeName value:color range:pRange];
}

- (void) colorVisibleText
{  
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    if (![[self delegate] performSelector:@selector(shouldSyntaxHighlightDocument)]) {
      return;
    }
  }
  
  if (self.coloringEngine) {
    NSRange vr = [self getVisibleRange];
//    NSLog(@"Color visible %@", NSStringFromRange(vr));
    [self.coloringEngine colorTextView:self
                           textStorage:[self textStorage]
                         layoutManager:[self layoutManager]
                               inRange:vr];
  } // End if colouring engine
}

- (void) colorText
{
  //  NSLog(@"Color visible text: delegate %@", self.delegate);
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    if (![[self delegate] performSelector:@selector(shouldSyntaxHighlightDocument)]) {
      return;
    }
  }
  
  NSRange vr = [self getVisibleRange];
//  NSLog(@"Coloring text %@", NSStringFromRange(vr));
  
  if (self.coloringEngine) {
    
    if (self.lastVisiblerange.location == vr.location) {
      // syntax highlight line
      //      NSLog(@"Highlight line");
      
      NSRange r = [[self string] lineRangeForRange:[self selectedRange]];
      
      [self.coloringEngine colorTextView:self
                             textStorage:[self textStorage]
                           layoutManager:[self layoutManager]
                                 inRange:r];
      
    } else {
      
      
      //      NSLog(@"Highlight visible");
      // adjust range to be greater than the visible range
      NSInteger loc = vr.location-vr.length/2;
      NSInteger strLen = [[self string] length];
      if (loc < 0)
        loc = 0;
      NSInteger length = vr.length*2;
      if (loc+length >= strLen) {
        length = strLen - loc - 1;
      }
      if (length < 0) {
        length = 0;
      }
      
      // make sure we start and end at line ends
      NSRange lr = [[self string] lineRangeForRange:NSMakeRange(loc, 0)];
      NSInteger diff = loc - lr.location;
      loc = lr.location;
      length += diff;
      lr = [[self string] lineRangeForRange:NSMakeRange(loc+length, 0)];
      NSRange r = NSMakeRange(loc, NSMaxRange(lr)-loc);
      
      
      // syntax highlight full visible range
      [self.coloringEngine colorTextView:self
                             textStorage:[self textStorage]
                           layoutManager:[self layoutManager]
                                 inRange:r];
    }
    
    // store visible range
    self.lastVisiblerange = vr;
    
  } // End if colouring engine
}

#pragma mark -
#pragma mark Actions



- (void) handleFrameChangeNotification:(NSNotification*)aNote
{
  NSDate *now = [NSDate date];
  if (self.lastRulerUpdate != nil && [now timeIntervalSinceDate:self.lastRulerUpdate] < kRulerUpdateInterval) {
    if (self.rulerUpdateQueued == NO) {
      self.rulerUpdateQueued = YES;
      [self performSelector:@selector(handleFrameChangeNotification:) withObject:aNote afterDelay:kRulerUpdateInterval];
    }
    return;
  }
  
  self.lastRulerUpdate = now;
  
  [_popupList dismiss];
  [self colorVisibleText];
  [self highlightMatchingWords];
  [self updateEditorRuler];
  
  self.rulerUpdateQueued = NO;
}

- (void) updateEditorRuler
{
  //NSLog(@"Update ruler");
  [self.editorRuler resetLineNumbers];
  [self.editorRuler setNeedsDisplay:YES];
//  [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark KVO

- (void) stopObserving
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentLineHeightMultiple]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TELineLength]];
}

- (void) observePreferences
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentLineHeightMultiple]
                options:NSKeyValueObservingOptionNew
                context:NULL];
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]
                options:NSKeyValueObservingOptionNew
                context:NULL];
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]
                options:NSKeyValueObservingOptionNew
                context:NULL];
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]
                options:NSKeyValueObservingOptionNew
                context:NULL];
	
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TELineLength]
                options:NSKeyValueObservingOptionNew
                context:NULL];
  

}


- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]]) {
    [self performSelectorOnMainThread:@selector(updateEditorRuler) withObject:nil waitUntilDone:YES];
    [self.editorRuler recalculateThickness];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]]) {
    [self performSelectorOnMainThread:@selector(updateEditorRuler) withObject:nil waitUntilDone:YES];
    [self.editorRuler recalculateThickness];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineLength]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEDocumentLineHeightMultiple]]) {
    [self applyFontAndColor:YES];
	}
  

}

- (void) updateThemeSettings
{
  TPTheme *theme = [[TPThemeManager sharedManager] currentTheme];
  self.documentEditorMarginColor = theme.documentEditorMarginColor;
  self.documentEditorBackgroundColor = theme.documentEditorBackgroundColor;
  self.currentLineColor = theme.currentLineColor;
  self.highlightCurrentLine = [theme.highlightCurrentLine boolValue];
  
  [self setSelectedTextAttributes:
   @{NSBackgroundColorAttributeName: theme.documentEditorSelectionBackgroundColor,
   NSForegroundColorAttributeName: theme.documentEditorSelectionColor}];

}

- (void) handleThemeChangedNotification:(NSNotification*)aNote
{
  [self applyFontAndColor:YES];
  [self updateThemeSettings];
  
  NSRange vr = [self getVisibleRange];
  [[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:vr];
  [self highlightMatchingWords];
  [self setNeedsDisplayInRect:[self bounds] avoidAdditionalLayout:YES];
  
}

- (void) setTypingColor:(NSColor*)aColor
{
  NSDictionary *catts = [NSDictionary currentTypingAttributes];
  NSMutableDictionary *atts = [catts mutableCopy];
  [atts setValue:aColor forKey:NSForegroundColorAttributeName];
  [self setTypingAttributes:atts];
}

- (void) applyLineSpacingToDocument
{
  NSDictionary *currentTypingAtts = [self typingAttributes];
  NSDictionary *atts = [NSDictionary currentTypingAttributes];
  NSParagraphStyle *newPS = atts[NSParagraphStyleAttributeName];
  NSParagraphStyle *oldPS = currentTypingAtts[NSParagraphStyleAttributeName];
  
  if (oldPS.lineHeightMultiple == newPS.lineHeightMultiple)
    return;
  
  NSRange r = NSMakeRange(0, [[self string] length]);
  [self.textStorage removeAttribute:NSParagraphStyleAttributeName range:r];
  [self.textStorage addAttribute:NSParagraphStyleAttributeName value:newPS range:r];
  [self setDefaultParagraphStyle:newPS];
}

- (void) forceFontAndColor
{
  [self applyFontAndColor:YES];
}

- (void) applyFontAndColor:(BOOL)forceUpdate
{
  TPTheme *theme = [[TPThemeManager sharedManager] currentTheme];
  
  //NSLog(@"%@", NSStringFromSelector(_cmd));
  NSDictionary *atts = [NSDictionary currentTypingAttributes];
  NSFont *newFont = atts[NSFontAttributeName];
  newFont = [NSFont fontWithName:[newFont fontName] size:self.zoomFactor+[newFont pointSize]];
  NSColor *newColor = atts[NSForegroundColorAttributeName];
  NSParagraphStyle *newPS = atts[NSParagraphStyleAttributeName];
  
  if (![newFont isEqualTo:[self font]] || forceUpdate) {
//    NSLog(@"Setting new font %@", newFont);
    [self setFont:newFont];
    self.averageCharacterWidth = [NSString averageCharacterWidthForFont:newFont];
  }
  if (![newColor isEqualTo:[self textColor]] || forceUpdate) {
//    NSLog(@"Setting new color");
    [self setTextColor:newColor];
  }
  if (![newPS isEqual:[self defaultParagraphStyle]]) {
//    NSLog(@"Setting new paragraph style");
    [self.textStorage addAttribute:NSParagraphStyleAttributeName value:newPS range:NSMakeRange(0, [[self string] length])];
    [self setDefaultParagraphStyle:newPS];
  }
  
  NSDictionary *currentAtts = [self typingAttributes];
  if (![currentAtts isEqualToDictionary:atts] || forceUpdate) {
//    NSLog(@"Setting typing attributes %@", newFont);
//    [self setTypingAttributes:atts];
    [self setTypingAttributes:@{NSForegroundColorAttributeName : newColor,
         NSFontAttributeName : newFont}];
  } else {
    //    NSLog(@"Skipping setting atts");
  }
  
  // background color
//  NSColor *c = theme.documentEditorBackgroundColor;
  // for some reason we need to do this otherwise the scrolling jumps around in the textview.
//  [self performSelector:@selector(setBackgroundColor:) withObject:c afterDelay:0];
  
  // cursor color
  NSColor *cc =  theme.documentEditorCursorColor;
  [self setInsertionPointColor:cc];
  
  // selection color
//  [self setSelectedTextAttributes:
//   @{NSBackgroundColorAttributeName: theme.documentEditorSelectionBackgroundColor,
//   NSForegroundColorAttributeName: theme.documentEditorSelectionColor}];
  
}

- (void) setWrapStyle
{
  self.wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] integerValue];
  self.wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] integerValue];
  
  // cache wrap settings
  self.currentWrapStyle = self.wrapStyle;
  self.currentWrapAt = self.wrapAt;
  
  NSTextContainer *textContainer = [self textContainer];
  if (self.wrapStyle == TPSoftWrap) {
    //NSLog(@"Soft wrap");
    [textContainer setWidthTracksTextView:NO];
    [textContainer setContainerSize:NSMakeSize(self.averageCharacterWidth*self.wrapAt*kFontWrapScaleCorrection, LargeTextHeight)];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:YES];
  }	else if (self.wrapStyle == TPNoWrap) {
    //NSLog(@"No wrap");
    [textContainer setWidthTracksTextView:NO];
    [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:YES];
  }	else if (self.wrapStyle == TPWindowWrap) {
    
    [self setVerticallyResizable:YES];
    [self setHorizontallyResizable: NO];
    [self setAutoresizingMask: NSViewWidthSizable];
    [textContainer setWidthTracksTextView: YES];
    [self setFrameSize: [[self enclosingScrollView] contentSize]];
    
  } else {
    //NSLog(@"Hard wrap");
    // set large size - hard wrap is handled in the wrapLine
    [textContainer setWidthTracksTextView:NO];
    [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:YES];
  }
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Text Storage Observing

- (void) processEditing:(NSNotification*)aNote
{
	//[self setNeedsDisplayInRect:[self bounds] avoidAdditionalLayout:NO];
}

- (void) stopObservingTextStorage
{
	if ([self textStorage]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self
									name:NSTextStorageDidProcessEditingNotification
								object:[self textStorage]];
	}
}


- (void) observeTextStorage
{
	if ([self textStorage]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		
		// Register for "text changed" notifications of our text storage:
		[nc addObserver:self selector:@selector(processEditing:)
							 name: NSTextStorageDidProcessEditingNotification
						 object:[self textStorage]];
	}
	
}

#pragma mark -
#pragma mark Completion and spelling



- (NSArray*)userDefaultCommands
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *commandDicts = [defaults valueForKey:TEUserCommands];
  NSMutableArray *commands = [NSMutableArray array];
  for (NSDictionary *dict in commandDicts) {
    [commands addObject:[dict valueForKey:@"Name"]];
  }
  return commands;
}

- (IBAction)cancelOperation:(id)sender
{
  if (_popupList && _popupList.isVisible) {
    [_popupList dismiss];
  } else {
    [self completeStuff:sender];
  }
}

- (IBAction)complete:(id)sender
{
  [self completeStuff:sender];
}

- (void) completeFromList:(NSArray*)aList
{
  //  NSLog(@"Complete from list");
	if ([aList count]==0) {
    [_popupList dismiss];
		return;
  }
  
	NSPoint point = [self listPointForCurrentWord];
	NSPoint wp = [self convertPoint:point toView:nil];
  //  NSLog(@"Completing %@ from list of %d items", popupList, [aList count]);
  if (_popupList == nil || [_popupList mode] != TPPopupListReplace) {
    //    NSLog(@"Making popup...");
    if (_popupList) {
      [_popupList dismiss];
    }
    
    _popupList = [[TPPopupListWindowController alloc] initWithEntries:aList
                                                              atPoint:wp
                                                       inParentWindow:[self window]
                                                                 mode:TPPopupListReplace
                                                                title:@"Replace..."];
    [_popupList setDelegate:self];
    [_popupList showPopup];
  } else {
    NSPoint point = [self listPointForCurrentWord];
    NSPoint current = [_popupList currentPoint];
    NSPoint wp = [self convertPoint:point toView:nil];
    // update the window in y
    if (current.y == 0.0 && current.x == 0.0) {
      [_popupList moveToPoint:wp];
    } else {
      [_popupList moveToPoint:NSMakePoint(current.x, wp.y)];
    }
    [_popupList setList:aList];
    [_popupList showPopup];
  }
}

- (void) insertFromList:(NSArray*)aList
{
	if ([aList count]==0) {
    [_popupList dismiss];
		return;
  }
	
	NSPoint point = [self listPointForCurrentWord];
	//			NSLog(@"Point for word:%@", NSStringFromPoint(point));
	NSPoint wp = [self convertPoint:point toView:nil];
	[self clearSpellingList];
  if (_popupList == nil || [_popupList mode] != TPPopupListInsert) {
    if (_popupList) {
      [_popupList dismiss];
    }
    _popupList = [[TPPopupListWindowController alloc] initWithEntries:aList
                                                              atPoint:wp
                                                       inParentWindow:[self window]
                                                                 mode:TPPopupListInsert
                                                                title:@"Insert..."];
    [_popupList setDelegate:self];
    [_popupList showPopup];
  } else {
    NSPoint point = [self listPointForCurrentWord];
    NSPoint current = [_popupList currentPoint];
    NSPoint wp = [self convertPoint:point toView:nil];
    // update the window in y
    if (current.y == 0.0 && current.x == 0.0) {
      [_popupList moveToPoint:wp];
    } else {
      [_popupList moveToPoint:NSMakePoint(current.x, wp.y)];
    }
    [_popupList setList:aList];
    [_popupList showPopup];
  }
}

- (IBAction) showSpellingList:(id)sender
{
	NSString *word = [self currentWord];
  //	NSLog(@"Checking spelling for '%@'", word);
	if (word) {
		NSSpellChecker *sc = [NSSpellChecker sharedSpellChecker];
    NSArray *guesses = [sc guessesForWordRange:NSMakeRange(0, [word length]) inString:word language:[[NSSpellChecker sharedSpellChecker] language] inSpellDocumentWithTag:0];
		if ([guesses count]>0) {
			
			NSPoint point = [self listPointForCurrentWord];
      //			NSLog(@"Point for word:%@", NSStringFromPoint(point));
			NSPoint wp = [self convertPoint:point toView:nil];
			[self clearSpellingList];
      if (_popupList == nil) {
        _popupList = [[TPPopupListWindowController alloc] initWithEntries:guesses
                                                                  atPoint:wp
                                                           inParentWindow:[self window]
                                                                     mode:TPPopupListSpell
                                                                    title:@"Correct..."];
        [_popupList setDelegate:self];
        [_popupList showPopup];
      } else {
        NSPoint point = [self listPointForCurrentWord];
        NSPoint wp = [self convertPoint:point toView:nil];
        // update the window in y
        [_popupList moveToPoint:wp];
        [_popupList setList:guesses];
        [_popupList showPopup];
      }
		}
	}
}

- (void) clearSpellingList
{
	if (_popupList) {
    [_popupList dismiss];
	}
}

- (void) insertWordAtCurrentLocation:(NSString*)aWord
{
	NSRange curr = [self selectedRange];
	NSRange rr = NSMakeRange(curr.location, 0);
  [self replaceTextInRange:rr withText:aWord];
}

- (void) replaceWordUpToCurrentLocationWith:(NSString*)aWord
{
	[self selectUpToCurrentLocation];
	NSRange sel = [self selectedRange];
  [self replaceTextInRange:sel withText:aWord];
}

- (void) replaceWordAtCurrentLocationWith:(NSString*)aWord
{
	NSRange sel = [self rangeForCurrentWord];
  [self replaceTextInRange:sel withText:aWord];
}

- (void) replaceTextInRange:(NSRange)aRange withText:(NSString*)text
{
  NSAttributedString *astr = [NSAttributedString stringWithPlaceholdersRestored:text attributes:[NSDictionary currentTypingAttributes]];
	if ([self shouldChangeTextInRange:aRange replacementString:[astr string]]) {
    [self.textStorage replaceCharactersInRange:aRange withAttributedString:astr];
    if ([astr length] < [text length]) {
      [self setSelectedRange:NSMakeRange(aRange.location, 0)];
      [self jumpToNextPlaceholder:self];
    }
    [self clearSpellingList];
    [self colorText];
    [self didChangeText];
  }
}

#pragma mark -
#pragma mark Folding

- (IBAction) unfoldSelection:(id)sender
{
	// get the line
	NSRange sel = [self selectedRange];
	NSAttributedString *attStr = [self attributedString];
	NSRange lineRange = [[self string] lineRangeForRange:NSMakeRange(sel.location, 0)];
	NSAttributedString *line = [attStr attributedSubstringFromRange:lineRange];
	
	int idx = 0;
	NSRange effRange;
	while (idx < [line length]) {
		
		NSTextAttachment *att = [line attribute:NSAttachmentAttributeName
																		atIndex:idx
														 effectiveRange:&effRange];
		
		if (att && [att respondsToSelector:@selector(object)]) {
			NSData *data = [[att fileWrapper] regularFileContents];
			NSString *code = [[NSString alloc] initWithData:data encoding:[MHFileReader defaultEncoding]];
			// delete the line up to and including the attachment
      [[self textStorage] beginEditing];
			[[self textStorage] replaceCharactersInRange:NSMakeRange(lineRange.location, idx+2)
																				withString:[code stringByAppendingString:@"\n"]];
			[[self textStorage] endEditing];
		}
		
		idx++;
	}
	
}

- (IBAction) collapseAll:(id)sender
{
  //  NSLog(@"Collapse all");
  [self.editorRuler collapseAll];
}

- (IBAction) expandAll:(id)sender
{
  //  NSLog(@"Expand all");
	[self unfoldAllInRange:NSMakeRange(0, [[self string] length]) max:100000];
}

- (void) unfoldAllInRange:(NSRange)aRange max:(NSInteger)max
{
  //  NSLog(@"unfoldAllInRange");
	NSAttributedString *text = [[self textStorage] attributedSubstringFromRange:aRange];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:text];
  
	[string unfoldAllInRange:aRange max:max];
  [string addAttributes:[NSDictionary currentTypingAttributes] range:NSMakeRange(0, [string length])];
	if ([[string string] isEqualToString:[text string]] == NO) {
    // then we unfoled
    [[self textStorage] beginEditing];
    [[self textStorage] deleteCharactersInRange:aRange];
    [[self textStorage] insertAttributedString:string atIndex:aRange.location];
    [[self textStorage] endEditing];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TEDidFoldUnfoldTextNotification object:self];
    [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
  }
}

- (void) unfoldTextWithFolder:(MHCodeFolder*)aFolder
{
	NSRange lineRange = [[self string] lineRangeForRange:NSMakeRange(aFolder.startIndex, 0)];
	[self unfoldAllInRange:lineRange max:10000];
}

- (void) foldTextWithFolder:(MHCodeFolder*)aFolder
{
  //  NSLog(@"foldTextWithFolder");
	NSRange foldRange = NSMakeRange(aFolder.startIndex, aFolder.endIndex-aFolder.startIndex);
  //  NSLog(@"Folding range %@", NSStringFromRange(foldRange));
	NSAttributedString *fold = [[self textStorage] attributedSubstringFromRange:foldRange];
  
	// make an attachement object
	TPFoldedCodeSnippet *snippet = [[TPFoldedCodeSnippet alloc] initWithCode:fold];
  snippet.object = aFolder;
	
	// make an attachment
	NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:snippet];
	NSMutableAttributedString *aaa = [[NSMutableAttributedString alloc] initWithAttributedString:attachment];
	
	[aaa addAttribute:NSCursorAttributeName
              value:[NSCursor pointingHandCursor]
              range:NSMakeRange(0, [aaa length])];
  
	[[self textStorage] deleteCharactersInRange:foldRange];
	[[self textStorage] insertAttributedString:aaa atIndex:foldRange.location];
  
  // update editor ruler
  [[NSNotificationCenter defaultCenter] postNotificationName:TEDidFoldUnfoldTextNotification object:self];
}



- (void) unfoldAttachment:(NSTextAttachment*)snippet atIndex:(NSNumber*)index
{
  //  NSLog(@"unfoldAttachment");
	// find the location of this attachment in the text
	NSData *data = [[snippet fileWrapper] regularFileContents];
	NSAttributedString *code = [[NSAttributedString alloc] initWithRTFD:data documentAttributes:nil];
	NSRange attRange = NSMakeRange([index unsignedLongValue], 1);
  [[self textStorage] beginEditing];
	[[self textStorage] removeAttribute:NSAttachmentAttributeName range:attRange];
	[[self textStorage] replaceCharactersInRange:attRange withAttributedString:code];
  [[self textStorage] endEditing];
  
  // update editor ruler
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
  [self updateEditorRuler];
  [[NSNotificationCenter defaultCenter] postNotificationName:TEDidFoldUnfoldTextNotification object:self];
}

#pragma mark -
#pragma mark TeXTextView delegate


-(NSString*)codeForCommand:(NSString *)command
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(codeForCommand:)]) {
    if (command && [command length]>0) {
      if ([command characterAtIndex:0] == '#') {
        command = [command substringFromIndex:1];
      }
      NSString *code = [self.delegate performSelector:@selector(codeForCommand:) withObject:command];
      return code;
    }
  }
  return nil;
}

-(NSArray*)commandsBeginningWithPrefix:(NSString*)prefix;
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(commandsBeginningWithPrefix:)]) {
    return [self.delegate performSelector:@selector(commandsBeginningWithPrefix:) withObject:prefix];
  }
  return nil;
}


#pragma mark -
#pragma mark Selection

- (void) jumpToLine:(NSInteger)aLinenumber select:(BOOL)selectLine
{
  NSMutableAttributedString *aStr = [[self textStorage] mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  MHLineNumber *matchingLine = nil;
  for (MHLineNumber *line in lineNumbers) {
    if (line.number == aLinenumber) {
      matchingLine = line;
      break;
    }
  }
  if (matchingLine) {
    if (selectLine) {
      [self setSelectedRange:matchingLine.range];
      [self scrollRangeToVisible:matchingLine.range];
    } else {
      NSRange r = NSMakeRange(matchingLine.range.location, 0);
      [self setSelectedRange:r];
      [self scrollRangeToVisible:r];
    }
  }
}


- (void) jumpToLine:(NSInteger)aLinenumber inFile:(FileEntity*)aFile select:(BOOL)selectLine
{
  NSMutableAttributedString *aStr = [[[aFile document] textStorage] mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  MHLineNumber *matchingLine = nil;
  for (MHLineNumber *line in lineNumbers) {
    if (line.number == aLinenumber) {
      matchingLine = line;
      break;
    }
  }
  if (matchingLine) {
    if (selectLine) {
      [self setSelectedRange:matchingLine.range];
      [self scrollRangeToVisible:matchingLine.range];
    } else {
      NSRange r = NSMakeRange(matchingLine.range.location, 0);
      [self setSelectedRange:r];
      [self scrollRangeToVisible:r];
    }
  }
}

- (void) replaceRange:(NSRange)aRange withText:(NSString*)replacement scrollToVisible:(BOOL)scroll animate:(BOOL)animate
{
  
  if ([self shouldChangeTextInRange:aRange replacementString:replacement]) {
    [self replaceCharactersInRange:aRange withString:replacement];
    [self didChangeText];
  }
  
//  [self setSelectedRange:aRange];
//  [self insertText:replacement];
  
  NSRange r = NSMakeRange(aRange.location, [replacement length]);
  
  if (scroll) {
    [self scrollRangeToVisible:r];
  }
  if (animate) {
    [self showFindIndicatorForRange:r];
  }
}

- (void) selectRange:(NSRange)aRange scrollToVisible:(BOOL)scroll animate:(BOOL)animate
{
  if (NSMaxRange(aRange) < [[self string] length]) {
    [self setSelectedRange:aRange];
    if (scroll) {
      [self scrollRangeToVisible:aRange];
    }
    if (animate) {
      [self showFindIndicatorForRange:aRange];
    }
  }
  
  [self colorVisibleText];
}


- (NSPoint) listPointForCurrentWord
{
	NSRange curr = [self selectedRange];
	[self selectWord:self];
	NSRange sel = [self selectedRange];
	[self setSelectedRange:curr];
	NSLayoutManager *lm = [self layoutManager];
	NSRange wr = NSMakeRange(sel.location+sel.length-1,1);
	NSRange gr = [lm glyphRangeForCharacterRange:wr actualCharacterRange:NULL];
  //	NSLog(@"Glyph range: %@", NSStringFromRange(gr));
	NSRect bounds = [lm boundingRectForGlyphRange:gr inTextContainer:[self textContainer]];
  //	NSLog(@"bounds: %@", NSStringFromRect(bounds));
	return bounds.origin;
}

- (NSString*) currentWord
{
	NSString *string = [self string];
	NSRange sel = [self rangeForCurrentWord];
  //	NSLog(@"Word range: %@", NSStringFromRange(sel));
	NSString *text = [string substringWithRange:sel];
	return text;
}

- (NSRange) rangeForCurrentCommand
{
  NSString *string = [self string];
  NSRange sel = [self selectedRange];
  NSInteger end = sel.location;
  if (end < 0 || end > [string length]) {
    return NSMakeRange(NSNotFound, 0);
  }
  NSInteger idx = end-1;
  NSInteger start = -1;
  BOOL foundSlash = NO;
  
  // edge case: if we are at the just outside the end of a command with an argument
  // this algorithm will return the command, which it shouldn't. So check for closing
  // brackets just before the selection point
  if (sel.location > 0) {
    unichar c = [string characterAtIndex:sel.location-1];
    if (c == '}' || c == ']') {
      return NSMakeRange(NSNotFound, 0);
    }
  }
  //  NSLog(@"Location %d, string length %d", end, [string length]);
  
  // go backwards until we find a '\'
  // stop if we hit a } or a newline
  unichar lastchar;
  unichar c = 'x';
  while (idx >= 0) {
    lastchar = c;
    c = [string characterAtIndex:idx];
    if ([newLineCharacterSet characterIsMember:c] ||
        c == '}' ) {
      break;
    }
    
    if (c == '\\' && ![whitespaceCharacterSet characterIsMember:lastchar]) {
      // if this is preceded by another \, we don't count this as a command, and return not found
      if (idx > 0) {
        unichar pc = [string characterAtIndex:idx-1];
        if (pc == '\\') {
          return NSMakeRange(NSNotFound, 0);
        }
      }
      foundSlash = YES;
      start = idx;
      break;
    }
    
    idx--;
  }
  
  //  NSLog(@"Found slash %d, index %d, start %d", foundSlash, idx, start);
  
  // if we didn't find a '\', return not found
  if (!foundSlash || start < 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  
  // go forwards until we find { followed by } or a whitespace or a newline, or the end of file
  while (idx < [string length]) {
    unichar c = [string characterAtIndex:idx];
    
    if ([newLineCharacterSet characterIsMember:c] || [whitespaceCharacterSet characterIsMember:c] || idx == [string length]) {
      end = idx-1;
      break;
    }
    if (c == '}' || c == ')' || c == ']' || c == '~') {
      end = idx-1;
      break;
    }
    
    if (c == '{') {
      end = idx-1;
      break;
    }
    
    idx++;
  }
  
  //  NSLog(@"End %d", end);
  
  // if we get past the selection point we return not found
  if (end > sel.location) {
    return NSMakeRange(NSNotFound, 0);
  }
  
  // the text between the '\' and the { is the command, but only if the original selection point was within the full range
  if (end >= [string length]) {
    end = [string length]-1;
  }
  NSRange r = NSMakeRange(start, end-start+1);
  
  return r;
}

- (NSString*)currentCommand
{
  NSString *string = [self string];
  NSRange r = [self rangeForCurrentCommand];
  if (r.location == NSNotFound || r.location >= [string length]) {
    return nil;
  }
  
  //  NSLog(@"Range %@", NSStringFromRange(r));
  NSString *word = [string substringWithRange:r];
  //  NSLog(@"Current command %@", word);
  if ([word length] == 0) {
    return nil;
  }
  if ([word characterAtIndex:0] == '\\') {
    return word;
  }
  
  return nil;
}

- (NSRange)rangeForCurrentSnippetCommand
{
  NSString *string = [self string];
  NSRange sel = [self selectedRange];
  NSInteger end = sel.location;
  NSInteger start = NSNotFound;
  NSInteger loc = end-1;
  
  while (loc < [string length]) {
    unichar c = [string characterAtIndex:loc];
    
    if ([whitespaceCharacterSet characterIsMember:c] ||
        [newLineCharacterSet characterIsMember:c]) {
      return NSMakeRange(NSNotFound, 0);
    }
    
    if (c == '#') {
      start = loc;
      break;
    }
    
    loc--;
  }
  
  if (start != NSNotFound && start < end) {
    return NSMakeRange(start, end-start);
  }
  
  return NSMakeRange(NSNotFound, 0);
}

- (NSString*)currentSnippetCommand
{
  NSString *string = [self string];
  NSRange r = [self rangeForCurrentSnippetCommand];
  if (r.location == NSNotFound) {
    return nil;
  }
  
  return [string substringWithRange:r];
}


- (NSRange) rangeForCurrentWord
{
	NSRange curr = [self selectedRange];
	
	// edge cases:
	// 1) we are at the beginning of the word in which case the selection sometimes doesn't work
	// 2) We are at the end of a word (indicated by the next character being newline or whitespace)
	NSInteger loc = curr.location;
	if (loc-1>=0) {
		NSString *str = [self string];
		if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[str characterAtIndex:loc-1]]) {
			[self setSelectedRange:NSMakeRange(loc, 1)];
		}
		if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[str characterAtIndex:loc]]) {
			[self setSelectedRange:NSMakeRange(loc-1, 1)];
		}
	}
	
	[self selectWord:self];
	NSRange sel = [self selectedRange];
	[self setSelectedRange:curr];
	return sel;
}

- (NSRange) lineRangeUptoCurrentSelection
{
  NSRange sel = [self selectedRange];
  NSAttributedString *astr = [self attributedString];
	NSUInteger idx = [astr lineBreakBeforeIndex:sel.location withinRange:NSMakeRange(0, sel.location)];
  NSInteger length = sel.location - idx;
  return NSMakeRange(idx, length);
}

- (NSInteger) lengthOfLineUpToLocation:(NSUInteger)location
{
	NSAttributedString *astr = [self attributedString];
	NSUInteger idx = [astr lineBreakBeforeIndex:location withinRange:NSMakeRange(0, location)];
	return location-idx;
}


- (NSRange) rangeForCurrentParagraph
{
	NSRange selRange = [self selectedRange];
	NSString *str = [self string];
	if ([str isEqual:@""]) {
		return NSMakeRange(0, 0);
	}
	
	// go back until we find an empty line, or the beginning of a command
	// - what is an empty line? Just newline and whitespace
	NSInteger start = selRange.location;
  //	NSLog(@"Starting from %@", NSStringFromRange(selRange));
	// if we are starting at the end of a line, we can move backwards
	if (start>0 && start < [str length] && [newLineCharacterSet characterIsMember:[str characterAtIndex:start]]) {
		start--;
	}
	
	// if we are starting from the end of the document
	if (start>0 && start == [str length])
		start--;
	
  //	NSLog(@"Starting search");
	while(start>=0 && start < [str length]) {
    unichar c = [str characterAtIndex:start];
		if ([newLineCharacterSet characterIsMember:c]) {
      //      NSLog(@"Found new line at %d", start);
			// this means we are at the end of a line.
			// Was the last line empty?
			NSRange lr = [str lineRangeForRange:NSMakeRange(start+1, 0)];
      //      NSLog(@"Line range: %@", NSStringFromRange(lr));
			NSString *lstr = [str substringWithRange:lr];
			
			// now remove all newlines and whitespace characters
			lstr = [lstr stringByTrimmingCharactersInSet:whitespaceCharacterSet];
			lstr = [lstr stringByTrimmingCharactersInSet:newLineCharacterSet];
			if ([lstr length]==0) {
				// then that line is empty
				start += lr.length+1;
				break;
			}
		}
    
		start--;
	}
	if (start<0)
		start = 0;
  
	// go forward until we find an empty line or the start of a command
	NSInteger end = start+1;
	while(end < [str length]) {
		unichar c = [str characterAtIndex:end];
		if ([newLineCharacterSet characterIsMember:c]) {
			
			// we are at the end of a line; was it an empty line?
			NSRange lr = [str lineRangeForRange:NSMakeRange(end, 0)];
			NSString *lstr = [str substringWithRange:lr];
      
			lstr = [lstr stringByTrimmingCharactersInSet:newLineCharacterSet];
			lstr = [lstr stringByTrimmingCharactersInSet:whitespaceCharacterSet];
      
			if ([lstr length]==0) {
				end -= lr.length;
				break;
			}
		}
    
		end++;
	}
  
  if (end >= [str length])
		end = [str length];
	
	if (end < start)
		end = start;
  
  if (end == NSNotFound)
    end = start;
  
  if (end >= [str length])
		end = [str length];
	
	if (end < start)
		end = start;
  
  if (end == NSNotFound)
    end = start;
  
	
	return NSMakeRange(start, end-start);
	
}

- (NSInteger) locationOfLastWhitespaceLessThan:(NSInteger)lineWrapLength
{
	NSString *str = [[self textStorage] string];
	NSRange selRange = [self selectedRange];
	NSInteger loc = selRange.location;
	
	while (loc >= 0 && loc < [str length]) {
    if ([whitespaceCharacterSet characterIsMember:[str characterAtIndex:loc-1]]) {
      //			NSLog(@"Returning %d", loc-1);
			return loc-1;
		}
		if ([newLineCharacterSet characterIsMember:[str characterAtIndex:loc-1]]) {
      //			NSLog(@"Returning -1,1");
			return -1;
		}
		loc--;
	}
  //	NSLog(@"Returning -1,2");
	return -1;
}

- (NSRange)rangeForCurrentLine
{
  return [[self string] lineRangeForRange:[self selectedRange]];
}

- (NSString*) currentLineToCursor
{
	NSRange selRange = [self selectedRange];
	NSString*	str = [[self textStorage] string];
  //	NSLog(@"Checking string %@", str);
	NSInteger loc = selRange.location;
  
  //	NSLog(@"Staring scan at %d", loc-1);
	while (loc > 0 && loc < [str length]) {
    //		NSLog(@"Checking character: '%c'", [str characterAtIndex:loc-1]);
		if ([newLineCharacterSet characterIsMember:[str characterAtIndex:loc-1]]) {
			break;
		}
		loc--;
	}
	NSInteger len = selRange.location-loc;
  //	NSLog(@"loc %d, len %d", loc, len);
	return [str substringWithRange:NSMakeRange(loc, MAX(len,0))];
}

- (void) selectUpToCurrentLocation
{
	NSRange curr = [self selectedRange];
	NSInteger loc = curr.location-1;
	NSString *string = [self string];
	NSInteger start = -1;
	while (loc >= 0 && loc < [string length]) {
		unichar c = [string characterAtIndex:loc];
    //		NSLog(@"  checking '%c'", c);
		if ([whitespaceCharacterSet characterIsMember:c] || [newLineCharacterSet characterIsMember:c]) {
			start = loc+1;
			break;
		}
		
		// other possible word breaks include '~' '\,' ','
		if (c == '~' || c == ',') {
			start = loc+1;
			break;
		}
    
    // If we have started to collect characters, then all a word to be delimited by brackets as well.
    // We need to check that loc<curr.lcoation-1 to ensure we are not just at the argument of a command,
    // for example, hitting escape with the cursor between the brackets of this text: '\cite{}'
    if ( c == '{' || c == '[' || c == '(' ) {
			start = loc+1;
			break;
		}
    if (c == '\\') {
			start = loc;
			break;
		}
    
		if (loc > 1) {
			if (c == ',' && [string characterAtIndex:loc-1] == '\\') {
				start = loc+1;
				break;
			}
		}
		
		loc--;
	}
  //	NSLog(@"Word starts at %d", start);
	if (start >= 0) {
		NSRange wr = NSMakeRange(start, curr.location+curr.length-start);
		[self setSelectedRange:wr];
	}
}

- (NSRange) getVisibleRange
{
  NSScrollView *sv = [self enclosingScrollView];
  if(!sv) return NSMakeRange(0,0);
  NSLayoutManager *lm = [self layoutManager];
  NSRect visRect = [self visibleRect];
  
  NSPoint tco = [self textContainerOrigin];
  visRect.origin.x -= tco.x;
  visRect.origin.y -= tco.y;
  
//  NSLog(@"Visible rect %@", NSStringFromRect(visRect));
  
  NSPoint topLeft = NSMakePoint(visRect.origin.x, visRect.origin.y + visRect.size.height);
  NSPoint botRight = NSMakePoint(visRect.origin.x + visRect.size.width, visRect.origin.y);
  
  NSUInteger endIdx = [lm characterIndexForPoint:topLeft inTextContainer:[self textContainer] fractionOfDistanceBetweenInsertionPoints:NULL];
  NSUInteger startIdx = [lm characterIndexForPoint:botRight inTextContainer:[self textContainer] fractionOfDistanceBetweenInsertionPoints:NULL];
  
//  NSLog(@"Char range %ld -> %ld", startIdx, endIdx);
  
  NSRange charRange = NSMakeRange(startIdx, endIdx-startIdx);
  
//  NSRange glyphRange = [lm glyphRangeForBoundingRect:visRect
//                                     inTextContainer:[self textContainer]];
//  
//  
//  NSLog(@"Visible glyph %@", NSStringFromRange(glyphRange));
//  
//  NSRange charRange = [lm characterRangeForGlyphRange:glyphRange
//                                     actualGlyphRange:NULL];
//  NSLog(@"Visible char %@", NSStringFromRange(charRange));
  
  return charRange;
}

- (void) setHighlightAlpha:(CGFloat)aValue
{
  if (highlightAlphaTimer == nil) {
    _highlightAlpha = aValue;
    
    //    NSLog(@"Starting timer");
    highlightAlphaTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                           target:self
                                                         selector:@selector(incrementHighlightAlpha)
                                                         userInfo:nil
                                                          repeats:YES];
  }
}

- (void) incrementHighlightAlpha
{
  //  NSLog(@"Timer fired");
  _highlightAlpha+=0.01;
  if (_highlightAlpha>=0.1) {
    //    NSLog(@"Stop timer");
    [highlightAlphaTimer invalidate];
    highlightAlphaTimer = nil;
  }
  //  NSLog(@"Setting alpha %f", highlightAlpha);
  
  [self setNeedsDisplay:YES];
}

// Returns a rectangle suitable for highlighting a background rectangle for the given text range.
- (NSRect) highlightRectForRange:(NSRange)aRange
{
//    NSLog(@"Getting highlight range for range %@", NSStringFromRange(aRange));
  NSRange r = aRange;
  NSRange startLineRange = [[self string] lineRangeForRange:NSMakeRange(r.location, 0)];
//    NSLog(@"Start line range %@", NSStringFromRange(startLineRange));
  NSInteger er = NSMaxRange(r)-1;
  NSString *text = [self string];
  
  
  if (er >= [text length]) {
    //    NSLog(@"Out of range");
    return NSZeroRect;
  }
  if (er < r.location) {
    er = r.location;
  }
  
  NSRange endLineRange = [[self string] lineRangeForRange:NSMakeRange(er, 0)];
//    NSLog(@"End line range %@", NSStringFromRange(endLineRange));
  
  NSRange cr = NSMakeRange(startLineRange.location, NSMaxRange(endLineRange)-startLineRange.location-1);
  if (NSMaxRange(cr) >= [self.string length]) {
    return  NSZeroRect;
  }
  
  NSLayoutManager *lm = [self layoutManager];
  

  NSUInteger gStartIdx = [lm glyphIndexForCharacterAtIndex:cr.location];
  NSUInteger gEndIdx = [lm glyphIndexForCharacterAtIndex:cr.location + cr.length - 1];
  
  
//  NSRange gr = [lm glyphRangeForCharacterRange:cr actualCharacterRange:NULL];
  NSRect br = [lm boundingRectForGlyphRange:NSMakeRange(gStartIdx, gEndIdx-gStartIdx+1) inTextContainer:[self textContainer]];
  
  NSRect b = [self bounds];
  CGFloat h = br.size.height;
  CGFloat w = b.size.width;
  CGFloat y = br.origin.y;
  
  NSPoint containerOrigin = [self textContainerOrigin];
  
  NSRect aRect = NSMakeRect(0, y, w, h);
//    NSLog(@"Highlight rect: %@", NSStringFromRect(aRect));
  // Convert from view coordinates to container coordinates
  aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
  return aRect;
}


- (void) handleSelectionChanged:(NSNotification*)aNote
{
  if (self != nil) {
    [self setNeedsDisplay:YES];
//    NSRange r = [self selectedRange];
//    [[NSNotificationCenter defaultCenter] postNotificationName:TECursorPositionDidChangeNotification
//                                                        object:self
//                                                      userInfo:@{@"index": [NSNumber numberWithInteger:r.location]}];
    
    [self colorText];
    [self highlightMatchingWords];
  }
}

- (void) highlightMatchingWords
{
  TPTheme *theme = [TPThemeManager currentTheme];
  
  NSRange r = [self selectedRange];
  NSRange vr = [self getVisibleRange];
  //  NSLog(@"Visible range %@", NSStringFromRange(vr));
  
  if ([theme.highlightMatchingWords boolValue]) {
    [[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:vr];
    
    NSString *string = [self string];
    if (r.length > 0 && NSMaxRange(r)<[string length]) {
      NSString *word = [[[self string] substringWithRange:r] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      word = [word stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
      if (word && [word length]>1) {
        NSString *textToSearch = [[self string] substringWithRange:vr];
        NSArray *matches = [textToSearch rangesOfString:word];
        
        NSColor *highlightColor = theme.matchingWordsColor;
        for (NSValue *match in matches) {
          NSRange r = [match rangeValue];
          r.location += vr.location;
          if ([[[string substringWithRange:r] stringByTrimmingCharactersInSet:whitespaceCharacterSet] length] > 0) {
            [[self layoutManager] addTemporaryAttribute:NSBackgroundColorAttributeName value:highlightColor forCharacterRange:r];
          }
        }
      }
    }
  }}

- (void) clearHighlight
{
  self.highlightRange = nil;
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark NSTextView overrides

- (void) cut:(id)sender
{
  NSRange sel = [self selectedRange];
  if (sel.length == 0) {
    return;
  }
  [self copy:sender];
  
  [self replaceRange:sel withText:@"" scrollToVisible:YES animate:NO];
}

- (void) copy:(id)sender
{
  NSRange sel = [self selectedRange];
  if (sel.length == 0) {
    return;
  }
  
  // get selected string
  NSAttributedString *text = [[self textStorage] attributedSubstringFromRange:sel];
  
  // replace placeholders
  NSAttributedString *source = [text replacePlaceholders];
  
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  [pb declareTypes:@[NSStringPboardType, NSRTFPboardType] owner:self];
  
  // put on pasteboard as plain text
  [pb setString:[source string] forType:NSStringPboardType];
  
  // put on pasteboard as RTF
  NSData *data = [source RTFFromRange:NSMakeRange(0, [source length]) documentAttributes:@{NSDocumentTypeDocumentAttribute :NSRTFTextDocumentType}];
  [pb setData:data forType:NSRTFPboardType];
}

- (void) paste:(id)sender
{
  // get plain text from pasteboard
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSString *pbstring = [pb stringForType:NSStringPboardType];
  
  if (pbstring == nil) {
    // paste as plain text
    [self pasteAsPlainText:sender];
  } else {
    
    // restore placeholders
    NSRange sel = [self selectedRange];
    
    NSAttributedString *astr = [NSAttributedString stringWithPlaceholdersRestored:pbstring attributes:[NSDictionary currentTypingAttributes]];
    if ([self shouldChangeTextInRange:sel replacementString:[astr string]]) {
      [self.textStorage replaceCharactersInRange:sel withAttributedString:astr];
      [self didChangeText];
      NSRange newRange = NSMakeRange(sel.location+[astr length], 0);
      [self setSelectedRange:newRange];
//      [self scrollRangeToVisible:newRange];
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
    }
  }
  
  [self applyFontAndColor:YES];
//  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
  [self highlightCurrentLine];
}

- (void) insertTab:(id)sender
{
  //	[super insertTab:[self stringForTab]];
	BOOL spaces = [[[NSUserDefaults standardUserDefaults] valueForKey:TEInsertSpacesForTabs] boolValue];
	if (spaces) {
		int NSpaces = [[[NSUserDefaults standardUserDefaults] valueForKey:TENumSpacesForTab] intValue];
		NSMutableString *str = [NSMutableString string];
		for (int i=0;i<NSpaces;i++) {
			[str appendString:@" "];
		}
    
    NSRange r = [self selectedRange];
    if ([self shouldChangeTextInRange:r replacementString:str]) {
      [self replaceCharactersInRange:r withString:str];
      [self didChangeText];
    }
	} else {
		[super insertTab:sender];
	}
	
}

- (void) insertNewline:(id)sender
{
  if ([_popupList isVisible]) {
    [_popupList selectSelectedItem:self];
    [_popupList dismiss];
    [self wrapLine];
    return;
  }
  
	// read the last line
	NSRange selRange = [self selectedRange];
	
	if (selRange.location == 0) {
		// now put in the requested newline
		[super insertNewline:sender];
    [self performSelector:@selector(colorText) withObject:nil afterDelay:0.1];
		return;
	}
	
	// using lineRangeForRange includes the line terminators so we do this by hand
	NSString *str = [self string];
	NSUInteger lineStart;
	NSUInteger lineEnd;
	[str getLineStart:&lineStart end:NULL contentsEnd:&lineEnd forRange:selRange];
	NSRange lineRange = NSMakeRange(lineStart, selRange.location-lineStart);
	NSString *previousLine = [str substringWithRange:lineRange];
  // get indentation
  NSInteger count = 0;
  NSString *indentString = @"";
  while (count < [previousLine length]) {
    unichar c = [previousLine characterAtIndex:count];
    if ([whitespaceCharacterSet characterIsMember:c] == NO) {
      indentString = [previousLine substringToIndex:count];
      break;
    }
    count++;
  }
	previousLine = [previousLine stringByTrimmingCharactersInSet:whitespaceCharacterSet];
	previousLine = [previousLine stringByTrimmingCharactersInSet:newLineCharacterSet];
	
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
	// Now let's do some special actions....
	//---- If the previous line was a \begin, we append the \end
	if ([[defaults valueForKey:TEAutomaticallyAddEndToBeginStatement] boolValue]
      && [previousLine hasPrefix:@"\\begin{"]) {
		
		// don't complete if the shift key is on, just add the tab
		if (self.shiftKeyOn) {
			[super insertNewline:sender];
			[self insertTab:sender];
      [self performSelector:@selector(colorText) withObject:nil afterDelay:0.1];
			return;
		}
		
		// if the current cursor location is not at the end of the \begin{} statement, we do nothing special
    NSInteger start = 0;
    NSInteger end   = 0;
    for (NSInteger kk=0; kk<[previousLine length]; kk++) {
      if ([previousLine characterAtIndex:kk]=='{') {
        start = kk+1;
        kk++;
      }
      if (kk < [previousLine length]) {
        if ([previousLine characterAtIndex:kk]=='}') {
          end = kk-1;
          break;
        }
      }
    }
    NSString *insert = nil;
    if (start < end && start != NSNotFound && end != NSNotFound) {
      NSString *tag = [previousLine substringWithRange:NSMakeRange(start, end-start+1)];
      insert = [NSString stringWithFormat:@"\n%@\\end{%@}", indentString, tag];
    }
    
    if (insert) {
      // now put in the requested newline
      [super insertNewline:sender];
      
      // insert the indent string
      NSRange r = [self selectedRange];
      if ([self shouldChangeTextInRange:r replacementString:indentString]) {
        [self replaceCharactersInRange:r withString:indentString];
        [self didChangeText];
      }
      
      // tab in
      [self insertTab:self];
      
      // record this location
      selRange = [self selectedRange];
      
      // add the new \end
      if ([self shouldChangeTextInRange:selRange replacementString:insert]) {
        [self replaceCharactersInRange:selRange withString:insert];
        [self didChangeText];
      }

      [self applyFontAndColor:YES];
      
      // wind back the location of the cursor
      [self setSelectedRange:selRange];
      [self performSelector:@selector(colorText) withObject:nil afterDelay:0.3];
      
      return;
    } // end if insert
    
    [super insertNewline:sender];
	} // end if \begin
	else if ([self currentSnippetCommand])
  {
    if (![self expandCurrentCommand]) {
      [super insertNewline:self];
    }
    
  } else {
    
    // get the indentation of this line
    NSRange indentRange = NSMakeRange(NSNotFound, 0);
    if (!_shiftKeyOn) {
      NSRange sel = [self selectedRange];
      indentRange = [self indentRangeForLineAtIndex:sel.location];
    }
    
    // Insert newline
    [super insertNewline:sender];
    [super scrollRangeToVisible:[self selectedRange]];
    
    // indent the new line
    if (!_shiftKeyOn && indentRange.location != NSNotFound) {
      NSRange sel = [self selectedRange];
      NSString *indentString = [str substringWithRange:indentRange];
      NSRange r = NSMakeRange(sel.location, 0);
      if([self shouldChangeTextInRange:r replacementString:indentString]) {
        [self replaceCharactersInRange:r withString:indentString];
        [self didChangeText];
      }
    }
  }
  
	// update line numbers
	[self updateEditorRuler];
	
}

- (void)setSpellingState:(NSInteger)value range:(NSRange)charRange
{
  // don't spell check commands
  if (charRange.location > 0) {
    if ([[self string] characterAtIndex:charRange.location-1] == '\\') {
      return;
    }
  }
  
  [super setSpellingState:value range:charRange];
}


- (NSString*)currentArgument
{
  NSRange sel = [self selectedRange];
  NSInteger loc = sel.location;
  return [[self string] parseArgumentAroundIndex:&loc];
}

// Return yes if the cursor is in the argument of any of the defined
// citation commands
- (BOOL)selectionIsInCitationCommand
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *citeCommands = [defaults valueForKey:TECiteCommands];
  NSRange sel = [self selectedRange];
  NSInteger loc = sel.location;
  
  return [self.string inCiteCommands:citeCommands atIndex:loc];
  
//  //  NSLog(@"Selection is in citation?");
//  NSString *word = [self currentCommand];
//  //  NSLog(@"word %@", word);
//  if (word == nil || [word length]==0) {
//    //    NSLog(@"   no");
//    return NO;
//  }
//  // check if it is one of the citation commands
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//  BOOL citeCommand = [word beginsWithElementInArray:[defaults valueForKey:TECiteCommands]] != NSNotFound;
//  if (citeCommand == NO) {
//    //    NSLog(@"   no");
//    return NO;
//  }
//  
//  // now check we are in an argument
//  NSString *arg = [self currentArgument];
//  //  NSLog(@"arg %@", arg);
//  if (arg == nil) {
//    //    NSLog(@"   no");
//    return NO;
//  }
  
  //  NSLog(@"   yes");
  return YES;
}


// Return yes if the cursor is in the argument of any of the defined
// reference commands
- (BOOL)selectionIsInRefCommand
{
  NSString *word = [self currentCommand];
  if (word == nil || [word length]==0) {
    return NO;
  }
  
  // check if it is one of the citation commands
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL refCommand = [word beginsWithElementInArray:[defaults valueForKey:TERefCommands]] != NSNotFound;
  if (refCommand == NO) {
    return NO;
  }
  
  // now check we are in an argument
  NSString *arg = [self currentArgument];
  if (arg == nil) {
    return NO;
  }
  
  return YES;
}

// Return yes if the cursor is in the argument of any of the defined
// file input commands
- (BOOL)selectionIsInFileCommand
{
  NSString *word = [self currentCommand];
  if (word == nil || [word length]==0) {
    return NO;
  }
  
  // check if it is one of the citation commands
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL citeCommand = [word beginsWithElementInArray:[defaults valueForKey:TEFileCommands]] != NSNotFound;
  if (citeCommand == NO) {
    return NO;
  }
  
  // now check we are in an argument
  NSString *arg = [self currentArgument];
  if (arg == nil) {
    return NO;
  }
  
  return YES;
}

- (BOOL) selectionIsInBeginCommand
{
  NSString *word = [self currentCommand];
  if (word == nil || [word length]==0) {
    return NO;
  }
  
  // check if the command is \begin
  if (![word isEqualToString:@"\\begin"]) {
    return NO;
  }
  
  // now check we are in an argument
  NSString *arg = [self currentArgument];
  if (arg == nil) {
    return NO;
  }
  
  return YES;
}

- (void) showListOfFileCompletions
{
  if ([self.delegate respondsToSelector:@selector(listOfTeXFilesPrependedWith:)]) {
    NSArray *list = [self.delegate performSelector:@selector(listOfTeXFilesPrependedWith:) withObject:@""];
    // filter the list by existing characters
    NSString *arg = [self currentArgument];
    if (arg != nil && [arg length] > 0) {
      arg = [arg lowercaseString];
      NSIndexSet *indices = [list indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *testString = [(NSString*)obj lowercaseString];
        if ([testString beginsWith:arg]) {
          return YES;
        }
        
        return NO;
      }];
      
      list = [list objectsAtIndexes:indices];
      if ([list count] > 0) {
        // if we have only one option, and the command is the same as the option, don't show the completion list
        if ([list count] == 1) {
          if ([arg isEqualToString:list[0]]) {
            [_popupList dismiss];
            return;
          }
        }
        
        [self completeFromList:list];
      }

    } else {
      [self insertFromList:list];
    }
  }
}

- (void) showListOfBeginCompletions
{
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *list = [defaults valueForKey:TEBeginCommands];
  if ([self.delegate respondsToSelector:@selector(listOfEnvironments)]) {
    list = [list arrayByAddingObjectsFromArray:[self.delegate performSelector:@selector(listOfEnvironments)]];
  }
  
  // filter the list by existing characters
  NSString *arg = [self currentArgument];
  if (arg != nil && [arg length] > 0) {
    arg = [arg lowercaseString];
    NSIndexSet *indices = [list indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      
      NSString *testString = [(NSString*)obj lowercaseString];
      if ([testString beginsWith:arg]) {
        return YES;
      }
      
      return NO;
    }];
    
    list = [list objectsAtIndexes:indices];
    if ([list count] > 0) {
      // if we have only one option, and the command is the same as the option, don't show the completion list
      if ([list count] == 1) {
        if ([arg isEqualToString:list[0]]) {
          [_popupList dismiss];
          return;
        }
      }
      
      [self completeFromList:list];
    }
  } else {
    [self insertFromList:list];
  }
  
}

- (void) showListOfRefCompletions
{
  if ([self.delegate respondsToSelector:@selector(listOfReferences)]) {
    NSArray *list = [self.delegate performSelector:@selector(listOfReferences)];
    
    // filter the list by existing characters
    NSString *arg = [self currentArgument];
    if (arg != nil && [arg length] > 0) {
      arg = [arg lowercaseString];
      NSIndexSet *indices = [list indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        TPLabel *label = (TPLabel*)obj;
        
        NSString *testString = [[label string] lowercaseString];
        if ([testString beginsWith:arg]) {
          return YES;
        }
        
        return NO;
      }];
      
      list = [list objectsAtIndexes:indices];
      if ([list count] > 0) {
        // if we have only one option, and the command is the same as the option, don't show the completion list
        if ([list count] == 1) {
          TPLabel *label = list[0];
          if ([arg isEqualToString:label.text]) {
            [_popupList dismiss];
            return;
          }
        }
        
        [self completeFromList:list];
      }
    } else {
      [self insertFromList:list];
    }
  }
}

- (void) showListOfCiteCompletions
{
  if ([self.delegate respondsToSelector:@selector(listOfCitations)]) {
    NSArray *list = [self.delegate performSelector:@selector(listOfCitations)];
    
    // filter the list by existing characters
    NSString *arg = [self currentArgument];
    if (arg != nil && [arg length]>0) {
      arg = [arg lowercaseString];
      NSIndexSet *indices = [list indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        // the list can contain NSAttributedString or BibliographyEntry objects, but both
        // support the -string message.
        NSString *testString = [[obj string] lowercaseString];
        NSRange matchRange = [testString rangeOfString:arg];
        if (matchRange.location != NSNotFound) {
          return YES;
        }
        
        return NO;
      }];
      
      list = [list objectsAtIndexes:indices];
      if ([list count] > 0) {
        // if we have only one option, and the command is the same as the option, don't show the completion list
        if ([list count] == 1) {
          BibliographyEntry *bib = list[0];
          if ([arg isEqualToString:[bib.tag lowercaseString]]) {
            [_popupList dismiss];
            return;
          }
        }
        
        [self completeFromList:list];
      }
    } else {
      [self completeFromList:list];
    }
  }
}

- (BOOL) completeArgument
{
  // check for completing arguments
  NSString *arg = [self currentArgument];
  if (arg != nil) {
    if ([self selectionIsInRefCommand]) {
      [self showListOfRefCompletions];
      return YES;
    }
    if ([self selectionIsInCitationCommand]) {
      //      NSLog(@"In cite");
      [self showListOfCiteCompletions];
      return YES;
    }
    if ([self selectionIsInFileCommand]) {
      //      NSLog(@"In file");
      [self showListOfFileCompletions];
      return YES;
    }
    if ([self selectionIsInBeginCommand]) {
      [self showListOfBeginCompletions];
      return YES;
    }
  }
  
  return NO;
}

- (IBAction)completeStuff:(id)sender
{
  //  NSLog(@"Complete stuff!!");
  
	NSString *string = [self string];
	NSRange curr = [self selectedRange];
	[self selectUpToCurrentLocation];
	NSRange selectedRange = [self selectedRange];
  //	NSRange wr = 	[self rangeForCurrentWord];
	[self setSelectedRange:curr];
  
	NSString *word = [string substringWithRange:selectedRange];
  //	NSString *command = [self currentCommand];
  NSString *arg = [self currentArgument];
	
  //NSLog(@"Completing... %@", word);
  NSString *command = word;
  //	NSLog(@"       or command: %@", command);
  //	NSLog(@"       or arg: %@", arg);
  
  
  //	NSLog(@"Delegate: %@", delegate);
  
  // complete a command if:
  //  a) the command is not nil and
  //  b) the command is not zero length and
  //  c) the argument is nil or the argument contains the command we are completing
  NSRange commandRangeInArg = [arg rangeOfString:command];
  
  if (command != nil && [command length] > 0 && (arg == nil || commandRangeInArg.location != NSNotFound) ) {
    
    NSArray *list = [NSMutableArray arrayWithArray:self.commandList];
    
    // get list of user defaults commands
    list = [list arrayByAddingObjectsFromArray:[self userDefaultCommands]];
    
    if ([self.delegate respondsToSelector:@selector(listOfCommands)]) {
      list = [list arrayByAddingObjectsFromArray:[self.delegate performSelector:@selector(listOfCommands)]];
    }
    if ([command length]>1) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", command];
      list = [list filteredArrayUsingPredicate:predicate];
    }
    if ([list count]>0) {
      [self completeFromList:list];
      
      
    } else {
      NSArray *list = [[NSSpellChecker sharedSpellChecker] completionsForPartialWordRange:NSMakeRange(0, [word length])
                                                                                 inString:word
                                                                                 language:nil
                                                                   inSpellDocumentWithTag:0];
      
      
      list = [list uniqueStringArray];
      
      [self completeFromList:list];
    }
	} else if ([self completeArgument]) {
    // do completion
	} else if ([word hasPrefix:@"#"]) {
    
    NSArray *possibleCommands = [self commandsBeginningWithPrefix:[self currentSnippetCommand]];
    //    NSLog(@"Got commands %@", possibleCommands);
    [self completeFromList:possibleCommands];
    
	} else {
		// otherwise we just call super
		NSArray *list = [[NSSpellChecker sharedSpellChecker] completionsForPartialWordRange:NSMakeRange(0, [word length])
																																							 inString:word
																																							 language:nil
																																 inSpellDocumentWithTag:0];
		[self completeFromList:list];
    
	}
  
  
}



- (void)keyDown:(NSEvent *)theEvent
{
  
	if ([theEvent keyCode] == 36) {
		if ([theEvent modifierFlags] & NSShiftKeyMask) {
      self.shiftKeyOn = YES;
		} else {
      self.shiftKeyOn = NO;
		}
	}
  
  if ([_popupList isVisible]) {
    // move down
    if ([theEvent keyCode] == 125 ) {
      [_popupList moveDown:self];
      return;
    }
    // move up
    if ([theEvent keyCode] == 126 ) {
      [_popupList moveUp:self];
      return;
    }
    
    // move right
    if ([theEvent keyCode] == 124 ) {
      // if the next character is a newline or whitespace, we dismiss the popup
      NSRange sel = [self selectedRange];
      if (sel.location < [[self string] length]) {
        unichar c = [[self string] characterAtIndex:sel.location];
        if ([whitespaceCharacterSet characterIsMember:c] || [newLineCharacterSet characterIsMember:c]) {
          [_popupList dismiss];
        } else {
          [super keyDown:theEvent];
          [self performSelector:@selector(completeStuff:) withObject:self afterDelay:0];
          return;
        }
      }
    }
    
    // move left
    if ([theEvent keyCode] == 123 ) {
      // if the previous character is a newline or whitespace, we dismiss the popup
      NSRange sel = [self selectedRange];
      if (sel.location > 0) {
        unichar c = [[self string] characterAtIndex:sel.location-1];
        if ([whitespaceCharacterSet characterIsMember:c] || [newLineCharacterSet characterIsMember:c]) {
          [_popupList dismiss];
        } else {
          // update the popup list
          [super keyDown:theEvent];
          [self performSelector:@selector(completeStuff:) withObject:self afterDelay:0];
          return;
        }
      }
    }
    
    // tab key to complete upto first / or end
    if ([theEvent keyCode] == 48 ) {
      NSString *selectedValue = [_popupList selectedValue];
      if (selectedValue) {
        
        NSString *arg = [self currentArgument];
        selectedValue = [selectedValue stringByReplacingOccurrencesOfString:arg withString:@""];
        
        // get part upto first /
        NSArray *parts = [selectedValue componentsSeparatedByString:@"/"];
        
        for (NSInteger kk=0; kk<[parts count]; kk++) {
          NSString *part = parts[kk];
          NSRange r = [arg rangeOfString:part];
          if (r.location != NSNotFound) {
            continue;
          } else {
            NSString *insert = [part stringByReplacingOccurrencesOfString:arg withString:@""];
            if (kk<[parts count]-1) {
              insert = [insert stringByAppendingString:@"/"];
            }
            NSRange selRange = [self selectedRange];
            if ([self shouldChangeTextInRange:selRange replacementString:insert]) {
              [self replaceCharactersInRange:selRange withString:insert];
              [self didChangeText];
            }
            [self completeArgument];
            [self wrapLine];
            break;
          }
        }
      }
      return;
    }
    
  }
  
	[super keyDown:theEvent];
}

- (void) mouseDown:(NSEvent *)theEvent
{
  [_popupList dismiss];
  [self clearHighlight];
	[self clearSpellingList];
  
	if ([theEvent modifierFlags] & NSCommandKeyMask) {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didCommandClickAtLine:column:)]) {
      NSInteger idx = [self characterIndexForPoint:[NSEvent mouseLocation]];
      NSInteger line = [self lineNumberForRange:NSMakeRange(idx, 0)];
      NSInteger column = [self columnForRange:NSMakeRange(idx, 0)];
      [(TeXEditorViewController*)self.delegate textView:self didCommandClickAtLine:line column:column];
    }
	}
  
	[super mouseDown:theEvent];
}


//- (void)viewWillDraw
//{
//  [self.editorRuler setNeedsDisplay:YES];
//	[super viewWillDraw];
//}

//- (NSRange) selectionRangeForProposedRange:(NSRange)proposedCharRange granularity:(NSSelectionGranularity)granularity
//{
//  NSLog(@"%@", NSStringFromSelector(_cmd));
//  return [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
//}

- (void) drawViewBackgroundInRect:(NSRect)rect
{
  //NSLog(@"Drawing background %@", NSStringFromRect(rect));
  
	[super drawViewBackgroundInRect:rect];

  CGFloat w = rect.size.width;
  if (self.wrapStyle == TPHardWrap || self.wrapStyle == TPSoftWrap) {
    NSRect r;
    
    if (self.wrapStyle == TPSoftWrap) {
      NSSize inset = [self textContainerInset];
      NSSize s = [[self textContainer] containerSize];
      w = inset.width+s.width;
      r = NSMakeRect(inset.width+s.width, rect.origin.y, rect.size.width, rect.size.height);
    } else {
      w = self.averageCharacterWidth*self.wrapAt*kFontWrapScaleCorrection;
      r = NSIntegralRect(NSMakeRect(w, rect.origin.y, w+rect.size.width, rect.size.height));
    }
    
    [self.documentEditorMarginColor set];
    [NSBezierPath fillRect:r];
  }
  
  // do rest of background
  [self.documentEditorBackgroundColor set];
  NSRect br = NSIntegralRect(NSMakeRect(0, rect.origin.y, w, rect.size.height));
//  NSLog(@"Background %@", NSStringFromRect(br));
  [NSBezierPath fillRect:br];
  
  
  // additional highlight range
  NSRange hr = NSRangeFromString(self.highlightRange);
  if (self.highlightRange && NSMaxRange(hr) < [self.string length]) {
    NSRect aRect = [self highlightRectForRange:hr];
    [[[self backgroundColor] shadowWithLevel:_highlightAlpha] set];
    [NSBezierPath fillRect:aRect];
  }
  
  // highlight current line
  if (self.highlightCurrentLine) {
    NSRange sel = [self selectedRange];
    NSString *str = [self string];
    if (sel.location < [str length]) {
//      NSRange lineRange = [str lineRangeForRange:NSMakeRange(sel.location,0)];
      if (NSEqualRanges(sel, self.currentLineRange) == NO) {
        self.currentLineRect = NSIntegralRect([self highlightRectForRange:sel]);
        self.currentLineRange = sel;
      }
      [self.currentLineColor set];
      [NSBezierPath fillRect:self.currentLineRect];
    }
  }
  
}


- (BOOL)becomeFirstResponder
{
  [self setNeedsDisplay:YES];
  return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
  [self setNeedsDisplay:YES];
  return [super resignFirstResponder];
}


// Override these delete methods to update text color which may have been set when inserting text
// within commands, comments etc. To make a nicer appearance we attempt to set the typing color of
// the text before inserting it in -insertText:. The result is that foreground color text attributes
// are sometimes applied to text fragements. We need to get rid of these when we, for example, delete
// the comment character.
- (void)deleteBackward:(id)sender
{
  [super deleteBackward:sender];
  [self applyCurrentTextColorToLine];
  [self colorText];
}

- (void)deleteWordBackward:(id)sender
{
  [super deleteWordBackward:sender];
  [self applyCurrentTextColorToLine];
  [self colorText];
}

- (void)deleteToBeginningOfLine:(id)sender
{
  [super deleteToBeginningOfLine:sender];
  [self applyCurrentTextColorToLine];
  [self colorText];
}

- (void) completeOpenBrace:(unichar)o withClosingBrace:(unichar)c
{
  // check if this is a \left{
  NSRange selRange = [self selectedRange];
  //NSLog(@"Completing brace at %@", NSStringFromRange(selRange));
  
  unichar cc = ' ';
  if (selRange.location > 0) {
    cc = [[self string] characterAtIndex:selRange.location-1];
  }
 
  // do we need to complete? Check the next character
  if (selRange.location < [self.string length]) {
    
    unichar nextc = [[self string] characterAtIndex:selRange.location];
    
    if (nextc == c && [[self string] shouldCloseOpeningBracket:o with:c atLocation:selRange.location] == NO ) {
      NSString *replacement = [NSString stringWithFormat:@"%c", o];
      if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
        [self replaceCharactersInRange:selRange withString:replacement];
        [self didChangeText];
      }
      return;
    }
  }
  
  
  if ([[self currentCommand] isEqualToString:@"\\left"]) {
    
    // special check to see if \right%c is already there
    NSString *toCheck = [NSString stringWithFormat:@"\\right%c", c];
    NSString *text = [[self string] substringWithRange:NSMakeRange(selRange.location, [toCheck length])];
    if ([toCheck isEqualToString:text]) {
      return;
    }
    
    NSString *replacement = [NSString stringWithFormat:@"%c\\right%c", o, c];
    if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
      [self replaceCharactersInRange:selRange withString:replacement];
      [self didChangeText];
    }
    NSRange newPos = NSMakeRange(selRange.location+1, 0);
    [self setSelectedRange:newPos];
  } else  if (cc == '\\') {
    NSString *replacement = [NSString stringWithFormat:@"%c\\%c", o, c];
    if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
      [self replaceCharactersInRange:selRange withString:replacement];
      [self didChangeText];
    }
    NSRange newPos = NSMakeRange(selRange.location+1, 0);
    [self setSelectedRange:newPos];
  } else {
    if (selRange.length > 0) {
      NSString *selected = [[self string] substringWithRange:selRange];
      NSString *replacement = [NSString stringWithFormat:@"%c%@%c", o, selected, c];
      if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
        [self replaceCharactersInRange:selRange withString:replacement];
        [self didChangeText];
      }
    } else {
      NSString *replacement = [NSString stringWithFormat:@"%c%c", o, c];
      if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
        [self replaceCharactersInRange:selRange withString:replacement];
        [self didChangeText];
      }
      [self moveLeft:self];
      [self autocompleteArgument];
    }
  }
}

- (void)insertText:(id)aString
{
  
  // check if the next character or preceeding character was a text attachment
	NSRange selRange = [self selectedRange];
	NSRange effRange;
	NSAttributedString *string = [self attributedString];
//	if ([string length] == 0) {
//		[super insertText:aString];
//		return;
//	}
  
	if (selRange.location < [string length]) {
		NSTextAttachment *att = [string attribute:NSAttachmentAttributeName
																			atIndex:selRange.location
															 effectiveRange:&effRange];
		if (att) {
      if ([att isKindOfClass:[TPFoldedCodeSnippet class]]) {
        NSRange lineRange = [[self string] lineRangeForRange:selRange];
        [self unfoldAllInRange:lineRange max:10000];
        return;
      }
      
      if ([att isKindOfClass:[MHPlaceholderAttachment class]]) {
        if ([self shouldChangeTextInRange:selRange replacementString:aString]) {
          [self replaceCharactersInRange:selRange withString:aString];
          [self didChangeText];
        }
        return;
      }
		}
	}
  
  // setup typing attributes
  //  NSInteger start = [self locationOfLastWhitespaceLessThan:selRange.location]+1;
  //  NSRange wordRange = NSMakeRange(start, selRange.location-start);
  //  NSString *word = [[self string] substringWithRange:wordRange];
  NSRange pRange = [self rangeForCurrentParagraph];
  NSRange lineRange = [[self string] lineRangeForRange:selRange];
  NSString *paragraph = [[self string] substringWithRange:pRange];
  paragraph = [paragraph stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString *line = [[self string] substringWithRange:lineRange];
  line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSInteger lineIndex = selRange.location-pRange.location;
  if (lineIndex < 0)
    lineIndex = 0;
  
  //NSLog(@"In arg? %d", [paragraph isInArgumentAtIndex:lineIndex]);
  //NSLog(@"In cmd? %d", [paragraph isCommandBeforeIndex:lineIndex]);
  
  if ([line isCommentLineBeforeIndex:lineIndex commentChar:[self commentChar]]) {
    [self setTypingColor:self.coloringEngine.commentColor];
  } else if ([paragraph isInCommandAtIndex:lineIndex]) {
    [self setTypingColor:self.coloringEngine.commandColor];
  } else if ([paragraph isArgumentOfCommandAtIndex:lineIndex]) {
//    if ([paragraph isCommandBeforeIndex:lineIndex]) {
//      [self setTypingColor:self.coloringEngine.commandColor];
//    } else {
      [self setTypingColor:self.coloringEngine.argumentsColor];
//    }
  } else {
    [self applyFontAndColor:NO];
  }
  
  //NSLog(@"Inserting text at index %ld", selRange.location);
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL completeBrace = [[defaults valueForKey:TEAutomaticallyInsertClosingBrace] boolValue];
  BOOL completeMath = [[defaults valueForKey:TEAutomaticallyInsertClosingMath] boolValue];
  BOOL skipClosingBrace = [[defaults valueForKey:TEAutomaticallySkipClosingBrackets] boolValue];
  
  if ([aString isEqual:@"{"] && completeBrace) {    
    [self completeOpenBrace:'{' withClosingBrace:'}'];
	} else 	if ([aString isEqual:@"["] && completeBrace) {
    [self completeOpenBrace:'[' withClosingBrace:']'];
	} else 	if ([aString isEqual:@"("] && completeBrace) {
    [self completeOpenBrace:'(' withClosingBrace:')'];
  } else if ([aString isEqual:@"$"] && completeMath) {
		// will this be an extra closing $?
		NSRange r = [self selectedRange];
    //    NSLog(@"Range %@", NSStringFromRange(r));
		if (skipClosingBrace && r.location < [string length] && [[self string] characterAtIndex:r.location] == '$') {
			// move right
			[self moveRight:self];
			return;
		}	else {
      if (selRange.length > 0) {
        NSString *selected = [[string string] substringWithRange:selRange];
        NSString *replacement = [NSString stringWithFormat:@"$%@$", selected];
        if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
          [self replaceCharactersInRange:selRange withString:replacement];
          [self didChangeText];
        }
      } else {
        NSString *replacement = @"$$";
        if ([self shouldChangeTextInRange:selRange replacementString:replacement]) {
          [self replaceCharactersInRange:selRange withString:replacement];
          [self didChangeText];
        }
        [self moveLeft:self];
      }
    }
	} else	if ([aString isEqual:@"}"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
    //    NSLog(@"Range %@", NSStringFromRange(r));
		if (skipClosingBrace && r.location < [string length] && [[self string] characterAtIndex:r.location] == '}') {
			// move right
			[self moveRight:self];
			return;
		}	else {
      if ([self shouldChangeTextInRange:selRange replacementString:aString]) {
        [self replaceCharactersInRange:selRange withString:aString];
        [self didChangeText];
      }
			return;
		}
	} else	if ([aString isEqual:@")"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
		if (skipClosingBrace && r.location < [string length] && [[self string] characterAtIndex:r.location] == ')') {
			// move right
			[self moveRight:self];
			return;
		}	else {
      if ([self shouldChangeTextInRange:selRange replacementString:aString]) {
        [self replaceCharactersInRange:selRange withString:aString];
        [self didChangeText];
      }
			return;
		}
	} else	if ([aString isEqual:@"]"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
		if (skipClosingBrace && r.location < [string length] && [[self string] characterAtIndex:r.location] == ']') {
			// move right
			[self moveRight:self];
			return;
		}	else {
      if ([self shouldChangeTextInRange:selRange replacementString:aString]) {
        [self replaceCharactersInRange:selRange withString:aString];
        [self didChangeText];
      }
			return;
		}
	} else	if (([[defaults valueForKey:TEAutomaticallyReplaceOpeningDoubleQuote] boolValue] ||
               [[defaults valueForKey:TEAutomaticallyReplaceClosingDoubleQuote] boolValue])
              && [aString isEqual:@"\""]
              && [[self fileExtension] isEqualToString:@"tex"]) {
		// do smart replacements
		NSRange r = [self selectedRange];
    if (r.location>0) {
      NSInteger loc = r.location-1;
      if ([whitespaceCharacterSet characterIsMember:[[self string] characterAtIndex:loc]] ||
          [newLineCharacterSet characterIsMember:[[self string] characterAtIndex:loc]]) {
        NSString *insert = [defaults valueForKey:TEOpeningDoubleQuoteReplacement];
        if ([self shouldChangeTextInRange:selRange replacementString:insert]) {
          [self replaceCharactersInRange:selRange withString:insert];
          [self didChangeText];
        }
      } else {
        NSString *insert = aString;
        if ([[defaults valueForKey:TEAutomaticallyReplaceClosingDoubleQuote] boolValue]) {
          insert = [defaults valueForKey:TEClosingDoubleQuoteReplacement];
        }
        
        if ([self shouldChangeTextInRange:selRange replacementString:insert]) {
          [self replaceCharactersInRange:selRange withString:insert];
          [self didChangeText];
        }
          
      }
    } else {
      if ([self shouldChangeTextInRange:selRange replacementString:aString]) {
        [self replaceCharactersInRange:selRange withString:aString];
        [self didChangeText];
      }
    }
  } else {
    //    NSLog(@"Inserting %@", aString);
    [super insertText:aString];
    
    // check if this is a short-cut code command
    NSString *command = [self currentSnippetCommand];
    if (command != nil && [command length] > 0) {
      NSString *code = [self codeForCommand:command];
      if (code && [code length]>0) {
        NSRange commandRange = [self rangeForCurrentSnippetCommand];
        [[self layoutManager] addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor yellowColor] forCharacterRange:commandRange];
      }
    }
  }
  
	[self wrapLine];
  
  [self colorText];
//  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
}


- (BOOL) delayedAutocompleteArgument
{
  __block BOOL result = NO;
  double delayInSeconds = 0.1;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    result = [self autocompleteArgument];
  });
  
  return result;
}

- (BOOL) autocompleteArgument
{
  NSString *arg = [self currentArgument];
  
  // show citation completion list?
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[defaults valueForKey:TEAutomaticallyShowCiteCompletionList] boolValue]) {
    if (arg != nil) {
      if ([self selectionIsInCitationCommand]) {
        [self showListOfCiteCompletions];
        return YES;
      }
    }
  }
  
  // show reference completion list?
  if ([[defaults valueForKey:TEAutomaticallyShowRefCompletionList] boolValue]) {
    if (arg != nil) {
      if ([self selectionIsInRefCommand]) {
        [self showListOfRefCompletions];
        return YES;
      }
    }
  }
  
  // show file completion list?
  if ([[defaults valueForKey:TEAutomaticallyShowFileCompletionList] boolValue]) {
    if (arg != nil) {
      if ([self selectionIsInFileCommand]) {
        [self showListOfFileCompletions];
        return YES;
      }
    }
  }
  
  // show begin completion list?
  if ([[defaults valueForKey:TEAutomaticallyShowBeginCompletionList] boolValue]) {
    if (arg != nil) {
      if ([self selectionIsInBeginCommand]) {
        [self showListOfBeginCompletions];
        return YES;
      }
    }
  }
  
  
  return NO;
}

- (BOOL) autocompleteCommand
{
  //  NSLog(@"Autocomplete command");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *arg = [self currentArgument];
  if ([[defaults valueForKey:TEAutomaticallyShowCommandCompletionList] boolValue]) {
    
    // if we have a command, and arg is nil, or arg is the same as the command, then complete the command
    NSRange commandRange = [self rangeForCurrentCommand];
    // check the range
    if (commandRange.location == NSNotFound) {
      return NO;
    }
    NSString *command = [[self string] substringWithRange:commandRange];
    
    // if the current cursor position is not part of the current command range, we don't have an argument
    // then don't complete
    
    NSRange sel = [self selectedRange];
    if (sel.location > NSMaxRange(commandRange)) {
      return NO;
    }
    
    //    NSLog(@"Current command %@", command);
    if (command != nil && [command length] > 0 && (arg == nil || [command isEqualToString:arg])) {
      NSArray *commands = [self commandsMatchingWord:command];
      if ([commands count]>0) {
        // if we have only one option, and the command is the same as the option, don't show the completion list
        if ([commands count] == 1) {
          if ([command isEqualToString:commands[0]]) {
            return NO;
          }
        }
        
        [self completeFromList:commands];
        return YES;
      }
    }
  }
  
  return NO;
}

- (void)didChangeText
{
  [super didChangeText];
  
  if (![self autocompleteArgument]) {
    if (![self autocompleteCommand]) {
      [_popupList dismiss];
    }
  }
  
  [self updateEditorRuler];
}


- (NSArray*)commandsMatchingWord:(NSString*)word
{
  if ([word hasPrefix:@"\\"]) {
    NSArray *list = [NSMutableArray arrayWithArray:self.commandList];
    
    // get list of user defaults commands
    list = [list arrayByAddingObjectsFromArray:[self userDefaultCommands]];
    
    if ([self.delegate respondsToSelector:@selector(listOfCommands)]) {
      list = [list arrayByAddingObjectsFromArray:[self.delegate performSelector:@selector(listOfCommands)]];
    }
    
    list = [list uniqueStringArray];
    
    if ([word length]>1) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", word];
      list = [list filteredArrayUsingPredicate:predicate];
    }
    return list;
  }
  
  return nil;
}

- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color
                        turnedOn:(BOOL)flag
{
  //Block Cursor
  if( flag )
  {
    [self _drawInsertionPointInRect:rect color:color];
  }
  else
  {
    [self setNeedsDisplayInRect:[self visibleRect]
          avoidAdditionalLayout:NO];
  }
}


- (void) _drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color
{
  NSString *cursorType = [[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentCursorType];
  
  NSPoint aPoint=NSMakePoint(rect.origin.x, rect.origin.y+rect.size.height/2);
  NSInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:aPoint
                                                  inTextContainer:[self textContainer]];
  NSRect glyphRect = [[self layoutManager] boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                                     inTextContainer:[self textContainer]];
  
  [color set];
  
  rect.size.width =rect.size.height/2;
  if(glyphRect.size.width > 0 && glyphRect.size.width < rect.size.width) {
    rect.size.width=glyphRect.size.width;
  }
  
  //rect = [self backingAlignedRect:rect options:NSAlignAllEdgesNearest];
  
  rect.origin.y = floor(rect.origin.y) + 0.5;
  rect.origin.x = floor(rect.origin.x) + 0.5;
  rect.size.width = floor(rect.size.width);
  rect.size.height = floor(rect.size.height);
  
  //    NSRectFillUsingOperation( rect, NSCompositePlusDarker);
  
  if ([cursorType isEqualToString:@"Box"]) {
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:0.75];
    [path stroke];
    
  } else if ([cursorType isEqualToString:@"Block"]) {
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:0.75];
    [path fill];
    
  } else {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
    [path lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
    [path setLineWidth:0.75];
    [path stroke];
  }
}

//- (void) _drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color
//{
//  BOOL block = YES;
//  NSString *cursorType = [[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentCursorType];
//  if ([cursorType isEqualToString:@"Block"]) {
//    block = YES;
//  }
//  
//  NSPoint aPoint = NSMakePoint( rect.origin.x,
//                               rect.origin.y+rect.size.height/2);
//  NSUInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:aPoint
//                                                   inTextContainer:[self textContainer]];
//  NSRect glyphRect = [[self layoutManager]
//                      boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)  inTextContainer:[self textContainer]];
//  
//  [color set ];
//  
//  rect.size.width = rect.size.height/2;
//  if(glyphRect.size.width > 0 && glyphRect.size.width < rect.size.height) {
//    rect.origin.x -= 1.0;
//    rect.size.width = glyphRect.size.width+2.0;
//  }
//  
//  //Block Cursor
//  if( block ) {
//    
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
//    [path setLineWidth:1.0];
//    [path stroke];
//    
//  } else {
//    NSBezierPath *path = [NSBezierPath bezierPath];
//    [path moveToPoint:NSMakePoint(rect.origin.x+1.0, rect.origin.y)];
//    [path lineToPoint:NSMakePoint(rect.origin.x+1.0, rect.origin.y + rect.size.height)];
//    [path setLineWidth:1.5];
//    [path stroke];
//    
//  }
//}

#pragma mark -
#pragma mark Text processing

- (NSRange)indentRangeForLineAtIndex:(NSInteger)loc
{
  NSString *str = [self string];
  NSInteger idx = NSNotFound;
  if (loc <= [str length]) {
    NSRange lineRange = [str lineRangeForRange:NSMakeRange(loc,0)];
    idx = lineRange.location;
    while (idx < NSMaxRange(lineRange)) {
      if (![whitespaceCharacterSet characterIsMember:[str characterAtIndex:idx]]) {
        break;
      }
      idx++;
    }
    if (idx < NSMaxRange(lineRange)) {
      return NSMakeRange(lineRange.location, idx-lineRange.location);
    }
  }
  
  return NSMakeRange(NSNotFound, 0);
}

- (NSString*) stringForTab
{
	NSMutableString *str = [NSMutableString string];
	BOOL spaces = [[[NSUserDefaults standardUserDefaults] valueForKey:TEInsertSpacesForTabs] boolValue];
	if (spaces) {
		int NSpaces = [[[NSUserDefaults standardUserDefaults] valueForKey:TENumSpacesForTab] intValue];
		for (int i=0;i<NSpaces;i++) {
			[str appendString:@" "];
		}
	} else {
		[str appendString:@"\t"];
	}
	return str;
}

- (NSString*)fileExtension
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileExtension)]) {
    return [self.delegate performSelector:@selector(fileExtension)];
  }
  return @"";
}

- (NSString*)commentChar
{
  if ([[self fileExtension] isEqualToString:@"tex"]) {
    return @"%";
  }
  return @"#";
}



- (void) didSelectPopupListItem
{
}

- (void) didDismissPopupList
{
}




- (BOOL) expandCurrentCommand
{
  NSString *currentCommand = [self currentSnippetCommand];
  if (currentCommand) {
    NSString *code = [self codeForCommand:currentCommand];
    if (code) {
      NSRange commandRange = [self rangeForCurrentSnippetCommand];
      NSAttributedString *astr = [NSAttributedString stringWithPlaceholdersRestored:code attributes:[NSDictionary currentTypingAttributes]];
      if ([self shouldChangeTextInRange:commandRange replacementString:[astr string]]) {
        [self.textStorage replaceCharactersInRange:commandRange withAttributedString:astr];
        [self didChangeText];
        
        // we should only do this if the snippet has placeholders
        [self setSelectedRange:NSMakeRange(commandRange.location, 0)];
        [self jumpToNextPlaceholder:self];
        NSRange rangeAfterJump = [self selectedRange];
        if (rangeAfterJump.location == commandRange.location) {
          // go to end
          [self setSelectedRange:NSMakeRange(commandRange.location+[astr length], 0)];
        }
        [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
      }
      return YES;
    }
  }
  return NO;
}

- (void) restoreAllPlaceholders
{
  NSAttributedString *str = [NSAttributedString stringWithPlaceholdersRestored:[self string] attributes:[NSDictionary currentTypingAttributes]];
//  NSAttributedString *str = [[NSAttributedString alloc] initWithString:[self string]];
  if ([[str string] isEqualToString:[self string]] == NO) {
    [self.textStorage beginEditing];
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithAttributedString:str]];
    [self.textStorage endEditing];
  }
}

- (NSRange) replacePlaceholdersInString:(NSString*)code range:(NSRange)commandRange
{
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString stringWithPlaceholdersRestored:code]];
  [str addAttributes:[self typingAttributes] range:NSMakeRange(0, [str length])];
  
  [self.textStorage beginEditing];
  [self.textStorage replaceCharactersInRange:commandRange withAttributedString:str];
  [self.textStorage endEditing];
  
  return NSMakeRange(commandRange.location, [str length]);
}

- (IBAction)jumpToPreviousPlaceholder:(id)sender
{
  NSRange selRange = [self selectedRange];
  NSRange vr = [self getVisibleRange];
  NSInteger idx = selRange.location;
  NSInteger strLen = [[self string] length];
  if (idx>0)
    idx--;
  
  BOOL didWrap = NO;
  while (idx > vr.location && idx < strLen) {
    
    NSRange effRange;
    NSTextAttachment *att = [[self attributedString] attribute:NSAttachmentAttributeName
                                                       atIndex:idx
                                                effectiveRange:&effRange];
    
    if (att && [att isKindOfClass:[MHPlaceholderAttachment class]]) {
      [self setSelectedRange:NSMakeRange(idx, 1)];
      return;
    }
    idx--;
    
    
    if (idx <= vr.location && didWrap) {
      break;
    }
    
    // wrap around
    if (idx == vr.location) {
      idx = NSMaxRange(vr);
      didWrap = YES;
    }
  }
  
}

- (IBAction)jumpToNextPlaceholder:(id)sender
{
  NSRange selRange = [self selectedRange];
  NSRange vr = [self getVisibleRange];
  NSInteger idx = NSMaxRange(selRange);
  BOOL didWrap = NO;
  while (idx>=0 && idx < NSMaxRange(vr)) {
    
    NSRange effRange;
    NSTextAttachment *att = [[self attributedString] attribute:NSAttachmentAttributeName
                                                       atIndex:idx
                                                effectiveRange:&effRange];
    
    if (att != nil && [att isKindOfClass:[MHPlaceholderAttachment class]]) {
      [self setSelectedRange:NSMakeRange(idx, 1)];
      return;
    }
    idx++;
    
    // check if we've finished searching
    if (idx > NSMaxRange(selRange) && didWrap) {
      break;
    }
    
    // wrap around
    if (idx == NSMaxRange(vr)) {
      idx = vr.location;
      didWrap = YES;
    }
  }
  
}


- (void) moveRight:(id)sender
{
	[super moveRight:sender];
	
	// if we moved over an opening or closing bracket, look for the other one and flash it
	[self performSelector:@selector(checkForMatchingBracketAfterMovingRight)
						 withObject:nil
						 afterDelay:0];
	
}


- (void) moveLeft:(id)sender
{
	[super moveLeft:sender];
	// if we moved over an opening or closing bracket, look for the other one and flash it
	[self performSelector:@selector(checkForMatchingBracketAfterMovingLeft)
						 withObject:nil
						 afterDelay:0];
}

- (void) checkForMatchingBracketAfterMovingLeft
{
	NSString *str = [self string];
	NSRange crange = [self selectedRange];
	
	if (crange.location < [str length]-1) {
		[self checkForMatchingBracket:[str characterAtIndex:crange.location]
											 offsetFrom:crange.location
															 by:0];
	}
}

- (void) checkForMatchingBracketAfterMovingRight
{
	NSString *str = [self string];
	NSRange crange = [self selectedRange];
	if (crange.location>0) {
		[self checkForMatchingBracket:[str characterAtIndex:crange.location-1]
											 offsetFrom:crange.location
															 by:-1];
	}
}

- (void) checkForMatchingBracket:(unichar)aChar offsetFrom:(NSInteger)index by:(NSInteger)offset
{
	NSInteger match = [self findMatchingBracketOfType:aChar atIndex:index+offset];
	if (match != NSNotFound) {
		[self showFindIndicatorForRange:NSMakeRange(match, 1)];
	}
}

- (NSInteger)searchBackwardsForChar:(unichar)openBracket matching:(unichar)closeBracket startingAt:(NSInteger)loc
{
  //	NSLog(@"Searching backwards for %C", openBracket);
	NSString *str = [self string];
	NSInteger bcount = 1;
	while (loc >= 0 && loc < [str length]) {
		if ([str characterAtIndex:loc] == closeBracket) {
			bcount++;
		}
		if ([str characterAtIndex:loc] == openBracket) {
			bcount--;
		}
		if (bcount == 0){
			return loc;
		}
		loc--;
	}
	return NSNotFound;
}

- (NSInteger)searchForwardsForChar:(unichar)closeBracket matching:(unichar)openBracket startingAt:(NSInteger)loc
{
  //	NSLog(@"Searching forwards for %C", closeBracket);
	NSString *str = [self string];
	NSInteger bcount = 1;
	while (loc >=0 && loc < [str length]) {
		if ([str characterAtIndex:loc] == openBracket) {
			bcount++;
		}
		if ([str characterAtIndex:loc] == closeBracket) {
			bcount--;
		}
		if (bcount == 0){
			return loc;
		}
		loc++;
	}
	return NSNotFound;
}

- (NSInteger)findMatchingBracketOfType:(unichar)aChar atIndex:(NSInteger)index
{
  //	NSLog(@"Matching %C", aChar);
	if (aChar == '}') {
		// go backwards in the text
		return [self searchBackwardsForChar:'{' matching:aChar startingAt:index-1];
	}
	if (aChar == '{') {
		// go forwards in the text
		return [self searchForwardsForChar:'}' matching:aChar startingAt:index+1];
	}
	if (aChar == ')') {
		// go backwards in the text
		return [self searchBackwardsForChar:'(' matching:aChar startingAt:index-1];
	}
	if (aChar == '(') {
		// go forwards in the text
		return [self searchForwardsForChar:')' matching:aChar startingAt:index+1];
	}
	if (aChar == '[') {
		// go forwards in the text
		return [self searchForwardsForChar:']' matching:aChar startingAt:index+1];
	}
	if (aChar == ']') {
		// go backwards in the text
		return [self searchBackwardsForChar:'[' matching:aChar startingAt:index-1];
	}
	
	return NSNotFound;
}


- (void) wrapLine
{
	if (self.wrapStyle != TPHardWrap)
		return;
  
  // don't wrap while we are completing
  if ([_popupList isVisible]) {
    return;
  }
  
  NSInteger lineWrapLength = self.wrapAt; //[[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
	// check the length of this line and insert newline if required
	// - we only do this if we are at the end of a line
	NSString *str = [[self textStorage] string];
	NSRange selRange = [self selectedRange];
	
	// is the next character a newline character, or are we at the end of the string?
	NSUInteger strLen = [str length];
	if (selRange.location == strLen ||
			(selRange.location<strLen &&
			 [newLineCharacterSet characterIsMember:[str characterAtIndex:selRange.location]]
			 )
			)
	{
		
		// then we are at the end of a line and we can do wrapping
		NSString*	lstr = [self currentLineToCursor];
		if ([lstr length] > lineWrapLength) {
			
			// Do a proper search for the last whitespace because
			// we could be at the end of a command, for example.
			// Also we should move back to find the start of the word that is before the
			// line wrap length
			
			// get location of the last whitespace
			NSInteger lastWhitespace = [self locationOfLastWhitespaceLessThan:lineWrapLength];
      //      NSLog(@"Last whitespace %ld", lastWhitespace);
      // if the last whitespace location is positive and greater than the start of this line
      NSRange linerange = [[self string] lineRangeForRange:selRange];
      //      NSLog(@"Line starts at %ld", linerange.location);
      
			if (lastWhitespace >= 0 && lastWhitespace>linerange.location) {
        NSInteger insertPoint = lastWhitespace+1;
        // cache the offset from lastWhitespace and
        NSInteger offset = selRange.location - insertPoint;
        
        [self setSelectedRange:NSMakeRange(insertPoint, 0)];
				[self insertNewline:self];
        // now go to the end of the new line
        NSRange currentSelection = [self selectedRange];
				[self setSelectedRange:NSMakeRange(currentSelection.location+offset, 0)];
			} else {
        // do nothing
			}
		}
	}
}

- (NSInteger)cursorPosition
{
  NSRange sel = [self selectedRange];
  return sel.location;
}

- (NSInteger)lineNumberForRange:(NSRange)aRange
{
  //  NSLog(@"Calculating line number");
  NSArray *lines = [self.editorRuler lineNumbersForTextRange:[self getVisibleRange]];
  //  NSLog(@"Got lines %@", lines);
  for (MHLineNumber *line in lines) {
    if (aRange.location >= line.range.location && aRange.location < NSMaxRange(line.range)) {
      return [[line valueForKey:@"number"] integerValue];
    }
    if (line.range.length == 0 && aRange.location == line.range.location) {
      return [[line valueForKey:@"number"] integerValue];
    }
  }
  return NSNotFound;
}

- (NSInteger)lineNumber
{
  //  NSLog(@"Getting line number for %@, from %@", self, self.editorRuler);
  NSRange sel = [self selectedRange];
  NSString *str = [self string];
  if (NSMaxRange(sel)>= [str length]) {
    return NSNotFound;
  }
  NSRange lineRange = [str lineRangeForRange:sel];
  if (lineRange.location != _lastLineRange.location) {
    _lastLineRange = lineRange;
    _lastLineNumber = [self lineNumberForRange:sel];
  }
  return _lastLineNumber;
}

- (NSInteger)columnForRange:(NSRange)aRange
{
  NSString *str = [self string];
  if (NSMaxRange(aRange) >= [str length]) {
    return -1;
  }
  NSRange lineRange = [str lineRangeForRange:aRange];
  return aRange.location-lineRange.location;
}

- (NSInteger)column
{
  NSRange sel = [self selectedRange];
  return [self columnForRange:sel];
}


#pragma mark -
#pragma mark Formatting text

- (void) insertStringBeforeAllLinesInSelection:(NSString*)aStr
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
	
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];
	
	// Get a mutable string for this range
	NSMutableString *newString = [NSMutableString string];
	[newString appendString:[str substringWithRange:r]];
	
	int inserted = 0;
	[newString insertString:aStr atIndex:0];
	NSInteger slen = [aStr length];
	inserted+=slen;
	
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
			[newString insertString:aStr atIndex:ll+1];
			inserted+=slen;
		}
	}
  
  if ([self shouldChangeTextInRange:r replacementString:newString]) {
    [self replaceCharactersInRange:r withString:newString];
    [self didChangeText];
  }
  
	r = [str paragraphRangeForRange:NSMakeRange(r.location, [newString length])];
  [self setSelectedRange:r];
}

- (IBAction) reformatParagraph:(id)sender
{
  // We start from the current paragraph since we don't format
  // a block of text larger than this.
	NSRange pRange = [self rangeForCurrentParagraph];
  
  
  // the position into the paragraph of text we are working with
	NSRange currRange = [self selectedRange];
  NSInteger startPosition = currRange.location - pRange.location;
  
  // reformatt the text for the selected linewidth
  NSInteger lineWrapLength = self.wrapAt; //[[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] integerValue];
  NSString *text = [[self string] substringWithRange:pRange];
  //  NSLog(@"Reformatting [%@]", text);
  NSString *newText = [text reformatStartingAtIndex:startPosition forLinewidth:lineWrapLength];
  if (newText) {
    //  NSLog(@"Got [%@]", newText);
    // replace string
    if ([self shouldChangeTextInRange:pRange replacementString:newText]) {
      [self breakUndoCoalescing];
      [self setSelectedRange:pRange];
      [self replaceCharactersInRange:pRange withString:newText];
      [self didChangeText];
      if (currRange.location+currRange.length > [[self string] length]) {
        currRange.location = [[self string] length]-1;
        currRange.length = 0;
      }
      [self setSelectedRange:currRange];
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:1];
      [self updateEditorRuler];
    }
  }
	return;
}


- (IBAction)selectParagraph:(id)sender
{
	NSRange pRange = [self rangeForCurrentParagraph];
  [self setSelectedRange:pRange];
}

- (IBAction) indentSelection:(id)sender
{
	[self insertStringBeforeAllLinesInSelection:[self stringForTab]];
}


- (IBAction) unindentSelection:(id)sender
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
	
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];
	
	// Get a mutable string for this range
	NSMutableString *newString = [NSMutableString string];
	[newString appendString:[str substringWithRange:r]];
	
	NSString *iStr = [self stringForTab];
	NSInteger slen = [iStr length];
	int removed = 0;
	NSRange cr = NSMakeRange(0, slen);
	if ([[newString substringWithRange:cr] isEqual:iStr]) {
		[newString replaceCharactersInRange:cr withString:@""];
		removed += slen;
	}
	
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
			if (ll+1+slen < [newString length]) {
				cr = NSMakeRange(ll+1, slen);
				if ([[newString substringWithRange:cr] isEqual:iStr]) {
					[newString replaceCharactersInRange:cr withString:@""];
					removed += slen;
				}
			}
		}
	}
	
  if ([self shouldChangeTextInRange:r replacementString:newString]) {
    [self replaceCharactersInRange:r withString:newString];
    [self didChangeText];
  }
  
  r = [str paragraphRangeForRange:NSMakeRange(r.location, [newString length])];
  [self setSelectedRange:r];
}

#pragma mark -
#pragma mark Drag and Drop

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard* pboard = [sender draggingPasteboard];
  
  NSPoint draggingLocation = [sender draggingLocation];
  draggingLocation = [self convertPoint:draggingLocation fromView:nil];
  // can't use Apple's characterIndexForPoint: here because that works in screen coords
  NSUInteger characterIndex = [self characterIndexOfPoint:draggingLocation];
  
	if ( [[pboard types] containsObject:NSFilenamesPboardType] )
	{
		NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
    for (NSString *file in files) {
      
      if ([[file pathExtension] isImage]) {
        [self insertImageBlockForFile:file atLocation:characterIndex];
        return YES;
      }
      
      if ([[[file pathExtension] valueForKey:@"isText"] boolValue]) {
        [self insertIncludeForFile:file atLocation:characterIndex];
        return YES;
      }
      
    }
	}
	
	return [super performDragOperation:sender];
}

- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint
{
  NSUInteger glyphIndex;
  NSLayoutManager *layoutManager = [self layoutManager];
  CGFloat fraction;
  NSRange range;
  
  range = [layoutManager glyphRangeForTextContainer:[self textContainer]];
  glyphIndex = [layoutManager glyphIndexForPoint:aPoint
                                 inTextContainer:[self textContainer]
                  fractionOfDistanceThroughGlyph:&fraction];
  
  if( fraction > 0.5 ) glyphIndex++;
  
  if( glyphIndex == NSMaxRange(range) )
    return  [[self textStorage] length];
  else
    return [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
  
}


- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
  // perform some post drag corrections
  NSRange selRange = [self selectedRange];
  
  NSString *str = [[self string] substringWithRange:selRange];
  
  // replace placeholders
  NSRange newRange = [self replacePlaceholdersInString:str range:selRange];
  
  // make sure the right font is used
  NSDictionary *atts = [NSDictionary currentTypingAttributes];
  [[self textStorage] addAttributes:atts range:newRange];
  
  // grab keyboard
  [[self window] makeFirstResponder:self];
  
  // color
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
}

- (void) insertIncludeForFile:(NSString*)aFile atLocation:(NSUInteger)location
{
  id project = [[self delegate] performSelector:@selector(project)];
  NSString *projectFolder = [project valueForKey:@"folder"];
  //  NSLog(@"Relative path: %@", [aFile relativePathTo:projectFolder]);
  
  NSString *file = [aFile ks_pathRelativeToDirectory:projectFolder];
  
  NSString *str = [NSString stringWithFormat:@"\\input{%@}", file];
  NSRange sel = NSMakeRange(location-1, 0);
  
  if ([self shouldChangeTextInRange:sel replacementString:str]) {
    [self replaceCharactersInRange:sel withString:str];
    [self didChangeText];
  }
  
  [self colorVisibleText];
  
  NSRange insertRange = NSMakeRange(sel.location, [str length]);
  [self setSelectedRange:insertRange];
  [[self layoutManager] ensureLayoutForCharacterRange:insertRange];
}


- (void) insertImageBlockForFile:(NSString*)aFile atLocation:(NSUInteger)location
{
  NSString *projectFolder = [[self delegate] performSelector:@selector(projectFolder)];
  NSString *file = [projectFolder relativePathTo:aFile];
  
  //NSLog(@"File %@", aFile);
  //NSLog(@"Project %@", projectFolder);
  //NSLog(@"computed path %@", file);
  
  NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
  NSString *str = [NSString stringWithFormat:@"\\begin{figure}[htbp]\n\\centering\n\\includegraphics[width=1.0\\textwidth]{%@}\n\\caption{My Nice Figure.}\n\\label{fig:%@}\n\\end{figure}\n", file, name];
  NSRange sel = NSMakeRange(location-1, 0);
  
  if ([self shouldChangeTextInRange:sel replacementString:str]) {
    [self replaceCharactersInRange:sel withString:str];
    [self didChangeText];
  }
  
  [self colorVisibleText];
  
  NSRange insertRange = NSMakeRange(sel.location, [str length]);
  [self setSelectedRange:insertRange];
  [[self layoutManager] ensureLayoutForCharacterRange:insertRange];
}

- (IBAction) pasteTable:(id)sender
{
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  if ( [[pboard types] containsObject:NSStringPboardType] ) {
    NSString *rawstring = [pboard stringForType:NSStringPboardType];
    _pastingRows = [rawstring componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // pop up a sheet asking for the column separator
    if (self.pasteConfigController == nil) {
      self.pasteConfigController = [[TPPasteTableConfigureWindowController alloc] init];
    }
    [NSApp beginSheet:self.pasteConfigController.window
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(pasteTableConfigureSheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
    
  }
}

- (void)pasteTableConfigureSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSCancelButton)
    return;
  
  NSMutableString *stringToPaste = [NSMutableString string];
  if (_pastingRows == nil) {
    return;
  }
  
  NSString *separator = [self.pasteConfigController separator];
  
  // check max columns
  NSInteger columnCount = 0;
  for (NSString *r in _pastingRows){
    NSArray *cols = [r componentsSeparatedByString:separator];
    if ([cols count] > columnCount) {
      columnCount = [cols count];
    }
  }
  
  // prepare table
  [stringToPaste appendFormat:@"\\begin{table}[htdp]\n"];
  [stringToPaste appendFormat:@"\\begin{center}\n"];
  [stringToPaste appendFormat:@"\\begin{tabular}{|"];
  for (int ii=0; ii<columnCount; ii++) {
    [stringToPaste appendFormat:@"c|"];
  }
  [stringToPaste appendFormat:@"} \\hline\n"];
  
  for (NSString *r in _pastingRows) {
    NSArray *cols = [r componentsSeparatedByString:separator];
    for (int cc=0; cc<columnCount; cc++) {
      if (cc < [cols count]) {
        [stringToPaste appendFormat:@" %@ ", [cols[cc] texString]];
      }
      if (cc+1 < columnCount) {
        [stringToPaste appendFormat:@"&"];
      }
    }
    [stringToPaste appendFormat:@"\\\\ \\hline\n"];
  }
  
  [stringToPaste appendFormat:@"\\end{tabular}\n"];
  [stringToPaste appendFormat:@"\\end{center}\n"];
  [stringToPaste appendFormat:@"\\caption{Pasted Table}\n"];
  [stringToPaste appendFormat:@"\\label{tab:pastedTable}\n"];
  [stringToPaste appendFormat:@"\\end{table}\n"];
  
  NSRange selRange = [self selectedRange];
  if ([self shouldChangeTextInRange:selRange replacementString:stringToPaste]) {
    [self replaceCharactersInRange:selRange withString:stringToPaste];
    [self didChangeText];
  }

  [self performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0];
  
}




#pragma mark -
#pragma mark Insert Table

- (IBAction)insertTable:(id)sender
{
  if (!self.tableConfigureController) {
    self.tableConfigureController = [[MHTableConfigureController alloc] initWithDelegate:self];
  }
  
  [NSApp beginSheet:self.tableConfigureController.window modalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:NULL];
  
}

- (void)tableConfigureDidAcceptConfiguration
{
  [NSApp endSheet:self.tableConfigureController.window];
  [self.tableConfigureController.window orderOut:self];
  
  NSInteger nrows = self.tableConfigureController.numberOfRows;
  NSInteger ncols = self.tableConfigureController.numberOfColumns;
  if (nrows != NSNotFound  && ncols != NSNotFound) {
    [self insertTableWithRows:nrows columns:ncols];
  }
}

- (void) tableConfigureDidCancelConfiguration
{
  [NSApp endSheet:self.tableConfigureController.window];
  [self.tableConfigureController.window orderOut:self];
}

- (void)insertTableWithRows:(NSUInteger)nrows columns:(NSUInteger)ncols
{
  NSMutableString *tableString = [NSMutableString string];
  
  // prepare table
  [tableString appendFormat:@"\\begin{table}[htdp]\n"];
  [tableString appendFormat:@"\\begin{center}\n"];
  [tableString appendFormat:@"\\begin{tabular}{|"];
  for (int ii=0; ii<ncols; ii++) {
    [tableString appendFormat:@"c|"];
  }
  [tableString appendFormat:@"} \\hline\n"];
  
  for (int rr=0; rr<nrows; rr++) {
    for (int cc=0; cc<ncols; cc++) {
      // make attachment
      if (cc < ncols) {
        [tableString appendFormat:@" @item%d%d@ ", rr, cc];
      }
      if (cc+1 < ncols) {
        [tableString appendFormat:@"&"];
      }
    }
    [tableString appendFormat:@"\\\\ \\hline\n"];
  }
  
  [tableString appendFormat:@"\\end{tabular}\n"];
  [tableString appendFormat:@"\\end{center}\n"];
  [tableString appendFormat:@"\\caption{New Table}\n"];
  [tableString appendFormat:@"\\label{tab:newTable}\n"];
  [tableString appendFormat:@"\\end{table}\n"];
  
  NSRange sel = [self selectedRange];
  
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString stringWithPlaceholdersRestored:tableString]];
  [str addAttributes:[self typingAttributes] range:NSMakeRange(0, [str length])];
  if ([self shouldChangeTextInRange:sel replacementString:[str string]]) {
    [self.textStorage replaceCharactersInRange:sel withAttributedString:str];
    [self didChangeText];
    [self setSelectedRange:NSMakeRange(sel.location, 0)];
    [self jumpToNextPlaceholder:self];
  }
}

- (IBAction)insertInlineMath:(id)sender
{
  NSRange sel = [self selectedRange];
  NSString *mathString = @"$@x@$";
  
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString stringWithPlaceholdersRestored:mathString]];
  [str addAttributes:[self typingAttributes] range:NSMakeRange(0, [str length])];
  if ([self shouldChangeTextInRange:sel replacementString:[str string]]) {
    [self.textStorage replaceCharactersInRange:sel withAttributedString:str];
    [self didChangeText];
    [self setSelectedRange:NSMakeRange(sel.location, 0)];
    [self jumpToNextPlaceholder:self];
  }
  
}


- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	NSInteger tag = [menuItem tag];
  
  // bold format
  if (tag == 4110 || tag == 4120 || tag == 4130 || tag == 4140 || tag == 4150
      || tag == 4160 || tag == 4170 || tag == 4180 || tag == 4190 || tag == 41100
      || tag == 41110) {
      return YES;
  }
  
  if (tag == 1060) {
    // paste as table. Check we have text on the pasteboard
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *type = [pboard availableTypeFromArray:@[NSRTFDPboardType, NSRTFPboardType, NSStringPboardType]];
    if (type) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // paste:
  if (tag == 1050) {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *type = [pboard availableTypeFromArray:@[NSStringPboardType]];
    if (type) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // pasteAsImage:
  if (tag == 1055) {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *type = [pboard availableTypeFromArray:[NSImage imageTypes]];
    if (type) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // pasteAsTable:
  if (tag == 1060) {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *type = [pboard availableTypeFromArray:@[NSPasteboardTypeTabularText]];
    if (type) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // zoom in
  if (tag == 2050) {
    if (self.zoomFactor == kMaxZoom)
      return NO;
  }  
  
  // zoom out
  if (tag == 2060) {
    if (self.zoomFactor == 0) 
      return NO;
  }
  
  return [super validateMenuItem:menuItem];
}

#pragma mark -
#pragma mark findbar



//- (void) cancelFind
//{
//  if ([self respondsToSelector:@selector(setUsesFindBar:)]) {
//    [self performTextFinderAction:<#(id)#>]
//  }
//}

//- (NSString*)string
//{
//  NSString *s = [super string];
//  NSLog(@"*** Getting string %@...", [s substringToIndex:MIN(30, [s length])]);
//  return s;
//}

-(NSUInteger) stringLength
{
//  NSLog(@"*** Getting string length...");
  return [[super string] length];
}

- (NSString *)stringAtIndex:(NSUInteger)characterIndex effectiveRange:(NSRangePointer)outRange endsWithSearchBoundary:(BOOL *)outFlag
{
//  [[self textStorage] atta]
  NSRange r = NSMakeRange(0, [[super string] length]);
//  NSLog(@"*** Returning range %@", NSStringFromRange(r));
  
  *outRange = r;
  *outFlag = YES;
  return [super string];
}

/*
 If the client cannot logically or efficiently flatten itself into a single string, then the following two methods should be used instead. These methods require the client to conceptually map its content to a single string, which is composed of a concatenation of all its substrings.
 
 The first method asks for the string that contains the given characer index, which the client should return. This client should also return, by reference, the "effective range" of that substring in the full conceptually concatenated string. Finally, the client should return whether the substring ends with a "search boundary", meaning that NSTextFinder should not attempt to find any matches that overlap this boundary.
 
 The client should report the full length of the conceptually concatenated string in the second model -- the sum of the lengths of all of its substrings.
 */


@end
