//
//  TeXTextView.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UKTextDocGoToBox.h"
#import "MHTableConfigureController.h"

extern NSString * const TELineNumberClickedNotification;

@class MHEditorRuler;
@class MHCodeFolder;
@class TeXColoringEngine;
@class TPPopupListWindowController;
@class FileEntity;
@class TeXTextView;

@protocol TeXTextViewDelegate <NSTextViewDelegate, MHTableConfigureDelegate>

@optional
-(id)project;
-(NSArray*)listOfCitations;
-(NSArray*)listOfReferences;
-(NSArray*)listOfTeXFilesPrependedWith:(NSString*)prefix;
-(NSArray*)listOfCommands;
-(BOOL)shouldSyntaxHighlightDocument;
-(NSArray*)bookmarksForCurrentFileInLineRange:(NSRange)aRange;
-(NSString*)fileExtension;
-(NSArray*)commandsBeginningWithPrefix:(NSString*)prefix;
-(NSString*)codeForCommand:(NSString*)command;
-(void)textView:(TeXTextView*)aTextView didCommandClickAtLine:(NSInteger)lineNumber column:(NSInteger)column;
@end

@interface TeXTextView : NSTextView <TeXTextViewDelegate, UKTextDocGoToBoxTarget> {
@private
  
	TPPopupListWindowController *popupList;
  
  MHEditorRuler *editorRuler;
  TeXColoringEngine *coloringEngine;
  NSString *highlightRange;
  NSColor *lineHighlightColor;
  
	// Character sets
	NSCharacterSet *newLineCharacterSet;
	NSCharacterSet *whitespaceCharacterSet;
  
  NSMutableArray *syntaxHighlightTags;
  
  NSTimer *highlightingTimer;
  
  BOOL shiftKeyOn;
  
	// Go to line
	IBOutlet UKTextDocGoToBox *goToLineController;
    
  NSMutableArray *commandList;
  
  NSRange _lastLineRange;
  NSInteger _lastLineNumber;
  
  NSMutableArray *wordHighlightRanges;
  
  MHTableConfigureController *tableConfigureController;
  
  NSInteger zoomFactor;
}

@property (assign) NSInteger zoomFactor;
@property (retain) NSTimer *highlightingTimer;
@property (retain) MHEditorRuler *editorRuler;
@property (retain) TeXColoringEngine *coloringEngine;
@property (retain) NSColor *lineHighlightColor;
@property (copy) NSString *highlightRange;
@property (retain) NSMutableArray *syntaxHighlightTags;
@property (assign) BOOL shiftKeyOn;
@property (retain) NSMutableArray *commandList;
@property (retain) NSMutableArray *wordHighlightRanges;
@property (retain) MHTableConfigureController *tableConfigureController;

- (void) setupLists;
- (void) setUpRuler;
- (void) defaultSetup;
- (void) turnOffWrapping;
- (void) updateEditorRuler;
- (void) setTypingColor:(NSColor*)aColor;
- (void) applyFontAndColor;
- (void) setWrapStyle;
- (void) handleFrameChangeNotification:(NSNotification*)aNote;

- (NSString*)fileExtension;
- (NSString*)commentChar;

#pragma mark -
#pragma mark GoTo Box protocol methods 

- (IBAction) gotoLine:(id)sender;
-(void)	goToCharacter: (int)charNum;
-(void)	goToLine: (int)targetLineNumber;
-(void)	goToLineWithNumber: (NSNumber*)targetLineNumber;
-(void) goToRangeFrom: (int)startCh toChar: (int)endCh;

#pragma mark -
#pragma mark Control

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (IBAction) toggleControlCharacters:(id)sender;
- (IBAction) toggleInvisibleCharacters:(id)sender;
- (IBAction) toggleCommentForSelection:(id)sender;
- (IBAction)commentSelection:(id)sender;
- (IBAction)uncommentSelection:(id)sender;

- (IBAction) showSpellingList:(id)sender;
- (IBAction)complete:(id)sender;

#pragma mark -
#pragma mark Text Storage Observing

- (void) processEditing:(NSNotification*)aNote;
- (void) stopObservingTextStorage;
- (void) observeTextStorage;


#pragma mark -
#pragma mark Syntax highlighting

- (NSArray*)bookmarksForLineRange:(NSRange)aRange;
- (void) resetLineNumbers;
- (void) colorWholeDocument;
- (void) colorVisibleText;
- (void) highlightMatchingWords;

#pragma mark -
#pragma mark KVO 
- (void) stopObserving;
- (void) observePreferences;

