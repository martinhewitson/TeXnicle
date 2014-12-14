//
//  MHEditorRuler.m
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

#import "MHEditorRuler.h"
#import "externs.h"
#import "TeXTextView.h"
#import "MHLineNumber.h"
#import "MHCodeFolder.h"
#import "MHFoldingTagDescription.h"
#import "MHFoldingTag.h"
#import "NSArray+Extensions.h"
#import "NSAttributedString+CodeFolding.h"
#import "NSString+Extension.h"
#import "NSAttributedString+CodeFolding.h"
#import "NSAttributedString+LineNumbers.h"
#import "Bookmark.h"
#import "TPFoldedCodeSnippet.h"
#import "TPThemeManager.h"

#define kDEFAULT_THICKNESS	22.0
#define kRULER_MARGIN		5.0
#define kYOFFSET		3.0
#define kFOLDING_GUTTER 20.0
#define kLineCalculationUpdateRate 0.05

@interface MHEditorRuler ()

@property (strong) NSDate *lastCalculation;
@property (strong) NSArray *lineNumbers;
@property (strong) NSArray *codeFolders;
@property (strong) NSMutableArray *foldingTagDescriptions;
@property (unsafe_unretained) TeXTextView *textView;
@property (strong) NSColor *textColor;
@property (strong) NSColor *alternateTextColor;
@property (strong) NSColor *backgroundColor;
@property (strong) NSFont *font;
@property (strong) NSDictionary *textAttributesDictionary;
@property (strong) NSDictionary *alternateTextAttributesDictionary;

@property (assign) CGFloat lineheightMultiple;
@property (assign) BOOL showLineNumbers;
@property (assign) BOOL showCodeFolders;

@property (assign) NSInteger lastLineCount;
@property (assign) CGFloat lastGutterWidth;

@property (strong) NSMutableAttributedString *labelText;
@property (assign) NSSize stringSize;
@property (assign) unsigned long oldMaxLabelStrlen;
@property (assign) unsigned long lastLineStrlen;
@property (assign) NSSize labelSize;

@end

@implementation MHEditorRuler

+ (MHEditorRuler*) editorRulerWithTextView:(NSTextView*)aTextView
{
  return [[MHEditorRuler alloc] initWithTextView:aTextView];
}

- (id)initWithTextView:(NSTextView*)aTextView
{
	self = [super initWithScrollView:[aTextView enclosingScrollView]
											 orientation:NSVerticalRuler];
	
  if (self) {
    _newThickness = -1.0;
    self.lineNumbers = @[];
    self.textView = (TeXTextView*)aTextView;
    
    [self setColors];
    
    self.font = [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
    
    // initialise the folding tag descriptions
    self.foldingTagDescriptions = [[NSMutableArray alloc] init];    
    [self.foldingTagDescriptions addObject:[MHFoldingTagDescription foldingTagWithStartTag:@"\\begin{" endTag:@"\\end{" followingArgument:YES]];        
    [self setClientView:aTextView];
    
    newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.showLineNumbers = [[defaults valueForKey:TEShowLineNumbers] boolValue];
    self.showCodeFolders = [[defaults valueForKey:TEShowCodeFolders] boolValue];
    self.lineheightMultiple = [[defaults valueForKey:TEDocumentLineHeightMultiple] floatValue];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleChangesToUserDefaults:) 
               name:NSUserDefaultsDidChangeNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleTextViewDidFoldUnfoldNotification:)
               name:TEDidFoldUnfoldTextNotification
             object:self.textView];
    
    [nc addObserver:self
           selector:@selector(handleThemeDidChangeNotification:)
               name:TPThemeSelectionChangedNotification
             object:nil];
    
  }
	  
	return self;
}

- (void) handleThemeDidChangeNotification:(NSNotification*)aNote
{
  [self setColors];
  [self setNeedsDisplay:YES];
}

- (void) setColors
{
  TPTheme *theme = [TPThemeManager currentTheme];
  self.textColor = theme.documentTextColor;
  self.alternateTextColor = [NSColor whiteColor];
  self.backgroundColor = theme.documentEditorBackgroundColor;
  self.textAttributesDictionary = nil;
  self.alternateTextAttributesDictionary = nil;
}

- (void) handleTextViewDidFoldUnfoldNotification:(NSNotification*)aNote
{
//  NSLog(@"Textview did fold/unfold");  
  [self resetLineNumbers];
}

- (void) handleChangesToUserDefaults:(NSNotification*)aNote
{
  //NSLog(@"User defaults changed");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  self.showLineNumbers = [[defaults valueForKey:TEShowLineNumbers] boolValue];
  self.showCodeFolders = [[defaults valueForKey:TEShowCodeFolders] boolValue];
  self.lineheightMultiple = [[defaults valueForKey:TEDocumentLineHeightMultiple] floatValue];

  NSRange visibleRange = [self.textView getVisibleRange];
  self.lastLineCount = NSNotFound;
  [self resetLineNumbers];
  [self recalculateThickness];
  [self calculationsForTextRange:visibleRange];
  [self setNeedsDisplay:YES];
  [self.textView setNeedsDisplay:YES];
}

