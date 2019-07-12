//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_MLBFileInfo.h"
#import "_Sandboxer.h"
#import "_SandboxerHelper.h"
#import "_Sandboxer-Header.h"
#import <QuickLook/QuickLook.h>

@interface _MLBFileInfo ()

@property (nonatomic, strong, readwrite) NSString *typeImageName;

@end

@implementation _MLBFileInfo

- (instancetype)initWithFileURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
        self.displayName = URL.lastPathComponent;
        self.attributes = [_MLBFileInfo attributesWithFileURL:URL];
        
        if ([self.attributes.fileType isEqualToString:NSFileTypeDirectory]) {
            self.type = _MLBFileTypeDirectory;
            self.filesCount = [_MLBFileInfo contentCountOfDirectoryAtURL:URL];
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [_SandboxerHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [_SandboxerHelper sizeOfFolder:URL.path]];
            }
        } else {
            self.extension = URL.pathExtension;
            self.type = [_MLBFileInfo fileTypeWithExtension:self.extension];
            self.filesCount = 0;
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [_SandboxerHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [_SandboxerHelper sizeOfFile:URL.path]];
            }
        }
        
        //liman
        if ([self.modificationDateText containsString:@"[] "]) {
            self.modificationDateText = [[self.modificationDateText mutableCopy] stringByReplacingOccurrencesOfString:@"[] " withString:@""];
        }
    }
    
    return self;
}

#pragma mark - Getters

- (BOOL)isDirectory {
    return self.type == _MLBFileTypeDirectory;
}

