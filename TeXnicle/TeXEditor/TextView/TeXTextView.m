//
//  TeXTextView.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TeXTextView.h"
#import "RegexKitLite.h"

#import "NSArray+Color.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "NSAttributedString+CodeFolding.h"
#import "NSString+Comparisons.h"
#import "NSString+CharacterSize.h"

#import "MHEditorRuler.h"
#import "MHCodeFolder.h"
#import "TeXColoringEngine.h"
#import "TPPopupListWindowController.h"
#import "TPFoldedCodeSnippet.h"
#import "NSString+RelativePath.h"

#import "MHLineNumber.h"

#import "externs.h"

#define LargeTextWidth  1e7
#define LargeTextHeight 1e7



@implementation TeXTextView

@synthesize editorRuler;
@synthesize coloringEngine;
@synthesize highlightRange;
@synthesize lineHighlightColor;
@synthesize syntaxHighlightTags;
@synthesize highlightingTimer;
@synthesize shiftKeyOn;
@synthesize commandList;
@synthesize beginList;



- (void) dealloc
{
//  NSLog(@"TextView dealloc");
  self.editorRuler = nil;
  self.lineHighlightColor = nil;
  self.coloringEngine = nil;
  [self.highlightingTimer invalidate];
  self.highlightingTimer = nil;
	[newLineCharacterSet release];
	[whitespaceCharacterSet release];
  [self stopObserving];
  [super dealloc];
}

- (void) awakeFromNib
{
//  NSLog(@"TextView awakeFromNib");
  
	newLineCharacterSet = [[NSCharacterSet newlineCharacterSet] retain];
	whitespaceCharacterSet = [[NSCharacterSet whitespaceCharacterSet] retain];	
    
  [self defaultSetup];
  [self setUpRuler];
  [self setupLists];
  
  self.coloringEngine = [TeXColoringEngine coloringEngineWithTextView:self];
//  self.highlightingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(colorVisibleText) userInfo:nil repeats:YES];
  
    
}


// Do the default setup for the text view.
- (void) defaultSetup
{
//  NSLog(@"TeX TextView default setup");
  self.lineHighlightColor = [[self backgroundColor] shadowWithLevel:0.1];
  
	[[self layoutManager] setAllowsNonContiguousLayout:YES];
//	[self setTextContainerInset:NSMakeSize(3, 3)];
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
  [self setTypingAttributes:[self currentTypingAttributes]];
  
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
  
 
  [nc addObserver:self
         selector:@selector(colorVisibleText)
             name:NSTextStorageDidProcessEditingNotification
           object:[self textStorage]];
}

- (NSDictionary*)currentTypingAttributes
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
  NSColor *color = [[defaults valueForKey:TESyntaxTextColor] colorValue];
  return [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
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
	
	self.commandList = [[NSMutableArray alloc] init];								
	[self.commandList addObjectsFromArray:[commmandDict valueForKey:@"Commands"]];
	
	// add all commands from the palette
  //	NSArray *pcommands = [[PaletteController sharedPaletteController] listOfCommands];	
  //	[commands addObjectsFromArray:pcommands];
	
	// remove \ from the front of commands
	NSString *c = [self.commandList componentsJoinedByString:@" "];
	[self.commandList removeAllObjects];
	[self.commandList addObjectsFromArray:[c componentsSeparatedByString:@" "]];
	
	// possible sections and completions for \begin
	self.beginList = [[NSMutableArray alloc] init];
	[self.beginList addObject:@"enumerate"];
	[self.beginList addObject:@"array"];
	[self.beginList addObject:@"matrix"];
	[self.beginList addObject:@"itemize"];
	[self.beginList addObject:@"eqnarray"];
	[self.beginList addObject:@"description"];
	[self.beginList addObject:@"quotation"];
	[self.beginList addObject:@"quote"];
	[self.beginList addObject:@"verbatim"];
	[self.beginList addObject:@"verse"];
	[self.beginList addObject:@"table"];
	[self.beginList addObject:@"tabular"];
	[self.beginList addObject:@"center"];
	[self.beginList addObject:@"figure"];
	[self.beginList addObject:@"table"];
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

-(void)	goToCharacter: (int)charNum
{
	[self goToRangeFrom: charNum toChar: charNum +1];
}


-(void) goToRangeFrom: (int)startCh toChar: (int)endCh
{
	NSRange		theRange = { 0, 0 };
	
	theRange.location = startCh -1;
	theRange.length = endCh -startCh;
	
	if( startCh == 0 || startCh > [[self string] length] )
		return;
	
	[self scrollRangeToVisible: theRange];
	[self setSelectedRange: theRange];
}

-(void)	goToLine: (int)targetLineNumber
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
      NSString *format = [NSString stringWithFormat:@"Line number %d not found in text"];
      [NSException raise:@"Line number not found" format:format, targetLineNumber];
    } else {
      // tell the user the line number is too high
      NSAlert *alert = [NSAlert alertWithMessageText:@"Document length exceeded." defaultButton:@"OK" 
                                     alternateButton:nil otherButton:nil informativeTextWithFormat:@"Requested line %d is greater than the number of lines in the document", targetLineNumber];
      [alert runModal];
    }
  }
}



