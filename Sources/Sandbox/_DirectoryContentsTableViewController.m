//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DirectoryContentsTableViewController.h"
#import "_FilePreviewController.h"
#import "_FileTableViewCell.h"
#import "_ImageResources.h"
#import "_Sandboxer.h"
#import <QuickLook/QuickLook.h>
#import "_Sandboxer-Header.h"
#import "_NetworkHelper.h"
#import "_ImageController.h"
#import "_SandboxerHelper.h"
#import "NSObject+CocoaDebug.h"

@interface _DirectoryContentsTableViewController () <QLPreviewControllerDataSource, UIViewControllerPreviewingDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray<_FileInfo *> *dataSource;
@property (nonatomic, strong) NSMutableArray<_FileInfo *> *dataSource_cache;
@property (nonatomic, strong) NSMutableArray<_FileInfo *> *dataSource_search;

@property (nonatomic, strong) _FileInfo *previewingFileInfo;
@property (nonatomic, strong) _FileInfo *deletingFileInfo;

@property (nonatomic, strong) UIBarButtonItem *refreshItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *deleteAllItem;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) NSString *randomId;
@property (nonatomic, copy) NSString *searchText;

@end

NSInteger const kMLBDeleteAlertViewTag = 101; // 左滑删除
NSInteger const kMLBDeleteAllAlertViewTag = 111; // Toolbar Delete All
NSInteger const kMLBDeleteSelectedAlertViewTag = 121; // Toolbar Delete

@implementation _DirectoryContentsTableViewController

//liman
- (void)customNavigationBar
{
    //****** 以下代码从LogNavigationViewController.swift复制 ******
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [_NetworkHelper shared].mainColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:20],
                                                                    NSForegroundColorAttributeName: [_NetworkHelper shared].mainColor
                                                                    };
}

- (void)exit {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Lifecycle
- (void)dealloc {
    [[_SandboxerHelper sharedInstance].searchTextDictionary removeObjectForKey:self.randomId];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.randomId = [_SandboxerHelper generateRandomId];

    if (![_SandboxerHelper sharedInstance].searchTextDictionary) {
        [_SandboxerHelper sharedInstance].searchTextDictionary = [NSMutableDictionary dictionary];
    }
    
    //
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //liman
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0 green:33/255.0 blue:36/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //liman
    if (_IsStringEmpty(self.title)) {
        if (self.isHomeDirectory) {
            [self customNavigationBar];//liman
            self.title = @"Sandbox";
        } else {
            self.title = self.fileInfo.displayName;
        }
    }
    
    //
    [self setupViews];
    [self registerForPreviewing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.searchText = [[_SandboxerHelper sharedInstance].searchTextDictionary objectForKey:self.randomId];

    [self loadDirectoryContents];
    [self endEditing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.tableView.isEditing) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    [self.searchBar resignFirstResponder];
}

#pragma mark - Private Methods
- (void)setupViews {
    //暂时不用
    self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    self.editItem.possibleTitles = [NSSet setWithObjects:@"Edit", @"Cancel", nil];
    
    //
    self.refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadDirectoryContents)];
    self.closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    
    if (self.homeDirectory) {
        self.navigationItem.leftBarButtonItems = @[self.closeItem];
        self.navigationItem.rightBarButtonItems = @[self.refreshItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.closeItem, self.refreshItem];
    }
    
    
    //
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - [UIApplication sharedApplication].statusBarFrame.size.height - 50) style:UITableViewStylePlain];
    
    
    BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        if (mainWindow.safeAreaInsets.top > 24.0) {
            iPhoneX = YES;
        }
    }
    
    if (iPhoneX) {
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - [UIApplication sharedApplication].statusBarFrame.size.height - 50 - 34);
    }
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.rowHeight = 60.0;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[_FileTableViewCell class] forCellReuseIdentifier:_FileTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor blackColor];
    self.searchBar.enablesReturnKeyAutomatically = NO;
    [self.view addSubview:self.searchBar];
    
    //hide searchBar icon
    UITextField *textFieldInsideSearchBar = [self.searchBar valueForKey:@"searchField"];
    textFieldInsideSearchBar.leftViewMode = UITextFieldViewModeNever;
    textFieldInsideSearchBar.leftView = nil;
    textFieldInsideSearchBar.backgroundColor = [UIColor whiteColor];
    textFieldInsideSearchBar.returnKeyType = UIReturnKeyDefault;
}

