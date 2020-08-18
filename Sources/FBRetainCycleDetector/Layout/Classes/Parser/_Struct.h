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

#import "_Type.h"

#import <memory>
#import <string>
#import <vector>

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  class _Struct: public _Type {
  public:
    const std::string struct_TypeName;
    
    _Struct(const std::string &name,
           const std::string &typeEncoding,
           const std::string &struct_TypeName,
           std::vector<std::shared_ptr<_Type>> &typesContainedInStruct)
    : _Type(name, typeEncoding),
      struct_TypeName(struct_TypeName),
    typesContainedInStruct(std::move(typesContainedInStruct)) {};
    _Struct(_Struct&&) = default;
    _Struct &operator=(_Struct&&) = default;
    
    _Struct(const _Struct&) = delete;
    _Struct &operator=(const _Struct&) = delete;
    
    std::vector<std::shared_ptr<_Type>> flatten_Types();
    
    virtual void pass_TypePath(std::vector<std::string> typePath);
    std::vector<std::shared_ptr<_Type>> typesContainedInStruct;
  };
} } }

#pragma clang diagnostic pop