- (NSString *)typeImageName {
    if (!_typeImageName) {
        
        switch (self.type) {
            case _MLBFileTypeUnknown: _typeImageName = @"icon_file_type_default"; break;
            case _MLBFileTypeDirectory: _typeImageName = self.filesCount == 0 ? @"icon_file_type_folder_empty" : @"icon_file_type_folder_not_empty"; break;
            // Image
            case _MLBFileTypeJPG: _typeImageName = @"icon_file_type_jpg"; break;
            case _MLBFileTypePNG: _typeImageName = @"icon_file_type_png"; break;
            case _MLBFileTypeGIF: _typeImageName = @"icon_file_type_gif"; break;
            case _MLBFileTypeSVG: _typeImageName = @"icon_file_type_svg"; break;
            case _MLBFileTypeBMP: _typeImageName = @"icon_file_type_bmp"; break;
            case _MLBFileTypeTIF: _typeImageName = @"icon_file_type_tif"; break;
            // Audio
            case _MLBFileTypeMP3: _typeImageName = @"icon_file_type_mp3"; break;
            case _MLBFileTypeAAC: _typeImageName = @"icon_file_type_aac"; break;
            case _MLBFileTypeWAV: _typeImageName = @"icon_file_type_wav"; break;
            case _MLBFileTypeOGG: _typeImageName = @"icon_file_type_ogg"; break;
            // Video
            case _MLBFileTypeMP4: _typeImageName = @"icon_file_type_mp4"; break;
            case _MLBFileTypeAVI: _typeImageName = @"icon_file_type_avi"; break;
            case _MLBFileTypeFLV: _typeImageName = @"icon_file_type_flv"; break;
            case _MLBFileTypeMIDI: _typeImageName = @"icon_file_type_midi"; break;
            case _MLBFileTypeMOV: _typeImageName = @"icon_file_type_mov"; break;
            case _MLBFileTypeMPG: _typeImageName = @"icon_file_type_mpg"; break;
            case _MLBFileTypeWMV: _typeImageName = @"icon_file_type_wmv"; break;
            // Apple
            case _MLBFileTypeDMG: _typeImageName = @"icon_file_type_dmg"; break;
            case _MLBFileTypeIPA: _typeImageName = @"icon_file_type_ipa"; break;
            case _MLBFileTypeNumbers: _typeImageName = @"icon_file_type_numbers"; break;
            case _MLBFileTypePages: _typeImageName = @"icon_file_type_pages"; break;
            case _MLBFileTypeKeynote: _typeImageName = @"icon_file_type_keynote"; break;
            // Google
            case _MLBFileTypeAPK: _typeImageName = @"icon_file_type_apk"; break;
            // Microsoft
            case _MLBFileTypeWord: _typeImageName = @"icon_file_type_doc"; break;
            case _MLBFileTypeExcel: _typeImageName = @"icon_file_type_xls"; break;
            case _MLBFileTypePPT: _typeImageName = @"icon_file_type_ppt"; break;
            case _MLBFileTypeEXE: _typeImageName = @"icon_file_type_exe"; break;
            case _MLBFileTypeDLL: _typeImageName = @"icon_file_type_dll"; break;
            // Document
            case _MLBFileTypeTXT: _typeImageName = @"icon_file_type_txt"; break;
            case _MLBFileTypeRTF: _typeImageName = @"icon_file_type_rtf"; break;
            case _MLBFileTypePDF: _typeImageName = @"icon_file_type_pdf"; break;
            case _MLBFileTypeZIP: _typeImageName = @"icon_file_type_zip"; break;
            case _MLBFileType7z: _typeImageName = @"icon_file_type_7z"; break;
            case _MLBFileTypeCVS: _typeImageName = @"icon_file_type_cvs"; break;
            case _MLBFileTypeMD: _typeImageName = @"icon_file_type_md"; break;
            // Programming
            case _MLBFileTypeSwift: _typeImageName = @"icon_file_type_swift"; break;
            case _MLBFileTypeJava: _typeImageName = @"icon_file_type_java"; break;
            case _MLBFileTypeC: _typeImageName = @"icon_file_type_c"; break;
            case _MLBFileTypeCPP: _typeImageName = @"icon_file_type_cpp"; break;
            case _MLBFileTypePHP: _typeImageName = @"icon_file_type_php"; break;
            case _MLBFileTypeJSON: _typeImageName = @"icon_file_type_json"; break;
            case _MLBFileTypePList: _typeImageName = @"icon_file_type_plist"; break;
            case _MLBFileTypeXML: _typeImageName = @"icon_file_type_xml"; break;
            case _MLBFileTypeDatabase: _typeImageName = @"icon_file_type_db"; break;
            case _MLBFileTypeJS: _typeImageName = @"icon_file_type_js"; break;
            case _MLBFileTypeHTML: _typeImageName = @"icon_file_type_html"; break;
            case _MLBFileTypeCSS: _typeImageName = @"icon_file_type_css"; break;
            case _MLBFileTypeBIN: _typeImageName = @"icon_file_type_bin"; break;
            case _MLBFileTypeDat: _typeImageName = @"icon_file_type_dat"; break;
            case _MLBFileTypeSQL: _typeImageName = @"icon_file_type_sql"; break;
            case _MLBFileTypeJAR: _typeImageName = @"icon_file_type_jar"; break;
            // Adobe
            case _MLBFileTypeFlash: _typeImageName = @"icon_file_type_fla"; break;
            case _MLBFileTypePSD: _typeImageName = @"icon_file_type_psd"; break;
            case _MLBFileTypeEPS: _typeImageName = @"icon_file_type_eps"; break;
            // Other
            case _MLBFileTypeTTF: _typeImageName = @"icon_file_type_ttf"; break;
            case _MLBFileTypeTorrent: _typeImageName = @"icon_file_type_torrent"; break;
        }
    }
    
    return _typeImageName;
}

- (BOOL)isCanPreviewInQuickLook {
    return [QLPreviewController canPreviewItem:self.URL];
}

- (BOOL)isCanPreviewInWebView {
    if (// Image
        self.type == _MLBFileTypePNG ||
        self.type == _MLBFileTypeJPG ||
        self.type == _MLBFileTypeGIF ||
        self.type == _MLBFileTypeSVG ||
        self.type == _MLBFileTypeBMP ||
        // Audio
        self.type == _MLBFileTypeWAV ||
        // Apple
        self.type == _MLBFileTypeNumbers ||
        self.type == _MLBFileTypePages ||
        self.type == _MLBFileTypeKeynote ||
        // Microsoft
        self.type == _MLBFileTypeWord ||
        self.type == _MLBFileTypeExcel ||
        // Document
        self.type == _MLBFileTypeTXT || // 编码问题
        self.type == _MLBFileTypePDF ||
        self.type == _MLBFileTypeMD ||
        // Programming
        self.type == _MLBFileTypeJava ||
        self.type == _MLBFileTypeSwift ||
        self.type == _MLBFileTypeCSS ||
        // Adobe
        self.type == _MLBFileTypePSD) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Public Methods

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL {
    NSDictionary<NSString *, id> *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:URL.path error:nil];
    
    return attributes;
}

