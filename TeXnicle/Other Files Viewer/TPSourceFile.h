//
//  TPSourceFile.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSourceItem.h"

@interface TPSourceFile : TPSourceItem

+ (TPSourceFile*)fileWithParent:(TPSourceItem*)aParent path:(NSURL*)aPath;

@end
