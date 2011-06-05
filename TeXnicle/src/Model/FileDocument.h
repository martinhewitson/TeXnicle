//
//  OpenDocument.h
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileDocument : NSObject {

	NSManagedObject *file;
	NSTextStorage *textStorage;
	NSUndoManager *undoManager;
	
}
@property (readwrite, assign) NSManagedObject *file;
@property (readwrite, assign) NSTextStorage *textStorage;
@property (readwrite, assign) NSUndoManager *undoManager;


- (id) initWithFile:(NSManagedObject*)aFile;
- (NSTextContainer*)textContainer;
- (BOOL) commitEdits;

@end
