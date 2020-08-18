//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_Struct.h"
#import "_Type.h"

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  
  /**
   This function will parse a struct encoding from an ivar, and return an _FBParsed_Struct instance.
   Check _FBParsed_Struct to learn more on how to interact with it.
   
   _FBParse_StructEncoding assumes the string passed to it will be a proper struct encoding.
   It will work with encodings provided by ivars (ivar_getTypeEncoding)
   */
  _Struct parse_StructEncoding(const std::string &structEncodingString);
  
  
  /**
   You can provide name for root struct you are passing. The name will be then used
   in typePath (check out _FBParsed_Type for details).
   The name here can be for example a name of an ivar with this struct.
   */
  _Struct parse_StructEncodingWithName(const std::string &structEncodingString,
                                     const std::string &structName);
  
  
} } }
