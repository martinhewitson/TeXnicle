//
//  TPSectionListController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "TPSectionListController.h"
#import "NSString+LaTeX.h"
#import "NSString+Extension.h"
#import "Bookmark.h"
#import "NSAttributedString+LineNumbers.h"
#import "TPRegularExpression.h"
#import "TPSectionListSection.h"
#import "externs.h"
#import "NSArray+Color.h"

NSString *TPsectionListPopupTitle = @"Jump to section...";

@interface TPSectionListController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TPSectionListController

- (id) initWithDelegate:(id<TPSectionListControllerDelegate>)aDelegate
{
  self = [self init];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (id) init
{
	self = [super init];
	if (self) {
		
    whiteSpace = [NSCharacterSet whitespaceCharacterSet];
    newlines = [NSCharacterSet newlineCharacterSet];
    
		sections = [[NSMutableArray alloc] init];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\section" isTeX:YES color:[[defaults valueForKey:TPOutlineSectionColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\subsection" isTeX:YES color:[[defaults valueForKey:TPOutlineSubsectionColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\subsubsection" isTeX:YES color:[[defaults valueForKey:TPOutlineSubsubsectionColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\paragraph" isTeX:YES color:[[defaults valueForKey:TPOutlineParagraphColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\subparagraph" isTeX:YES color:[[defaults valueForKey:TPOutlineSubparagraphColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\part" isTeX:YES color:[[defaults valueForKey:TPOutlinePartColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\\\chapter" isTeX:YES color:[[defaults valueForKey:TPOutlineChapterColor] colorValue]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\\@.*\\{" isTeX:YES color:[NSColor magentaColor]]];

    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\%\%MARK" isTeX:NO isMarker:YES color:[NSColor lightGrayColor]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\%\%FIGURE" isTeX:NO isMarker:YES color:[NSColor lightGrayColor]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\%\%TABLE" isTeX:NO isMarker:YES color:[NSColor lightGrayColor]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\%\%LIST" isTeX:NO isMarker:YES color:[NSColor lightGrayColor]]];
    [sections addObject:[[TPSectionListSection alloc] initWithTag:@"\%\%EQUATION" isTeX:NO isMarker:YES color:[NSColor lightGrayColor]]];
    
	}
	return self;
}

- (void) tearDown
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  whiteSpace = nil;
  newlines = nil;
  [self.timer invalidate];
  self.timer = nil;
  self.textView = nil;
  self.popupMenu = nil;
  self.delegate = nil;
}


- (void) setup
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(calculateSections:)
						 name:NSPopUpButtonWillPopUpNotification
					 object:self.popupMenu];

	self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                target:self
                                              selector:@selector(fillSectionMenu)
                                              userInfo:nil
                                               repeats:YES];
	
	[self fillSectionMenu];
	[self createMarkerMenu];
  [self addTitle];
}

