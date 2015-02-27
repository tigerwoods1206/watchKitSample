/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The `WatchListInterfaceController` that presents a single list managed by a `ListPresenterType` instance.
            
*/

import WatchKit
import ListerKit

class WatchListsInterfaceController: WKInterfaceController, ListsControllerDelegate {
    // MARK: Types
    
    struct WatchStoryboard {
        static let interfaceControllerName = "WatchListsInterfaceController"
        
        struct RowTypes {
            static let list = "WatchListsInterfaceControllerListRowType"
            static let noLists = "WatchListsInterfaceControllerNoListsRowType"
        }
        
        struct Segues {
            static let listSelection = "WatchListsInterfaceControllerListSelectionSegue"
        }
    }
    
    // MARK: Properties
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    var listsController: ListsController!

    // MARK: Initializers
    
    override init(context: AnyObject?) {
        super.init(context: context)

        initializeListsController()
        
        let noListsIndexSet = NSIndexSet(index: 0)
        interfaceTable.insertRowsAtIndexes(noListsIndexSet, withRowType: WatchStoryboard.RowTypes.noLists)
        
        if AppConfiguration.sharedConfiguration.isFirstLaunch {
            println("Lister does not currently support configuring a storage option before the iOS app is launched. Please launch the iOS app first. See the Release Notes section in README.md for more information.")
        }
    }
    
    func initializeListsController() {
        var listCoordinator: ListCoordinator

        if AppConfiguration.sharedConfiguration.storageOption != .Cloud {
            // This will be called if the storage option is either Local or NotSet.
            listCoordinator = LocalListCoordinator(pathExtension: AppConfiguration.listerFileExtension)
        }
        else {
            listCoordinator = CloudListCoordinator(pathExtension: AppConfiguration.listerFileExtension)
        }
        
        listsController = ListsController(listCoordinator: listCoordinator, delegateQueue: NSOperationQueue.mainQueue()) { lhs, rhs in
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .OrderedAscending
        }
    }
    
    // MARK: ListsControllerDelegate

    func listsController(listsController: ListsController, didInsertListInfo listInfo: ListInfo, atIndex index: Int) {
        let indexSet = NSIndexSet(index: index)
        
        // The lists controller was previously empty. Remove the "no lists" row.
        if index == 0 && listsController.count == 1 {
            interfaceTable.removeRowsAtIndexes(indexSet)
        }
        
        interfaceTable.insertRowsAtIndexes(indexSet, withRowType: WatchStoryboard.RowTypes.list)

        configureRowControllerAtIndex(index)
    }
    
    func listsController(listsController: ListsController, didRemoveListInfo listInfo: ListInfo, atIndex index: Int) {
        let indexSet = NSIndexSet(index: index)
        
        // The lists controller is now empty. Add the "no lists" row.
        if index == 0 && listsController.count == 0 {
            interfaceTable.insertRowsAtIndexes(indexSet, withRowType: WatchStoryboard.RowTypes.noLists)
        }
        
        interfaceTable.removeRowsAtIndexes(indexSet)
    }
    
    func listsController(listsController: ListsController, didUpdateListInfo listInfo: ListInfo, atIndex index: Int) {
        configureRowControllerAtIndex(index)
    }

    // MARK: Segues
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == WatchStoryboard.Segues.listSelection {
            let listInfo = listsController[rowIndex]

            return listInfo
        }
        
        return nil
    }
    
    // MARK: Convenience
    
    func configureRowControllerAtIndex(index: Int) {
        let watchListRowController = interfaceTable.rowControllerAtIndex(index) as ColoredTextRowController
        
        let listInfo = listsController[index]
        
        watchListRowController.setText(listInfo.name)
        
        listInfo.fetchInfoWithCompletionHandler() {
            dispatch_async(dispatch_get_main_queue()) {
                let watchListRowController = self.interfaceTable.rowControllerAtIndex(index) as ColoredTextRowController

                watchListRowController.setColor(listInfo.color!.colorValue)
            }
        }
    }
    
    // MARK: Interface Life Cycle

    override func willActivate() {
        listsController.delegate = self

        listsController.startSearching()
    }

    override func didDeactivate() {
        listsController.stopSearching()
        
        listsController.delegate = nil
    }
    
    override func actionForUserActivity(userActivity: [NSObject : AnyObject]?, context: AutoreleasingUnsafeMutablePointer<AnyObject?>) -> String? {
        // The Lister watch app only supports continuing activities where
        // `GlanceInterfaceController.UserActivity.Keys.listInfoURLPath` is provided.
        let listInfoURLPath = userActivity?[GlanceInterfaceController.UserActivity.Keys.listInfoURLPath] as? String
        
        if listInfoURLPath == nil {
            return nil
        }
        
        let listInfoURL = NSURL(fileURLWithPath: listInfoURLPath!)!
        let listInfo = ListInfo(URL: listInfoURL)
        
        // Set the context to the listInfo (following the behavior of the selection segue).
        context.memory = listInfo
        
        // Returne the watch list scene's identifier, set in Interface Builder to route the wearer to it.
        return WatchListInterfaceController.WatchStoryboard.interfaceControllerName
    }
}
