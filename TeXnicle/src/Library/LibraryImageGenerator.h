//
//  LibraryImageGenerator.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LibraryController.h"

extern NSString * const TPLibraryImageGeneratorTaskDidFinishNotification;

@interface LibraryImageGenerator : NSObject {

	NSMutableDictionary *symbol;
	BOOL mathMode;
	LibraryController *controller;
	
}

- (id) initWithSymbol:(NSMutableDictionary*)aSymbol mathMode:(BOOL)mode andController:(LibraryController*)aController;

@property (readwrite, assign) NSMutableDictionary *symbol;
@property (readwrite, assign) BOOL mathMode;

@end