- (void)setClientView:(NSView *)client
{  
	if ([client isKindOfClass:[NSTextView class]]) {
		TeXTextView *aTextView = (TeXTextView*)client;
    self.textView = aTextView;
		[super setClientView:aTextView];		
	} else {
		[super setClientView:client];
	}
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
//  NSLog(@"Dealloc MHEditorRuler");
//	[self setClientView:nil];	
}

- (void) drawRect:(NSRect)dirtyRect
{
//  [super drawRect:dirtyRect];
//  NSLog(@"Draw rect %@", NSStringFromRect(dirtyRect));
  [self drawHashMarksAndLabelsInRect:dirtyRect];
}

- (void)resetLineNumbers
{
//  NSLog(@"resetLineNumbers");
  _recalculateLines = YES;
  NSRange visibleRange = [self.textView getVisibleRange];
  if (!NSEqualRanges(visibleRange, lastVisibleRange)) {
    [self calculationsForTextRange:visibleRange];
    lastVisibleRange = visibleRange;
    [self setNeedsDisplay:YES];
  }
}


- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect
{
  
  // check user defaults
	BOOL shouldDrawLineNumbers = _showLineNumbers;
  BOOL shouldFoldCode = _showCodeFolders;
  
  if (_showCodeFolders == NO && _showLineNumbers == NO) {
    return;
  }
//  NSLog(@"drawHashMarksAndLabelsInRect %@", NSStringFromRect(aRect));
  
  NSRectArray  rects;
  NSUInteger   rectCount;
  NSAttributedString *attStr = [self.textView attributedString];
  NSRange visibleRange = [self.textView getVisibleRange];
  NSRange nullRange = NSMakeRange(NSNotFound, 0);
  NSLayoutManager *layoutManager = [self.textView layoutManager];
  NSTextContainer *container = [self.textView textContainer];
	NSRect visibleRect = [self.textView visibleRect];  
  
  // fill background
	if (self.backgroundColor != nil)
	{
		[self.backgroundColor set];
		NSRectFill(aRect);
		
		[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(aRect)-0.5, NSMinY(aRect)) toPoint:NSMakePoint(NSMaxX(aRect) - 0.5, NSMaxY(aRect))];
		if (shouldDrawLineNumbers) {
			CGFloat foldWidth = 0.0;
      if (shouldFoldCode) {
				foldWidth = kFOLDING_GUTTER;
      }
			[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(aRect)-foldWidth-0.5, NSMinY(aRect)) toPoint:NSMakePoint(NSMaxX(aRect) - foldWidth - 0.5, NSMaxY(aRect))];
		}
	}
    
  // calculate visible lines
