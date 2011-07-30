//
//  TPPopuplistView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TPPopuplistView : NSView {

	IBOutlet NSTableView *table;
	id delegate;
	
}

@property (readwrite, assign) id delegate;
- (void) listDoubleClick;

@end
