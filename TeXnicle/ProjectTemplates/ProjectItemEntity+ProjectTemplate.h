//
//  ProjectItemEntity+ProjectTemplate.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "ProjectItemEntity.h"

@interface ProjectItemEntity (ProjectTemplate)

- (void) writeContentsAndChildrenToURL:(NSURL*)aURL;

@end
