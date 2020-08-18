//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBStructEncodingParser.h"

#import <algorithm>
#import <memory>
#import <string>
#import <unordered_set>
#import <vector>

#import "_BaseType.h"

namespace {
  class _StringScanner {
  public:
    const std::string string;
    size_t index;
    
    _StringScanner(const std::string &string): string(string), index(0) {}
    
    bool scanString(const std::string &stringToScan) {
      if (!(string.compare(index, stringToScan.length(), stringToScan) == 0)) {
        return false;
      }
      index += stringToScan.length();
      return true;
    }
    
    const std::string scanUpToString(const std::string &upToString) {
      size_t pos = string.find(upToString, index);
      if (pos == std::string::npos) {
        // Mark as whole string scanned
        index = string.length();
        return "";
      }
      
      std::string inBetweenString = string.substr(index, pos - index);
      index = pos;
      return inBetweenString;
    }
    
    const char currentCharacter() {
      return string[index];
    }
    
    const std::string scanUpToCharacterFromSet(const std::string &characterSet) {
      size_t pos = string.find_first_of(characterSet, index);
      if (pos == std::string::npos) {
        index = string.length();
        return "";
      }
      
      std::string inBetweenString = string.substr(index, pos-index);
      index = pos;
      return inBetweenString;
    }
  };
  
};

namespace _FB { namespace RetainCycleDetector { namespace Parser {
  
  /**
   Intermediate struct object used inside the algorithm to pass some
   information when parsing nested structures.
   */
  struct __StructParseResult {
    std::vector<std::shared_ptr<_Type>> contained_Types;
    const std::string typeName;
  };
  
  static const auto kOpen_Struct = "{";
  static const auto kClose_Struct = "}";
  static const auto kLiteralEndingCharacters = "\"}";
  static const auto kQuote = "\"";
  
  static struct __StructParseResult _Parse_StructEncodingWithScanner(_StringScanner &scanner,
                                                                   NSString *debug_Struct) {
    std::vector<std::shared_ptr<_BaseType>> types;
    
    // Every struct starts with '{'
    __unused const auto scannedCorrectly = scanner.scanString(kOpen_Struct);
    NSCAssert(scannedCorrectly, @"The first character of struct encoding should be {; debug_struct: %@", debug_Struct);
    
    // Parse name
    const auto struct_TypeName = scanner.scanUpToString("=");
    scanner.scanString("=");
    
    while (!(scanner.scanString(kClose_Struct))) {
      if (scanner.scanString(kQuote)) {
        const auto parseResult = scanner.scanUpToString(kQuote);
        scanner.scanString(kQuote);
        if (parseResult.length() > 0) {
          types.push_back(std::make_shared<Unresolved>(parseResult));
        }
      } else if (scanner.currentCharacter() == '{') {
        // We do not want to consume '{' because we will call parser recursively
        const auto locBefore = scanner.index;
        auto parseResult = _Parse_StructEncodingWithScanner(scanner, debug_Struct);
        
        std::shared_ptr<Unresolved> valueFromBefore;
        if (!types.empty()) {
          valueFromBefore = std::dynamic_pointer_cast<Unresolved>(types.back());
          types.pop_back();
        }
        const auto extractedNameFromBefore = valueFromBefore ? valueFromBefore->value
                                                             : "";
        std::shared_ptr<_Struct> type = std::make_shared<_Struct>(extractedNameFromBefore,
                                                                scanner.string.substr(locBefore, (scanner.index - locBefore)),
                                                                parseResult.typeName,
                                                                parseResult.contained_Types);
        
        types.emplace_back(type);
      } else {
        // It's a type name (literal), let's advance until we find '"', or '}'
        const auto parseResult = scanner.scanUpToCharacterFromSet(kLiteralEndingCharacters);
        std::string nameFromBefore = "";
        if (types.size() > 0) {
          if (std::shared_ptr<Unresolved> maybeUnresolved = std::dynamic_pointer_cast<Unresolved>(types.back())) {
            nameFromBefore = maybeUnresolved->value;
            types.pop_back();
          }
        }
        std::shared_ptr<_Type> type = std::make_shared<_Type>(nameFromBefore, parseResult);
        types.emplace_back(type);
      }
    }
    
    std::vector<std::shared_ptr<_Type>> filteredVector;
    
    for (const auto &t: types) {
      if (const auto converted_Type = std::dynamic_pointer_cast<_Type>(t)) {
        filteredVector.emplace_back(converted_Type);
      }
    }
    
    return {
      .contained_Types = filteredVector,
      .typeName = struct_TypeName,
    };
  }
  
  _Struct parse_StructEncoding(const std::string &structEncodingString) {
    return parse_StructEncodingWithName(structEncodingString, "");
  }
  
  _Struct parse_StructEncodingWithName(const std::string &structEncodingString,
                                     const std::string &structName) {
    _StringScanner scanner = _StringScanner(structEncodingString);
    auto result = _Parse_StructEncodingWithScanner(scanner,
                                                  [NSString stringWithCString:structEncodingString.c_str()
                                                                     encoding:NSUTF8StringEncoding]);
    
    _Struct outer_Struct = _Struct(structName,
                                structEncodingString,
                                result.typeName,
                                result.contained_Types);
    outer_Struct.pass_TypePath({});
    return outer_Struct;
  }
} } }