#pragma mark -
#pragma mark Control

- (IBAction) toggleCommentForSelection:(id)sender
{
	NSRange				selRange = [self selectedRange];
	NSMutableString*	str = [[self textStorage] mutableString];
  
	// Get the range to edit
	NSRange r = [str paragraphRangeForRange:selRange];	
	// Get a mutable string for this range
	NSMutableString *newString = [NSMutableString string];
	[newString appendString:[str substringWithRange:r]];
	int inserted = 0;
	if ([newString characterAtIndex:0]=='%') {
		[newString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
		inserted--;
	} else {
		[newString insertString:@"%" atIndex:0];
		inserted++;
	}
	
	for (int ll=0; ll<[newString length]-1; ll++) {
		if ([newLineCharacterSet characterIsMember:[newString characterAtIndex:ll]]) {
			if ([newString characterAtIndex:ll+1] == '%') {
				[newString replaceCharactersInRange:NSMakeRange(ll+1, 1) withString:@""];
				inserted--;
			} else {
				[newString insertString:@"%" atIndex:ll+1];
				inserted++;
			}
		}
	}
	
	[self setSelectedRange:r];
	[self delete:self];
	[self insertText:newString];
	NSInteger len = selRange.length+inserted;
	
	if (inserted>0) {
		len--;
		if (len<0)
			len = 0;
		[self setSelectedRange:NSMakeRange(selRange.location+1,len)];
	} else {
		len++;
		if (len<0)
			len = 0;
		[self setSelectedRange:NSMakeRange(selRange.location-1,len)];
	}
	
  // color visible text
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
	
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



#pragma mark -
#pragma mark Syntax highlighting

- (void) resetLineNumbers
{
  [self.editorRuler resetLineNumbers];
  [self setNeedsDisplay:YES];
}

- (void) colorWholeDocument
{
//  NSLog(@"Coloring whole document %@", [self textStorage]);
  [self.coloringEngine colorText:[self textStorage]
                   layoutManager:[self layoutManager]
                         inRange:NSMakeRange(0, [[self string] length])];
  [self setNeedsDisplay:YES];
}

- (void) colorVisibleText
{
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
  loc = lr.location;
  lr = [[self string] lineRangeForRange:NSMakeRange(loc+length, 0)];
  NSRange r = NSMakeRange(loc, NSMaxRange(lr)-loc);
  
//  NSLog(@"Coloring range %ld-%ld", r.location, r.location+r.length);
  [self.coloringEngine colorText:[self textStorage]
                   layoutManager:[self layoutManager]
                         inRange:r];
  
}

#pragma mark -
#pragma mark Actions

- (void)didChangeText
{
//  NSLog(@"Did change text %@", [self string]);
  [self updateEditorRuler];  
  [self colorVisibleText];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:1.0];
}

- (void)viewWillDraw
{
//  [self colorVisibleText];
  [self.editorRuler setNeedsDisplay:YES];
	[super viewWillDraw];
}

- (void) drawViewBackgroundInRect:(NSRect)rect
{
	[super drawViewBackgroundInRect:rect];
	
  // additional highlight range
	if (self.highlightRange) {    
    NSRect aRect = [self highlightRectForRange:NSRangeFromString(self.highlightRange)];		
		[[[self backgroundColor] shadowWithLevel:0.2] set];
		[NSBezierPath fillRect:aRect];
	} else {
    [[self backgroundColor] set];
    [NSBezierPath fillRect:[self bounds]];
  }
  
  // highlight current line
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:TEHighlightCurrentLine] boolValue]) {
    NSRange sel = [self selectedRange];
    NSString *str = [self string];
    if (sel.location < [str length]) {
      NSRange lineRange = [str lineRangeForRange:NSMakeRange(sel.location,0)];
      NSRect lineRect = [self highlightRectForRange:lineRange];
      [self.lineHighlightColor set];
      [NSBezierPath fillRect:lineRect];
    }
  }
  
  
  // line width
  int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
  if (wrapStyle == TPHardWrap || wrapStyle == TPSoftWrap) {
    int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
    CGFloat scale = [NSString averageCharacterWidthForCurrentFont];
    NSRect vr = [self visibleRect];
    NSRect r = NSMakeRect(scale*wrapAt+1, vr.origin.y, vr.size.width, vr.size.height);
    [[[self backgroundColor] shadowWithLevel:0.05] set];
    [NSBezierPath fillRect:r];
  }
  
}


