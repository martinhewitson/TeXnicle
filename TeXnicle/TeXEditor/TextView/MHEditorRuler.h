//
//  MHEditorRuler.h
//  TeXEditor
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
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
  NSColor *backgroundColor;
  NSFont  *font;
  NSMutableArray *foldingTagDescriptions;
  BOOL wasAcceptingMouseEvents;
  NSRange lastVisibleRange;
  NSDictionary *textAttributesDictionary;
	NSCharacterSet *newLineCharacterSet;
}

@property (retain) NSArray *lineNumbers;
@property (retain) NSArray *codeFolders;
@property (retain) NSMutableArray *foldingTagDescriptions;
@property (assign) TeXTextView *textView;
@property (retain) NSColor *textColor;
@property (retain) NSColor *backgroundColor;
@property (retain) NSFont *font;
@property (retain) NSDictionary *textAttributesDictionary;

+ (MHEditorRuler*) editorRulerWithTextView:(NSTextView*)aTextView;
- (id)initWithTextView:(NSTextView*)aTextView;

- (void) calculationsForTextRange:(NSRange)aRange;
- (NSArray*) lineNumbersForTextRange:(NSRange)aRange;
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

@end
