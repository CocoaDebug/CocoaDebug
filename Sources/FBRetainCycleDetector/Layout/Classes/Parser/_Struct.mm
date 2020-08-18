//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_Struct.h"

#import <algorithm>

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  void _Struct::pass_TypePath(std::vector<std::string> typePath) {
    this->typePath = typePath;
    
    if (name.length() > 0) {
      typePath.emplace_back(name);
    }
    if (struct_TypeName.length() > 0 && struct_TypeName != "?") {
      typePath.emplace_back(struct_TypeName);
    }
    
    for (auto &type: typesContainedInStruct) {
      type->pass_TypePath(typePath);
    }
  }
  
  std::vector<std::shared_ptr<_Type>> _Struct::flatten_Types() {
    std::vector<std::shared_ptr<_Type>> flattened_Types;
    
    for (const auto &type:typesContainedInStruct) {
      const auto maybe_Struct = std::dynamic_pointer_cast<_Struct>(type);
      if (maybe_Struct) {
        // Complex type, recursively grab all references
        flattened_Types.reserve(flattened_Types.size() + std::distance(maybe_Struct->typesContainedInStruct.begin(),
                                                                     maybe_Struct->typesContainedInStruct.end()));
        flattened_Types.insert(flattened_Types.end(),
                              maybe_Struct->typesContainedInStruct.begin(),
                              maybe_Struct->typesContainedInStruct.end());
      } else {
        // Simple type
        flattened_Types.emplace_back(type);
      }
    }
    
    return flattened_Types;
  }
  
} } }
