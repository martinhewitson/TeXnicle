//
//  MHEditorRuler.h
//  TeXnicle
//
//  Created by Martin Hewitson on 03/04/11.
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

#import <Foundation/Foundation.h>

@class TeXTextView;
@class MHCodeFolder;
@class MHLineNumber;

@interface MHEditorRuler : NSRulerView {
@private
  BOOL wasAcceptingMouseEvents;
  NSRange lastVisibleRange;
	NSCharacterSet *newLineCharacterSet;
  NSGradient *_bookmarkGradient;
  NSInteger _lastMaxVisibleLine;
  BOOL _recalculateLines;
  BOOL _forceThicknessRecalculation;
  
  CGFloat _lineGutterWidth;
  CGFloat _folderGutterWidth;
  CGFloat _newThickness;
  
  
  MHCodeFolder *highlightedFolder;
}


+ (MHEditorRuler*) editorRulerWithTextView:(NSTextView*)aTextView;
- (id)initWithTextView:(NSTextView*)aTextView;

- (NSBezierPath*) makeBookmarkPathForWidth:(CGFloat)bwidth height:(CGFloat)rectHeight ypos:(CGFloat)ypos;

- (void) calculationsForTextRange:(NSRange)aRange;
- (NSArray*) lineNumbersForTextRange:(NSRange)aRange;
- (MHLineNumber*)lineNumberForPoint:(NSPoint)aPoint;
- (NSArray*) foldingTagsForTextRange:(NSRange)aRange;
- (NSDictionary*) matchTagPairs:(NSArray*)foldingTags;
- (NSArray*) makeFoldersForTextRange:(NSRange)aRange;
- (NSRange) rangeForLinenumber:(NSInteger)aLinenumber;
- (MHLineNumber*)lineNumberContainingIndex:(NSInteger)anIndex;

- (void) collapseAll;
- (MHCodeFolder*) firstUnfoldedSection;
- (void) toggleFoldedStateForFolder:(MHCodeFolder*)aFolder;
- (void) removeAllTrackingRects;
- (void) resetTrackingRects;
- (void) resetLineNumbers;
- (void) handleTextViewDidFoldUnfoldNotification:(NSNotification*)aNote;

- (void) recalculateThickness;

#pragma mark -
#pragma mark Attributes

- (NSDictionary *) textAttributes;
- (NSDictionary *) alternateTextAttributes;
@end
