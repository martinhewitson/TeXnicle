//
//  MHPDFView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHPDFView.h"

@implementation MHPDFView


- (void)performFindPanelAction:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(findInPDF:)]) {
    [self.delegate performSelector:@selector(findInPDF:) withObject:self];
  }
}


@end
