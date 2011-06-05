//
//  MHEditorRuler.m
//  TeXEditor
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
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

#define kDEFAULT_THICKNESS	22.0
#define kRULER_MARGIN		5.0
#define kFOLDING_GUTTER 20.0

@implementation MHEditorRuler

@synthesize textAttributesDictionary;
@synthesize textView;
@synthesize lineNumbers;
@synthesize codeFolders;
@synthesize textColor;
@synthesize backgroundColor;
@synthesize font;
@synthesize foldingTagDescriptions;

+ (MHEditorRuler*) editorRulerWithTextView:(NSTextView*)aTextView
{
  return [[[MHEditorRuler alloc] initWithTextView:aTextView] autorelease];
}

- (id)initWithTextView:(NSTextView*)aTextView
{
	self = [super initWithScrollView:[aTextView enclosingScrollView]
											 orientation:NSVerticalRuler];
	
  if (self) {
    self.lineNumbers = [NSArray array];
    self.textView = (TeXTextView*)aTextView;
    self.textColor = [NSColor darkGrayColor];
//    self.backgroundColor = [NSColor darkGrayColor];  
    CGFloat v = 237;
    self.backgroundColor = [NSColor colorWithDeviceRed:v/255.0 green:v/255.0 blue:v/255.0 alpha:1.0];

    self.font = [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
    
    // initialise the folding tag descriptions
    self.foldingTagDescriptions = [[[NSMutableArray alloc] init] autorelease];    
    [self.foldingTagDescriptions addObject:[MHFoldingTagDescription foldingTagWithStartTag:@"\\begin" endTag:@"\\end" followingArgument:YES]];        
    [self setClientView:aTextView];
    
    newLineCharacterSet = [[NSCharacterSet newlineCharacterSet] retain];
    
  }
	  
	return self;
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
  [newLineCharacterSet release];
  self.foldingTagDescriptions = nil;
  self.textColor = nil;
  self.backgroundColor = nil;
  self.font = nil;
  self.lineNumbers = nil;
  self.codeFolders = nil;
  self.textAttributesDictionary = nil;
	[self setClientView:nil];	
	[super dealloc];
}

//- (void) drawRect:(NSRect)dirtyRect
//{
//  [super drawRect:dirtyRect];
//  [self drawHashMarksAndLabelsInRect:dirtyRect];
//}

- (void)resetLineNumbers
{
  self.lineNumbers = nil;
  self.codeFolders = nil;
}

- (void) setNeedsDisplay 
{
  [self setNeedsDisplay:YES];
  [self performSelector:@selector(invalidateHashMarks) withObject:nil afterDelay:0];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect
{
//  NSLog(@"drawHashMarksAndLabelsInRect");
  
  // check user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL shouldDrawLineNumbers = [[defaults valueForKey:TEShowLineNumbers] boolValue];
	BOOL shouldFoldCode = [[defaults valueForKey:TEShowCodeFolders] boolValue];
  
  NSRectArray  rects;
  NSUInteger   rectCount;
  NSAttributedString *attStr = [self.textView attributedString];
  NSRange visibleRange = [self.textView getVisibleRange];
  NSRange nullRange = NSMakeRange(NSNotFound, 0);
  NSLayoutManager *layoutManager = [self.textView layoutManager];
  NSTextContainer *container = [self.textView textContainer];
	NSRect visibleRect = [self.textView visibleRect];  
  
  // fill background
  NSRect r = [self visibleRect];
	if (self.backgroundColor != nil)
	{
		[self.backgroundColor set];
		NSRectFill(r);
		
		[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(r)-0.5, NSMinY(r)) toPoint:NSMakePoint(NSMaxX(r) - 0.5, NSMaxY(r))];
		if (shouldDrawLineNumbers) {
			CGFloat foldWidth = 0.0;
			if (shouldFoldCode)
				foldWidth = kFOLDING_GUTTER;
			[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(r)-foldWidth-0.5, NSMinY(r)) toPoint:NSMakePoint(NSMaxX(r) - foldWidth - 0.5, NSMaxY(r))];
		}
	}
//  [self.backgroundColor set];
//  NSRectFill(r);
    
  // calculate visible lines
  if (self.lineNumbers == nil || !NSEqualRanges(visibleRange, lastVisibleRange)) {
    [self calculationsForTextRange:visibleRange];
    lastVisibleRange = visibleRange;
  }
  
  // if we don't have any lines, there's no need to proceed.
  if ([self.lineNumbers count]<1)
    return;
  
  
  float yinset = [self.textView textContainerInset].height;        
  
  CGFloat foldWidth = 0.0;
  if (shouldFoldCode) {
    foldWidth = kFOLDING_GUTTER;
  }

  // The maximum line number we will draw. This is needed to set the width of the
  // gutter. Unfortunately, this means that if we scroll down to larger line numbers
  // the gutter will change width. This could be avoided by computing the total line 
  // count in an independent way.
  NSUInteger maxLine = [[self.lineNumbers lastObject] number];
  NSMutableAttributedString *labelText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", maxLine + 1] attributes:[self textAttributes]] autorelease];
  NSSize stringSize = [labelText size];

  // some useful numbers for drawing the line numbers
  CGFloat boundsWidth = NSWidth([self bounds]);
  CGFloat bwmrm = boundsWidth - kRULER_MARGIN;
  CGFloat bwmrm2 = bwmrm * 2.0;
  CGFloat strHeight = stringSize.height;
  
  // go at least one character further to ensure we cover the visible range
  visibleRange.length++;
  
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
        
        MHCodeFolder *folder = nil;
        // we need to see how many lines are folded so that the line count will be correct
        if (shouldFoldCode) {
          // get a folder that starts on this line
          folder = [MHCodeFolder codeFolderStartingAtIndex:line.number inFolders:self.codeFolders];          
          if (folder) {
            if (folder.isValid) {
              // check for attachment in the folder string
              NSAttributedString *substr = [attStr attributedSubstringFromRange:NSMakeRange(folder.startIndex, folder.endIndex-folder.startIndex+1)];
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
          // set string
          [[labelText mutableString] setString:[NSString stringWithFormat:@"%d", line.number]];
          // get size
          NSSize s = [labelText size];
          // Draw string flush right, centered vertically within the line
          NSRect srect = NSMakeRect(bwmrm - foldWidth - s.width,
                                    ypos + (rectHeight - strHeight) / 2.0,
                                    bwmrm2, rectHeight);
          [labelText drawInRect:srect];
        }
        
        // draw code folders
        if (shouldFoldCode) {
//          NSLog(@"Drawing folder: %@", folder);
          if (folder) {
            
            // compute the rect for the image to be drawn in
            NSRect imRect = NSMakeRect(boundsWidth - kFOLDING_GUTTER + (kFOLDING_GUTTER-rectHeight)/2.0, 
                                       ypos + (rectHeight - stringSize.height) / 2.0, 
                                       rectHeight, rectHeight);
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
                NSRect imRect = NSMakeRect(boundsWidth - kFOLDING_GUTTER + (kFOLDING_GUTTER-rectHeight)/2.0, 
                                           ypos + (rectHeight - stringSize.height) / 2.0, 
                                           rectHeight, rectHeight);
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


#pragma mark -
#pragma mark Lines and Folders

// This computes the new set of line numbers and the new set of code folders
// for the given range. It also updates the thickness of the ruler. The new 
// linenumbers and code folders are then set to the instance properties.
- (void)calculationsForTextRange:(NSRange)aRange
{
  
//  NSLog(@"*** Calculating lines");
  // compute and cache the linenumbers in view
  NSArray *newLineNumbers = [self lineNumbersForTextRange:aRange];
  
//  NSArray *foldingTags = [self foldingTagsForTextRange:aRange];
  // make a set of code folders in view
  NSArray *newFolders = [self makeFoldersForTextRange:aRange];
  
//  NSLog(@"Got folders: %@", newFolders);
  
  // update ruler thickness
  float oldThickness = [self ruleThickness];
  float newThickness = [self requiredThickness];
  if (fabs(oldThickness - newThickness) > 1)
  {
    NSInvocation			*invocation;
    
    // Not a good idea to resize the view during calculations (which can happen during
    // display). Do a delayed perform (using NSInvocation since arg is a float).
    invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(setRuleThickness:)]];
    [invocation setSelector:@selector(setRuleThickness:)];
    [invocation setTarget:self];
    [invocation setArgument:&newThickness atIndex:2];    
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.0];
  }
  
  self.lineNumbers = newLineNumbers;
  self.codeFolders = newFolders;
}


// Make the set of code folders for the given range of text.
- (NSArray*) makeFoldersForTextRange:(NSRange)aRange
{
//  NSLog(@"*** Making folders");
  NSString *text = [self.textView string];
//  NSString *searchString = [text substringWithRange:aRange];
//  NSLog(@"Searching %@", searchString);
  
  // First collect an array of folding tag descriptions that are in range
  NSArray *foldingTagArray = [self foldingTagsForTextRange:aRange];
  
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
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray array], @"folders", [NSArray array], @"tags", nil];
  }
  
  NSMutableArray *returnFolders = [NSMutableArray array];
  NSMutableArray *usedTags      = [NSMutableArray array];
  
  // get first tag  
  MHFoldingTag *firstTag = [foldingTagArray objectAtIndex:0];
  // If this is an end tag, we build a code folder with a missing start index. This will get completed later.
  // The assumption is that the start of this code folder is out of view.
  if (!firstTag.isStartTag) {
    MHCodeFolder *folder = [MHCodeFolder codeFolderWithStartIndex:NSNotFound endIndex:firstTag.index startLine:NSNotFound endLine:firstTag.lineNumber tag:firstTag.tag];
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:folder], @"folders", [NSArray arrayWithObject:firstTag], @"tags", nil];
  }
  
  // Here we must have a start tag, so now we loop over the rest looking for a matching end tag
  MHFoldingTag *nextTag = nil;
  BOOL matchFound = NO;
  for (NSInteger kk=1; kk<Ntags; kk++) {
    nextTag = [foldingTagArray objectAtIndex:kk];
    if (nextTag.isStartTag) {
      // spawn a recursive call because we have nested folders here
      NSDictionary *dict = [self matchTagPairs:[foldingTagArray subarrayWithRange:NSMakeRange(kk, Ntags-1-kk)]];
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
      // we make a folder and stop
      MHCodeFolder *folder = [MHCodeFolder codeFolderWithStartIndex:firstTag.index endIndex:nextTag.index startLine:firstTag.lineNumber endLine:nextTag.lineNumber tag:firstTag.tag];
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
  return [NSDictionary dictionaryWithObjectsAndKeys:returnFolders, @"folders", usedTags, @"tags", nil];  
}

// Get an array of all folding tags found in the given text range.
- (NSArray*) foldingTagsForTextRange:(NSRange)aRange
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL foldCode = [[defaults valueForKey:TEShowCodeFolders] boolValue];
  NSMutableArray *foundFoldingTags = [NSMutableArray array];
  if (!foldCode) {
    return foundFoldingTags;
  }
  
  NSUInteger start = aRange.location;
  NSString *text = [self.textView string];
  NSAttributedString *attStr = [self.textView attributedString];
  NSInteger lineNumber;
  
  // go forwards from the start until we reach the start of the input range
  NSUInteger idx;
  NSRange lineRange;
  idx = aRange.location;
  
  // count lines up to start of range
  lineNumber = 1;
  for (idx = 0; idx < start;) {
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    lineNumber += [NSAttributedString lineCountForLine:[attStr attributedSubstringFromRange:lineRange]];
		idx = NSMaxRange(lineRange);
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
      MHCodeFolder *attFolder = [att valueForKey:@"object"];
      if (attFolder) {
        lineNumber += attFolder.lineCount;
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
  NSMutableArray *lines = [NSMutableArray array];
  
  NSUInteger start = aRange.location;
  NSUInteger stop = start + aRange.length;
  NSString *text = [self.textView string];
  NSAttributedString *attStr = [textView attributedString];
  
  // go forwards from the start until we reach the start of the visible range
  NSUInteger idx;
  NSUInteger lineNumber = 1;
  NSRange lineRange;
  for (idx = 0; idx < start;) {
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    lineNumber += [NSAttributedString lineCountForLine:[attStr attributedSubstringFromRange:lineRange]];
		idx = NSMaxRange(lineRange);
	}
  
  // now loop over the visible range and collect line numbers
  MHLineNumber *line;
  while (idx < stop)
  {
    // get the range of the current line
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    // make a line object with the given number and starting index
    line = [MHLineNumber lineNumberWithValue:lineNumber index:lineRange.location range:lineRange];    
    [lines addObject:line];
    
    // Get an attributed version of this line
    NSAttributedString *attLine = [attStr attributedSubstringFromRange:lineRange];    
    // Get a line count for this line of text.
    lineNumber+=[NSAttributedString lineCountForLine:attLine];
    
    // move on to the next line
		idx = NSMaxRange(lineRange);
  }

//  NSLog(@"idx=%ld, text length = %ld", idx, [text length]);
  
//  if ([text length]>0) {
//    NSLog(@"Last char %c", [text characterAtIndex:[text length]-1]);
//  }
  
  // check if we have a newline right at the end
  if (idx>0 && idx <= [text length] && [text length]>0) {
    if ([newLineCharacterSet characterIsMember:[text characterAtIndex:idx-1]]) {
//      NSLog(@"Last character is newline");
      line = [MHLineNumber lineNumberWithValue:lineNumber index:idx range:[text lineRangeForRange:NSMakeRange(idx, 0)]];    
      [lines addObject:line];
    }
  }
  
//  NSLog(@"%@ Made lines %@", self, lines);
  return [NSArray arrayWithArray:lines];
}




// Compute the required thickness of the ruler.
- (CGFloat)requiredThickness
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL includeLineNumbers = [[defaults valueForKey:TEShowLineNumbers] boolValue];
	BOOL includeCodeFolders = [[defaults valueForKey:TEShowCodeFolders] boolValue];
  
	if (!includeLineNumbers) {
		if (!includeCodeFolders)
			return 1.0;
		
		return ceilf(kFOLDING_GUTTER);
	}
	
	NSUInteger			lineCount, digits, i;
	NSSize              stringSize;
	
  NSInteger idx = [[self.textView string] length];
	lineCount = [[[self lineNumbersForTextRange:NSMakeRange(idx, 0)] lastObject] number];
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
	if (includeCodeFolders)
		foldWidth = kFOLDING_GUTTER;
	
	return ceilf(MAX(kDEFAULT_THICKNESS, stringSize.width + kRULER_MARGIN * 2 + foldWidth));
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
		[self setNeedsDisplay:YES];
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
	id view = [self clientView];
	if ([view isKindOfClass:[NSTextView class]]) {
		if (aFolder) {
			if (aFolder.folded) {
        if ([self.textView respondsToSelector:@selector(unfoldTextWithFolder:)]) {
          [self.textView performSelector:@selector(unfoldTextWithFolder:) withObject:aFolder];
          aFolder.folded = NO;
        }
			} else {
        if ([self.textView respondsToSelector:@selector(foldTextWithFolder:)]) {
          [self.textView performSelector:@selector(foldTextWithFolder:) withObject:aFolder];
          aFolder.folded = YES;
        }
      }
    }
  }
	[self setNeedsDisplay:YES];
}

- (MHLineNumber*)lineNumberContainingIndex:(NSInteger)anIndex
{
  NSLog(@"%@ Searching lines %@", self, self.lineNumbers);
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
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	MHCodeFolder *folder = [self folderForPoint:clickPoint];
//  NSLog(@"Clicked on %@", folder);
  [self resetLineNumbers];
	[self toggleFoldedStateForFolder:folder];
  [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  wasAcceptingMouseEvents = [[self window] acceptsMouseMovedEvents];
  [[self window] setAcceptsMouseMovedEvents:YES];
  [[self window] makeFirstResponder:self];
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  MHCodeFolder *folder = [self folderForPoint:point];
  if (folder) {
//    NSLog(@"%@", folder);
    // set highlight rect on textview
    NSRange r = NSMakeRange(folder.startIndex, folder.endIndex-folder.startIndex+1);
    [[self textView] setHighlightRange:NSStringFromRange(r)];
    [[self textView] setNeedsDisplay:YES];
  }
  
  [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent 
{
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  MHCodeFolder *folder = [self folderForPoint:point];
  if (folder) {
    // set highlight rect on textview
    NSRange r = NSMakeRange(folder.startIndex, folder.endIndex-folder.startIndex+1);
    [[self textView] setHighlightRange:NSStringFromRange(r)];
    [[self textView] setNeedsDisplay:YES];
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
  [[self window] setAcceptsMouseMovedEvents:wasAcceptingMouseEvents];
  [[self textView] clearHighlight];
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Attributes

- (NSDictionary *)textAttributes
{
  if (!self.textAttributesDictionary) {
    
    self.textAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                      self.font, NSFontAttributeName, 
                      self.textColor, NSForegroundColorAttributeName,
                      nil];
    
  }
  
  return self.textAttributesDictionary;
}

@end
