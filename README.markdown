ARGenericTableViewController
===============

The ARGenericTableViewController framework offers a higher flexibility to create tables with different 
cell types in iOS using an object oriented approach.

The ARGenericTableViewController is a iOS component to configure TableViews. Just like static TableViews 
in the Storyboard you can easily configure complex TableViews with lots of different Cell 
Classes in Code. The sections and cells of the TableView are represented by plain objects which 
have all the information to layout the TableView and to react to user events. 

You can change the content of the TableView by modifying the objects. Surley the changes
can be animated. All the TableView delegate and datasource protocol methods are implemented 
for you.


Please enjoy this framework!


Features:
-------

- configure the TableView with objects and blocks
- simplifies the creation of static or dynamic TableViews
- provides the ability to change the content of the TableView very easily and with animations
- works with iOS 5.0+
- uses ARC
- available via CocoaPods
- MIT open source licence

How to use
---------

1. Create a subclass of the `ARGenericTableViewController` (It is also possible to work directly with the `ARGenericTableViewController`)

2. Create an `ARTableViewData` object as a representation of the whole tableview

3. Create and configure an `ARSectionData` object and add it to the `ARTableViewData` object with the `addSectionData:` method

3. Create and configure an `ARCellData` object and add it to the `ARSectionData` object with the `addCellData:` method

4. Set the `tableViewData` property of the `ARGenericTableViewController`.  This will automatically reload the TableView


Example
-------
    ARTableViewData *tableViewData = [[ARTableViewData alloc] init];
    ARSectionData *sectionData = [[ARSectionData alloc] init];
    sectionData.headerTitle = @"Header";
    [tableViewData addSectionData:sectionData];
    
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:@"Cell"];
    cellData.editable = YES;
    cellData.height = 44;

    [cellData setCellConfigurationBlock:^(UITableViewCell *cell) {
        // called in cellForRowAtIndexPath
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", i];
    }];

    [cellData setCellSelectionBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        // called in didSelectRowAtIndexPath
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = [NSString stringWithFormat:@"Cell %d", i];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }];

    [sectionData addCellData:cellData];
    
	// tableViewData property is provided by ARGenericTableViewController
    self.tableViewData = tableViewData;


Licence
----------
 Copyright (c) 2013 arconsis IT-Solutions GmbH (http://www.arconsis.com )
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial 
 portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
