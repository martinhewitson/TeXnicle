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

#define LargeTextWidth  1e7
#define LargeTextHeight 1e7

#define kMaxZoom 42

#define kFontWrapScaleCorrection 1.07

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

@end

@implementation TeXTextView

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
    
  [self defaultSetup];
  [self setUpRuler];
  [self setupLists];
  
  [self setSmartInsertDeleteEnabled:NO];
  [self setAutomaticTextReplacementEnabled:NO];
  [self setAutomaticSpellingCorrectionEnabled:NO];
  
  self.coloringEngine = [TeXColoringEngine coloringEngineWithTextView:self];
 
  [self applyFontAndColor:YES];
}



// Do the default setup for the text view.
- (void) defaultSetup
{
  if ([self respondsToSelector:@selector(setUsesFindBar:)]) {
    [self setUsesFindBar:YES];
  } else {
    [self setUsesFindPanel:YES];
  }
  
  // set color for line highlighting
  self.lineHighlightColor = [[self backgroundColor] shadowWithLevel:0.1];
  
	[[self layoutManager] setAllowsNonContiguousLayout:YES];
  [self turnOffWrapping];
  [self observePreferences];
  
  // set font and color
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  // basic text
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
  NSColor *color = [[defaults valueForKey:TESyntaxTextColor] colorValue];
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
  
  [self setPostsFrameChangedNotifications:YES];
  [[[self enclosingScrollView] contentView] setPostsBoundsChangedNotifications:YES];
  [nc addObserver:self
         selector:@selector(handleFrameChangeNotification:)
             name:NSViewBoundsDidChangeNotification 
           object:[[self enclosingScrollView] contentView]];
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
  
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
	
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
  
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
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
	
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
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
  [self setNeedsDisplay:YES];
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
  NSRange pRange = [self rangeForCurrentLine];  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSColor *color = [[defaults valueForKey:TESyntaxTextColor] colorValue];
  [[self textStorage] addAttribute:NSForegroundColorAttributeName value:color range:pRange];
}

- (void) colorVisibleText
{
//  NSLog(@"Color visible text: delegate %@", self.delegate);
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(shouldSyntaxHighlightDocument)]) {
    if (![[self delegate] performSelector:@selector(shouldSyntaxHighlightDocument)]) {
      return;
    }
  }
  
  NSRange vr = [self getVisibleRange];
//  NSLog(@"Visible range %ld-%ld", vr.location, vr.location+vr.length);
  
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
  
//  NSLog(@"Coloring range %ld-%ld", r.location, r.location+r.length);
  if (self.coloringEngine) {
    [self.coloringEngine colorTextView:self
                           textStorage:[self textStorage]
                         layoutManager:[self layoutManager]
                               inRange:r];
  }
  
}

#pragma mark -
#pragma mark Actions



- (void) handleFrameChangeNotification:(NSNotification*)aNote
{
//  NSLog(@"Frame change");
  [_popupList dismiss];
  [self colorVisibleText];
  [self highlightMatchingWords];
  [self updateEditorRuler];
}

- (void) updateEditorRuler
{
  [self.editorRuler resetLineNumbers];
  [self.editorRuler setNeedsDisplay:YES];
  [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark KVO 

- (void) stopObserving
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TESyntaxTextColor]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentFont]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentBackgroundColor]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEHighlightCurrentLine]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TEHighlightMatchingWords]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TESelectedTextColor]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TESelectedTextBackgroundColor]];  
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TELineLength]];
}

