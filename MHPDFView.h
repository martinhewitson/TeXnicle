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

@interface MHPDFView : PDFView


- (void)performFindPanelAction:(id)sender;


@end