- (void) handleFrameChangeNotification:(NSNotification*)aNote
{
//  NSLog(@"Frame change");
//  [self updateEditorRuler];
//  [self colorVisibleText];
}

- (void) updateEditorRuler
{
//  NSLog(@"Update editor ruler...");
  [self.editorRuler resetLineNumbers];
  [self.editorRuler performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.1];
  [self setNeedsDisplay:YES];
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
  
	[super keyDown:theEvent];
}

- (void) mouseDown:(NSEvent *)theEvent
{
  [self clearHighlight];
	[self clearSpellingList];
	[super mouseDown:theEvent];
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
//  NSLog(@"Changed in %@", keyPath);
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TEDocumentBackgroundColor]]) {	
    NSColor *c = [[[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentBackgroundColor] colorValue];
    [self setBackgroundColor:c];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowCodeFolders]]) {
    [self performSelector:@selector(updateEditorRuler) withObject:nil afterDelay:0];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEShowLineNumbers]]) {
    [self performSelector:@selector(updateEditorRuler) withObject:nil afterDelay:0];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEHighlightCurrentLine]]) {
		[self setNeedsDisplayInRect:[self bounds] avoidAdditionalLayout:YES];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineWrapStyle]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TELineLength]]) {
    [self setWrapStyle];
	} else if ([keyPath isEqual:[NSString stringWithFormat:@"values.%@", TEDocumentFont]]) {
    [self applyFontAndColor];
	}
}

- (void) applyFontAndColor
{
  NSDictionary *atts = [self currentTypingAttributes];
  NSFont *newFont = [atts valueForKey:NSFontAttributeName];
  NSColor *newColor = [atts valueForKey:NSForegroundColorAttributeName];
  if (![newFont isEqualTo:[self font]]) {
    [self setFont:[atts valueForKey:NSFontAttributeName]];
  }
  if (![newColor isEqualTo:[self textColor]]) {
    [self setTextColor:[atts valueForKey:NSForegroundColorAttributeName]];
  }
  [self setTypingAttributes:atts];
}

