//
//  TPFoldedCodeSnippet.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TPFoldedCodeSnippet : NSTextAttachment {

	NSString *code;
	id object;
	
}

@property (readwrite, assign) NSString *code;
@property (readwrite, retain) id object;

- (id) initWithCode:(NSAttributedString*)aString;

@end
