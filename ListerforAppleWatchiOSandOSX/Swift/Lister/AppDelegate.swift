/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The application delegate.
            
*/

import UIKit
import ListerKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    // MARK: Types
    
    struct MainStoryboard {
        static let name = "Main"
        
        struct Identifiers {
            static let emptyViewController = "emptyViewController"
        }
    }

    // MARK: Properties

    var window: UIWindow!

    var listsController: ListsController!

    // MARK: View Controller Accessor Convenience
    
    /**
        The root view controller of the window will always be a `UISplitViewController`. This is set up
        in the main storyboard.
    */
    var splitViewController: UISplitViewController {
        return window.rootViewController as UISplitViewController
    }

    /// The primary view controller of the split view controller defined in the main storyboard.
    var primaryViewController: UINavigationController {
        return splitViewController.viewControllers.first as UINavigationController
    }
    
    /**
        The view controller that displays the list of documents. If it's not visible, then this value
        is `nil`.
    */
    var listDocumentsViewController: ListDocumentsViewController? {
        return primaryViewController.viewControllers.first as? ListDocumentsViewController
    }
    
    // MARK: UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUbiquityIdentityDidChangeNotification:", name: NSUbiquityIdentityDidChangeNotification, object: nil)
        
        AppConfiguration.sharedConfiguration.runHandlerOnFirstLaunch {
            ListUtilities.copyInitialLists()
        }

        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible
        let navigationController = splitViewController.viewControllers.last as UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        navigationController.topViewController.navigationItem.leftItemsSupplementBackButton = true
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        setupUserStoragePreferences()
    }
    
    func application(_: UIApplication, continueUserActivity: NSUserActivity, restorationHandler: [AnyObject] -> Void) -> Bool {
        // Lister only supports a single user activity type; if you support more than one the type is available from the `continueUserActivity` parameter.
        if let listDocumentsViewController = listDocumentsViewController {
            restorationHandler([listDocumentsViewController])
            return true
        }
        
        return false
    }
    
    // MARK: UISplitViewControllerDelegate

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController _: UIViewController) -> Bool {
        // If there's a list that's currently selected in separated mode and we want to show it in collapsed mode, we'll transfer over the view controller's settings.
        if secondaryViewController is UINavigationController && (secondaryViewController as UINavigationController).topViewController is ListViewController {
            let secondaryNavigationController = secondaryViewController as UINavigationController
            primaryViewController.navigationBar.titleTextAttributes = secondaryNavigationController.navigationBar.titleTextAttributes
            primaryViewController.navigationBar.tintColor = secondaryNavigationController.navigationBar.tintColor
            primaryViewController.toolbar?.tintColor = secondaryNavigationController.toolbar?.tintColor
            
            return false
        }
        
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController _: UIViewController) -> UIViewController? {
        if primaryViewController.topViewController is UINavigationController && (primaryViewController.topViewController as UINavigationController).topViewController is ListViewController {
            let secondaryViewController = primaryViewController.popViewControllerAnimated(false) as UINavigationController
            let listViewController = secondaryViewController.topViewController as ListViewController
            
            // Obtain the `textAttributes` and `tintColor` to setup the separated navigation controller.    
            let textAttributes = listViewController.textAttributes
            let tintColor = listViewController.listPresenter.color.colorValue
            
            secondaryViewController.navigationBar.titleTextAttributes = textAttributes
            secondaryViewController.navigationBar.tintColor = tintColor
            secondaryViewController.toolbar?.tintColor = tintColor

            secondaryViewController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
            
            return secondaryViewController
        }
        
        return nil
    }
    
    // MARK: Notifications
    
    func handleUbiquityIdentityDidChangeNotification(notification: NSNotification) {
        primaryViewController.popToRootViewControllerAnimated(true)
        
        setupUserStoragePreferences()
    }
    
    // MARK: User Storage Preferences
    
    func setupUserStoragePreferences() {
        let storageState = AppConfiguration.sharedConfiguration.storageState
    
        // Check to see if the account has changed since the last time the method was called. If it
        // has, let the user know that their documents have changed. If they've already chosen local
        // storage (i.e. not iCloud), don't notify them since there's no impact.
        if storageState.accountDidChange && storageState.storageOption == .Cloud {
            notifyUserOfAccountChange(storageState)
            // Return early. State resolution will take place after the user acknowledges the change.
            return
        }

        resolveStateForUserStorageState(storageState)
    }
    
    func resolveStateForUserStorageState(storageState: StorageState) {
        if storageState.cloudAvailable {
            if storageState.storageOption == .NotSet  || (storageState.storageOption == .Local && storageState.accountDidChange) {
                // iCloud is available, but we need to ask the user what they prefer.
                promptUserForStorageOption()
            }
            else {
                // The user has already selected a specific storage option. Set up the lists controller
                // to use that storage option.
                configureListsController(accountChanged: storageState.accountDidChange)
            }
        }
        else {
            // iCloud is not available, so we'll reset the storage option and configure the list
            // controller. The next time that the user signs in with an iCloud account, he or she can
            // change provide their desired storage option.
            if storageState.storageOption != .NotSet {
                AppConfiguration.sharedConfiguration.storageOption = .NotSet
            }
            
            configureListsController(accountChanged: storageState.accountDidChange)
        }
    }
    
    // MARK: Alerts
    
    func notifyUserOfAccountChange(storageState: StorageState) {
        // Copy a 'Today' list from the bundle to the local documents directory if a 'Today' list
        // doesn't exist. This provides more context for the user than no lists and ensures the user
        // always has a 'Today' list (a design choice made in Lister).
        if !storageState.cloudAvailable {
            ListUtilities.copyTodayList()
        }
        
        let title = NSLocalizedString("Sign Out of iCloud", comment: "")
        let message = NSLocalizedString("You have signed out of the iCloud account previously used to store documents. Sign back in with that account to access those documents.", comment: "")
        let okActionTitle = NSLocalizedString("OK", comment: "")
        
        let signedOutController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        let action = UIAlertAction(title: okActionTitle, style: .Cancel) { action in
            self.resolveStateForUserStorageState(storageState)
        }
        signedOutController.addAction(action)
        
        listDocumentsViewController?.presentViewController(signedOutController, animated: true, completion: nil)
    }
    
    func promptUserForStorageOption() {
        let title = NSLocalizedString("Choose Storage Option", comment: "")
        let message = NSLocalizedString("Do you want to store documents in iCloud or only on this device?", comment: "")
        let localOnlyActionTitle = NSLocalizedString("Local Only", comment: "")
        let cloudActionTitle = NSLocalizedString("iCloud", comment: "")
        
        let storageController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let localOption = UIAlertAction(title: localOnlyActionTitle, style: .Default) { localAction in
            AppConfiguration.sharedConfiguration.storageOption = .Local

            self.configureListsController(accountChanged: true)
        }
        storageController.addAction(localOption)
        
        let cloudOption = UIAlertAction(title: cloudActionTitle, style: .Default) { cloudAction in
            AppConfiguration.sharedConfiguration.storageOption = .Cloud

            self.configureListsController(accountChanged: true) {
                ListUtilities.migrateLocalListsToCloud()
            }
        }
        storageController.addAction(cloudOption)
        
        listDocumentsViewController?.presentViewController(storageController, animated: true, completion: nil)
    }
   
    // MARK: Convenience
    
    func configureListsController(#accountChanged: Bool, storageOptionChangeHandler: (Void -> Void)? = nil) {
        if listsController != nil && !accountChanged {
            // The current controller is appropriate. There is no need to reconfigure it.
            return
        }
        
        var listCoordinator: ListCoordinator
        
        if AppConfiguration.sharedConfiguration.storageOption != .Cloud {
            // This will be called if the storage option is either Local or NotSet.
            listCoordinator = LocalListCoordinator(pathExtension: AppConfiguration.listerFileExtension, firstQueryUpdateHandler: storageOptionChangeHandler)
        }
        else {
            listCoordinator = CloudListCoordinator(pathExtension: AppConfiguration.listerFileExtension, firstQueryUpdateHandler: storageOptionChangeHandler)
        }

        if listsController == nil {
            listsController = ListsController(listCoordinator: listCoordinator, delegateQueue: NSOperationQueue.mainQueue()) { lhs, rhs in
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .OrderedAscending
            }

            listDocumentsViewController?.listsController = listsController
            
            listsController.startSearching()
        }
        else if accountChanged {
            listsController.listCoordinator = listCoordinator
        }
    }
}