- (void) observePreferences
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentFont]
                options:NSKeyValueObservingOptionNew
                context:NULL];		

  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TESyntaxTextColor]
                options:NSKeyValueObservingOptionNew
                context:NULL];		
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEDocumentBackgroundColor]
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
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEHighlightCurrentLine]
                options:NSKeyValueObservingOptionNew
                context:NULL];		
  
  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TEHighlightMatchingWords]
                options:NSKeyValueObservingOptionNew
                context:NULL];		

  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TESelectedTextColor]
                options:NSKeyValueObservingOptionNew
                context:NULL];		

  [defaults addObserver:self
             forKeyPath:[NSString stringWithFormat:@"values.%@", TESelectedTextBackgroundColor]
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
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TEDocumentBackgroundColor]]) {	
    NSColor *c = [[[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentBackgroundColor] colorValue];
    [self setBackgroundColor:c];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]]) {
    [self performSelectorOnMainThread:@selector(updateEditorRuler) withObject:nil waitUntilDone:YES];
    [self.editorRuler recalculateThickness];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]]) {
    [self performSelectorOnMainThread:@selector(updateEditorRuler) withObject:nil waitUntilDone:YES];
    [self.editorRuler recalculateThickness];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEHighlightMatchingWords]]) {
    NSRange vr = [self getVisibleRange];
    [[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:vr];
    [self highlightMatchingWords];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEHighlightCurrentLine]]) {
		[self setNeedsDisplayInRect:[self bounds] avoidAdditionalLayout:YES];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineLength]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TESelectedTextColor]]) {
    [self applyFontAndColor:YES];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TESelectedTextBackgroundColor]]) {
    [self applyFontAndColor:YES];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEDocumentFont]]) {
    [self applyFontAndColor:YES];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TESyntaxTextColor]]) {
    [self applyFontAndColor:YES];
	}
}

- (void) setTypingColor:(NSColor*)aColor
{
  NSDictionary *catts = [NSDictionary currentTypingAttributes];
  NSMutableDictionary *atts = [catts mutableCopy];
  [atts setValue:aColor forKey:NSForegroundColorAttributeName];
  [self setTypingAttributes:atts];
}

