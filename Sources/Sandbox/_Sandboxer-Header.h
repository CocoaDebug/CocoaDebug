//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#ifndef _Sandboxer_Header_h
#define _Sandboxer_Header_h

#define _IsStringEmpty(string)                    (nil == string || (NSNull *)string == [NSNull null] || [@"" isEqualToString:string])
#define _IsStringNotEmpty(string)                 (string && (NSNull *)string != [NSNull null] && ![@"" isEqualToString:string])


#endif /* _Sandboxer_Header_h */
