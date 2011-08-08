//
//  MHEditorRuler.h
//  TeXEditor
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeXTextView;
@class MHCodeFolder;
@class MHLineNumber;

@interface MHEditorRuler : NSRulerView {
@private
  TeXTextView *textView;
  NSArray *lineNumbers;
  NSArray *codeFolders;
  NSColor *textColor;
  NSColor *alternateTextColor;
  NSColor *backgroundColor;
  NSFont  *font;
  NSMutableArray *foldingTagDescriptions;
  BOOL wasAcceptingMouseEvents;
  NSRange lastVisibleRange;
  NSDictionary *textAttributesDictionary;
  NSDictionary *alternateTextAttributesDictionary;
	NSCharacterSet *newLineCharacterSet;
  NSGradient *_bookmarkGradient;
}

@property (retain) NSArray *lineNumbers;
@property (retain) NSArray *codeFolders;
@property (retain) NSMutableArray *foldingTagDescriptions;
@property (assign) TeXTextView *textView;
@property (retain) NSColor *textColor;
@property (retain) NSColor *alternateTextColor;
@property (retain) NSColor *backgroundColor;
@property (retain) NSFont *font;
@property (retain) NSDictionary *textAttributesDictionary;
@property (retain) NSDictionary *alternateTextAttributesDictionary;

+ (MHEditorRuler*) editorRulerWithTextView:(NSTextView*)aTextView;
- (id)initWithTextView:(NSTextView*)aTextView;

- (NSBezierPath*) makeBookmarkPathForWidth:(CGFloat)bwidth height:(CGFloat)rectHeight ypos:(CGFloat)ypos;

- (void) calculationsForTextRange:(NSRange)aRange;
- (NSArray*) lineNumbersForTextRange:(NSRange)aRange;
- (MHLineNumber*)lineNumberForPoint:(NSPoint)aPoint;
- (NSArray*) foldingTagsForTextRange:(NSRange)aRange;
- (NSDictionary*) matchTagPairs:(NSArray*)foldingTags;
- (NSArray*) makeFoldersForTextRange:(NSRange)aRange;
- (MHLineNumber*)lineNumberContainingIndex:(NSInteger)anIndex;

- (void) collapseAll;
- (MHCodeFolder*) firstUnfoldedSection;
- (void) toggleFoldedStateForFolder:(MHCodeFolder*)aFolder;
- (void) removeAllTrackingRects;
- (void) resetTrackingRects;
- (void) resetLineNumbers;
- (void) setNeedsDisplay;

#pragma mark -
#pragma mark Attributes

- (NSDictionary *) textAttributes;
- (NSDictionary *) alternateTextAttributes;
@end