//  NSLog(@"   Last range %@, this range %@", NSStringFromRange(lastVisibleRange), NSStringFromRange(visibleRange));
  if (!NSEqualRanges(visibleRange, lastVisibleRange)) {
    [self calculationsForTextRange:visibleRange];
    lastVisibleRange = visibleRange;
  }
  
  // if we don't have any lines, there's no need to proceed.
  if ([self.lineNumbers count]<1)
    return;
  
  // bookmarks
  MHLineNumber *firstLine = (self.lineNumbers)[0];
  NSArray *bookmarks = [self.textView bookmarksForLineRange:NSMakeRange(firstLine.number, _lastMaxVisibleLine - firstLine.number)];
  
  float yinset = [self.textView textContainerInset].height;        
  
  CGFloat foldWidth = 0.0;
  if (shouldFoldCode) {
    foldWidth = kFOLDING_GUTTER;
  }

  // some useful numbers for drawing the line numbers
  CGFloat boundsWidth = NSWidth([self bounds]);
  CGFloat bwmrm = boundsWidth - kRULER_MARGIN;
  CGFloat bwmrm2 = bwmrm * 2.0;
  CGFloat strHeight = self.stringSize.height;
  
  // go at least one character further to ensure we cover the visible range
  visibleRange.length++;
  
  char txt[16];
  self.lastLineStrlen = 0;
  // loop over the lines
  for (MHLineNumber *line in self.lineNumbers) {
    // NSLog(@"** Drawing line %@", line);
    // if this line is visible, we will draw it
    if (NSLocationInRange(line.index, visibleRange))
    {
      rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(line.index, 0)
                           withinSelectedCharacterRange:nullRange
                                        inTextContainer:container
                                              rectCount:&rectCount];
      
      if (rectCount > 0)
      {          
        NSRect r = rects[0];
        CGFloat rectHeight = NSHeight(r);
        CGFloat rectWidth = kFOLDING_GUTTER;
        
        MHCodeFolder *folder = nil;
        // we need to see how many lines are folded so that the line count will be correct
        if (shouldFoldCode) {
          // get a folder that starts on this line
          folder = [MHCodeFolder codeFolderStartingAtIndex:line.number inFolders:self.codeFolders];          
          if (folder) {
            if (folder.isValid) {
              // check for attachment in the folder string
              NSRange r = NSMakeRange(folder.startIndex, folder.endIndex-folder.startIndex+1);
//              NSLog(@"Folder %@", folder);
//              NSLog(@"String range %@", NSStringFromRange(r));
              NSAttributedString *substr = [attStr attributedSubstringFromRange:r];
//              NSLog(@"Checking line %@", substr);
              // determine if this folder is folded. It must contain an attachment and the start and end line must be the same
              if ([substr containsAttachments] && folder.startLine == folder.endLine) {
//                NSLog(@"Folder contains atts: %@", folder);
                folder.folded = YES;
              } else {
                folder.folded = NO;
              }
            }
          }
        } // end if shouldFoldCode
        
        // Note that the ruler view is only as tall as the visible
        // portion. Need to compensate for the clipview's coordinates.
        float ypos = yinset  + NSMinY(r)  - NSMinY(visibleRect);
        if (shouldDrawLineNumbers) {
          // check for bookmark
          Bookmark *b = [Bookmark bookmarkWithLinenumber:line.number inArray:bookmarks];
          // set string
          sprintf(txt, "%ld", (unsigned long)line.number);
          NSString *lstr = [NSString stringWithUTF8String:txt];
          [[self.labelText mutableString] setString:lstr];
          if (b) {
            [self.labelText setAttributes:[self alternateTextAttributes] range:NSMakeRange(0, [self.labelText length])];
          } else {
            [self.labelText setAttributes:[self textAttributes] range:NSMakeRange(0, [self.labelText length])];
          }
          // get size
          if ([self.labelText length] != self.lastLineStrlen) {
            self.lastLineStrlen = [self.labelText length];
            self.labelSize = [self.labelText size];
          }

          // Draw string flush right, centered vertically within the line
          NSRect srect = NSMakeRect(bwmrm - foldWidth - self.labelSize.width,
                                    ypos + rectHeight - strHeight - kYOFFSET,
                                    bwmrm2, rectHeight);
          
          line.rect = srect;
          
          if (b) {
            CGFloat bwidth = boundsWidth-foldWidth;
            CGFloat bypos = ypos+rectHeight-strHeight-1.5*kYOFFSET;
            NSBezierPath *path = [self makeBookmarkPathForWidth:bwidth height:MIN(rectHeight, 16.0) ypos:bypos];
            [_bookmarkGradient drawInBezierPath:path angle:0];
            [[[NSColor colorWithDeviceRed:0.2 green:0.2 blue:1.0 alpha:1.0] highlightWithLevel:0.5] set];
            [path setLineWidth:1.0];
            [path stroke];
          }
          
          [self.labelText drawInRect:srect];
        }
        
        // draw code folders
        if (shouldFoldCode) {
//          NSLog(@"Drawing folder: %@", folder);
          if (folder) {
            
            // compute the rect for the image to be drawn in
            CGFloat s = MIN(rectWidth, rectHeight);
            NSRect imRect = NSMakeRect(boundsWidth - kFOLDING_GUTTER + (kFOLDING_GUTTER-rectWidth)/2.0, 
                                       ypos - self.lineheightMultiple*kYOFFSET + (rectHeight - self.stringSize.height),
                                       s, s);
            NSImage *im = nil;
            if (folder.isValid) {
              if (folder.folded) {
                im = [NSImage imageNamed:@"disclosure_right"];
              } else {
                im = [NSImage imageNamed:@"disclosure_up"];
              }
            } else {
              im = [NSImage imageNamed:@"disclosure_down_invalid"];
            }
            
            // draw the image
            NSSize imsize = [im size];
            [im drawInRect:imRect 
                  fromRect:NSMakeRect(0, 0, imsize.width, imsize.height) 
                 operation:NSCompositeSourceAtop
                  fraction:1.0];
            
            // Set the start rect for this folder. We store this as a string. This is 
            // used later to set up the tracking rects.
            [folder setStartRect:NSStringFromRect(imRect)];
            
          } else {
            // we are not at the start of a folder, but perhaps we are at the end?
            folder = [MHCodeFolder codeFolderEndingAtIndex:line.number inFolders:self.codeFolders];
            if (folder) {
              if (!folder.folded) {
                // make rect for placing the image
                CGFloat s = MIN(rectWidth, rectHeight);
                NSRect imRect = NSMakeRect(boundsWidth - kFOLDING_GUTTER + (kFOLDING_GUTTER-rectWidth)/2.0,
                                           ypos - self.lineheightMultiple*kYOFFSET + (rectHeight - self.stringSize.height),
                                           s, s);
                NSImage *im = nil;
                if (folder.isValid) {
                  im = [NSImage imageNamed:@"disclosure_down"];
                } else {
                  im = [NSImage imageNamed:@"disclosure_down_invalid"];
                }
                
                // draw the image
                NSSize imsize = [im size];
                [im drawInRect:imRect 
                      fromRect:NSMakeRect(0, 0, imsize.width, imsize.height) 
                     operation:NSCompositeSourceAtop
                      fraction:1.0];
                
                // Set the end rect for this folder. We store this as a string. This is 
                // used later to set up the tracking rects.
                [folder setEndRect:NSStringFromRect(imRect)];
                
              } // end if folder.folded
            } // end if folder
          } // end start/end folder
        } // end shouldFoldCode         
      } // end if we have a layout rect
    } // end if in visible range      
  } // end loop over linenumbers
  
  // set up the tracking rects which allow us to respond to the user
  // clicking on the folders
  [self resetTrackingRects];
}