#pragma mark -
#pragma mark Folding

- (IBAction) unfoldSelection:(id)sender;
- (IBAction) collapseAll:(id)sender;
- (IBAction) expandAll:(id)sender;
- (void) unfoldAllInRange:(NSRange)aRange max:(NSInteger)max;
- (void) unfoldTextWithFolder:(MHCodeFolder*)aFolder;
- (void) foldTextWithFolder:(MHCodeFolder*)aFolder;
- (void) unfoldAttachment:(NSTextAttachment*)snippet atIndex:(NSNumber*)index;

#pragma mark -
#pragma mark Completion and spelling

- (void) completeFromList:(NSArray*)aList;
- (void) insertFromList:(NSArray*)aList;
- (IBAction) showSpellingList:(id)sender;
- (void) insertWordAtCurrentLocation:(NSString*)aWord;
- (void) replaceWordUpToCurrentLocationWith:(NSString*)aWord;
- (void) replaceWordAtCurrentLocationWith:(NSString*)aWord;
- (void) clearSpellingList;
- (NSArray*)userDefaultCommands;

- (void) didSelectPopupListItem;
- (void) didDismissPopupList;


#pragma mark -
#pragma mark Selection

- (void) jumpToLine:(NSInteger)aLinenumber inFile:(FileEntity*)aFile select:(BOOL)selectLine;
- (void) selectRange:(NSRange)aRange scrollToVisible:(BOOL)scroll animate:(BOOL)animate;
- (void) replaceRange:(NSRange)aRange withText:(NSString*)replacement scrollToVisible:(BOOL)scroll animate:(BOOL)animate;

- (NSInteger) lengthOfLineUpToLocation:(NSUInteger)location;
- (NSRange) rangeForCurrentParagraph;
- (NSInteger) locationOfLastWhitespaceLessThan:(NSInteger)lineWrapLength;
- (NSString*) currentLineToCursor;
- (NSRange) getVisibleRange;
- (void) selectUpToCurrentLocation;
- (void) handleSelectionChanged:(NSNotification*)aNote;
- (NSRect) highlightRectForRange:(NSRange)aRange;
- (void) clearHighlight;
- (NSRange) rangeForCurrentParagraph;
- (NSRange) rangeForCurrentWord;
- (NSString*) currentWord;
- (NSPoint) listPointForCurrentWord;
- (NSRange) rangeForCurrentCommand;
- (NSString*) currentCommand;
- (BOOL) expandCurrentCommand;
- (void) replacePlaceholdersInString:(NSString*)code range:(NSRange)commandRange;
- (IBAction)jumpToPreviousPlaceholder:(id)sender;
- (IBAction)jumpToNextPlaceholder:(id)sender;

- (void) checkForMatchingBracketAfterMovingLeft;
- (void) checkForMatchingBracketAfterMovingRight;
- (void) checkForMatchingBracket:(unichar)aChar offsetFrom:(NSInteger)index by:(NSInteger)offset;
- (NSInteger)searchBackwardsForChar:(unichar)openBracket matching:(unichar)closeBracket startingAt:(NSInteger)loc;
- (NSInteger)searchForwardsForChar:(unichar)closeBracket matching:(unichar)openBracket startingAt:(NSInteger)loc;
- (NSInteger)findMatchingBracketOfType:(unichar)aChar atIndex:(NSInteger)index;
- (void) wrapLine;

- (NSInteger)cursorPosition;
- (NSInteger)lineNumber;
- (NSInteger)column;
- (NSInteger)columnForRange:(NSRange)aRange;
- (NSInteger)lineNumberForRange:(NSRange)aRange;
- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint;

#pragma mark -
#pragma mark Formatting text

- (NSRange)indentRangeForLineAtIndex:(NSInteger)loc;
- (void) insertStringBeforeAllLinesInSelection:(NSString*)aStr;
- (IBAction) reformatParagraph:(id)sender;
- (IBAction) reformatRange:(NSRange)pRange;
- (IBAction) indentSelection:(id)sender;
- (IBAction) unindentSelection:(id)sender;

- (void) insertIncludeForFile:(NSString*)aFile atLocation:(NSUInteger)location;
- (void) insertImageBlockForFile:(NSString*)aFile atLocation:(NSUInteger)location;
- (IBAction) pasteTable:(id)sender;
- (void)insertTableWithRows:(NSUInteger)nrows columns:(NSUInteger)ncols;
- (IBAction)pasteAsImage:(id)sender;
- (IBAction)insertInlineMath:(id)sender;

@end
