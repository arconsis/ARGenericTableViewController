/*
 * ARGenericTableViewController.m
 *
 * Copyright (c) 2013 arconsis IT-Solutions GmbH
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#import "ARGenericTableViewController.h"

@interface ARGenericTableViewController ()
@property (nonatomic, strong) UIBarButtonItem *internalEditButtonItem;
@property (nonatomic, strong) NSMutableDictionary *tableViewCellClassDict;
@end

@implementation ARGenericTableViewController

- (void)setup
{
    self.animateChanges = NO;
    self.tableViewCellClassDict = [[NSMutableDictionary alloc] init];

}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setup];
    return self;
}

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)dealloc
{
    if (self.isViewLoaded) {
      [self.tableView removeObserver:self forKeyPath:@"editing"];      
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.tableView.superview) {
        self.tableView.frame = self.view.bounds;
        [self.view addSubview:self.tableView];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView addObserver:self forKeyPath:@"editing" options:0 context:NULL];
}

- (void)registerClass:(Class)Class forCellReuseIdentifier:(NSString *)identifier
{
    if (![Class isSubclassOfClass:[UITableViewCell class]]) {
        return;
    }
    if ([self.tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)]) {
        [self.tableView registerClass:Class forCellReuseIdentifier:identifier];
    } else {
        [self.tableViewCellClassDict setValue:Class forKey:identifier];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqual:@"editing"]) {
        [self setEditing:self.tableView.editing];
    }
}

- (void)setTableViewData:(ARTableViewData *)tableViewData
{
    _tableViewData = tableViewData;
    self.tableViewData.delegate = self;
    [self.tableView reloadData];
}

- (BOOL)isEditing
{
    return self.tableView.isEditing;
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewData.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].cellCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].footerTitle;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableViewData cellDataAtIndexPath:indexPath].movable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.tableViewData moveCellDataFromIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];

    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:sourceIndexPath];
    if (cellData.cellMoveBlock) {
        cellData.cellMoveBlock(tableView,sourceIndexPath,destinationIndexPath);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
        
        if (cellData.cellDeleteBlock) {
            cellData.cellDeleteBlock(tableView,indexPath);
        }
        [self.tableViewData removeCellDataAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
    return cellData.editable || cellData.movable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
    
    NSString *CellIdentifier = cellData.identifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        Class TableViewClass = self.tableViewCellClassDict[CellIdentifier];
        cell = [[TableViewClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    if (cellData.cellConfigurationBlock) {
        cellData.cellConfigurationBlock(cell);
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
    if (cellData.cellDynamicHeightBlock) {
        return cellData.cellDynamicHeightBlock(tableView, indexPath);
    } else {
        return cellData.height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self.tableViewData sectionDataForSection:section].footerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
    return cellData.editable ? cellData.editingStyle : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
    
    if (!cellData.keepSelection) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    if (cellData.cellSelectionBlock) {
        cellData.cellSelectionBlock(tableView, indexPath);
    }

}

#pragma mark - Table view data delegate

- (void)tableViewDataWillChange:(ARTableViewData *)tableViewData
{
    if (self.animateChanges) {
        [self.tableView beginUpdates];
    }
}

- (void)tableViewData:(ARTableViewData *)tableViewData didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(TableViewDataChangeType)type newSectionIndex:(NSUInteger)newSectionIndex
{
    if (!self.animateChanges) {
        return;
    }
    
    switch(type) {
        case TableViewDataChangeInsert:
        {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeDelete:
        {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeUpdate:
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeMove:
        {
            [self.tableView moveSection:sectionIndex toSection:newSectionIndex];
            break;
        }
    }
}

- (void)tableViewData:(ARTableViewData *)tableViewData didChangeRowAtIndexPath:(NSIndexPath *)indexPath forChangeType:(TableViewDataChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.animateChanges) {
        return;
    }

    UITableView *tableView = self.tableView;

    switch(type) {

        case TableViewDataChangeInsert:
        {
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeUpdate:
        {
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case TableViewDataChangeMove:
        {
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        }
    }
}

- (void)tableViewDataDidChange:(ARTableViewData *)tableViewData
{
    if (self.animateChanges) {
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}
@end