- (NSBezierPath*) makeBookmarkPathForWidth:(CGFloat)bwidth height:(CGFloat)rectHeight ypos:(CGFloat)ypos
{
  if (!_bookmarkGradient) {
    _bookmarkGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.2 green:0.2 blue:1.0 alpha:1.0] 
                                                      endingColor:[NSColor colorWithDeviceRed:0.5 green:0.5 blue:1.0 alpha:1.0]];
  }
  CGFloat arrowwidth = 0.3*bwidth;
  CGFloat inset = 2.0;
  CGFloat radius = 6.0;
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(inset, inset+radius)];
  [path curveToPoint:NSMakePoint(inset+radius, inset) controlPoint1:NSMakePoint(inset, inset) controlPoint2:NSMakePoint(inset, inset)];
  [path lineToPoint:NSMakePoint(bwidth-arrowwidth, inset)];
  [path lineToPoint:NSMakePoint(bwidth, rectHeight/2.0)];
  [path lineToPoint:NSMakePoint(bwidth-arrowwidth, rectHeight-inset)];
  [path lineToPoint:NSMakePoint(inset+radius, rectHeight-inset)];
  [path curveToPoint:NSMakePoint(inset, rectHeight-inset-radius) controlPoint1:NSMakePoint(inset, rectHeight-inset) controlPoint2:NSMakePoint(inset, rectHeight-inset)];
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy:0 yBy:ypos];
  [path transformUsingAffineTransform:transform];
  return path;
}

#pragma mark -
#pragma mark Lines and Folders

- (void) recalculateThickness
{
//  NSLog(@"recalculateThickness");
  _forceThicknessRecalculation = YES;
}

// This computes the new set of line numbers and the new set of code folders
// for the given range. It also updates the thickness of the ruler. The new 
// linenumbers and code folders are then set to the instance properties.
- (void)calculationsForTextRange:(NSRange)aRange
{
//  NSLog(@"calculationsForTextRange");
  
//  NSLog(@"Calculations for range %@", NSStringFromRange(aRange));
  // compute and cache the linenumbers in view
  NSArray *newLineNumbers = [self lineNumbersForTextRange:aRange];
  NSInteger lineCount = [[newLineNumbers lastObject] number];
  
//  NSArray *foldingTags = [self foldingTagsForTextRange:aRange];
  // make a set of code folders in view
  NSArray *newFolders = [self makeFoldersForTextRange:aRange];
  
//  NSLog(@"Got folders: %@", newFolders);
  
  // update ruler thickness
//  NSLog(@"Last max line %ld: new max line %ld", [[newLineNumbers lastObject] number], _lastMaxVisibleLine);
  NSInteger newMaxLine = [[newLineNumbers lastObject] number];
  
  if (newMaxLine > _lastMaxVisibleLine || _forceThicknessRecalculation) {
    float oldThickness = [self ruleThickness];
    float newThickness = [self requiredThicknessForLineCount:lineCount];
    if (fabs(oldThickness - newThickness) > 1)
    {
      _newThickness = newThickness;
      [self performSelectorOnMainThread:@selector(setNewThickness) withObject:nil waitUntilDone:YES];
    }
    _forceThicknessRecalculation = NO;
  }
  
  self.lineNumbers = newLineNumbers;
  self.codeFolders = newFolders;
  _recalculateLines = NO;
  
  char txt[100];
  sprintf(txt, "%ld", newMaxLine);
  if (strlen(txt) != self.oldMaxLabelStrlen) {
    
    float oldThickness = [self ruleThickness];
    float newThickness = [self requiredThicknessForLineCount:lineCount];
    if (fabs(oldThickness - newThickness) > 1)
    {
      _newThickness = newThickness;
      [self performSelectorOnMainThread:@selector(setNewThickness) withObject:nil waitUntilDone:YES];
    }
    _forceThicknessRecalculation = NO;
    
    
    self.labelText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", _lastMaxVisibleLine + 1] attributes:[self textAttributes]];
    self.stringSize = [self.labelText size];

    self.oldMaxLabelStrlen = strlen(txt);
  }
  _lastMaxVisibleLine = newMaxLine;
}

