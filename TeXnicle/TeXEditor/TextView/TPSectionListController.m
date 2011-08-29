//
//  TPSectionListController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPSectionListController.h"
#import "NSString+LaTeX.h"
#import "RegexKitLite.h"
#import "NSString+Extension.h"
#import "Bookmark.h"
#import "NSAttributedString+LineNumbers.h"

NSString *TPsectionListPopupTitle = @"Jump to section...";

@implementation TPSectionListController

@synthesize timer;
@synthesize delegate;

- (id) init
{
	self = [super init];
	if (self) {
		
		sections = [[NSMutableArray alloc] init];
		
		[sections addObject:@"\\\\section"];
		[sections addObject:@"\\\\subsection"];
		[sections addObject:@"\\\\subsubsection"];
		[sections addObject:@"\\\\paragraph"];
		[sections addObject:@"\\\\subparagraph"];
		[sections addObject:@"\\\\part"];
		[sections addObject:@"\%\%MARK"];
		[sections addObject:@"\%\%FIGURE"];
		[sections addObject:@"\%\%TABLE"];
		[sections addObject:@"\%\%LIST"];
		[sections addObject:@"\%\%EQUATION"];
		[sections addObject:@"\\@.*\\{"];
		
	}
	return self;
}

- (void) awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(calculateSections:)
						 name:NSPopUpButtonWillPopUpNotification
					 object:popupMenu];

	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
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
	[item release];		
	
	// FIGURE 
	item = [[NSMenuItem alloc] initWithTitle:@"FIGURE"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	[item release];		
	
	// TABLE 
	item = [[NSMenuItem alloc] initWithTitle:@"TABLE"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	[item release];		
	
	// LIST 
	item = [[NSMenuItem alloc] initWithTitle:@"LIST"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	[item release];		
	
	// EQUATION 
	item = [[NSMenuItem alloc] initWithTitle:@"EQUATION"
																		action:@selector(addSelectedMarker:)
														 keyEquivalent:@""];
	[item setTarget:self];
	[addMarkerActionMenu addItem:item];
	[item release];		
}


- (void) deactivate
{
//	NSLog(@"Deactivate TPSectionListController");
	[self.timer invalidate];
}

- (void) dealloc
{
  NSLog(@"TPSectionListController dealloc");
  self.timer = nil;
	[addMarkerActionMenu release];
	[sections release];
	[super dealloc];
}

#pragma mark -
#pragma mark Control  

- (void) addSelectedMarker:(id)sender
{
	NSString *prefix = @"\%\%";
	[textView insertText:[[prefix stringByAppendingString:[sender title]] stringByAppendingString:@" "]];
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
	if (!popupMenu) {
//    NSLog(@"No popupMenu");
		return;
  }
	
	if (!textView) {
//    NSLog(@"No textView");
		return;
  }

	if (!timer) {
//    NSLog(@"No timer");
		return;
  }
	
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSMutableArray *found = [NSMutableArray array];
	
	NSString *string = [textView string];
	if (!string || [string isEqual:@""]) {   
//    NSLog(@"String empty");
		[popupMenu removeAllItems];		
    [self addTitle];
    [popupMenu setNeedsDisplay:YES];
		return;
	}
	
//  NSLog(@"String not empty");
  
	// look for each section tag
  BOOL isMarker = NO;
	for (NSString *tag in sections) {
		NSString *regexp;
		if ([tag isEqual:@"%%MARK"] || 
				[tag isEqual:@"%%FIGURE"] || 
				[tag isEqual:@"%%TABLE"] || 
				[tag isEqual:@"%%LIST"] || 
				[tag isEqual:@"%%EQUATION"]) {
			regexp = [NSString stringWithFormat:@"%@.*(\\n)", tag];
      isMarker = YES;
		} else {
			// we have a TeX section
			regexp = [NSString stringWithFormat:@"%@[\\*]?\\{.*\\}", tag];
		}
		
		NSArray *results = [string componentsMatchedByRegex:regexp];
//    NSLog(@"Scan results for %@:  %@", regexp, results);
		NSScanner *aScanner = [NSScanner scannerWithString:string];
		if ([results count] > 0) {			
			for (NSString *result in results) {
				NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
				returnResult = [returnResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [aScanner scanUpToString:returnResult intoString:NULL];
//        NSLog(@"Return result: %@", returnResult);
        NSRange lineRange = [string lineRangeForRange:NSMakeRange([aScanner scanLocation], 0)];
//        NSLog(@"Scanner location %ld", [aScanner scanLocation]);
//        NSLog(@"Sub string %@", [string substringWithRange:lineRange]);
        if (![[string substringWithRange:lineRange] containsCommentCharBeforeIndex:[aScanner scanLocation]] || isMarker) {
          NSString *type = [tag stringByReplacingOccurrencesOfString:@"\\" withString:@""];
          NSString *arg = [returnResult stringByReplacingOccurrencesOfString:type withString:@""];
          type = [type stringByReplacingOccurrencesOfString:@"%%" withString:@""];
          type = [type uppercaseString];
          arg = [arg stringByReplacingOccurrencesOfString:@"\\" withString:@""];
          arg = [arg stringByReplacingOccurrencesOfString:@"{" withString:@""];
          arg = [arg stringByReplacingOccurrencesOfString:@"}" withString:@""];
          NSString *disp = [NSString stringWithFormat:@"%@: %@", type, arg];
          NSMutableAttributedString *adisp = [[NSMutableAttributedString alloc] initWithString:disp];
          [adisp addAttribute:NSForegroundColorAttributeName
                        value:[NSColor lightGrayColor]
                        range:NSMakeRange(0, [type length]+1)];
          [adisp addAttribute:NSForegroundColorAttributeName
                        value:[NSColor darkGrayColor]
                        range:NSMakeRange([type length]+1, [disp length]-[type length]-1)];
          
          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          [dict setObject:adisp forKey:@"title"];
          [dict setObject:[NSNumber numberWithInteger:[aScanner scanLocation]] forKey:@"index"];
          [found addObject:dict];
          [adisp release];				
        }
			} // end loop over results
		} // end if [results count] > 0
	}
	
	// add bib items
	NSString *regexp = @"\\@.*\\{.*,";
	NSArray *searchResults = [string componentsMatchedByRegex:regexp];
//  NSLog(@"Bib search results: %@", searchResults);
	NSScanner *aScanner = [NSScanner scannerWithString:string];
	if ([searchResults count] > 0) {			
		for (NSString *result in searchResults) {
			NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
			returnResult = [returnResult stringByTrimmingCharactersInSet:ws];			
			[aScanner scanUpToString:returnResult intoString:NULL];			
			int loc = 0;
			int tagEnd = -1;			
			while (loc < [returnResult length]) {				
				if ([returnResult characterAtIndex:loc]=='{') {
					tagEnd = loc;
					break;
				}
				loc++;
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
			
			NSString *arg = [returnResult substringWithRange:NSMakeRange(tagStart+1, tagEnd-tagStart-1)];
			arg = [arg stringByTrimmingCharactersInSet:ws];
			NSString *disp = [NSString stringWithFormat:@"%@: %@", type, arg];
			NSMutableAttributedString *adisp = [[NSMutableAttributedString alloc] initWithString:disp];
			[adisp addAttribute:NSForegroundColorAttributeName
										value:[NSColor lightGrayColor]
										range:NSMakeRange(0, [type length])];
			
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setObject:adisp forKey:@"title"];
			[dict setObject:[NSNumber numberWithInteger:[aScanner scanLocation]] forKey:@"index"];
			[found addObject:dict];
			[adisp release];				
		}
	}
	
	// sort items by index
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *results = [found sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];	
	NSMutableArray *current = [NSMutableArray array];
	for (NSMenuItem *item in [popupMenu itemArray]) {
    
    // skip the placeholder
    NSString *title = [item title];
//    NSLog(@"Checking %@ %@==%@", title, [title class], [TPsectionListPopupTitle class]);
    if ([title isEqual:TPsectionListPopupTitle]) {
      continue;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[item title] forKey:@"title"];
    [dict setObject:[NSNumber numberWithInteger:[item tag]] forKey:@"index"];
    [current addObject:dict];
	}
	
	BOOL sameMenu = YES;
	sameMenu = ([current count] == [results count]);
	if (sameMenu) {
		// compare contents
		int jj=0;
		for (NSDictionary *cdict in current) {
			NSDictionary *rdict = [results objectAtIndex:jj];
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
		
//		NSLog(@"Different menu");
//    NSLog(@"Results: %@", results);
		// can we return to the same selection?
//		NSString *selectedTitle = [[popupMenu selectedItem] title];
//		NSInteger selectedTag   = [[popupMenu selectedItem] tag];
		
		[popupMenu removeAllItems];		
    [self addTitle];
		for (NSDictionary *result in results) {
			[popupMenu addItemWithTitle:@"foo"];
			[[popupMenu lastItem] setAttributedTitle:[result valueForKey:@"title"]];
			[[popupMenu lastItem] setTag:[[result valueForKey:@"index"] intValue]];
		}
    
    // add bookmarks
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookmarksForCurrentFile)]) {      
      NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"linenumber" ascending:YES]];
      NSArray *bookmarks = [[self.delegate bookmarksForCurrentFile] sortedArrayUsingDescriptors:descriptors];
      for (Bookmark *b in bookmarks) {
        NSAttributedString *str = b.displayString;
        [popupMenu addItemWithTitle:[str string]];
        [[popupMenu lastItem] setAttributedTitle:str];
        NSInteger linenumber = [[textView attributedString] indexForLineNumber:[b.linenumber integerValue]];
        [[popupMenu lastItem] setTag:linenumber];
      }
    }
    
    
//    NSLog(@"Menus %@", [popupMenu itemArray]);
    [popupMenu selectItemAtIndex:0];
    
    
    
		    
//		if (![popupMenu selectItemWithTag:selectedTag]) {
//			[popupMenu selectItemWithTitle:selectedTitle];
//		}		
	}
	
	[desc release];		
}

- (void) addTitle
{
  [popupMenu setTitle:TPsectionListPopupTitle];
  [popupMenu addItemWithTitle:TPsectionListPopupTitle];
  
  NSMutableAttributedString *titleString = [[[NSMutableAttributedString alloc] initWithString:@"Jump to section..."] autorelease];
  [titleString addAttribute:NSForegroundColorAttributeName
                      value:[NSColor lightGrayColor]
                      range:NSMakeRange(0, [titleString length])];
  
  [[popupMenu lastItem] setAttributedTitle:titleString];
  [[popupMenu lastItem] setTag:0];
}

- (IBAction)calculateSections:(id)sender
{
	[self fillSectionMenu];
}

- (IBAction) gotoSection:(id)sender
{
	// now get the selected
	NSMenuItem *selected = [popupMenu selectedItem];
//	[selected setState:NSOnState];
	NSUInteger tag = [selected tag];
	NSRange tagRange = NSMakeRange(tag, 0);
	[textView setSelectedRange:tagRange];
	[textView selectLine:self];
	[textView scrollRangeToVisible:tagRange];
  [self fillSectionMenu];
  
  [[textView window] makeFirstResponder:textView];
  [popupMenu selectItemAtIndex:0];
}

@end