- (void) setWrapStyle
{
  int wrapStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineWrapStyle] intValue];
  int wrapAt = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
  NSTextContainer *textContainer = [self textContainer];
  if (wrapStyle == TPSoftWrap) {
    CGFloat scale = [NSString averageCharacterWidthForCurrentFont];
    [textContainer setContainerSize:NSMakeSize(scale*wrapAt, LargeTextHeight)];
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

- (IBAction)complete:(id)sender
{
	NSString *string = [self string];
	NSRange curr = [self selectedRange];
	[self selectUpToCurrentLocation];
	NSRange selectedRange = [self selectedRange];
  //	NSRange wr = 	[self rangeForCurrentWord];
	[self setSelectedRange:curr];
	
  
	NSString *word = [string substringWithRange:selectedRange];
	
	
//  NSLog(@"Completing... %@", word);
	
	// If we are completing one of the special cases (ref, cite, include, input, ...)
	// then we use a custom popup list to present the options
	
	id delegate = [self delegate];
  //	NSLog(@"Delegate: %@", delegate);
	if ([word isEqual:@"\\include{"] || [word isEqual:@"\\input{"]) {
		if ([delegate respondsToSelector:@selector(listOfTeXFilesPrependedWith:)]) {
			NSArray *list = [delegate performSelector:@selector(listOfTeXFilesPrependedWith:) withObject:@""];
			[self insertFromList:list];			
		}
	} else if ([word beginsWith:@"\\ref{"]) {
		if ([delegate respondsToSelector:@selector(listOfReferences)]) {
			NSArray *list = [delegate performSelector:@selector(listOfReferences)];
      //			NSLog(@"List: %@", list);
			[self insertFromList:list];			
		}
	} else if ([word beginsWith:@"\\cite{"]) {
    //		NSLog(@"Checking for selector listOfCitations...");
		if ([delegate respondsToSelector:@selector(listOfCitations)]) {
			NSArray *list = [delegate performSelector:@selector(listOfCitations)];
			[self insertFromList:list];			
		}
	} else if ([word isEqual:@"\\begin{"]) {
		NSArray *list = self.beginList;
		[self insertFromList:list];			
	} else if ([word hasPrefix:@"\\"]) {
    NSArray *list = [NSMutableArray arrayWithArray:self.commandList];
    
    // get list of user defaults commands
    list = [list arrayByAddingObjectsFromArray:[self userDefaultCommands]];
    
    if ([delegate respondsToSelector:@selector(listOfCommands)]) {
      list = [list arrayByAddingObjectsFromArray:[delegate listOfCommands]];
    }
    if ([word length]>1) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", word];
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
      // otherwise we just call super
      //			[super complete:sender];
    }
	} else {
		// otherwise we just call super
//    NSLog(@"Spell checking");
		NSArray *list = [[NSSpellChecker sharedSpellChecker] completionsForPartialWordRange:NSMakeRange(0, [word length]) 
																																							 inString:word
																																							 language:nil
																																 inSpellDocumentWithTag:0];
		[self completeFromList:list];
    //		[super complete:sender];
		
    
		
	}
}

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

- (void) completeFromList:(NSArray*)aList
{
//  NSLog(@"Completing from list %@", aList);
	if ([aList count]==0) 
		return;
	
	NSPoint point = [self listPointForCurrentWord];
	//			NSLog(@"Point for word:%@", NSStringFromPoint(point));
	NSPoint wp = [self convertPoint:point toView:nil];
	[self clearSpellingList];
	popupList = [[TPPopupListWindowController alloc] initWithEntries:aList
																													 atPoint:wp
																										inParentWindow:[self window]
																															mode:TPPopupListReplace
																														 title:@"Replace..."];
	[popupList setDelegate:self];
	[popupList showPopup];	
}

- (void) insertFromList:(NSArray*)aList
{
	if ([aList count]==0) 
		return;
	
	NSPoint point = [self listPointForCurrentWord];
	//			NSLog(@"Point for word:%@", NSStringFromPoint(point));
	NSPoint wp = [self convertPoint:point toView:nil];
	[self clearSpellingList];
	popupList = [[TPPopupListWindowController alloc] initWithEntries:aList
																													 atPoint:wp
																										inParentWindow:[self window]
																															mode:TPPopupListInsert
																														 title:@"Insert..."];
	[popupList setDelegate:self];
	[popupList showPopup];	
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
			popupList = [[TPPopupListWindowController alloc] initWithEntries:guesses
																															 atPoint:wp
																												inParentWindow:[self window]
																																	mode:TPPopupListSpell
																																 title:@"Correct..."];
			[popupList setDelegate:self];
			[popupList showPopup];
		}
	}
}

