//
//  Settings+ProjectTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "Settings+ProjectTemplate.h"
#import "ProjectEntity.h"
#import "FileEntity.h"

@implementation Settings (ProjectTemplate)

- (NSDictionary*)dictionary
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  [dict setObject:self.engineName forKey:@"engineName"];
  [dict setObject:self.doBibtex forKey:@"doBibtex"];
  [dict setObject:self.doPS2PDF forKey:@"doPS2PDF"];
  [dict setObject:self.nCompile forKey:@"nCompile"];
  [dict setObject:self.openConsole forKey:@"openConsole"];
  [dict setObject:self.showStatusBar forKey:@"showStatusBar"];
  [dict setObject:[self.project.mainFile pathRelativeToProject] forKey:@"mainfile"];
  
  return dict;
}

@end