- (void)registerForPreviewing {
    if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        if (@available(iOS 9.0, *)) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:self.view];
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)loadDirectoryContents {
    self.refreshItem.enabled = NO;
    
    __weak _DirectoryContentsTableViewController *weakSelf = self;

    //子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableArray<_FileInfo *> *dataSource_ = [_FileInfo contentsOfDirectoryAtURL:weakSelf.fileInfo.URL];
        if ([dataSource_ count] > 0) {
            weakSelf.dataSource = dataSource_;
            weakSelf.dataSource_cache = dataSource_;
        }
        
        //主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.refreshItem.enabled = YES;
            [weakSelf updateToolbarItems];
            [weakSelf searchBar:weakSelf.searchBar textDidChange:weakSelf.searchBar.text];
        });
    });
    
    [self.searchBar resignFirstResponder];
}

- (_FileInfo *)fileInfoAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (UIViewController *)viewControllerWithFileInfo:(_FileInfo *)fileInfo {
    if (fileInfo.isDirectory) {
        _DirectoryContentsTableViewController *directoryContentsTableViewController = [[_DirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.fileInfo = fileInfo;
//        directoryContentsTableViewController.hidesBottomBarWhenPushed = YES;//liman
        return directoryContentsTableViewController;
    } else {
        if ([_Sandboxer shared].isShareable && fileInfo.isCanPreviewInQuickLook) {
            //NSLog(@"Quick Look can preview this file");
            self.previewingFileInfo = fileInfo;
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.hidesBottomBarWhenPushed = YES;//liman
            return previewController;
        } else {
            //liman
            if (fileInfo.URL) {
                NSData *data = [NSData dataWithContentsOfURL:fileInfo.URL];
                if (data) {
                    UIImage *image = [UIImage imageWithGIFData:data];
                    if (image) {
                        _ImageController *vc = [[_ImageController alloc] initWithImage:image fileInfo:fileInfo];
                        vc.hidesBottomBarWhenPushed = YES;//liman
                        return vc;
                    }
                }
            }
            
            //NSLog(@"Quick Look can not preview this file");
            _FilePreviewController *filePreviewController = [[_FilePreviewController alloc] init];
            filePreviewController.fileInfo = fileInfo;
            filePreviewController.hidesBottomBarWhenPushed = YES;//liman
            return filePreviewController;
        }
    }
}

- (BOOL)isCanDeleteAll {
    if ((![_Sandboxer shared].isFileDeletable && ![_Sandboxer shared].isDirectoryDeletable) || self.dataSource.count == 0) {
        return NO;
    }
    
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    [self getDeletableFileCount:&fileCount directoryCount:&directoryCount];
    
    if (([_Sandboxer shared].isFileDeletable && ![_Sandboxer shared].isDirectoryDeletable && fileCount == 0) || // 只能删除文件，但是文件数为 0
        (![_Sandboxer shared].isFileDeletable && [_Sandboxer shared].isDirectoryDeletable && directoryCount == 0)) { // 只能删除文件夹，但是文件夹数为 0
        return NO;
    }
    
    return YES;
}

- (void)getDeletableFileCount:(NSInteger *)fileCount directoryCount:(NSInteger *)directoryCount {
    NSInteger fc = 0;
    NSInteger dc = 0;
    for (_FileInfo *fileInfo in self.dataSource) {
        if (fileInfo.isDirectory && [_Sandboxer shared].isDirectoryDeletable) {
            dc++;
        } else if (!fileInfo.isDirectory && [_Sandboxer shared].isFileDeletable) {
            fc++;
        }
    }
    
    *fileCount = fc;
    *directoryCount = dc;
}

- (void)updateToolbarItems {
    [self updateToolbarDeleteAllItem];
    [self updateToolbarDeleteItem];
}

- (void)updateToolbarDeleteAllItem {
    if (self.deleteAllItem) {
        self.deleteAllItem.enabled = [self isCanDeleteAll];
    }
}

- (void)updateToolbarDeleteItem {
    if (self.deleteItem) {
        self.deleteItem.enabled = self.tableView.indexPathsForSelectedRows.count > 0;
    }
}

- (NSString *)messageForDeleteWithFileCount:(NSInteger)fileCount directoryCount:(NSInteger)directoryCount {
    NSMutableString *message = [NSMutableString stringWithString:@"Are you sure to delete"];
    if ([_Sandboxer shared].isFileDeletable && fileCount > 0) {
        [message appendFormat:@"%ld files", (long)fileCount];
    }
    
    if ([_Sandboxer shared].isDirectoryDeletable && directoryCount > 0) {
        if ([_Sandboxer shared].isFileDeletable && fileCount > 0) {
            [message appendString:@","];
        }
        
        [message appendFormat:@"%ld directories", (long)directoryCount];
    }
    
    [message appendString:@"?"];
    
    return message.copy;
}

#pragma mark - alert
- (UIAlertController *)alertControllerForDeleteWithMessage:(NSString *)message deleteHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:handler]];
    return alert;
}

- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not supported" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - target action
- (void)didTapView {
    [self.searchBar resignFirstResponder];
}

- (void)editAction {
    if (![_Sandboxer shared].isFileDeletable && ![_Sandboxer shared].isDirectoryDeletable) {
        [self showAlert];
        return;
    }
    
    if (!self.tableView.isEditing) {
        [self beginEditing];
    } else {
        [self endEditing];
    }
    
    [self.searchBar resignFirstResponder];
}

- (void)beginEditing {
    if (self.tableView.isEditing) { return; }
    self.tableView.editing = YES;
    self.editItem.title = @"Cancel";
    self.editItem.style = UIBarButtonItemStyleDone;
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (nil == self.deleteAllItem) {
        self.deleteAllItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction)];
        self.deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedFilesAction)];
        
        //liman
        [self.deleteAllItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        [self.deleteItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        [self.deleteAllItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:209/255.0 green:157/255.0 blue:157/255.0 alpha:1.0]} forState:UIControlStateHighlighted];
        [self.deleteItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:209/255.0 green:157/255.0 blue:157/255.0 alpha:1.0]} forState:UIControlStateHighlighted];
        
        
        [self setToolbarItems:@[self.deleteAllItem,
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                self.deleteItem] animated:YES];
    }
    
    [self updateToolbarItems];
}

- (void)endEditing {
    if (!self.tableView.isEditing) { return; }
    self.tableView.editing = NO;
    self.editItem.title = @"Edit";
    self.editItem.style = UIBarButtonItemStylePlain;

    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)deleteAllAction {
    if (![self isCanDeleteAll]) {
        return;
    }
    
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    [self getDeletableFileCount:&fileCount directoryCount:&directoryCount];
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    
    UIAlertController *alert = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
        [self deleteAllFiles];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteSelectedFilesAction {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
        ////NSLog(@"mlb - Delete file: %@", fileInfo.displayName);
        if (fileInfo.isDirectory) {
            directoryCount++;
        } else {
            fileCount++;
        }
    }
    
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    
    UIAlertController *alert = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
        [self deleteSelectedFiles];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteAllFiles {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<_FileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    NSMutableArray<NSIndexPath *> *deletedIndexPaths = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^(_FileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self deleteFile:obj]) {
            ////NSLog(@"mlb - %@, idx = %lu, obj = %@", NSStringFromSelector(_cmd), (unsigned long)idx, obj.displayName);
            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            [deletedFileInfos addObject:obj];
        }
    }];
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    
    //TODO... cache search
    
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFiles {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<_FileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        _FileInfo *fileInfo = self.dataSource[indexPath.row];
        if ([self deleteFile:fileInfo]) {
            [deletedFileInfos addObject:fileInfo];
        }
    }
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    
    //TODO... cache search
    
    [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFile {
    if ([self deleteFile:self.deletingFileInfo]) {
        NSInteger index = -1;
        index = [self.dataSource indexOfObject:self.deletingFileInfo];
        
        [self.dataSource removeObject:self.deletingFileInfo];
        
        if ([self.dataSource_cache count] > 0 && [self.dataSource_cache containsObject:self.deletingFileInfo]) {
            [self.dataSource_cache removeObject:self.deletingFileInfo];
        }
        if ([self.dataSource_search count] > 0 && [self.dataSource_search containsObject:self.deletingFileInfo]) {
            [self.dataSource_search removeObject:self.deletingFileInfo];
        }
        
        if (index >= 0) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.deletingFileInfo = nil;
    }
}

- (BOOL)deleteFile:(_FileInfo *)fileInfo {
    if (![_Sandboxer shared].isFileDeletable || // 是否可以删除文件
        (![_Sandboxer shared].isDirectoryDeletable && fileInfo.isDirectory)) { // 是否可以删除文件夹
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileInfo.URL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileInfo.URL error:&error];
        if (error) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FileTableViewCellReuseIdentifier forIndexPath:indexPath];
    _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    cell.imageView.image = [_ImageResources fileTypeImageNamed:fileInfo.typeImageName];
    cell.textLabel.text = [_Sandboxer shared].isExtensionHidden ? fileInfo.displayName.stringByDeletingPathExtension : fileInfo.displayName;
//    cell.accessoryType = fileInfo.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryNone; //liman
    
    //liman
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fileInfo.modificationDateText];
    if ([attributedString length] >= 25) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName: [_NetworkHelper shared].mainColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:12]} range:NSMakeRange(0, 25)];
    }
    cell.detailTextLabel.attributedText = [attributedString copy];
