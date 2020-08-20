//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FileInfo.h"
#import "_Sandboxer.h"
#import "_SandboxerHelper.h"
#import "_Sandboxer-Header.h"
#import <QuickLook/QuickLook.h>

@interface _FileInfo ()

@property (nonatomic, strong, readwrite) NSString *typeImageName;

@end

@implementation _FileInfo

- (instancetype)initWithFileURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
        self.displayName = URL.lastPathComponent;
        self.attributes = [_FileInfo attributesWithFileURL:URL];
        
        if ([self.attributes.fileType isEqualToString:NSFileTypeDirectory]) {
            self.type = _FileTypeDirectory;
            self.filesCount = [_FileInfo contentCountOfDirectoryAtURL:URL];
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [_SandboxerHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [_SandboxerHelper sizeOfFolder:URL.path]];
            }
        } else {
            self.extension = URL.pathExtension;
            self.type = [_FileInfo fileTypeWithExtension:self.extension];
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
    return self.type == _FileTypeDirectory;
}

- (NSString *)typeImageName {
    if (!_typeImageName) {
        
        switch (self.type) {
            case _FileTypeUnknown: _typeImageName = @"icon_file_type_default"; break;
            case _FileTypeDirectory: _typeImageName = self.filesCount == 0 ? @"icon_file_type_folder_empty" : @"icon_file_type_folder_not_empty"; break;
            // Image
            case _FileTypeJPG: _typeImageName = @"icon_file_type_jpg"; break;
            case _FileTypePNG: _typeImageName = @"icon_file_type_png"; break;
            case _FileTypeGIF: _typeImageName = @"icon_file_type_gif"; break;
            case _FileTypeSVG: _typeImageName = @"icon_file_type_svg"; break;
            case _FileTypeBMP: _typeImageName = @"icon_file_type_bmp"; break;
            case _FileTypeTIF: _typeImageName = @"icon_file_type_tif"; break;
            // Audio
            case _FileTypeMP3: _typeImageName = @"icon_file_type_mp3"; break;
            case _FileTypeAAC: _typeImageName = @"icon_file_type_aac"; break;
            case _FileTypeWAV: _typeImageName = @"icon_file_type_wav"; break;
            case _FileTypeOGG: _typeImageName = @"icon_file_type_ogg"; break;
            // Video
            case _FileTypeMP4: _typeImageName = @"icon_file_type_mp4"; break;
            case _FileTypeAVI: _typeImageName = @"icon_file_type_avi"; break;
            case _FileTypeFLV: _typeImageName = @"icon_file_type_flv"; break;
            case _FileTypeMIDI: _typeImageName = @"icon_file_type_midi"; break;
            case _FileTypeMOV: _typeImageName = @"icon_file_type_mov"; break;
            case _FileTypeMPG: _typeImageName = @"icon_file_type_mpg"; break;
            case _FileTypeWMV: _typeImageName = @"icon_file_type_wmv"; break;
            // Apple
            case _FileTypeDMG: _typeImageName = @"icon_file_type_dmg"; break;
            case _FileTypeIPA: _typeImageName = @"icon_file_type_ipa"; break;
            case _FileTypeNumbers: _typeImageName = @"icon_file_type_numbers"; break;
            case _FileTypePages: _typeImageName = @"icon_file_type_pages"; break;
            case _FileTypeKeynote: _typeImageName = @"icon_file_type_keynote"; break;
            // Google
            case _FileTypeAPK: _typeImageName = @"icon_file_type_apk"; break;
            // Microsoft
            case _FileTypeWord: _typeImageName = @"icon_file_type_doc"; break;
            case _FileTypeExcel: _typeImageName = @"icon_file_type_xls"; break;
            case _FileTypePPT: _typeImageName = @"icon_file_type_ppt"; break;
            case _FileTypeEXE: _typeImageName = @"icon_file_type_exe"; break;
            case _FileTypeDLL: _typeImageName = @"icon_file_type_dll"; break;
            // Document
            case _FileTypeTXT: _typeImageName = @"icon_file_type_txt"; break;
            case _FileTypeRTF: _typeImageName = @"icon_file_type_rtf"; break;
            case _FileTypePDF: _typeImageName = @"icon_file_type_pdf"; break;
            case _FileTypeZIP: _typeImageName = @"icon_file_type_zip"; break;
            case _FileType7z: _typeImageName = @"icon_file_type_7z"; break;
            case _FileTypeCVS: _typeImageName = @"icon_file_type_cvs"; break;
            case _FileTypeMD: _typeImageName = @"icon_file_type_md"; break;
            // Programming
            case _FileTypeSwift: _typeImageName = @"icon_file_type_swift"; break;
            case _FileTypeJava: _typeImageName = @"icon_file_type_java"; break;
            case _FileTypeC: _typeImageName = @"icon_file_type_c"; break;
            case _FileTypeCPP: _typeImageName = @"icon_file_type_cpp"; break;
            case _FileTypePHP: _typeImageName = @"icon_file_type_php"; break;
            case _FileTypeJSON: _typeImageName = @"icon_file_type_json"; break;
            case _FileTypePList: _typeImageName = @"icon_file_type_plist"; break;
            case _FileTypeXML: _typeImageName = @"icon_file_type_xml"; break;
            case _FileTypeDatabase: _typeImageName = @"icon_file_type_db"; break;
            case _FileTypeJS: _typeImageName = @"icon_file_type_js"; break;
            case _FileTypeHTML: _typeImageName = @"icon_file_type_html"; break;
            case _FileTypeCSS: _typeImageName = @"icon_file_type_css"; break;
            case _FileTypeBIN: _typeImageName = @"icon_file_type_bin"; break;
            case _FileTypeDat: _typeImageName = @"icon_file_type_dat"; break;
            case _FileTypeSQL: _typeImageName = @"icon_file_type_sql"; break;
            case _FileTypeJAR: _typeImageName = @"icon_file_type_jar"; break;
            // Adobe
            case _FileTypeFlash: _typeImageName = @"icon_file_type_fla"; break;
            case _FileTypePSD: _typeImageName = @"icon_file_type_psd"; break;
            case _FileTypeEPS: _typeImageName = @"icon_file_type_eps"; break;
            // Other
            case _FileTypeTTF: _typeImageName = @"icon_file_type_ttf"; break;
            case _FileTypeTorrent: _typeImageName = @"icon_file_type_torrent"; break;
        }
    }
    
    return _typeImageName;
}