- (void) createMarkerMenu
{
	// Make popup menu with bound actions
	addMarkerActionMenu = [[NSMenu alloc] initWithTitle:@"Add Marker Action Menu"];	
	[addMarkerActionMenu setAutoenablesItems:YES];
	
	// MARK
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"MARK"
																								action:@selector(addSelectedMarker:)
																				 keyEquivalent:@""];
	[item setTarget:self];
	[item setEnabled:YES];
	[addMarkerActionMenu addItem:item];
	
	// FIGURE 
	item = [[NSMenuItem alloc] initWithTitle:@"FIGURE"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	
	// TABLE 
	item = [[NSMenuItem alloc] initWithTitle:@"TABLE"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	
	// LIST 
	item = [[NSMenuItem alloc] initWithTitle:@"LIST"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	
	// EQUATION 
	item = [[NSMenuItem alloc] initWithTitle:@"EQUATION"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
}


- (void) deactivate
{
//	NSLog(@"Deactivate TPSectionListController");
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
//  NSLog(@"Dealloc TPSectionListController");
  [self deactivate];

}

#pragma mark -
#pragma mark Control  

- (void) addSelectedMarker:(id)sender
{
	NSString *prefix = @"\%\%";
	[self.textView insertText:[[prefix stringByAppendingString:[sender title]] stringByAppendingString:@" "]];
}

- (IBAction) addMarkAction:(id)sender
{
	
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
		
	[NSMenu popUpContextMenu:addMarkerActionMenu withEvent:event forView:(NSButton *)sender];
	
	
}


- (void)fillSectionMenu
{
  if (![NSApp isActive]) {
    return;
  }
  
	if (!_popupMenu) {
//    NSLog(@"No popupMenu");
		return;
  }
	
	if (!_textView) {
//    NSLog(@"No textView");
		return;
  }

	if (!_timer) {
//    NSLog(@"No timer");
		return;
  }
	
	NSMutableArray *found = [NSMutableArray array];
	
	NSString *string = [self.textView string];
	if (string == nil || [string length] == 0) {   
//    NSLog(@"String empty");
		[self.popupMenu removeAllItems];		
    [self addTitle];
    [self.popupMenu setNeedsDisplay:YES];
		return;
	}
	
//  NSLog(@"String not empty");
  
	// look for each section tag
	for (TPSectionListSection *section in sections) {
    NSString *tag = section.tag;
		NSString *regexp = section.regexp;
    BOOL isMarker = section.isMarker;
		
    NSArray *results = [TPRegularExpression rangesMatching:regexp inText:string];
    //NSLog(@"Scan results for %@:  %@", regexp, results);
		if ([results count] > 0) {
			for (NSValue *rv in results) {
        NSRange r = [rv rangeValue];
        NSString *result = [string substringWithRange:r];
				NSString *returnResult = [result stringByTrimmingCharactersInSet:newlines];
				returnResult = [returnResult stringByTrimmingCharactersInSet:whiteSpace];
//        NSLog(@"Return result: %@", returnResult);
        NSRange lineRange = [string lineRangeForRange:NSMakeRange(r.location, 0)];
//        NSRange lineRange = [string lineRangeForRange:NSMakeRange([aScanner scanLocation], 0)];
//        NSLog(@"Scanner location %ld", [aScanner scanLocation]);
//        NSLog(@"Sub string %@", [string substringWithRange:lineRange]);
        if (![[string substringWithRange:lineRange] containsCommentCharBeforeIndex:r.location] || isMarker) {
          NSString *type = [tag stringByReplacingOccurrencesOfString:@"\\" withString:@""];
          NSString *arg = [returnResult argument];
          if (arg == nil) {
            // just take the rest of the line
            NSRange typeRange = [returnResult rangeOfString:type];
            if (typeRange.location != NSNotFound && typeRange.length > 0) {
              arg = [returnResult stringByReplacingCharactersInRange:typeRange withString:@""];
            }
          }
          
          type = [type stringByReplacingOccurrencesOfString:@"%%" withString:@""];
          type = [type uppercaseString];
          arg = [arg stringByReplacingOccurrencesOfString:@"\\" withString:@""];
          NSString *disp = [NSString stringWithFormat:@"%@: %@", type, arg];
          NSMutableAttributedString *adisp = [[NSMutableAttributedString alloc] initWithString:disp];
          [adisp addAttribute:NSForegroundColorAttributeName
                        value:section.color
                        range:NSMakeRange(0, [type length]+1)];
          
          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          dict[@"title"] = adisp;
          dict[@"index"] = [NSNumber numberWithInteger:r.location];
          [found addObject:dict];
        }
			} // end loop over results
		} // end if [results count] > 0
	}
	
	// add bib items
	NSString *regexp = @"\\@.*\\{.*,";
  NSArray *ranges = [TPRegularExpression rangesMatching:regexp inText:string];
//  NSLog(@"Bib search results: %@", searchResults);
	if ([ranges count] > 0) {
		for (NSValue *rv in ranges) {
      NSRange r = [rv rangeValue];
      NSString *result = [string substringWithRange:r];
			NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
			returnResult = [returnResult stringByTrimmingCharactersInSet:whiteSpace];
			int loc = 0;
			int tagEnd = -1;			
			while (loc < [returnResult length]) {				
				if ([returnResult characterAtIndex:loc]=='{') {
					tagEnd = loc;
					break;
				}
				loc++;
			}	
      if (tagEnd < 1) {
        continue;
      }
			NSString *type = [returnResult substringWithRange:NSMakeRange(1, tagEnd-1)];
			type = [type uppercaseString];
			
			loc = tagEnd;
			int tagStart = tagEnd;
			tagEnd = -1;
			while (loc < [returnResult length]) {		
				if ([returnResult characterAtIndex:loc]==',') {
					tagEnd = loc;
					break;
				}
				loc++;
			}			
      if (tagEnd < 1) {
        continue;
      }
      
      if (tagEnd<=tagStart)
        continue;
			
			NSString *arg = [returnResult substringWithRange:NSMakeRange(tagStart+1, tagEnd-tagStart-1)];
			arg = [arg stringByTrimmingCharactersInSet:whiteSpace];
			NSString *disp = [NSString stringWithFormat:@"%@: %@", type, arg];
			NSMutableAttributedString *adisp = [[NSMutableAttributedString alloc] initWithString:disp];
			[adisp addAttribute:NSForegroundColorAttributeName
										value:[NSColor magentaColor]
										range:NSMakeRange(0, [type length])];
			
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			dict[@"title"] = adisp;
			dict[@"index"] = [NSNumber numberWithInteger:r.location];
			[found addObject:dict];
		}
	}
  
  // add bookmarks
  if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForCurrentFile)]) {      
    NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"linenumber" ascending:YES]];
    NSArray *bookmarks = [[self.delegate bookmarksForCurrentFile] sortedArrayUsingDescriptors:descriptors];
    for (Bookmark *b in bookmarks) {
      if (b.displayString != nil) {
        NSMutableAttributedString *str = [b.displayString mutableCopy];
        [str addAttribute:NSForegroundColorAttributeName
                    value:[NSColor blueColor]
                    range:NSMakeRange(0, [str length])];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"title"] = str;
        NSInteger index = [[self.textView attributedString] indexForLineNumber:[b.linenumber integerValue]];
        dict[@"index"] = @(index);
        [found addObject:dict];
      }
    }
  }
  
	
	// sort items by index
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *results = [found sortedArrayUsingDescriptors:@[desc]];	
	NSMutableArray *current = [NSMutableArray array];
	for (NSMenuItem *item in [self.popupMenu itemArray]) {
    
    // skip the placeholder
    NSString *title = [item title];
//    NSLog(@"Checking %@ %@==%@", title, [title class], [TPsectionListPopupTitle class]);
    if ([title isEqual:TPsectionListPopupTitle]) {
      continue;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"title"] = [item title];
    dict[@"index"] = @([item tag]);
    [current addObject:dict];
	}
	
	BOOL sameMenu = YES;
	sameMenu = ([current count] == [results count]);
	if (sameMenu) {
		// compare contents
		int jj=0;
		for (NSDictionary *cdict in current) {
			NSDictionary *rdict = results[jj];
			if (![[[rdict valueForKey:@"title"] string] isEqual:[cdict valueForKey:@"title"]]) {
				sameMenu = NO;
				break;
			}			
			if ([[rdict valueForKey:@"index"] intValue] != [[cdict valueForKey:@"index"] intValue]) {
				sameMenu = NO;
				break;
			}
			jj++;
		}		
	}
  
