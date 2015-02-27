/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The `WatchListInterfaceController` interface controller that presents a single list managed by a `ListPresenterType` object.
            
*/

import WatchKit
import ListerKit

/**
    The interface controller that presents a list. The interface controller listens for changes to how the list
    should be presented by the list presenter.
*/
class WatchListInterfaceController: WKInterfaceController, ListPresenterDelegate {
    // MARK: Types
    
    struct WatchStoryboard {
        static let  interfaceControllerName = "WatchListInterfaceController"
        
        struct RowTypes {
            static let item = "WatchListControllerItemRowType"
            static let noItems = "WatchListControllerNoItemsRowType"
        }
    }
    
    // MARK: Properties
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    let listDocument: ListDocument!
    
    var listPresenter: IncompleteListItemsPresenter! {
        return listDocument?.listPresenter as? IncompleteListItemsPresenter
    }
    
    // MARK: Initializers
    
    override init(context: AnyObject?) {
        precondition(context is ListInfo, "Expected class of `context` to be ListInfo.")

        let listInfo = context as ListInfo
        listDocument = ListDocument(fileURL: listInfo.URL)
        
        super.init(context: context)

        // Set the title of the interface controller based on the list's name.
        setTitle(listInfo.name)
     
        // Fill the interface table with the current list items.
        setupInterfaceTable()
    }
    
    func setupInterfaceTable() {
        listDocument.listPresenter = IncompleteListItemsPresenter()
        
        listPresenter.delegate = self
        
        listDocument.openWithCompletionHandler { success in
            if !success {
                println("Couldn't open document: \(self.listDocument?.fileURL).")
                
                return
            }
        }
    }
    
    // MARK: Interface Table Selection
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let listItem = listPresenter.presentedListItems[rowIndex]

        listPresenter.toggleListItem(listItem)
    }
    
    // MARK: Actions
    
    @IBAction func markAllListItemsAsComplete() {
        listPresenter.updatePresentedListItemsToCompletionState(true)
    }
    
    @IBAction func markAllListItemsAsIncomplete() {
        listPresenter.updatePresentedListItemsToCompletionState(false)
    }
    
    func refreshAllData() {
        let listItemCount = listPresenter.count
        if listItemCount > 0 {
            interfaceTable.setNumberOfRows(listItemCount, withRowType: WatchStoryboard.RowTypes.item)
            
            for idx in 0..<listItemCount {
                configureRowControllerAtIndex(idx)
            }
        }
        else {
            let indexSet = NSIndexSet(index: 0)
            interfaceTable.insertRowsAtIndexes(indexSet, withRowType: WatchStoryboard.RowTypes.noItems)
        }
    }
    
    // MARK: ListPresenterDelegate
    
    func listPresenterDidRefreshCompleteLayout(_: ListPresenterType) {
        refreshAllData()
    }
    
    func listPresenterWillChangeListLayout(_: ListPresenterType, isInitialLayout: Bool) {
        // `WKInterfaceTable` objects do not need to be notified of changes to the table, so this is a no op.
    }
    
    func listPresenter(_: ListPresenterType, didInsertListItem listItem: ListItem, atIndex index: Int) {
        let indexSet = NSIndexSet(index: index)
        
        // The list presenter was previously empty. Remove the "no items" row.
        if index == 0 && listPresenter!.count == 1 {
            interfaceTable.removeRowsAtIndexes(indexSet)
        }
        
        interfaceTable.insertRowsAtIndexes(indexSet, withRowType: WatchStoryboard.RowTypes.item)
    }
    
    func listPresenter(_: ListPresenterType, didRemoveListItem listItem: ListItem, atIndex index: Int) {
        let indexSet = NSIndexSet(index: index)

        interfaceTable.removeRowsAtIndexes(indexSet)
        
        // The list presenter is now empty. Add the "no items" row.
        if index == 0 && listPresenter!.isEmpty {
            interfaceTable.insertRowsAtIndexes(indexSet, withRowType: WatchStoryboard.RowTypes.noItems)
        }
    }
    
    func listPresenter(_: ListPresenterType, didUpdateListItem listItem: ListItem, atIndex index: Int) {
        configureRowControllerAtIndex(index)
    }
    
    func listPresenter(_: ListPresenterType, didMoveListItem listItem: ListItem, fromIndex: Int, toIndex: Int) {
        // Remove the item from the fromIndex straight away.
        let fromIndexSet = NSIndexSet(index: fromIndex)
        
        interfaceTable.removeRowsAtIndexes(fromIndexSet)
        
        /*
            Determine where to insert the moved item. If the `toIndex` was beyond the `fromIndex`, normalize
            its value.
        */
        var toIndexSet: NSIndexSet
        if toIndex > fromIndex {
            toIndexSet = NSIndexSet(index: toIndex - 1)
        }
        else {
            toIndexSet = NSIndexSet(index: toIndex)
        }
        
        interfaceTable.insertRowsAtIndexes(toIndexSet, withRowType: WatchStoryboard.RowTypes.item)
    }
    
    func listPresenter(_: ListPresenterType, didUpdateListColorWithColor color: List.Color) {
        for idx in 0..<listPresenter.count {
            configureRowControllerAtIndex(idx)
        }
    }
    
    func listPresenterDidChangeListLayout(_: ListPresenterType, isInitialLayout: Bool) {
        if isInitialLayout {
            // Display all of the list items on the first layout.
            refreshAllData()
        }
        else {
            /*
                The underlying document changed because of user interaction (this event only occurs if the
                list presenter's underlying list presentation changes based on user interaction).
            */
            listDocument.updateChangeCount(.Done)
        }
    }
    
    // MARK: Convenience
    
    func configureRowControllerAtIndex(index: Int) {
        let listItemRowController = interfaceTable.rowControllerAtIndex(index) as ListItemRowController
        
        let listItem = listPresenter.presentedListItems[index]
        
        listItemRowController.setText(listItem.text)
        let textColor = listItem.isComplete ? UIColor.grayColor() : UIColor.whiteColor()
        listItemRowController.setTextColor(textColor)
        
        // Update the checkbox image.
        let state = listItem.isComplete ? "checked" : "unchecked"
        let imageName = "checkbox-\(listPresenter.color.description.lowercaseString)-\(state)"
        listItemRowController.setCheckBoxImageNamed(imageName)
    }
    
    // MARK: Interface Life Cycle
    
    override func didDeactivate() {
        listDocument.closeWithCompletionHandler(nil)
    }
}
