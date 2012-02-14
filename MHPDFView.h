//
//  MHPDFView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Quartz/Quartz.h>

extern NSString * const MHPDFViewDidGainFocusNotification;
extern NSString * const MHPDFViewDidLoseFocusNotification;

@class MHPDFView;

@protocol MHPDFViewDelegate <NSObject>

- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint;

@end

@interface MHPDFView : PDFView {
@private
  id<MHPDFViewDelegate> delegate;
}

@property (assign) IBOutlet id<MHPDFViewDelegate> delegate;

- (void)performFindPanelAction:(id)sender;
- (void)setNeedsDisplayInRect:(NSRect)rect ofPage:(PDFPage *)page;

- (void)displayLineAtPoint:(NSPoint)point inPageAtIndex:(NSUInteger)pageIndex;


@end
