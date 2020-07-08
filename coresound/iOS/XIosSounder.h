//
//  XIosSounder.h
//  XSound
//
//  Created by Oogh on 2020/07/06.
//  Copyright © 2020 Oogh. All rights reserved.
//

#ifndef XIosSounder_h
#define XIosSounder_h

@interface XIosSounder : NSObject

- (void)setInput:(NSString*)filename;

- (void)start;

- (void)stop;

@end

#endif /* XIosSounder_h */