- (void) applyFontAndColor:(BOOL)forceUpdate
{
//  NSLog(@"Apply font and color");
  
//  NSRect visibleRect = [self visibleRect];
//  NSRange sel = [self selectedRange];
//  NSLog(@"  Visible rect: %@", NSStringFromRect(visibleRect));
//  NSLog(@"  Selected range %@", NSStringFromRange(sel));
  
  NSDictionary *atts = [NSDictionary currentTypingAttributes];
  NSFont *newFont = [atts valueForKey:NSFontAttributeName];
  newFont = [NSFont fontWithName:[newFont fontName] size:self.zoomFactor+[newFont pointSize]];
  NSColor *newColor = [atts valueForKey:NSForegroundColorAttributeName];
  if (![newFont isEqualTo:[self font]] || forceUpdate) {
//    NSLog(@"Setting new font");
    [self setFont:newFont];
  }
  if (![newColor isEqualTo:[self textColor]] || forceUpdate) {
//    NSLog(@"Setting new color");
    [self setTextColor:newColor];
  }
  
  NSDictionary *currentAtts = [self typingAttributes];
  if (![currentAtts isEqualToDictionary:atts] || forceUpdate) {
//    NSLog(@"setting typing atts");
    [self setTypingAttributes:atts];
  } else {
//    NSLog(@"Skipping setting atts");
  }
  
  // background color
  NSColor *c = [[[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentBackgroundColor] colorValue];
  // for some reason we need to do this otherwise the scrolling jumps around in the textview.
  [self performSelector:@selector(setBackgroundColor:) withObject:c afterDelay:0];
  
  // selection color
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [self setSelectedTextAttributes:
   @{NSBackgroundColorAttributeName: [[defaults valueForKey:TESelectedTextBackgroundColor] colorValue],
    NSForegroundColorAttributeName: [[defaults valueForKey:TESelectedTextColor] colorValue]}];
  
//  [self scrollRangeToVisible:sel];
//  [self scrollRectToVisible:visibleRect];
//  
//  NSLog(@"Finished.");
//  NSLog(@"  Visible rect: %@", NSStringFromRect(visibleRect));
//  NSLog(@"  Selected range %@", NSStringFromRange(sel));
//  
}

- (void) setWrapStyle
{
  int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
  int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
  NSTextContainer *textContainer = [self textContainer];
  if (wrapStyle == TPSoftWrap) {
    CGFloat scale = [NSString averageCharacterWidthForFont:self.font];
    [textContainer setContainerSize:NSMakeSize(scale*wrapAt*kFontWrapScaleCorrection, LargeTextHeight)];
  }	else if (wrapStyle == TPNoWrap) {
    [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
  } else {
    // set large size - hard wrap is handled in the wrapLine
    [textContainer setContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
  }
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Text Storage Observing

- (void) processEditing:(NSNotification*)aNote
{
	[self setNeedsDisplayInRect:[self bounds] avoidAdditionalLayout:NO];
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
		NSArray *guesses = [sc guessesForWord:word];
		if ([guesses count]>0) {
      //			NSLog(@"Guesses: %@", guesses);
			
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
        NSPoint current = [_popupList currentPoint];
        NSPoint wp = [self convertPoint:point toView:nil];
        // update the window in y
        [_popupList moveToPoint:NSMakePoint(current.x, wp.y)];
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
	NSString *replacement = [NSString stringWithString:aWord];
	NSRange curr = [self selectedRange];
	NSRange rr = NSMakeRange(curr.location, 0);
	[self shouldChangeTextInRange:rr replacementString:replacement];
	[self replaceCharactersInRange:rr withString:replacement];
	[self clearSpellingList];
  [self colorVisibleText];
}

- (void) replaceWordUpToCurrentLocationWith:(NSString*)aWord
{
	NSString *replacement = [NSString stringWithString:aWord];
	[self selectUpToCurrentLocation];
	NSRange sel = [self selectedRange];
	[self shouldChangeTextInRange:sel replacementString:replacement];
	[self replaceCharactersInRange:sel withString:replacement];
	[self clearSpellingList];
  [self colorVisibleText];
}

- (void) replaceWordAtCurrentLocationWith:(NSString*)aWord
{
	NSString *replacement = [NSString stringWithString:aWord];
	//	NSLog(@"Replacing current word with %@", replacement);
  //	[self selectWord:self];
	NSRange sel = [self rangeForCurrentWord];
	[self shouldChangeTextInRange:sel replacementString:replacement];
	[self replaceCharactersInRange:sel withString:replacement];
	[self clearSpellingList];
  [self colorVisibleText];
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
			[[self textStorage] replaceCharactersInRange:NSMakeRange(lineRange.location, idx+2) 
																				withString:[code stringByAppendingString:@"\n"]];
			
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
	if ([[string string] isEqualToString:[text string]] == NO) {
    // then we unfoled
    [[self textStorage] deleteCharactersInRange:aRange];
    [[self textStorage] insertAttributedString:string atIndex:aRange.location];
    
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
	[[self textStorage] removeAttribute:NSAttachmentAttributeName range:attRange];
	[[self textStorage] replaceCharactersInRange:attRange withAttributedString:code];
  
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
  [self setSelectedRange:aRange];  
  [self insertText:replacement];
  
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
  
  NSRange glyphRange = [lm glyphRangeForBoundingRect:visRect                        
                                     inTextContainer:[self textContainer]];
  NSRange charRange = [lm characterRangeForGlyphRange:glyphRange                       
                                     actualGlyphRange:NULL];
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
//  NSLog(@"Getting highlight range for range %@", NSStringFromRange(aRange));
  NSRange r = aRange;
  NSRange startLineRange = [[self string] lineRangeForRange:NSMakeRange(r.location, 0)];
//  NSLog(@"Start line range %@", NSStringFromRange(startLineRange));
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
//  NSLog(@"End line range %@", NSStringFromRange(endLineRange));
  
  NSRange gr = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(startLineRange.location, NSMaxRange(endLineRange)-startLineRange.location-1)
                                            actualCharacterRange:NULL];
  NSRect br = [[self layoutManager] boundingRectForGlyphRange:gr inTextContainer:[self textContainer]];
  
  NSRect b = [self bounds];
  CGFloat h = br.size.height;
  CGFloat w = b.size.width;
  CGFloat y = br.origin.y;
  
  NSPoint containerOrigin = [self textContainerOrigin];
  
  NSRect aRect = NSMakeRect(0, y, w, h);
//  NSLog(@"Highlight rect: %@", NSStringFromRect(aRect));
  // Convert from view coordinates to container coordinates
  aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
  return aRect;
}


- (void) handleSelectionChanged:(NSNotification*)aNote
{
  [self setNeedsDisplay:YES];
  NSRange r = [self selectedRange];
  [[NSNotificationCenter defaultCenter] postNotificationName:TECursorPositionDidChangeNotification
                                                      object:self
                                                    userInfo:@{@"index": [NSNumber numberWithInteger:r.location]}];
  
  [self colorVisibleText];
  [self setTypingAttributes:[NSDictionary currentTypingAttributes]];

  [self highlightMatchingWords];
}

- (void) highlightMatchingWords
{  
  
  NSRange r = [self selectedRange];
  NSRange vr = [self getVisibleRange];
  //  NSLog(@"Visible range %@", NSStringFromRange(vr));
  
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([[defaults valueForKey:TEHighlightMatchingWords] boolValue]) {
    [[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:vr];
    
    NSString *string = [self string];
    if (r.length > 0 && NSMaxRange(r)<[string length]) {
      NSString *word = [[[self string] substringWithRange:r] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      word = [word stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
      if (word && [word length]>1) {
        NSString *textToSearch = [[self string] substringWithRange:vr];
        NSArray *matches = [textToSearch rangesOfString:word];
        
        NSColor *highlightColor = [[defaults valueForKey:TEHighlightMatchingWordsColor] colorValue];
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

- (void) paste:(id)sender
{
  [self pasteAsPlainText:sender];
  [self applyFontAndColor:YES];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
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
		[self insertText:str];		
	} else {
		[super insertTab:sender];
	}
	
}

- (void) insertNewline:(id)sender
{
  if ([_popupList isVisible]) {
    [_popupList selectSelectedItem:self];
    [self wrapLine];
    return;
  }
  
	// read the last line
	NSRange selRange = [self selectedRange];
	
	if (selRange.location == 0) {
		// now put in the requested newline
		[super insertNewline:sender];
    [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
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
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
			return;
		}		
		
		// if the current cursor location is not at the end of the \begin{} statement, we do nothing special    
    int start = 0;
    int end   = 0;
    for (int kk=0; kk<[previousLine length]; kk++) {
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
      [super insertText:indentString];
      
      // tab in
      [self insertTab:self];
      
      // record this location
      selRange = [self selectedRange];
      
      // add the new \end
      [self insertText:insert];
      [self applyFontAndColor:YES];
      
      // wind back the location of the cursor					
      [self setSelectedRange:selRange];				
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];        
      
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
        
    // indent the new line
    if (!_shiftKeyOn && indentRange.location != NSNotFound) {
      NSRange sel = [self selectedRange];
      NSString *indentString = [str substringWithRange:indentRange];
      [self replaceCharactersInRange:NSMakeRange(sel.location, 0) withString:indentString];
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
//  NSLog(@"Selection is in citation?");
  NSString *word = [self currentCommand];
//  NSLog(@"word %@", word);
  if (word == nil || [word length]==0) {
//    NSLog(@"   no");
    return NO;
  }
  // check if it is one of the citation commands
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL citeCommand = [word beginsWithElementInArray:[defaults valueForKey:TECiteCommands]] != NSNotFound;  
  if (citeCommand == NO) {
//    NSLog(@"   no");
    return NO;
  }
  
  // now check we are in an argument
  NSString *arg = [self currentArgument];
//  NSLog(@"arg %@", arg);
  if (arg == nil) {    
//    NSLog(@"   no");
    return NO;
  }
  
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
      [self completeFromList:list];
    } else {
      [self insertFromList:list];
    }
  }
}

- (void) showListOfBeginCompletions
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *list = [defaults valueForKey:TEBeginCommands];
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
    [self completeFromList:list];
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
      [self completeFromList:list];
    } else {
      [self insertFromList:list];
    }    
  }
}

- (void) showListOfCiteCompletions
{
//  NSLog(@"Showing list of citation completions...");
  
  if ([self.delegate respondsToSelector:@selector(listOfCitations)]) {
    NSArray *list = [self.delegate performSelector:@selector(listOfCitations)];
    
    // filter the list by existing characters
    NSString *arg = [self currentArgument];
//    NSLog(@"Completing arg %@", arg);
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
      [self completeFromList:list];
    } else {
      [self completeFromList:list];
    }
  }
}

- (BOOL) completeArgument
{
  // check for completing arguments
  NSString *arg = [self currentArgument];
//  NSLog(@"Completing arg '%@'", arg);
  if (arg != nil) {
    if ([self selectionIsInRefCommand]) {
//      NSLog(@"In ref");
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
	
//  NSLog(@"Completing... %@", word);
  NSString *command = word;
//	NSLog(@"       or command: %@", command);
//	NSLog(@"       or arg: %@", arg);
  
	id delegate = [self delegate];
  //	NSLog(@"Delegate: %@", delegate);
  if ([self completeArgument]) {
    // do completion
	} else if (command != nil && [command length] > 0 && (arg == nil || [arg isEqualToString:command]) ) {
    
    NSArray *list = [NSMutableArray arrayWithArray:self.commandList];

    // get list of user defaults commands
    list = [list arrayByAddingObjectsFromArray:[self userDefaultCommands]];
    
    if ([delegate respondsToSelector:@selector(listOfCommands)]) {
      list = [list arrayByAddingObjectsFromArray:[delegate listOfCommands]];
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
      [self completeFromList:list];
    }
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
    
    // tab key to complete
    if ([theEvent keyCode] == 48 ) {
      [_popupList selectSelectedItem:self];
      [self wrapLine];
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
      if ([self.delegate respondsToSelector:@selector(textView:didCommandClickAtLine:column:)]) {
        [(TeXEditorViewController*)self.delegate textView:self didCommandClickAtLine:line column:column];
      }
    }
	}
  
	[super mouseDown:theEvent];
}


//- (void)viewWillDraw
//{
//  [self.editorRuler setNeedsDisplay:YES];
//	[super viewWillDraw];
//}

- (void) drawViewBackgroundInRect:(NSRect)rect
{
	[super drawViewBackgroundInRect:rect];
  
  // additional highlight range
	if (self.highlightRange) {    
    NSRect aRect = [self highlightRectForRange:NSRangeFromString(self.highlightRange)];		
		[[[self backgroundColor] shadowWithLevel:_highlightAlpha] set];
		[NSBezierPath fillRect:aRect];
	} else {
    [[self backgroundColor] set];
    [NSBezierPath fillRect:[self bounds]];
  }  
  
  // highlight current line
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([[defaults valueForKey:TEHighlightCurrentLine] boolValue]) {
    NSRange sel = [self selectedRange];
    NSString *str = [self string];
    if (sel.location <= [str length]) {
      NSRange lineRange = [str lineRangeForRange:NSMakeRange(sel.location,0)];
      NSRect lineRect = [self highlightRectForRange:lineRange];
      NSColor *highlightColor = [[defaults valueForKey:TEHighlightCurrentLineColor] colorValue];
      [highlightColor set];
      [NSBezierPath fillRect:lineRect];
    }
  }
  
  
  // line width
  int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
  if (wrapStyle == TPHardWrap || wrapStyle == TPSoftWrap) {
    NSRect vr = [self visibleRect];
    NSRect r;
    
    if (wrapStyle == TPSoftWrap) {
      NSSize inset = [self textContainerInset];
      NSSize s = [[self textContainer] containerSize];
      r = NSMakeRect(inset.width+s.width, vr.origin.y, vr.size.width, vr.size.height);
    } else {
      int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
      CGFloat scale = [NSString averageCharacterWidthForFont:self.font];
      r = NSMakeRect(scale*wrapAt*kFontWrapScaleCorrection, vr.origin.y, vr.size.width, vr.size.height);
    }
    
    if ([[self backgroundColor] isDarkerThan:0.7]) {
      [[[self backgroundColor] highlightWithLevel:0.1] set];
    } else {
      [[[self backgroundColor] shadowWithLevel:0.1] set];
    }
        
    [NSBezierPath fillRect:r];
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
  [self colorVisibleText];
}

- (void)deleteWordBackward:(id)sender
{
  [super deleteWordBackward:sender];
  [self applyCurrentTextColorToLine];
  [self colorVisibleText];
}

- (void)deleteToBeginningOfLine:(id)sender
{
  [super deleteToBeginningOfLine:sender];
  [self applyCurrentTextColorToLine];
  [self colorVisibleText];
}


- (void)insertText:(id)aString
{	
  
  // check if the next character or preceeding character was a text attachment
	NSRange selRange = [self selectedRange];
	NSRange effRange;
	NSAttributedString *string = [self attributedString];
	if ([string length] == 0) {
		[super insertText:aString];
		return;
	}
  
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
        [super replaceCharactersInRange:selRange withString:aString];
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
  
  if ([line isCommentLineBeforeIndex:lineIndex commentChar:[self commentChar]]) {
    [self setTypingColor:self.coloringEngine.commentColor];
  } else if ([paragraph isInArgumentAtIndex:lineIndex]) {
    [self setTypingColor:self.coloringEngine.argumentsColor];
  } else if ([line isCommandBeforeIndex:lineIndex]) {
    [self setTypingColor:self.coloringEngine.commandColor];
  } else {
    [self applyFontAndColor:NO];
  }
  
//  NSLog(@"Inserting text at index %d", selRange.location);
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL completeBrace = [[defaults valueForKey:TEAutomaticallyInsertClosingBrace] boolValue];
  BOOL skipClosingBrace = [[defaults valueForKey:TEAutomaticallySkipClosingBrackets] boolValue];
  
  if ([aString isEqual:@"{"] && completeBrace) {
    // get selected text
    if (selRange.length > 0) {
      NSString *selected = [[string string] substringWithRange:selRange];
      [super replaceCharactersInRange:selRange withString:[NSString stringWithFormat:@"{%@}", selected]];
    } else {
      [super insertText:@"{}"];
      [self moveLeft:self];
      [self autocompleteArgument];
    }
	} else 	if ([aString isEqual:@"["] && completeBrace) {
		NSRange r = [self selectedRange];
		r.location-=2;
		r.length+=2;
		[super insertText:@"[]"];
		[self moveLeft:self];
	} else 	if ([aString isEqual:@"("] && completeBrace) {
		NSRange r = [self selectedRange];
		r.location-=2;
		r.length+=2;
		[super insertText:@"()"];
		[self moveLeft:self];
	} else	if ([aString isEqual:@"}"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
//    NSLog(@"Range %@", NSStringFromRange(r));
		if (skipClosingBrace && r.location < [string length] && [[self string] characterAtIndex:r.location] == '}') {
			// move right
			[self moveRight:self];
			return;
		}	else {
			[super insertText:aString];
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
			[super insertText:aString];
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
			[super insertText:aString];
			return;
		}	
	} else	if ([[defaults valueForKey:TEAutomaticallyReplaceOpeningDoubleQuote] boolValue]
              && [aString isEqual:@"\""] 
              && [[self fileExtension] isEqualToString:@"tex"]) {
		// do smart replacements
		NSRange r = [self selectedRange];
    if (r.location>0) {
      NSInteger loc = r.location-1;
      if ([whitespaceCharacterSet characterIsMember:[[self string] characterAtIndex:loc]]) {
        [self insertText:@"``"];        
      } else {
        [super insertText:aString];
      }
    } else {
      [super insertText:aString];
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
}


- (BOOL) autocompleteArgument
{  
  NSString *arg = [self currentArgument];
//  NSLog(@"Autocomplete arg %@", arg);
  
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
  
  [self updateEditorRuler];

  if (![self autocompleteArgument]) {
    if (![self autocompleteCommand]) {
      [_popupList dismiss];
    }
  }
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
    if ([word length]>1) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", word];
      list = [list filteredArrayUsingPredicate:predicate];			
    }
    return list;
  }

  return nil;
}

#pragma mark -
#pragma mark Text processing

- (NSRange)indentRangeForLineAtIndex:(NSInteger)loc
{
  NSString *str = [self string];
  NSInteger idx = NSNotFound;
  if (loc <= [str length]) {
    NSRange lineRange = [str lineRangeForRange:NSMakeRange(loc,0)];
//    NSLog(@"Line range %@", NSStringFromRange(lineRange));
    idx = lineRange.location;
    while (idx < NSMaxRange(lineRange)) {
//      NSLog(@"    checking char %c", [str characterAtIndex:idx]);
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
      [[self undoManager] beginUndoGrouping];
      [self shouldChangeTextInRange:commandRange replacementString:code];
      [self replaceCharactersInRange:commandRange withString:code];
      [self replacePlaceholdersInString:code range:commandRange];      
      [self didChangeText];
      [[self undoManager] endUndoGrouping];
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
      return YES;
    }
  }
  return NO;
}

- (NSRange) replacePlaceholdersInString:(NSString*)code range:(NSRange)commandRange
{
  NSString *originalCode = code;
  
  // Replace placeholders
  NSString *regexp = [TPLibraryController placeholderRegexp];
  NSArray *placeholders = [TPRegularExpression stringsMatching:regexp inText:code];
  
  NSRange firstPlaceholder = NSMakeRange(NSNotFound, 0);
  for (__strong NSString *placeholder in placeholders) {
    placeholder = [placeholder stringByTrimmingCharactersInSet:whitespaceCharacterSet];
    NSRange r = [code rangeOfString:placeholder];
    if (firstPlaceholder.location == NSNotFound) {
      firstPlaceholder = NSMakeRange(commandRange.location+r.location, 1);
    }
    
    // make attachment
    MHPlaceholderAttachment *placeholderAttachment = [[MHPlaceholderAttachment alloc] initWithName:[placeholder substringWithRange:NSMakeRange(1, [placeholder length]-2)]];    
    NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:placeholderAttachment];
    NSRange placeholderRange = NSMakeRange(commandRange.location+r.location, r.length);
    [self shouldChangeTextInRange:placeholderRange replacementString:@" "];
    [[self textStorage] replaceCharactersInRange:placeholderRange withAttributedString:attachment];
    [self didChangeText];
    // replace placeholder with blank just to make the counting right
    code = [code stringByReplacingCharactersInRange:r withString:@" "];
  }      
  
  // select the first placeholder
  if (firstPlaceholder.location != NSNotFound) {
    [self setSelectedRange:firstPlaceholder];
  }
  
  // adjust and return range
  NSInteger reduction = [originalCode length] - [code length];
  NSRange returnRange = NSMakeRange(commandRange.location, commandRange.length - reduction);
  return returnRange;
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
	int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
	if (wrapStyle != TPHardWrap) 
		return;
  
  // don't wrap while we are completing
  if ([_popupList isVisible]) {
    return;
  }
  
	int lineWrapLength = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
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
	  
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
  
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
	NSInteger lineWrapLength = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] integerValue];
  NSString *text = [[self string] substringWithRange:pRange];
//  NSLog(@"Reformatting [%@]", text);
  NSString *newText = [text reformatStartingAtIndex:startPosition forLinewidth:lineWrapLength];
  
//  NSLog(@"Got [%@]", newText);
  // replace string
	[self breakUndoCoalescing];
	[self setSelectedRange:pRange];
  [self shouldChangeTextInRange:pRange replacementString:newText];
  [[self textStorage] beginEditing];
  [[self textStorage] replaceCharactersInRange:pRange withString:newText];
  [[self textStorage] endEditing];
	[self setSelectedRange:currRange];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:1];
  
	return;
}


- (IBAction)selectParagraph:(id)sender
{
	NSRange pRange = [self rangeForCurrentParagraph];
  [self setSelectedRange:pRange];
}



- (IBAction) reformatRange:(NSRange)pRange
{
	
	NSRange currRange = [self selectedRange];
	[self setSelectedRange:pRange];	
	NSString *oldStr = [[self string] substringWithRange:pRange];
  NSLog(@"Reformatting text: \n[%@]", oldStr);
  
  if ([oldStr length] == 0) {
    return;
  }
  
  // get the initial indent: either the number of whitespaces or the index in the line of the \command
	NSInteger offset = 0;
  NSInteger loc = 0;
  NSString *indent = @"";
  if ([oldStr characterAtIndex:0] == '\\') {
    NSRange lineRange = [[self string] lineRangeForRange:pRange];
    offset = pRange.location - lineRange.location;
    if ([oldStr hasPrefix:@"\\item"]) {
      indent = [[self string] substringWithRange:NSMakeRange(lineRange.location, offset)];
    }
//    NSRange lineRange = ;
  } else {
    while ([whitespaceCharacterSet characterIsMember:[oldStr characterAtIndex:loc]]) {
      loc++;
    }
    indent = [oldStr substringToIndex:loc];
    pRange.location += [indent length];
    pRange.length -= [indent length];
  }
  
  
	NSInteger lineWrapLength = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] integerValue] - [indent length];
  
  NSString *newString = [oldStr substringFromIndex:loc];
  newString = [TPRegularExpression stringByReplacingOccurrencesOfRegex:@"[\n\r\t]+" withString:@" " inString:newString];
  //	NSString *newString = [NSString stringWithControlsFilteredForString:oldStr];
  
  // replace multiple ' ' with a single space
  newString = [TPRegularExpression stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" " inString:newString];
	
  NSLog(@"Scanning through \n[%@]", newString);
  
	// Now go through and put in \n when we are past the linelength
  //	NSString *lineBreakStr = [NSString stringWithFormat:@" %C", NSLineSeparatorCharacter];
	NSString *lineBreakStr = [NSString stringWithFormat:@"\n"];
  loc = 0;
  NSInteger count = offset;
	while (loc < [newString length]) {
//    NSLog(@"Checking location %d = '%c'", loc, [newString characterAtIndex:loc]);
		if (count >= lineWrapLength) {
//      NSLog(@"  past line wrap");
      if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:loc]]) {
        // if we already have a newline, reset the count
//        NSLog(@"    already have newline");
        count = 0;
      } else if ([whitespaceCharacterSet characterIsMember:[newString characterAtIndex:loc]]) {
        // rewind to previous whitespace if we are past the line length
//        NSLog(@"   rewinding to last whitespace");
        NSInteger start = loc;
        if (count > lineWrapLength) {
          loc--;
          
          // WE NEED TO CHECK IF WE ACTUALLY FIND A WHITESPACE OR NEWLINE, OTHERWISE CARRY ON FROM WHERE WE WERE!!
          BOOL rewound = NO;
          while (loc >= 0) {
//            NSLog(@"      checking char '%c'", [newString characterAtIndex:loc]);
            if ([whitespaceCharacterSet characterIsMember:[newString characterAtIndex:loc]]) {
              loc++;
              rewound = YES;
              break;
            }
            
            if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:loc]]) {
              break;
            }
            loc--;
          }
          
          if (rewound == NO) {
            loc = start;
          }
        }
        
//        NSLog(@"   replacing newline at %d", loc);
				newString = [newString stringByReplacingCharactersInRange:NSMakeRange(loc, 0)
																											 withString:lineBreakStr];
        count = 0;
			} else {
        // do nothing
      }
		}
    count++;
		loc++;
	}
    
