//
//  TPDescriptionView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDescriptionView : NSView {
@private
  NSTextFieldCell *descriptionCell;
  NSString *descriptionText;
  NSColor *backgroundColor;
  NSColor *borderColor;
}

@property (retain) NSTextFieldCell *descriptionCell;
@property (copy) NSString *descriptionText;
@property (retain) NSColor *backgroundColor;
@property (retain) NSColor *borderColor;


@end
