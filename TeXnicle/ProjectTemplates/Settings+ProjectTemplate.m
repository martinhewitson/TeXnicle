//
//  Settings+ProjectTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
