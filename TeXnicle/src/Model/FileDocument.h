//
//  OpenDocument.h
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileEntity;

@interface FileDocument : NSObject {

	FileEntity *file;
	NSTextStorage *textStorage;
	NSUndoManager *undoManager;
	
}
@property (readwrite, assign) NSManagedObject *file;
@property (readwrite, assign) NSTextStorage *textStorage;
@property (readwrite, assign) NSUndoManager *undoManager;


- (id) initWithFile:(FileEntity*)aFile;
- (NSTextContainer*)textContainer;
- (BOOL) commitEdits;

@end
