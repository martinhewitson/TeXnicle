//
//  MHSynctexController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHSynctexController.h"

@implementation MHSynctexController
@synthesize textView;
@synthesize pdfViews;

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

- (void) dealloc
{
  self.textView = nil;
  self.pdfViews = nil;
  [super dealloc];
}

- (void) displaySelectionInPDFFile:(NSString*)pdfpath sourceFile:(NSString*)sourcepath lineNumber:(NSInteger)lineNumber column:(NSInteger)column
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
            if (pageIndex < [pdfDoc pageCount]) {
              PDFPage *page = [pdfDoc pageAtIndex:pageIndex];
              y = NSMaxY([page boundsForBox:kPDFDisplayBoxMediaBox]) - y;
              NSPoint point = NSMakePoint(x, y);
              [pdfView displayLineAtPoint:point inPageAtIndex:pageIndex];
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
          return [NSString stringWithCString:file encoding:NSUTF8StringEncoding];
        }
      }
    }
    
    // free scanner
    synctex_scanner_free(scanner);  
  }
  
  return nil;
}


@end
