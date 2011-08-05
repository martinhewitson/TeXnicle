//
//  TPResultDocument.h
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileEntity;
@class TPDocumentMatch;

@interface TPResultDocument : NSObject {
@private
  FileEntity *document;
  NSMutableArray *matches;
}

@property (retain) FileEntity *document;
@property (retain) NSMutableArray *matches;
@property (readonly) NSAttributedString *displayString;
@property (readonly) NSAttributedString *selectedDisplayString;


+ (TPResultDocument*)resultWithDocuemnt:(FileEntity*)aDocument;
- (id)initWithDocument:(FileEntity*)aDocument;

- (void) addMatch:(TPDocumentMatch*)aMatch;

@end
