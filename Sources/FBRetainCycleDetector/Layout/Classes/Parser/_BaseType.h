//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <string>

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  class _BaseType {
  public:
    virtual ~_BaseType() {}
  };
  
  class Unresolved: public _BaseType {
  public:
    std::string value;
    Unresolved(std::string value): value(value) {}
    Unresolved(Unresolved&&) = default;
    Unresolved &operator=(Unresolved&&) = default;
    
    Unresolved(const Unresolved&) = delete;
    Unresolved &operator=(const Unresolved&) = delete;
  };
} } }
