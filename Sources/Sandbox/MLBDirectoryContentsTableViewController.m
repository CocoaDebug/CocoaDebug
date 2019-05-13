//
//  MLBDirectoryContentsTableViewController.m
//  Example
//
//  Created by meilbn on 18/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import "MLBDirectoryContentsTableViewController.h"
#import "MLBFilePreviewController.h"
#import "MLBFileTableViewCell.h"
#import "MLBImageResources.h"
#import "Sandboxer.h"
#import <QuickLook/QuickLook.h>
#import "Sandboxer-Header.h"
#import "NSBundle+Sandboxer.h"

@interface MLBDirectoryContentsTableViewController () <QLPreviewControllerDataSource, UIViewControllerPreviewingDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSMutableArray<MLBFileInfo *> *dataSource;
@property (strong, nonatomic) NSMutableArray<MLBFileInfo *> *filteredDataSource;

@property (strong, nonatomic) MLBFileInfo *previewingFileInfo;
@property (strong, nonatomic) MLBFileInfo *deletingFileInfo;

@property (strong, nonatomic) UIBarButtonItem *refreshItem;
@property (strong, nonatomic) UIBarButtonItem *editItem;
@property (strong, nonatomic) UIBarButtonItem *deleteAllItem;
@property (strong, nonatomic) UIBarButtonItem *deleteItem;

@end

NSInteger const kMLBDeleteAlertViewTag = 101; // 左滑删除
NSInteger const kMLBDeleteAllAlertViewTag = 111; // Toolbar Delete All
NSInteger const kMLBDeleteSelectedAlertViewTag = 121; // Toolbar Delete

@implementation MLBDirectoryContentsTableViewController {
    BOOL _isFirstAppear;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (MLBIsStringEmpty(self.title)) {
        if (self.isHomeDirectory) {
            self.title = [NSBundle mlb_localizedStringForKey:@"home"];
        } else {
            self.title = self.fileInfo.displayName;
        }
    }
    
    //liman
//    if (self.isHomeDirectory) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle mlb_localizedStringForKey:@"close"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissAction)];
//    }
    
    [self initDatas];
    [self setupViews];
    [self registerForPreviewing];
    [self loadDirectoryContents];
    
    
    //liman
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tableView.isEditing) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Private Methods

- (void)initDatas {
    _isFirstAppear = YES;
}

- (void)setupViews {
    self.refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadDirectoryContents)];
    NSMutableArray<UIBarButtonItem *> *rightBarButtonItems = [NSMutableArray arrayWithObject:self.refreshItem];
    if ([Sandboxer shared].isFileDeletable || [Sandboxer shared].isDirectoryDeletable) {
        self.editItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle mlb_localizedStringForKey:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
        self.editItem.possibleTitles = [NSSet setWithObjects:[NSBundle mlb_localizedStringForKey:@"edit"], [NSBundle mlb_localizedStringForKey:@"cancel"], nil];
        [rightBarButtonItems addObject:self.editItem];
    }
    
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView registerClass:[MLBFileTableViewCell class] forCellReuseIdentifier:MLBFileTableViewCellReuseIdentifier];
    self.tableView.rowHeight = 60.0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.searchResultsUpdater = self;
        self.searchController.searchBar.delegate = self;
        self.searchController.delegate = self;
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
    } else {
        
    }
}

- (void)registerForPreviewing {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [MLBFileInfo contentsOfDirectoryAtURL:self.fileInfo.URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshItem.enabled = YES;
            [self.tableView reloadData];
            [self updateToolbarItems];
            if (self->_isFirstAppear) {
                self->_isFirstAppear = NO;
                if (self.searchController) {
                    CGPoint point = CGPointMake(0, CGRectGetHeight(self.searchController.searchBar.frame) - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) - CGRectGetHeight(self.navigationController.navigationBar.frame));
                    [self.tableView setContentOffset:point animated:NO];
                }
            }
        });
    });
}