- (void) setNewThickness
{
  if (_newThickness >=0) {
    [self setRuleThickness:_newThickness];
  }
}


// Make the set of code folders for the given range of text.
- (NSArray*) makeFoldersForTextRange:(NSRange)aRange
{
  if (self.showCodeFolders == NO) {
    return @[];
  }
  
//  NSLog(@"*** Making folders");
  NSString *text = [self.textView string];
//  NSString *searchString = [text substringWithRange:aRange];
//  NSLog(@"Searching %@", searchString);
  
  // First collect an array of folding tag descriptions that are in range
  NSArray *foldingTagArray = [self foldingTagsForTextRange:aRange];
//  NSLog(@"Tags found: %@", foldingTagArray);
  // Make a mutable copy of the folding tags so that we can remove them as
  // they get sorted in to pairs.
  NSMutableArray *tags = [NSMutableArray arrayWithArray:foldingTagArray];
  // Match all the tags in to pairs. The resulting dictionary has the matched
  // code folders and a list of the used tags.
  NSDictionary *dict = [self matchTagPairs:foldingTagArray];
  // Get the code folders
  NSMutableArray *folders = [NSMutableArray arrayWithArray:[dict valueForKey:@"folders"]];
  // Get the tags used
  NSArray *usedTags = [dict valueForKey:@"tags"];
  // Now remove the used tags from the full list
  [tags removeObjectsInArray:usedTags];
  // Now we iterate the process as long as we can still make pairs
  NSInteger changed = 1;
  while (changed > 0) {
    // match pairs in the remaining tag array
    dict = [self matchTagPairs:tags];
    // add the matched code folders
    [folders addObjectsFromArray:[dict valueForKey:@"folders"]];
    // remove the tags we used
    usedTags = [dict valueForKey:@"tags"];
    [tags removeObjectsInArray:usedTags];
    // how many did we change?
    changed = [usedTags count];
  }
    
//  NSLog(@"Matched folders: %@", folders);
  
  // Now complete incomplete folders. Some folders won't have a beginning 
  // or end index since they are out of view. We need to scan the text 
  // backwards and forwards to complete any incomplete folders.
  for (MHCodeFolder *folder in folders) {
    [folder completeFolderWithText:text forTags:self.foldingTagDescriptions];
  }
  
//  NSLog(@"Completed folders: %@", folders);
//  NSLog(@"Remaining tags: %@", tags);
  
  return folders;
}

// Returns a dictionary containing an array of MHCodeFolders from the matching pairs with key "folders".
// Used tags are returned in another array with the key "tags".
- (NSDictionary*)matchTagPairs:(NSArray*)foldingTagArray
{
  // If we only have one tag, it's hard to make a pair, so return two empty arrays.
  NSInteger Ntags = [foldingTagArray count];
  if (Ntags<1 || !foldingTagArray) {
    return @{@"folders": @[], @"tags": @[]};
  }
  
  NSMutableArray *returnFolders = [NSMutableArray array];
  NSMutableArray *usedTags      = [NSMutableArray array];
  
  // get first tag  
  MHFoldingTag *firstTag = foldingTagArray[0];
//  NSLog(@"* Building folder for %@ from %@", firstTag, foldingTagArray);
  // If this is an end tag, we build a code folder with a missing start index. This will get completed later.
  // The assumption is that the start of this code folder is out of view.
  if (!firstTag.isStartTag) {
    MHCodeFolder *folder = [MHCodeFolder codeFolderWithStartIndex:NSNotFound endIndex:firstTag.index startLine:NSNotFound endLine:firstTag.lineNumber tag:firstTag.tag];
    return @{@"folders": @[folder], @"tags": @[firstTag]};
  }
  
  // Here we must have a start tag, so now we loop over the rest looking for a matching end tag
  MHFoldingTag *nextTag = nil;
  BOOL matchFound = NO;
  for (NSInteger kk=1; kk<Ntags; kk++) {
    nextTag = foldingTagArray[kk];
//    NSLog(@"  Checking tag: %@ for %@", nextTag, firstTag);
    if (nextTag.isStartTag) {
//      NSLog(@"      Is start tag %@", nextTag);
      // spawn a recursive call because we have nested folders here
      NSDictionary *dict = [self matchTagPairs:[foldingTagArray subarrayWithRange:NSMakeRange(kk, Ntags-kk)]];
      NSArray *matchedPairs = [dict valueForKey:@"folders"];
      NSArray *usedTagsInMatching = [dict valueForKey:@"tags"];
      if (![usedTagsInMatching isEmpty]) {
        [returnFolders addObjectsFromArray:matchedPairs];
        [usedTags addObjectsFromArray:usedTagsInMatching];
        NSInteger lastMatch = [foldingTagArray indexOfObject:[usedTags lastObject]];
        if (lastMatch != NSNotFound) {
          kk = lastMatch;
        }
      }
    } else {
//      NSLog(@"      Is end tag %@ for %@", nextTag, firstTag);
      // we make a folder and stop
//      NSLog(@"    Making folder for %@", firstTag);
      MHCodeFolder *folder = [MHCodeFolder codeFolderWithStartIndex:firstTag.index endIndex:nextTag.index startLine:firstTag.lineNumber endLine:nextTag.lineNumber tag:firstTag.tag];
//      NSLog(@"    Made folder: %@", folder);
      [returnFolders addObject:folder];
      [usedTags addObject:firstTag];
      [usedTags addObject:nextTag];
      matchFound = YES;
      break;
    }
  }
  
  // If we got through all the folders and didn't find a matching end tag, we create a folder with no end index. The 
  // assumption is that the end of the folder is out of view. This will be completed by scanning the text later.
  if (!matchFound) {
    MHCodeFolder *folder = [MHCodeFolder codeFolderWithStartIndex:firstTag.index endIndex:NSNotFound startLine:firstTag.lineNumber endLine:NSNotFound tag:firstTag.tag];
    [returnFolders addObject:folder];
    [usedTags addObject:firstTag];
  }
    
  // return the code folders and the used tags
  return @{@"folders": returnFolders, @"tags": usedTags};  
}

