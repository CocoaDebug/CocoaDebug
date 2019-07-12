//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "_MLBDirectoryContentsTableViewController.h"
#import "_MLBFilePreviewController.h"
#import "_MLBFileTableViewCell.h"
#import "_MLBImageResources.h"
#import "_Sandboxer.h"
#import <QuickLook/QuickLook.h>
#import "_Sandboxer-Header.h"
#import "_NetworkHelper.h"

@interface _MLBDirectoryContentsTableViewController () <QLPreviewControllerDataSource, UIViewControllerPreviewingDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray<_MLBFileInfo *> *dataSource;
@property (strong, nonatomic) _MLBFileInfo *previewingFileInfo;
@property (strong, nonatomic) _MLBFileInfo *deletingFileInfo;

@property (strong, nonatomic) UIBarButtonItem *refreshItem;
@property (strong, nonatomic) UIBarButtonItem *editItem;
@property (strong, nonatomic) UIBarButtonItem *deleteAllItem;
@property (strong, nonatomic) UIBarButtonItem *deleteItem;

@end

NSInteger const kMLBDeleteAlertViewTag = 101; // 左滑删除
NSInteger const kMLBDeleteAllAlertViewTag = 111; // Toolbar Delete All
NSInteger const kMLBDeleteSelectedAlertViewTag = 121; // Toolbar Delete

@implementation _MLBDirectoryContentsTableViewController

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
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    leftItem.tintColor = [_NetworkHelper shared].mainColor;
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftItem;
}

- (void)exit {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //liman
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0 green:33/255.0 blue:36/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //liman
    if (_MLBIsStringEmpty(self.title)) {
        if (self.isHomeDirectory) {
            [self customNavigationBar];//liman
            self.title = @"Sandbox";
        } else {
            self.title = self.fileInfo.displayName;
        }
    }
    
    
    [self setupViews];
    [self registerForPreviewing];
    [self loadDirectoryContents];
    
    
    //liman
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //liman
    [self loadDirectoryContents];
    [self endEditing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tableView.isEditing) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Private Methods

- (void)setupViews {
    self.refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadDirectoryContents)];
    NSMutableArray<UIBarButtonItem *> *rightBarButtonItems = [NSMutableArray arrayWithObject:self.refreshItem];
    if ([_Sandboxer shared].isFileDeletable || [_Sandboxer shared].isDirectoryDeletable) {
        self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
        self.editItem.possibleTitles = [NSSet setWithObjects:@"Edit", @"Cancel", nil];
        [rightBarButtonItems addObject:self.editItem];
    }
    
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView registerClass:[_MLBFileTableViewCell class] forCellReuseIdentifier:_MLBFileTableViewCellReuseIdentifier];
    self.tableView.rowHeight = 60.0;

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
    
    __weak _MLBDirectoryContentsTableViewController *weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableArray<_MLBFileInfo *> *dataSource_ = [_MLBFileInfo contentsOfDirectoryAtURL:weakSelf.fileInfo.URL];
        if ([dataSource_ count] > 0) {
            weakSelf.dataSource = dataSource_;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.refreshItem.enabled = YES;
            [weakSelf updateToolbarItems];
            if ([dataSource_ count] > 0) {
                [weakSelf.tableView reloadData];
            }
        });
    });
}

