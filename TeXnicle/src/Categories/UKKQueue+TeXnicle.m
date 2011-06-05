//
//  UKKQueue+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/12/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "UKKQueue+TeXnicle.h"


@implementation UKKQueue (TeXnicle)

- (BOOL) watchingPath:(NSString*)aPath
{
	int idx = [watchedPaths indexOfObject: aPath];
	//NSLog(@"Watching %d", idx);
	return idx >= 0;
}

@end