//  newString = [newString stringByReplacingOccurrencesOfRegex:@"\n\\s*" withString:[NSString stringWithFormat:@"\n%@", indent]];
//  newString = [TPRegularExpression stringByReplacingOccurrencesOfRegex:@"\n\\s*" withString:[NSString stringWithFormat:@"\n%@", indent] inString:newString];
//  newString = [indent stringByAppendingString:newString];
  
	[self breakUndoCoalescing];
	[self setSelectedRange:pRange];
  [self shouldChangeTextInRange:pRange replacementString:newString];
  [[self textStorage] beginEditing];
  [[self textStorage] replaceCharactersInRange:pRange withString:newString];
  [[self textStorage] endEditing];
	[self setSelectedRange:currRange];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:1];
	return;
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
	
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
  
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
  [self setSelectedRange:sel];
  [self insertText:str];
  [self colorVisibleText];
  
  NSRange insertRange = NSMakeRange(sel.location, [str length]);
  [self setSelectedRange:insertRange];
  [[self layoutManager] ensureLayoutForCharacterRange:insertRange];
}


- (void) insertImageBlockForFile:(NSString*)aFile atLocation:(NSUInteger)location
{
  id project = [[self delegate] performSelector:@selector(project)];
  NSString *projectFolder = [project valueForKey:@"folder"];
  NSString *file = [projectFolder relativePathTo:aFile];
  
//  NSLog(@"File %@", aFile);
//  NSLog(@"Project %@", projectFolder);
//  NSLog(@"computed path %@", file);
  
  NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
  NSString *str = [NSString stringWithFormat:@"\\begin{figure}[htbp]\n\\centering\n\\includegraphics[width=1.0\\textwidth]{%@}\n\\caption{My Nice Figure.}\n\\label{fig:%@}\n\\end{figure}\n", file, name];
  NSRange sel = NSMakeRange(location-1, 0);
  [self setSelectedRange:sel];
  [self insertText:str];
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
  
  [self insertText:stringToPaste];      
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
  [self insertText:tableString];    
  
  [self replacePlaceholdersInString:tableString range:sel];
}

- (IBAction)insertInlineMath:(id)sender
{
  NSRange sel = [self selectedRange];
  NSString *mathString = @"$@x@$";
  [self insertText:mathString];
  [self replacePlaceholdersInString:mathString range:sel];
  [self jumpToPreviousPlaceholder:self];
}


- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	NSInteger tag = [menuItem tag];
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

@end