// Get an array of all folding tags found in the given text range.
- (NSArray*) foldingTagsForTextRange:(NSRange)aRange
{
  BOOL foldCode = self.showCodeFolders;
  NSMutableArray *foundFoldingTags = [NSMutableArray array];
  if (!foldCode) {
    return foundFoldingTags;
  }
  
//  NSUInteger start = aRange.location;
  NSString *text = [self.textView string];
  if (text == nil) {
    return foundFoldingTags;
  }
  
  NSAttributedString *attStr = [self.textView attributedString];
  if ([attStr length] == 0) {
    return foundFoldingTags;
  }
  
  NSInteger lineNumber;
  
  // go forwards from the start until we reach the start of the input range
  NSUInteger idx;
  NSRange lineRange;
  
  if (self.lineNumbers == nil || [self.lineNumbers count] == 0) {
    lineNumber = 1;
    for (idx = 0; idx < aRange.location & idx < [text length];) {
      if (idx >= [text length]) {
        break;
      }
      lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
      if (lineRange.location != NSNotFound) {
        lineNumber += [NSAttributedString lineCountForLine:[attStr attributedSubstringFromRange:lineRange]];
      }
      idx = NSMaxRange(lineRange);
    }
  } else {
    MHLineNumber *firstLine = (self.lineNumbers)[0];
    idx = firstLine.range.location;
    lineNumber = firstLine.number;
  }
  
  if (idx >= [text length]) {
    return foundFoldingTags;
  }
  
//  NSInteger startIndex = idx;
//  NSInteger startLineNumber = lineNumber;  
//  NSLog(@"*** Starting first tag search from index %ld, line %ld", startIndex, startLineNumber);
//  NSLog(@"   checking line %@", [text substringWithRange:[text lineRangeForRange:NSMakeRange(idx, 0)]]);
  
  MHFoldingTagDescription *tag;
  NSString *line;
  NSInteger tmpIndex = 0;
  NSInteger matched;
  do
  {
    tmpIndex = 0; // start scanning at the start of the line
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    line = [text substringWithRange:lineRange];
    //NSLog(@"Checking line %@", line);
    
    // Check the full line. We loop looking for all tags in the line
    NSInteger searchStart;
    while (tmpIndex != NSNotFound && tmpIndex<[line length]) {
      searchStart = tmpIndex;
      tag = [MHFoldingTagDescription foldingTagInLine:line atIndex:&tmpIndex fromTags:self.foldingTagDescriptions matched:&matched];
      //NSLog(@"index %ld", tmpIndex);
      if (tag) {
        // if the line contains a % sign before the tag, we don't include it        
        //NSLog(@"Found tag at %ld, %ld, %ld, %ld", lineNumber, tmpIndex, tag.index, matched);
        if (![line containsCommentCharBeforeIndex:tmpIndex]) {
          MHFoldingTag *ftag = nil;
          if (matched == MHFoldingTagStartMatched) {
            ftag = [MHFoldingTag tagWithStartTag:tag index:lineRange.location+tmpIndex lineNumber:lineNumber isStartTag:YES];
          } else {
            ftag = [MHFoldingTag tagWithStartTag:tag index:lineRange.location+searchStart+tag.index lineNumber:lineNumber isStartTag:NO];
          }
          if (ftag) {
            //          NSLog(@"Made tag %@", ftag);
            [foundFoldingTags addObject:ftag];
          }
        }
      }
    }
    idx = NSMaxRange(lineRange);
    lineNumber++;
    
    // check if the line has an attachment and jump forward the appropriate number of lines
    NSAttributedString *attLine = [attStr attributedSubstringFromRange:lineRange];
    if ([attLine containsAttachments]) {
      NSTextAttachment *att = [attLine firstAttachment];
      if (att && [att isKindOfClass:[TPFoldedCodeSnippet class]]) {
        MHCodeFolder *attFolder = [att valueForKey:@"object"];
        if (attFolder) {
          lineNumber += attFolder.lineCount;
        }
      }
    } // end if line contains attachments
    
  }
  while (idx < NSMaxRange(aRange));
  
//  NSLog(@"Found folding tags: %@", foundFoldingTags);
  
  return foundFoldingTags;
}