- (void)filterContentsForSearchText:(NSString *)text {
    if (nil == self.filteredDataSource) {
        self.filteredDataSource = [NSMutableArray array];
    }
    
    [self.filteredDataSource removeAllObjects];
    [self.filteredDataSource addObjectsFromArray:[self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.displayName CONTAINS[cd] %@", text]]];
    [self.tableView reloadData];
}

- (MLBFileInfo *)fileInfoAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController && self.searchController.isActive) {
        return self.filteredDataSource[indexPath.row];
    }
    
    return self.dataSource[indexPath.row];
}

- (UIViewController *)viewControllerWithFileInfo:(MLBFileInfo *)fileInfo {
    if (fileInfo.isDirectory) {
        MLBDirectoryContentsTableViewController *directoryContentsTableViewController = [[MLBDirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.fileInfo = fileInfo;
        return directoryContentsTableViewController;
    } else {
        if ([Sandboxer shared].isShareable && fileInfo.isCanPreviewInQuickLook) {
            ////NSLog(@"Quick Look can preview this file");
            self.previewingFileInfo = fileInfo;
            
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            return previewController;
        } else {
            ////NSLog(@"Quick Look can not preview this file");
            MLBFilePreviewController *filePreviewController = [[MLBFilePreviewController alloc] init];
            filePreviewController.fileInfo = fileInfo;
            return filePreviewController;
        }
    }
}

- (BOOL)isCanDeleteAll {
    if ((![Sandboxer shared].isFileDeletable && ![Sandboxer shared].isDirectoryDeletable) || self.dataSource.count == 0) {
        return NO;
    }
    
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    [self getDeletableFileCount:&fileCount directoryCount:&directoryCount];
    
    if (([Sandboxer shared].isFileDeletable && ![Sandboxer shared].isDirectoryDeletable && fileCount == 0) || // 只能删除文件，但是文件数为 0
        (![Sandboxer shared].isFileDeletable && [Sandboxer shared].isDirectoryDeletable && directoryCount == 0)) { // 只能删除文件夹，但是文件夹数为 0
        return NO;
    }
    
    return YES;
}

- (void)getDeletableFileCount:(NSInteger *)fileCount directoryCount:(NSInteger *)directoryCount {
    NSInteger fc = 0;
    NSInteger dc = 0;
    for (MLBFileInfo *fileInfo in self.dataSource) {
        if (fileInfo.isDirectory && [Sandboxer shared].isDirectoryDeletable) {
            dc++;
        } else if (!fileInfo.isDirectory && [Sandboxer shared].isFileDeletable) {
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
    NSMutableString *message = [NSMutableString stringWithString:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_prefix"]];
    if ([Sandboxer shared].isFileDeletable && fileCount > 0) {
        [message appendFormat:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_file_count"], fileCount];
    }
    
    if ([Sandboxer shared].isDirectoryDeletable && directoryCount > 0) {
        if ([Sandboxer shared].isFileDeletable && fileCount > 0) {
            [message appendString:[NSBundle mlb_localizedStringForKey:@"comma"]];
        }
        
        [message appendFormat:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_directory_count"], directoryCount];
    }
    
    [message appendString:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_question_suffix"]];
    
    return message.copy;
}

- (UIAlertController *)alertControllerForDeleteWithMessage:(NSString *)message deleteHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_cancel"] style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_delete"] style:UIAlertActionStyleDestructive handler:handler]];
    return alertController;
}

- (UIAlertView *)alertViewForDeleteWithMessage:(NSString *)message tag:(NSInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_cancel"] otherButtonTitles:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_delete"], nil];
    alertView.tag = tag;
    return alertView;
}

#pragma mark - Action

- (void)dismissAction {
    [[Sandboxer shared] trigger];
}

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
    self.editItem.title = [NSBundle mlb_localizedStringForKey:@"cancel"];
    self.editItem.style = UIBarButtonItemStyleDone;
    if (self.searchController) {
        self.searchController.searchBar.userInteractionEnabled = NO;
        self.searchController.searchBar.alpha = 0.4;
    }
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (nil == self.deleteAllItem) {
        self.deleteAllItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle mlb_localizedStringForKey:@"delete_all"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction)];
        self.deleteItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle mlb_localizedStringForKey:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedFilesAction)];
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
    if (self.searchController) {
        self.searchController.searchBar.userInteractionEnabled = YES;
        self.searchController.searchBar.alpha = 1.0;
    }
    
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
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
        MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
        ////NSLog(@"mlb - Delete file: %@", fileInfo.displayName);
        if (fileInfo.isDirectory) {
            directoryCount++;
        } else {
            fileCount++;
        }
    }
    
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
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
    NSMutableArray<MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    NSMutableArray<NSIndexPath *> *deletedIndexPaths = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^(MLBFileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    NSMutableArray<MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        MLBFileInfo *fileInfo = self.dataSource[indexPath.row];
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
        if (self.searchController && self.searchController.isActive) {
            index = [self.filteredDataSource indexOfObject:self.deletingFileInfo];
            [self.filteredDataSource removeObject:self.deletingFileInfo];
        } else {
            index = [self.dataSource indexOfObject:self.deletingFileInfo];
        }
        
        [self.dataSource removeObject:self.deletingFileInfo];
        if (index >= 0) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.deletingFileInfo = nil;
    }
}