- (_MLBFileInfo *)fileInfoAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (UIViewController *)viewControllerWithFileInfo:(_MLBFileInfo *)fileInfo {
    if (fileInfo.isDirectory) {
        _MLBDirectoryContentsTableViewController *directoryContentsTableViewController = [[_MLBDirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.fileInfo = fileInfo;
        directoryContentsTableViewController.hidesBottomBarWhenPushed = YES;//liman
        return directoryContentsTableViewController;
    } else {
        if ([_Sandboxer shared].isShareable && fileInfo.isCanPreviewInQuickLook) {
            ////NSLog(@"Quick Look can preview this file");
            self.previewingFileInfo = fileInfo;
            
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.hidesBottomBarWhenPushed = YES;//liman
            return previewController;
        } else {
            ////NSLog(@"Quick Look can not preview this file");
            _MLBFilePreviewController *filePreviewController = [[_MLBFilePreviewController alloc] init];
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
    for (_MLBFileInfo *fileInfo in self.dataSource) {
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
        BOOL isEnable = [self isCanDeleteAll];
        self.deleteAllItem.enabled = isEnable;
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

- (UIAlertController *)alertControllerForDeleteWithMessage:(NSString *)message deleteHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:handler]];
    return alertController;
}

- (UIAlertView *)alertViewForDeleteWithMessage:(NSString *)message tag:(NSInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertView.tag = tag;
    return alertView;
}

#pragma mark - Action

- (void)editAction {
    if (!self.tableView.isEditing) {
        [self beginEditing];
    } else {
        [self endEditing];
    }
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
    if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alertController = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
            [self deleteAllFiles];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[self alertViewForDeleteWithMessage:message tag:kMLBDeleteAllAlertViewTag] show];
    }
}

- (void)deleteSelectedFilesAction {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
        ////NSLog(@"mlb - Delete file: %@", fileInfo.displayName);
        if (fileInfo.isDirectory) {
            directoryCount++;
        } else {
            fileCount++;
        }
    }
    
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alertController = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
            [self deleteSelectedFiles];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[self alertViewForDeleteWithMessage:message tag:kMLBDeleteSelectedAlertViewTag] show];
    }
}

- (void)deleteAllFiles {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<_MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    NSMutableArray<NSIndexPath *> *deletedIndexPaths = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^(_MLBFileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self deleteFile:obj]) {
            ////NSLog(@"mlb - %@, idx = %lu, obj = %@", NSStringFromSelector(_cmd), (unsigned long)idx, obj.displayName);
            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            [deletedFileInfos addObject:obj];
        }
    }];
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFiles {
    ////NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<_MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        _MLBFileInfo *fileInfo = self.dataSource[indexPath.row];
        if ([self deleteFile:fileInfo]) {
            [deletedFileInfos addObject:fileInfo];
        }
    }
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFile {
    if ([self deleteFile:self.deletingFileInfo]) {
        NSInteger index = -1;
        index = [self.dataSource indexOfObject:self.deletingFileInfo];
        
        [self.dataSource removeObject:self.deletingFileInfo];
        if (index >= 0) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.deletingFileInfo = nil;
    }
}

- (BOOL)deleteFile:(_MLBFileInfo *)fileInfo {
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
    _MLBFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_MLBFileTableViewCellReuseIdentifier forIndexPath:indexPath];
    _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    cell.imageView.image = [_MLBImageResources fileTypeImageNamed:fileInfo.typeImageName];
    cell.textLabel.text = [_Sandboxer shared].isExtensionHidden ? fileInfo.displayName.stringByDeletingPathExtension : fileInfo.displayName;
    cell.accessoryType = fileInfo.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
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
    _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ////NSLog(@"Clicked delete editing style");
        self.deletingFileInfo = fileInfo;
        NSMutableString *message = [NSMutableString string];
        if (fileInfo.isDirectory) {
            [message appendFormat:@"Are you sure to delete this directory(including %lu files(or directories) inside)?", (unsigned long)fileInfo.filesCount];
        } else {
            [message appendString:@"Are you sure to delete this file?"];
        }
        
        if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self deleteSelectedFile];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [[self alertViewForDeleteWithMessage:message tag:kMLBDeleteAlertViewTag] show];
        }
    }
}

#pragma mark UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![_Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![_Sandboxer shared].isFileDeletable)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [self updateToolbarDeleteItem];
        }
    } else {
        [self.navigationController pushViewController:[self viewControllerWithFileInfo:fileInfo] animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![_Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![_Sandboxer shared].isFileDeletable)) {
            
        } else {
            [self updateToolbarDeleteItem];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == kMLBDeleteAlertViewTag) {
            [self deleteSelectedFile];
        } else if (alertView.tag == kMLBDeleteAllAlertViewTag) {
            [self deleteAllFiles];
        } else if (alertView.tag == kMLBDeleteSelectedAlertViewTag) {
            [self deleteSelectedFiles];
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
    _MLBFileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) { return nil; }
    
    _MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
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

@end

#pragma clang diagnostic pop