//    cell.detailTextLabel.text = fileInfo.modificationDateText;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self fileInfoAtIndexPath:indexPath].isDirectory) {
        return [_Sandboxer shared].isDirectoryDeletable;
    } else {
        return [_Sandboxer shared].isFileDeletable;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ////NSLog(@"Clicked delete editing style");
        self.deletingFileInfo = fileInfo;
        NSMutableString *message = [NSMutableString string];
        if (fileInfo.isDirectory) {
            [message appendFormat:@"Are you sure to delete this directory(including %lu files(or directories) inside)?", (unsigned long)fileInfo.filesCount];
        } else {
            [message appendString:@"Are you sure to delete this file?"];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteSelectedFile];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.searchBar;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![_Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![_Sandboxer shared].isFileDeletable)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [self updateToolbarDeleteItem];
        }
    } else {
        [self.navigationController pushViewController:[self viewControllerWithFileInfo:fileInfo] animated:YES];
    }
    
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![_Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![_Sandboxer shared].isFileDeletable)) {
            
        } else {
            [self updateToolbarDeleteItem];
        }
    }
}


#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.previewingFileInfo ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewingFileInfo.URL;
}

#pragma mark - UIViewControllerPreviewingDelegate

/// Create a previewing view controller to be shown at "Peek".
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    // Obtain the index path and the cell that was pressed.
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    _FileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) { return nil; }
    
    _FileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    // Create a detail view controller and set its properties.
    UIViewController *detailViewController = [self viewControllerWithFileInfo:fileInfo];
    
    /*
     Set the height of the preview by setting the preferred content size of the detail view controller.
     Width should be zero, because it's not used in portrait.
     */
    detailViewController.preferredContentSize = CGSizeZero;
    
    // Set the source rect to the cell frame, so surrounding elements are blurred.
    if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        if (@available(iOS 9.0, *)) {
            previewingContext.sourceRect = cell.frame;
        } else {
            // Fallback on earlier versions
        }
    }
    
    return detailViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText && ![self.searchText isEqualToString:searchText]) {
        [[_SandboxerHelper sharedInstance].searchTextDictionary setObject:searchText forKey:self.randomId];
    }

    if (!searchText || [searchText isEqualToString:@""]) {
        self.dataSource = self.dataSource_cache;
        [self.tableView reloadData];
        return;
    }
    
    if (!self.dataSource_search) {
        self.dataSource_search = [NSMutableArray array];
    } else {
        [self.dataSource_search removeAllObjects];
    }
    
    for (_FileInfo *obj in self.dataSource_cache) {
        if ([[obj.displayName lowercaseString] containsString:[searchText lowercaseString]]) {
            [self.dataSource_search addObject:obj];
        }
    }
    
    self.dataSource = self.dataSource_search;
    [self.tableView reloadData];
}

@end