- (BOOL)deleteFile:(MLBFileInfo *)fileInfo {
    if (![Sandboxer shared].isFileDeletable || // 是否可以删除文件
        (![Sandboxer shared].isDirectoryDeletable && fileInfo.isDirectory)) { // 是否可以删除文件夹
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileInfo.URL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileInfo.URL error:&error];
        if (error) {
            ////NSLog(@"mlb - %@, file path: %@, error: %@", NSStringFromSelector(_cmd), fileInfo.URL.path, error.localizedDescription);
            return NO;
        } else {
            ////NSLog(@"mlb - %@, file deleted", NSStringFromSelector(_cmd));
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController && self.searchController.isActive) {
        return self.filteredDataSource.count;
    } else {
        return self.dataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MLBFileTableViewCellReuseIdentifier forIndexPath:indexPath];
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    cell.imageView.image = [MLBImageResources fileTypeImageNamed:fileInfo.typeImageName];
    cell.textLabel.text = [Sandboxer shared].isExtensionHidden ? fileInfo.displayName.stringByDeletingPathExtension : fileInfo.displayName;
    cell.detailTextLabel.text = fileInfo.modificationDateText;
    cell.accessoryType = fileInfo.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self fileInfoAtIndexPath:indexPath].isDirectory) {
        return [Sandboxer shared].isDirectoryDeletable;
    } else {
        return [Sandboxer shared].isFileDeletable;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ////NSLog(@"Clicked delete editing style");
        self.deletingFileInfo = fileInfo;
        NSMutableString *message = [NSMutableString string];
        if (fileInfo.isDirectory) {
            [message appendFormat:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_single_directory"], fileInfo.filesCount];
        } else {
            [message appendString:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_single_file"]];
        }
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_cancel"] style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle mlb_localizedStringForKey:@"sure_to_delete_delete"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
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
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![Sandboxer shared].isFileDeletable)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [self updateToolbarDeleteItem];
        }
    } else {
        if (self.searchController) {
            self.searchController.active = NO;
        }
        
        [self.navigationController pushViewController:[self viewControllerWithFileInfo:fileInfo] animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![Sandboxer shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![Sandboxer shared].isFileDeletable)) {
            
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

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentsForSearchText:searchController.searchBar.text];
}

#pragma mark - UISearchBarDelegate

#pragma mark - UISearchControllerDelegate

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
    MLBFileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) { return nil; }
    
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    // Create a detail view controller and set its properties.
    UIViewController *detailViewController = [self viewControllerWithFileInfo:fileInfo];
    
    /*
     Set the height of the preview by setting the preferred content size of the detail view controller.
     Width should be zero, because it's not used in portrait.
     */
    detailViewController.preferredContentSize = CGSizeZero;
    
    // Set the source rect to the cell frame, so surrounding elements are blurred.
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
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
