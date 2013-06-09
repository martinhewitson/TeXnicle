//
//  MHSynctexController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
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

#import "MHSynctexController.h"

@implementation MHSynctexController

- (id) initWithEditor:(TeXTextView*)aTextView pdfViews:(NSArray*)pdfViewArray;
{
  self = [super init];
  if (self) {
    self.textView = aTextView;
    self.pdfViews = [NSMutableArray array];
    [self.pdfViews addObjectsFromArray:pdfViewArray];
  }
  return self;
}

- (void) displaySelectionInPDFFile:(NSString*)pdfpath sourceFile:(NSString*)sourcepath lineNumber:(NSInteger)lineNumber column:(NSInteger)column
{
  [self displaySelectionInPDFFile:pdfpath sourceFile:sourcepath lineNumber:lineNumber column:column giveFocus:YES];
}

- (void) displaySelectionInPDFFile:(NSString*)pdfpath sourceFile:(NSString*)sourcepath lineNumber:(NSInteger)lineNumber column:(NSInteger)column
                         giveFocus:(BOOL)shouldFocus
{
  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:pdfpath]) {
    return;
  }
  
  synctex_scanner_t scanner = synctex_scanner_new_with_output_file([pdfpath cStringUsingEncoding:NSUTF8StringEncoding], NULL, 1);
  if (scanner != NULL) {
    //    synctex_scanner_display(scanner);
    if (synctex_display_query(scanner, [sourcepath cStringUsingEncoding:NSUTF8StringEncoding], (int)lineNumber, (int)column) > 0) {
      synctex_node_t node = synctex_next_result(scanner);
      if (node) {
        NSUInteger page = synctex_node_page(node);
        NSInteger pageIndex = MAX(page, 1u) - 1;
        
        float x = synctex_node_visible_h(node);
        float y = synctex_node_visible_v(node);
        
        for (MHPDFView *pdfView in self.pdfViews) {
          if ([pdfView document]) {
            PDFDocument *pdfDoc = [pdfView document];
            if (pdfDoc) {
              if (pageIndex < [pdfDoc pageCount]) {
                PDFPage *page = [pdfDoc pageAtIndex:pageIndex];
                y = NSMaxY([page boundsForBox:kPDFDisplayBoxMediaBox]) - y;
                NSPoint point = NSMakePoint(x, y);
                [pdfView displayLineAtPoint:point inPageAtIndex:pageIndex giveFocus:shouldFocus];
                [pdfView displayLineAtPoint:point inPageAtIndex:pageIndex giveFocus:shouldFocus];
              }
            }
          }
        }
      }
    }
    // free scanner
    synctex_scanner_free(scanner);  
  }
}

- (NSString*) sourceFileForPDFFile:(NSString*)pdfpath lineNumber:(NSInteger*)line pageIndex:(NSInteger)pageIndex pageBounds:(NSRect)bounds point:(NSPoint)point
{
  synctex_scanner_t scanner = synctex_scanner_new_with_output_file([pdfpath cStringUsingEncoding:NSUTF8StringEncoding], NULL, 1);
  if (scanner != NULL) {
    
    if (synctex_edit_query(scanner, (int)pageIndex + 1, point.x, NSMaxY(bounds) - point.y) > 0) {
      synctex_node_t node;
      const char *file;
      while ((node = synctex_next_result(scanner))) {
        if ((file = synctex_scanner_get_name(scanner, synctex_node_tag(node)))) {
          *line = MAX(synctex_node_line(node), 1);
          return @(file);
        }
      }
    }
    
    // free scanner
    synctex_scanner_free(scanner);  
  }
  
  return nil;
}


@end
