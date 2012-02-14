//
//  MHSynctexController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "synctex_parser.h"
#import "TeXTextView.h"
#import "MHPDFView.h"

@interface MHSynctexController : NSObject {
@private
  TeXTextView *textView;
  NSMutableArray *pdfViews;
}

@property (retain) TeXTextView *textView;
@property (retain) NSMutableArray *pdfViews;

- (id) initWithEditor:(TeXTextView*)aTextView pdfViews:(NSArray*)pdfViewArray;


- (void) displaySelectionInPDFFile:(NSString*)pdfpath sourceFile:(NSString*)sourcepath lineNumber:(NSInteger)lineNumber column:(NSInteger)column;
- (NSString*) sourceFileForPDFFile:(NSString*)pdfpath lineNumber:(NSInteger*)line pageIndex:(NSInteger)pageIndex pageBounds:(NSRect)bounds point:(NSPoint)point;

@end