+ (NSMutableArray<_MLBFileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL {
//    ////NSLog(@"%@, url = %@", NSStringFromSelector(_cmd), URL.path);
    NSMutableArray *fileInfos = [NSMutableArray array];
    BOOL isDir = NO;
    BOOL isExists = [NSFileManager.defaultManager fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSError *error;
        NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:URL.path error:&error];
        if (!error) {
            for (NSString *name in contents) {
                if (_Sandboxer.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                _MLBFileInfo *fileInfo = [[_MLBFileInfo alloc] initWithFileURL:[URL URLByAppendingPathComponent:name]];
                [fileInfos addObject:fileInfo];
            }
        }
    }
    
    return fileInfos;
}

+ (NSUInteger)contentCountOfDirectoryAtURL:(NSURL *)URL {
//    ////NSLog(@"%@, url = %@", NSStringFromSelector(_cmd), URL.path);
    NSUInteger count = 0;
    BOOL isDir = NO;
    BOOL isExists = [NSFileManager.defaultManager fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSError *error;
        NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:URL.path error:&error];
        if (!error) {
            for (NSString *name in contents) {
                if (_Sandboxer.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                count++;
            }
        }
    }
    
    return count;
}

+ (_MLBFileType)fileTypeWithExtension:(NSString *)extension {
    _MLBFileType type = _MLBFileTypeUnknown;
    
    if (_MLBIsStringEmpty(extension)) {
        return type;
    }
    
    // Image
    if ([extension compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeJPG;
    } else if ([extension compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePNG;
    } else if ([extension compare:@"gif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeGIF;
    } else if ([extension compare:@"svg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeSVG;
    } else if ([extension compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeBMP;
    } else if ([extension compare:@"tif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeTIF;
    }
    // Audio
    else if ([extension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMP3;
    } else if ([extension compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeAAC;
    } else if ([extension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeWAV;
    } else if ([extension compare:@"ogg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeOGG;
    }
    // Video
    else if ([extension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMP4;
    } else if ([extension compare:@"avi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeAVI;
    } else if ([extension compare:@"flv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeFLV;
    } else if ([extension compare:@"midi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMIDI;
    } else if ([extension compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMOV;
    } else if ([extension compare:@"mpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMPG;
    } else if ([extension compare:@"wmv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeWMV;
    }
    // Apple
    else if ([extension compare:@"dmg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeDMG;
    } else if ([extension compare:@"ipa" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeIPA;
    } else if ([extension compare:@"numbers" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeNumbers;
    } else if ([extension compare:@"pages" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePages;
    } else if ([extension compare:@"key" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeKeynote;
    }
    // Google
    else if ([extension compare:@"apk" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeAPK;
    }
    // Microsoft
    else if ([extension compare:@"doc" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
             [extension compare:@"docx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeWord;
    } else if ([extension compare:@"xls" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"xlsx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeExcel;
    } else if ([extension compare:@"ppt" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"pptx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePPT;
    } else if ([extension compare:@"exe" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeEXE;
    } else if ([extension compare:@"dll" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeDLL;
    }
    // Document
    else if ([extension compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeTXT;
    } else if ([extension compare:@"rtf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeRTF;
    } else if ([extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePDF;
    } else if ([extension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeZIP;
    } else if ([extension compare:@"7z" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileType7z;
    } else if ([extension compare:@"cvs" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeCVS;
    } else if ([extension compare:@"md" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeMD;
    }
    // Programming
    else if ([extension compare:@"swift" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeSwift;
    } else if ([extension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeJava;
    } else if ([extension compare:@"c" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeC;
    } else if ([extension compare:@"cpp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeCPP;
    } else if ([extension compare:@"php" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePHP;
    } else if ([extension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeJSON;
    } else if ([extension compare:@"plist" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePList;
    } else if ([extension compare:@"xml" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeXML;
    } else if ([extension compare:@"db" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeDatabase;
    } else if ([extension compare:@"js" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeJS;
    } else if ([extension compare:@"html" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeHTML;
    } else if ([extension compare:@"css" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeCSS;
    } else if ([extension compare:@"bin" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeBIN;
    } else if ([extension compare:@"dat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeDat;
    } else if ([extension compare:@"sql" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeSQL;
    } else if ([extension compare:@"jar" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeJAR;
    }
    // Adobe
    else if ([extension compare:@"psd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypePSD;
    }
    else if ([extension compare:@"eps" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeEPS;
    }
    // Other
    else if ([extension compare:@"ttf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeTTF;
    } else if ([extension compare:@"torrent" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _MLBFileTypeTorrent;
    }
    
    return type;
}

@end
