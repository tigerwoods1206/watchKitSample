/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Controls the interface of the Glance. The controller displays statistics about the Today list.
            
*/

import WatchKit
import ListerKit

class GlanceInterfaceController: WKInterfaceController, ListsControllerDelegate, ListPresenterDelegate {
    // MARK: Types
    
    struct UserActivity {
        static let glance = "com.example.apple-samplecode.Lister.glance"
        
        struct Keys {
            static let listInfoURLPath = "ListInfoURLPathKey"
        }
    }
    
    // MARK: Properties
    
    @IBOutlet weak var glanceBadgeImage: WKInterfaceImage!
    
    @IBOutlet weak var glanceBadgeGroup: WKInterfaceGroup!
    
    @IBOutlet weak var remainingItemsLabel: WKInterfaceLabel!
    
    var listsController: ListsController?
    
    var listDocument: ListDocument?
    
    var listPresenter: AllListItemsPresenter! {
        return listDocument?.listPresenter as? AllListItemsPresenter
    }
    
    // MARK: Initializers
    
    override init(context: AnyObject?) {
        super.init(context: context)

        setupInterface()
        
        if AppConfiguration.sharedConfiguration.isFirstLaunch {
            println("Lister does not currently support configuring a storage option before the iOS app is launched. Please launch the iOS app first. See the Release Notes section in README.md for more information.")
        }
    }
    
    // MARK: Setup

    func setupInterface() {
        initializeListsController()
        
        // Show the initial data.
        glanceBadgeImage.setImage(nil)

        remainingItemsLabel.setHidden(true)
    }
    
    func initializeListsController() {
        // Determine what kind of storage we should be using (local or iCloud).
        var listCoordinator: ListCoordinator

        if AppConfiguration.sharedConfiguration.storageOption != .Cloud {
            // This will be called if the storage option is either Local or NotSet.
            listCoordinator = LocalListCoordinator(lastPathComponent: AppConfiguration.localizedTodayDocumentNameAndExtension)
        }
        else {
            listCoordinator = CloudListCoordinator(lastPathComponent: AppConfiguration.localizedTodayDocumentNameAndExtension)
        }
        
        listsController = ListsController(listCoordinator: listCoordinator, delegateQueue: NSOperationQueue.mainQueue()) { lhs, rhs in
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .OrderedAscending
        }
        
        listsController!.delegate = self
        
        listsController!.startSearching()
    }
    
    // MARK: ListsControllerDelegate

    func listsController(_: ListsController, didInsertListInfo listInfo: ListInfo, atIndex index: Int) {
        // We only expect a single result to be returned, so we will treat this listInfo as the Today document.
        processListInfoAsTodayDocument(listInfo)
    }
    
    // MARK: ListPresenterDelegate
    
    func listPresenterDidRefreshCompleteLayout(_: ListPresenterType) {
        // Since the list changed completely, show present the Glance badge.
        presentGlanceBadge()
    }
    
    /**
        These methods are no ops because all of the data is bulk rendered after the the content changes. This
        can occur in `listPresenterDidRefreshCompleteLayout(_:)` or in `listPresenterDidChangeListLayout(_:isInitialLayout:)`.
    */
    func listPresenterWillChangeListLayout(_: ListPresenterType, isInitialLayout: Bool) {}
    func listPresenter(_: ListPresenterType, didInsertListItem listItem: ListItem, atIndex index: Int) {}
    func listPresenter(_: ListPresenterType, didRemoveListItem listItem: ListItem, atIndex index: Int) {}
    func listPresenter(_: ListPresenterType, didUpdateListItem listItem: ListItem, atIndex index: Int) {}
    func listPresenter(_: ListPresenterType, didUpdateListColorWithColor color: List.Color) {}
    func listPresenter(_: ListPresenterType, didMoveListItem listItem: ListItem, fromIndex: Int, toIndex: Int) {}
    
    func listPresenterDidChangeListLayout(_: ListPresenterType, isInitialLayout: Bool) {
        /*
            The list's layout changed. However, since we don't care that a small detail about the list changed,
            we're going to re-animate the badge.
        */
        presentGlanceBadge()
    }
    
    // MARK: Convenience
    
    func processListInfoAsTodayDocument(listInfo: ListInfo) {
        let userInfo = [UserActivity.Keys.listInfoURLPath: listInfo.URL.path!]
        updateUserActivity(UserActivity.glance, userInfo: userInfo)
        
        let listPresenter = AllListItemsPresenter()

        listDocument = ListDocument(fileURL: listInfo.URL, listPresenter: listPresenter)
        
        listPresenter.delegate = self

        listDocument?.openWithCompletionHandler() { success in
            if !success {
                NSLog("Couldn't open document: \(self.listDocument?.fileURL.absoluteString)")

                return
            }
        }
    }
    
    func presentGlanceBadge() {
        let totalListItemCount = listPresenter.count
        
        let completeListItemCount = listPresenter.presentedListItems.filter { $0.isComplete }.count
        
        let glanceBadge = GlanceBadge(totalItemCount: totalListItemCount, completeItemCount: completeListItemCount)
        
        glanceBadgeGroup.setBackgroundImage(glanceBadge.groupBackgroundImage)
        glanceBadgeImage.setImageNamed(glanceBadge.imageName)
        glanceBadgeImage.startAnimatingWithImagesInRange(glanceBadge.imageRange, duration: glanceBadge.animationDuration, repeatCount: 1)
        
        /*
            Create a localized string for the # items remaining in the Glance badge. The string is retrieved
            from the Localizable.stringsdict file.
        */
        let itemsRemainingText = String.localizedStringWithFormat(NSLocalizedString("%d items left", comment: ""), glanceBadge.incompleteItemCount)
        remainingItemsLabel.setText(itemsRemainingText)
        remainingItemsLabel.setHidden(false)
    }
}