- (BOOL)isCanPreviewInQuickLook {
    return [QLPreviewController canPreviewItem:self.URL];
}

- (BOOL)isCanPreviewInWebView {
    if (// Image
        self.type == _FileTypePNG ||
        self.type == _FileTypeJPG ||
        self.type == _FileTypeGIF ||
        self.type == _FileTypeSVG ||
        self.type == _FileTypeBMP ||
        // Audio
        self.type == _FileTypeWAV ||
        // Apple
        self.type == _FileTypeNumbers ||
        self.type == _FileTypePages ||
        self.type == _FileTypeKeynote ||
        // Microsoft
        self.type == _FileTypeWord ||
        self.type == _FileTypeExcel ||
        // Document
        self.type == _FileTypeTXT || // 编码问题
        self.type == _FileTypePDF ||
        self.type == _FileTypeMD ||
        // Programming
        self.type == _FileTypeJava ||
        self.type == _FileTypeSwift ||
        self.type == _FileTypeCSS ||
        // Adobe
        self.type == _FileTypePSD) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Public Methods

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL {
    NSDictionary<NSString *, id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:URL.path error:nil];
    
    return attributes;
}

+ (NSMutableArray<_FileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL {
//    ////NSLog(@"%@, url = %@", NSStringFromSelector(_cmd), URL.path);
    NSMutableArray *fileInfos = [NSMutableArray array];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSArray<NSString *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:URL.path error:nil];
        if ([contents count] > 0) {
            for (NSString *name in contents) {
                if (_Sandboxer.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                _FileInfo *fileInfo = [[_FileInfo alloc] initWithFileURL:[URL URLByAppendingPathComponent:name]];
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
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSArray<NSString *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:URL.path error:nil];
        if ([contents count] > 0) {
            for (NSString *name in contents) {
                if (_Sandboxer.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                count++;
            }
        }
    }
    
    return count;
}

+ (_FileType)fileTypeWithExtension:(NSString *)extension {
    _FileType type = _FileTypeUnknown;
    
    if (_IsStringEmpty(extension)) {
        return type;
    }
    
    // Image
    if ([extension compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeJPG;
    } else if ([extension compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePNG;
    } else if ([extension compare:@"gif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeGIF;
    } else if ([extension compare:@"svg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeSVG;
    } else if ([extension compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeBMP;
    } else if ([extension compare:@"tif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeTIF;
    }
    // Audio
    else if ([extension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMP3;
    } else if ([extension compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeAAC;
    } else if ([extension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeWAV;
    } else if ([extension compare:@"ogg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeOGG;
    }
    // Video
    else if ([extension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMP4;
    } else if ([extension compare:@"avi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeAVI;
    } else if ([extension compare:@"flv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeFLV;
    } else if ([extension compare:@"midi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMIDI;
    } else if ([extension compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMOV;
    } else if ([extension compare:@"mpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMPG;
    } else if ([extension compare:@"wmv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeWMV;
    }
    // Apple
    else if ([extension compare:@"dmg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeDMG;
    } else if ([extension compare:@"ipa" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeIPA;
    } else if ([extension compare:@"numbers" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeNumbers;
    } else if ([extension compare:@"pages" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePages;
    } else if ([extension compare:@"key" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeKeynote;
    }
    // Google
    else if ([extension compare:@"apk" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeAPK;
    }
    // Microsoft
    else if ([extension compare:@"doc" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
             [extension compare:@"docx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeWord;
    } else if ([extension compare:@"xls" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"xlsx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeExcel;
    } else if ([extension compare:@"ppt" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"pptx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePPT;
    } else if ([extension compare:@"exe" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeEXE;
    } else if ([extension compare:@"dll" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeDLL;
    }
    // Document
    else if ([extension compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeTXT;
    } else if ([extension compare:@"rtf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeRTF;
    } else if ([extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePDF;
    } else if ([extension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeZIP;
    } else if ([extension compare:@"7z" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileType7z;
    } else if ([extension compare:@"cvs" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeCVS;
    } else if ([extension compare:@"md" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeMD;
    }
    // Programming
    else if ([extension compare:@"swift" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeSwift;
    } else if ([extension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeJava;
    } else if ([extension compare:@"c" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeC;
    } else if ([extension compare:@"cpp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeCPP;
    } else if ([extension compare:@"php" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePHP;
    } else if ([extension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeJSON;
    } else if ([extension compare:@"plist" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePList;
    } else if ([extension compare:@"xml" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeXML;
    } else if ([extension compare:@"db" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeDatabase;
    } else if ([extension compare:@"js" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeJS;
    } else if ([extension compare:@"html" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeHTML;
    } else if ([extension compare:@"css" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeCSS;
    } else if ([extension compare:@"bin" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeBIN;
    } else if ([extension compare:@"dat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeDat;
    } else if ([extension compare:@"sql" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeSQL;
    } else if ([extension compare:@"jar" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeJAR;
    }
    // Adobe
    else if ([extension compare:@"psd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypePSD;
    }
    else if ([extension compare:@"eps" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeEPS;
    }
    // Other
    else if ([extension compare:@"ttf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeTTF;
    } else if ([extension compare:@"torrent" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = _FileTypeTorrent;
    }
    
    return type;
}

@end
