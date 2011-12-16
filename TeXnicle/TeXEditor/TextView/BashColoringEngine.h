//
//  BashColoringEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"TeXColoringEngine.h"

@interface BashColoringEngine : TeXColoringEngine {
@private
  NSArray *keywords;
}

@property (retain) NSArray *keywords;

@end