// remove all tracking rects from this view
- (void) removeAllTrackingRects
{
  for (MHCodeFolder *folder in self.codeFolders) {
    [self removeTrackingRect:folder.startTrackingRect];
    [self removeTrackingRect:folder.endTrackingRect];
  }
}

// Reset the tracking rects for this view. The tracking rects are 
// stored inside the code folders as long as the view has drawn. 
- (void) resetTrackingRects
{
  // remove all tracking rects
  [self removeAllTrackingRects];
  
  // now add new tracking rects
  for (MHCodeFolder *folder in self.codeFolders) {
    folder.startTrackingRect = [self addTrackingRect:NSRectFromString(folder.startRect) owner:self userData:NULL assumeInside:NO];
    folder.endTrackingRect = [self addTrackingRect:NSRectFromString(folder.endRect) owner:self userData:NULL assumeInside:NO];    
  }
}


// Build an array of line number objects for the given text range.
- (NSArray*) lineNumbersForTextRange:(NSRange)aRange
{
  NSAttributedString *attStr = [self.textView attributedString];
  
  // check the range against the linenumbers we already have
  if (self.lineNumbers && [self.lineNumbers count] > 0) {
    MHLineNumber *firstLine = (self.lineNumbers)[0];
//    NSLog(@"Requested range %@", NSStringFromRange(aRange));
//    NSLog(@"Min line: %ld, %@", [[self.lineNumbers objectAtIndex:0] number], NSStringFromRange([[self.lineNumbers objectAtIndex:0] range]));  
    
    // if the visible range still includes our first line from last time, we can shortcut the calculation. We don't need to start 
    // from the start of the file again.
    if (aRange.location >= firstLine.range.location) {
      return [attStr lineNumbersForTextRange:aRange startIndex:firstLine.range.location startLine:firstLine.number useCodeFolding:_showCodeFolders];
    }    
  }
  return [attStr lineNumbersForTextRange:aRange useCodeFolding:_showCodeFolders];
}

- (MHLineNumber*)lineNumberForPoint:(NSPoint)aPoint
{
  
  // some useful numbers for drawing the line numbers
//  NSLog(@"Looking for point %@", NSStringFromPoint(aPoint));
  for (MHLineNumber *line in self.lineNumbers) {
//    NSLog(@"  in %@", line);
    NSRect r = NSMakeRect(0, line.rect.origin.y, _lineGutterWidth, line.rect.size.height);
    if (NSPointInRect(aPoint, r)) {
      return line;
    }
  }
  return nil;
}



// Compute the required thickness of the ruler.
- (CGFloat)requiredThicknessForLineCount:(NSInteger)lineCount
{
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL includeLineNumbers = _showLineNumbers;
	BOOL includeCodeFolders = _showCodeFolders;
  
	if (!includeLineNumbers) {
		if (!includeCodeFolders)
			return 0.0;
		
		return ceilf(kFOLDING_GUTTER);
	}
  
  if (self.lastLineCount == lineCount) {
    return self.lastGutterWidth;
  }
	
	NSUInteger			digits, i;
	NSSize              stringSize;
	
//  NSInteger idx = [[self.textView string] length];
//	lineCount = [[lineNumbers lastObject] number];
  
  
//	lineCount = [[self.lineNumbers lastObject] number];
	digits = (unsigned)log10(lineCount) + 1;
  NSMutableString *sampleString = [NSMutableString stringWithString:@""];
	for (i = 0; i < digits; i++)
	{
		// Use "8" since it is one of the fatter numbers. Anything but "1"
		// will probably be ok here. I could be pedantic and actually find the fattest
		// number for the current font but nah.
		[sampleString appendString:@"8"];
	}
	
	stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
	  
	// Round up the value. There is a bug on 10.4 where the display gets all wonky when scrolling if you don't
	// return an integral value here.
	CGFloat foldWidth = 0.0;
  CGFloat minWidth = kDEFAULT_THICKNESS;
	if (includeCodeFolders) {
		foldWidth = kFOLDING_GUTTER;
    minWidth = kDEFAULT_THICKNESS + kFOLDING_GUTTER;
	}
  
  _lineGutterWidth = stringSize.width + kRULER_MARGIN * 2;
  _folderGutterWidth = foldWidth;
  CGFloat width = ceilf(MAX(minWidth, _lineGutterWidth + _folderGutterWidth));
  
  self.lastLineCount = lineCount;
  self.lastGutterWidth = width;
  
	return width;
}

