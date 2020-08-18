//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdefaulted-function-deleted"

#import <Foundation/Foundation.h>

#import <memory>
#import <string>
#import <vector>

#import "_BaseType.h"

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  class _Type: public _BaseType {
  public:
    const std::string name;
    const std::string typeEncoding;
    
    _Type(const std::string &name,
         const std::string &typeEncoding): name(name), typeEncoding(typeEncoding) {}
    _Type(_Type&&) = default;
    _Type &operator=(_Type&&) = default;
    
    _Type(const _Type&) = delete;
    _Type &operator=(const _Type&) = delete;
    
    virtual void pass_TypePath(std::vector<std::string> typePath) {
      this->typePath = typePath;
    }
    
    std::vector<std::string> typePath;
  };
} } }

#pragma clang diagnostic pop
