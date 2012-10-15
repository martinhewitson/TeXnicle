//
//  NSString+Reformatting.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Reformatting)



// reformat the given string for the suggested linewidth starting at the given index.
- (NSString*) reformatStartingAtIndex:(NSInteger)startPosition forLinewidth:(NSInteger)linewidth;



@end
