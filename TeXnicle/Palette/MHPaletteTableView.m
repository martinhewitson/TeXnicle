//
//  MHPaletteTableView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHPaletteTableView.h"

@implementation MHPaletteTableView

- (IBAction) insertSelectedSymbols:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(insertSelectedSymbols:)]) {
    [self.delegate performSelector:@selector(insertSelectedSymbols:) withObject:self];
  }
}


@end