//  NSLog(@"Same menu? %d", sameMenu);
		
	if (!sameMenu) {
		
		[self.popupMenu removeAllItems];		
    [self addTitle];
		for (NSDictionary *result in results) {
			[self.popupMenu addItemWithTitle:@"foo"];
			[[self.popupMenu lastItem] setAttributedTitle:[result valueForKey:@"title"]];
			[[self.popupMenu lastItem] setTag:[[result valueForKey:@"index"] intValue]];
		}
    
    [self.popupMenu selectItemAtIndex:0];

	}
	
}

- (void) addTitle
{
  [self.popupMenu setTitle:TPsectionListPopupTitle];
  [self.popupMenu addItemWithTitle:TPsectionListPopupTitle];
  
  NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"Jump to section..."];
  [titleString addAttribute:NSForegroundColorAttributeName
                      value:[NSColor lightGrayColor]
                      range:NSMakeRange(0, [titleString length])];
  
  [[self.popupMenu lastItem] setAttributedTitle:titleString];
  [[self.popupMenu lastItem] setTag:0];
}

- (IBAction)calculateSections:(id)sender
{
	[self fillSectionMenu];
}

- (IBAction) gotoSection:(id)sender
{
	// now get the selected
	NSMenuItem *selected = [self.popupMenu selectedItem];
  if ([self.popupMenu indexOfItem:selected] == 0) {
    return;
  }
  
//	[selected setState:NSOnState];
	NSUInteger tag = [selected tag];
	NSRange tagRange = NSMakeRange(tag, 0);
	[self.textView setSelectedRange:tagRange];
	[self.textView selectLine:self];
	[self.textView scrollRangeToVisible:tagRange];
  [self fillSectionMenu];
  
  [[self.textView window] makeFirstResponder:self.textView];
  [self.popupMenu selectItemAtIndex:0];
}

@end