- (void) clearSpellingList
{
//  NSLog(@"Clearing old spelling list %@", popupList);
	if (popupList) {
    [popupList dismiss];
		[popupList release];
		popupList = nil;
    //		NSLog(@"... done");
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
}

- (void) replaceWordUpToCurrentLocationWith:(NSString*)aWord
{
	NSString *replacement = [NSString stringWithString:aWord];
  //	NSLog(@"Replacing current word with %@", replacement);
	[self selectUpToCurrentLocation];
	NSRange sel = [self selectedRange];
	[self shouldChangeTextInRange:sel replacementString:replacement];
	[self replaceCharactersInRange:sel withString:replacement];
	[self clearSpellingList];
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
		
		if (att) {			
			NSData *data = [[att fileWrapper] regularFileContents];
			NSString *code = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			// delete the line up to and including the attachment
			[[self textStorage] replaceCharactersInRange:NSMakeRange(lineRange.location, idx+2) 
																				withString:[code stringByAppendingString:@"\n"]];
			[code release];
			
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
	NSAttributedString *text = [[self textStorage] attributedSubstringFromRange:aRange];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:text];
  
	[string unfoldAllInRange:aRange max:max];
	
	[[self textStorage] beginEditing];
	[[self textStorage] deleteCharactersInRange:aRange];
	[[self textStorage] insertAttributedString:string atIndex:aRange.location];
	[[self textStorage] endEditing];
	[string release];
  
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
}

- (void) unfoldTextWithFolder:(MHCodeFolder*)aFolder
{	
	NSRange lineRange = [[self string] lineRangeForRange:NSMakeRange(aFolder.startIndex, 0)];
	[self unfoldAllInRange:lineRange max:10000];
}

- (void) foldTextWithFolder:(MHCodeFolder*)aFolder
{	
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
	
	[aaa release];
	[snippet release];
  
  // update editor ruler
	[self.editorRuler resetLineNumbers];
  [self.editorRuler setNeedsDisplay:YES];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
}


- (void) unfoldAttachment:(NSTextAttachment*)snippet atIndex:(NSNumber*)index
{	
	// find the location of this attachment in the text	
	NSData *data = [[snippet fileWrapper] regularFileContents];
	NSAttributedString *code = [[NSAttributedString alloc] initWithRTFD:data documentAttributes:nil];
	NSRange attRange = NSMakeRange([index unsignedLongValue], 1);
	[[self textStorage] removeAttribute:NSAttachmentAttributeName range:attRange];
	[[self textStorage] replaceCharactersInRange:attRange withAttributedString:code];
	[code release];
  
  // update editor ruler
	[self.editorRuler resetLineNumbers];
  [self.editorRuler setNeedsDisplay:YES];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.2];
}

#pragma mark -
#pragma mark Selection


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
	
	// go back until we find an empty line
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
		if ([newLineCharacterSet characterIsMember:[str characterAtIndex:start]]) {
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
	
	
	// go forward until we find an empty line
	NSInteger end = start;
	while(end < [str length]) {
		
		if ([newLineCharacterSet characterIsMember:[str characterAtIndex:end]]) {
			
			// we are at the end of a line; was it an empty line?
			NSRange lr = [str lineRangeForRange:NSMakeRange(end, 0)];
			NSString *lstr = [str substringWithRange:lr];
			lstr = [lstr stringByTrimmingCharactersInSet:whitespaceCharacterSet];
			lstr = [lstr stringByTrimmingCharactersInSet:newLineCharacterSet];
			if ([lstr length]==0) {
				end--;
				break;
			}
		}		
		end++;
	}
	
	if (end >= [str length]) 
		end = [str length];
	
	if (end < start)
		end = start;
	
	return NSMakeRange(start, end-start);
	
}

