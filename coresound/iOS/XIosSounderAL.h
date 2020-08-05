//
//  XIosSounder.h
//  XSound
//
//  Created by Oogh on 2020/07/06.
//  Copyright © 2020 Oogh. All rights reserved.
//

#ifndef XIosSounderAL_h
#define XIosSounderAL_h

@interface XIosSounderAL : NSObject

- (void)setInput:(NSString*)filename;

- (void)start;

- (void)stop;

@end

#endif /* XIosSounderAL_h */
