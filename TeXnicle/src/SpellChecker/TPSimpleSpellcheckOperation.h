//
//  TPSimpleSpellcheckOperation.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSimpleSpellcheckOperation : NSOperation {
  NSString *text;
  
  NSArray *words;
}

@property (copy) NSString *text;
@property (retain) NSArray *words;

- (id) initWithText:(NSString*)aString;

@end