- (NSInteger) locationOfLastWhitespaceLessThan:(int)lineWrapLength
{
	NSString *str = [[self textStorage] string];
	NSRange selRange = [self selectedRange];
	NSInteger loc = selRange.location;
	
	while (loc >= 0) {
		if ([self lengthOfLineUpToLocation:loc]<lineWrapLength &&
				[whitespaceCharacterSet characterIsMember:[str characterAtIndex:loc-1]]) {
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

- (NSString*) currentLineToCursor
{
	NSRange selRange = [self selectedRange];
	NSString*	str = [[self textStorage] string];
  //	NSLog(@"Checking string %@", str);
	NSInteger loc = selRange.location;
  
  //	NSLog(@"Staring scan at %d", loc-1);
	while (loc > 0) {
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
	while (loc>=0) {
		unichar c = [string characterAtIndex:loc];
    //		NSLog(@"  checking '%c'", c);
		if ([whitespaceCharacterSet characterIsMember:c] || [newLineCharacterSet characterIsMember:c]) {
			start = loc+1;
			break;
		}
		
		// other possible word breaks include '~' '\,'
		if (c == '~') {
			start = loc+1;
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

// Returns a rectangle suitable for highlighting a background rectangle for the given text range.
- (NSRect) highlightRectForRange:(NSRange)aRange
{
  NSRange r = aRange;
  NSRange startLineRange = [[self string] lineRangeForRange:NSMakeRange(r.location, 0)];
  NSInteger er = NSMaxRange(r)-1;
  if (er >= [[self string] length]) {
    return NSZeroRect;
  }
  NSRange endLineRange = [[self string] lineRangeForRange:NSMakeRange(er, 0)];
  
  NSRange gr = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(startLineRange.location, NSMaxRange(endLineRange)-startLineRange.location)
                                            actualCharacterRange:NULL];
  NSRect br = [[self layoutManager] boundingRectForGlyphRange:gr inTextContainer:[self textContainer]];
  
  NSRect b = [self bounds];
  CGFloat h = br.size.height;
  CGFloat w = b.size.width;
  CGFloat y = br.origin.y;
  
  NSPoint containerOrigin = [self textContainerOrigin];
  
  NSRect aRect = NSMakeRect(0, y, w, h);
  // Convert from view coordinates to container coordinates
  aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
  return aRect;
}


- (void) handleSelectionChanged:(NSNotification*)aNote
{
  
  [self setNeedsDisplay:YES];
  [self updateEditorRuler];
  NSRange r = [self selectedRange];
  [[NSNotificationCenter defaultCenter] postNotificationName:TECursorPositionDidChangeNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:r.location] forKey:@"index"]];
  
  [self colorVisibleText];
  [self setTypingAttributes:[self currentTypingAttributes]];

  
}

- (void) clearHighlight
{
  self.highlightRange = nil;
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Text processing

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

- (void)insertText:(id)aString
{	
//  NSLog(@"Insert %@", aString);
  
  // check if the next character or preceeding character was a text attachment
	NSRange selRange = [self selectedRange];
	NSRange effRange;
	NSAttributedString *string = [self attributedString];
	if ([string length] == 0) {
		[super insertText:aString];
		return;
	}
                             
//  // get the attributes of the preceeding character
//  if (selRange.location > 0 && selRange.location+2<[string length]) {    
//    NSDictionary *dict = [[self layoutManager] temporaryAttributesAtCharacterIndex:selRange.location-1 effectiveRange:&effRange];
//    [[self layoutManager] addTemporaryAttributes:dict forCharacterRange:NSMakeRange(selRange.location, 2)];
//  }
//	
	if (selRange.location < [string length]) {
		NSTextAttachment *att = [string attribute:NSAttachmentAttributeName
																			atIndex:selRange.location
															 effectiveRange:&effRange];
		if (att) {
			NSRange lineRange = [[self string] lineRangeForRange:selRange];
			[self unfoldAllInRange:lineRange max:10000];
			return;
		}
		if (selRange.location>0) {
			NSTextAttachment *att = [string attribute:NSAttachmentAttributeName
																				atIndex:selRange.location-1
																 effectiveRange:&effRange];
			if (att) {
				NSRange lineRange = [[self string] lineRangeForRange:selRange];
				[self unfoldAllInRange:lineRange max:10000];
				return;
			}
		}
	}
  
	
	if ([aString isEqual:@"{"]) {
    // get selected text
    if (selRange.length > 0) {
      NSString *selected = [[string string] substringWithRange:selRange];
      [super replaceCharactersInRange:selRange withString:[NSString stringWithFormat:@"{%@}", selected]];
    } else {
      [super insertText:@"{}"];
      [self moveLeft:self];
    }
	} else 	if ([aString isEqual:@"["]) {
		NSRange r = [self selectedRange];
		r.location-=2;
		r.length+=2;
		[super insertText:@"[]"];
		[self moveLeft:self];
	} else 	if ([aString isEqual:@"("]) {
		NSRange r = [self selectedRange];
		r.location-=2;
		r.length+=2;
		[super insertText:@"()"];
		[self moveLeft:self];
	} else	if ([aString isEqual:@"}"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
		if ([[self string] characterAtIndex:r.location] == '}') {
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
		if ([[self string] characterAtIndex:r.location] == ')') {
			// move right
			[self moveRight:self];
			return;
		}	else {
			[super insertText:aString];
			return;
		}	
	} else	if ([aString isEqual:@"\""]) {
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
	} else	if ([aString isEqual:@"]"]) {
		// will this be an extra closing bracket?
		NSRange r = [self selectedRange];
		if ([[self string] characterAtIndex:r.location] == ']') {
			// move right
			[self moveRight:self];
			return;
		}	else {
			[super insertText:aString];
			return;
		}	
	} else {
		[super insertText:aString];
	}
		
	[self wrapLine];
}

- (void) insertNewline:(id)sender
{	
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
	NSRange lineRange = NSMakeRange(lineStart, lineEnd-lineStart); 
	NSString *previousLine = [[str substringWithRange:lineRange] 
														stringByTrimmingCharactersInSet:whitespaceCharacterSet];
	previousLine = [previousLine stringByTrimmingCharactersInSet:newLineCharacterSet];
	
	// Now let's do some special actions....
	
	//---- If the previous line was a \begin, we append the \end
	if ([previousLine hasPrefix:@"\\begin{"]) {			
		
		// don't complete if the shift key is on, just add the tab
		if (self.shiftKeyOn) {
			[super insertNewline:sender];
			[self insertTab:sender];
      [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
			return;
		}		
		
		// if the current cursor location is not at the end of the \begin{} statement, we do nothing special			
		if (selRange.location == lineRange.location+lineRange.length) {
			int start = 0;
			int end   = 0;
			for (int kk=0; kk<[previousLine length]; kk++) {
				if ([previousLine characterAtIndex:kk]=='{') {
					start = kk+1;
					kk++;
				}
				if ([previousLine characterAtIndex:kk]=='}') {
					end = kk-1;
					break;
				}
			}
			
			NSString *insert = nil;
			if (start < end) {
				NSString *tag = [previousLine substringWithRange:NSMakeRange(start, end-start+1)];
				insert = [NSString stringWithFormat:@"\n\\end{%@}", tag];
			}
			
			if (insert) {
				// now put in the requested newline
				[super insertNewline:sender];
				
				// add the new \end
				[self insertTab:self];
				
				// record this location
				selRange = [self selectedRange];
				
				// add the new \end
				[self insertText:insert];
				
				// wind back the location of the cursor					
				[self setSelectedRange:selRange];
				
        [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
				return;
			} // end if insert
		} // if we are at the end of the \begin statement			
	} // end if \begin
	
	
	[super insertNewline:sender];
	
	// update line numbers
	[self updateEditorRuler];
	
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
	while (loc >= 0) {			
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
	while (loc < [str length]) {			
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
  
	int lineWrapLength = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
	// check the length of this line and insert newline if required
	// - we only do this if we are at the end of a line	
	NSString *str = [[self textStorage] string];
	NSRange selRange = [self selectedRange];
  //	NSRect selRect = [self visibleRect];
	
  //	NSLog(@"Checking character '%c'", [str characterAtIndex:selRange.location]);
	
	// is the next character a newline character, or are we at the end of the string?
  //	NSLog(@"Checking location %d against length %d", selRange.location, [str length]);
	NSUInteger strLen = [str length];
	if (selRange.location == strLen || 
			(selRange.location<strLen && 
			 [newLineCharacterSet characterIsMember:[str characterAtIndex:selRange.location]]
			 )
			) 
	{
		
		// then we are at the end of a line and we can do wrapping
		NSString*	lstr = [self currentLineToCursor];
    //		NSLog(@"Line: %@", lstr);
		if ([lstr length] > lineWrapLength) {
			
			// Do a proper search for the last whitespace because
			// we could be at the end of a command, for example.
			// Also we should move back to find the start of the word that is before the
			// line wrap length
			
			// get location of the last whitespace
			NSInteger lastWhitespace = [self locationOfLastWhitespaceLessThan:lineWrapLength];
      //			NSLog(@"Last ws: %d", lastWhitespace);
			if (lastWhitespace>=0) {
        //				NSLog(@"Inserting new line");
				[self setSelectedRange:NSMakeRange(lastWhitespace, 1)];
        //				[self insertText:lineBreakStr];
				[self insertNewline:self];
        //				[super insertLineBreak:self];
        //				selRange.location++;
				[self setSelectedRange:selRange];
        //				[self scrollRectToVisible:selRect];
			} else {
				
        //				NSLog(@"Last whitespace is not >0; %d", lastWhitespace);
			}
		} else {
      //			NSLog(@"Line length: %d", [lstr length]);
      //						NSLog(@"String not longer than lineWrap length");
		}
	} else {
    //				NSLog(@"Next character '%c' is not a newline", [str characterAtIndex:selRange.location]);
	}
	
	
	
}


- (NSInteger)cursorPosition
{
  NSRange sel = [self selectedRange];
  return sel.location;
}

- (NSInteger)lineNumber
{
//  NSLog(@"Getting line number for %@, from %@", self, self.editorRuler);
  NSRange sel = [self selectedRange];
  NSArray *lines = [self.editorRuler lineNumbersForTextRange:[self getVisibleRange]];
//  NSLog(@"Got lines %@", lines);
  for (MHLineNumber *line in lines) {
//    NSLog(@"Looking for %ld in %ld:%ld", sel.location, line.range.location, NSMaxRange(line.range)); 
    if (sel.location >= line.range.location && sel.location < NSMaxRange(line.range)) {
      return [[line valueForKey:@"number"] integerValue];
    }
    if (line.range.length == 0 && sel.location == line.range.location) {
      return [[line valueForKey:@"number"] integerValue];
    }
  }
//  if ([lines count]==1) {
//  }
  return NSNotFound;
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
	[self setSelectedRange:NSMakeRange(selRange.location+slen, selRange.length)];
}

- (IBAction) reformatParagraph:(id)sender
{
  //	NSLog(@"Reformat paragraph");
	
	NSRange pRange = [self rangeForCurrentParagraph];
	
  [self reformatRange:pRange];
	return;
}

- (IBAction) reformatRange:(NSRange)pRange
{
  //	NSLog(@"Reformat paragraph");
	
	int lineWrapLength = [[[NSUserDefaults standardUserDefaults] valueForKey:TELineLength] intValue];
	NSRange currRange = [self selectedRange];
//	NSRange pRange = [self rangeForCurrentParagraph];
	
	[self setSelectedRange:pRange];	
	NSString *oldStr = [[self string] substringWithRange:pRange];
	NSString *newString = [oldStr stringByReplacingOccurrencesOfRegex:@"[\n\r]+" withString:@" "];
  //	NSString *newString = [NSString stringWithControlsFilteredForString:oldStr];
	
	// Now go through and put in \n when we are past the linelength
  //	NSString *lineBreakStr = [NSString stringWithFormat:@" %C", NSLineSeparatorCharacter];
	NSString *lineBreakStr = [NSString stringWithFormat:@"\n", NSLineSeparatorCharacter];
	int loc = 0;
	int insert = lineWrapLength;
	NSCharacterSet *wsCharSet = whitespaceCharacterSet;
	while (loc < [newString length]) {
		if (loc > insert) {
			if ([wsCharSet characterIsMember:[newString characterAtIndex:loc]]) {
				newString = [newString stringByReplacingCharactersInRange:NSMakeRange(loc, 1)
																											 withString:lineBreakStr];
				insert += lineWrapLength;				
        //				currRange.location--;
			}
		}
		loc++;
	}
  
	newString = [newString stringByTrimmingCharactersInSet:whitespaceCharacterSet];
	[self breakUndoCoalescing];
	[self setSelectedRange:pRange];
  [self shouldChangeTextInRange:pRange replacementString:newString];
  [[self textStorage] beginEditing];
  [[self textStorage] replaceCharactersInRange:pRange withString:newString];
  [[self textStorage] endEditing];
	[self setSelectedRange:currRange];
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
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
  NSInteger diff = selRange.location-removed;
  if (diff>=0) {
    [self setSelectedRange:NSMakeRange(diff, selRange.length)];
  }
}

#pragma mark -
#pragma mark Drag and Drop

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard* pboard = [sender draggingPasteboard];
  
  NSLog(@"pboard types: %@", [pboard types]);
  
  NSLog(@"%@", sender);
  
  NSPoint draggingLocation = [sender draggingLocation];
  draggingLocation = [self convertPoint:draggingLocation fromView:nil];
  NSUInteger characterIndex = [self characterIndexOfPoint:draggingLocation];
  
//	NSDragOperation sourceDragMask= [sender draggingSourceOperationMask];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] )
	{
		NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
    for (NSString *file in files) {
      
      CFStringRef fileExtension = (CFStringRef) [file pathExtension];
      CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
      
      if (UTTypeConformsTo(fileUTI, kUTTypeImage) || UTTypeConformsTo(fileUTI, kUTTypePDF)) {
        [self insertImageBlockForFile:file atLocation:characterIndex];        
        CFRelease(fileUTI);
        return YES;
      }
      
      if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
        [self insertIncludeForFile:file atLocation:characterIndex];        
        CFRelease(fileUTI);
        return YES;
      }
      
      CFRelease(fileUTI);
      
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
  [self performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
}

- (void) insertIncludeForFile:(NSString*)aFile atLocation:(NSUInteger)location
{
  id project = [[self delegate] performSelector:@selector(project)];
  NSString *projectFolder = [project valueForKey:@"folder"];
  NSString *file = [[aFile relativePathTo:projectFolder] stringByAppendingPathComponent:[aFile lastPathComponent]];

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

@end