// Returns the folder for a given point. This is done
// by checking the start and end rect for each folder.
- (MHCodeFolder*)folderForPoint:(NSPoint)aPoint
{
	for (MHCodeFolder *folder in self.codeFolders) {
		NSRect sr = NSRectFromString(folder.startRect);
		if (NSPointInRect(aPoint, sr)) {
			return folder;
		}
		NSRect er = NSRectFromString(folder.endRect);
		if (NSPointInRect(aPoint, er)) {
			return folder;
		}
	}
	return nil;
}

- (void) collapseAll
{
	MHCodeFolder *folder = nil;
	while ((folder = [self firstUnfoldedSection])) {
		[self toggleFoldedStateForFolder:folder];
		[self resetLineNumbers];
	}
}

- (MHCodeFolder*) firstUnfoldedSection
{
	for (MHCodeFolder *folder in self.codeFolders) {
		if (!folder.folded) {
			return folder;
		}
	}
	return nil;
}


// Toggle the folded state of the given folder.
- (void) toggleFoldedStateForFolder:(MHCodeFolder*)aFolder
{
  if ([aFolder isValid]) {
    id view = [self clientView];
    if ([view isKindOfClass:[NSTextView class]]) {
      if (aFolder) {
        if (aFolder.folded) {
          aFolder.folded = NO;
          //        NSLog(@"   unfold");
          [self.textView unfoldTextWithFolder:aFolder];
        } else {
          aFolder.folded = YES;
          //        NSLog(@"   fold");
          [self.textView foldTextWithFolder:aFolder];
        }
      }
    }
  }
}

- (NSRange) rangeForLinenumber:(NSInteger)aLinenumber
{
  for (MHLineNumber *line in self.lineNumbers) {
    if (aLinenumber == line.number) {
      return line.range;
    }
  }
  return NSMakeRange(NSNotFound, 0);
}

- (MHLineNumber*)lineNumberContainingIndex:(NSInteger)anIndex
{
  for (MHLineNumber *line in self.lineNumbers) {
    if (anIndex >= line.range.location && anIndex < NSMaxRange(line.range)) {
      return line;
    }
  }
  return nil;
}

#pragma mark -
#pragma mark Mouse actions

- (void)mouseDown:(NSEvent *)theEvent
{
//  NSLog(@"--------------- Mouse down");
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  MHCodeFolder *folder = nil;
  folder = [self folderForPoint:clickPoint];
  
  if (folder == nil) {
    // can we get the line number clicked on?
    MHLineNumber *clickedLine = [self lineNumberForPoint:clickPoint];
    if (clickedLine) {
      NSDictionary *dict = @{@"LineNumber": clickedLine};
      [[NSNotificationCenter defaultCenter] postNotificationName:TELineNumberClickedNotification
                                                          object:self.textView
                                                        userInfo:dict];
      [self setNeedsDisplay:YES];
    }
  } else {
    [self toggleFoldedStateForFolder:folder];
  }
  
//  NSLog(@"Clicked on %@", folder);
}


- (void)mouseEntered:(NSEvent *)theEvent 
{
  wasAcceptingMouseEvents = [[self window] acceptsMouseMovedEvents];
  [[self window] setAcceptsMouseMovedEvents:YES];
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self highlightFolderRangeForPoint:point];
//  [[self window] makeFirstResponder:self.textView];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self highlightFolderRangeForPoint:point];
}

- (void) highlightFolderRangeForPoint:(NSPoint)point
{
  MHCodeFolder *folder = [self folderForPoint:point];
  if (folder != nil) {
    if (folder != highlightedFolder) {
      highlightedFolder = folder;
      // set highlight rect on textview
      NSRange r = NSMakeRange(folder.startIndex, folder.endIndex-folder.startIndex+1);
      [[self textView] setHighlightRange:NSStringFromRange(r)];
      [[self textView] setHighlightAlpha:0.0];
      [[self textView] setNeedsDisplay:YES];
    }
  } else {
    highlightedFolder = nil;
    [[self textView] clearHighlight];
  }
}

- (void)mouseExited:(NSEvent *)theEvent 
{
  [[self window] setAcceptsMouseMovedEvents:wasAcceptingMouseEvents];
  [[self textView] clearHighlight];
  highlightedFolder = nil;
  [[self window] makeFirstResponder:[self textView]];
}

#pragma mark -
#pragma mark Attributes

- (NSDictionary *)textAttributes
{
  if (!self.textAttributesDictionary) {
    
    self.textAttributesDictionary = @{NSFontAttributeName: self.font, 
                      NSForegroundColorAttributeName: self.textColor};
    
  }
  
  return self.textAttributesDictionary;
}

- (NSDictionary *)alternateTextAttributes
{
  if (!self.alternateTextAttributesDictionary) {
    
    self.alternateTextAttributesDictionary = @{NSFontAttributeName: self.font, 
                                     NSForegroundColorAttributeName: self.alternateTextColor};
    
  }
  
  return self.alternateTextAttributesDictionary;
}


@end
