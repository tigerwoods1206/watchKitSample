# WatchKit Catalog: Using WatchKit Interface Elements

WatchKit Catalog is an exploration of the UI elements available in the WatchKit framework. Throughout the sample, you'll find tips and configurations that will help guide the development of your Watch app.

### Tips

- To debug the Glance or notifications in the iOS Simulator, select the appropriate scheme in the Xcode toolbar and then Build and Run.

- Tapping the Glance will launch the Watch app. In AAPLGlanceController, -updateUserActivity:userInfo: is called in -willActivate and takes advantage of Handoff to launch the wearer into the image detail controller (AAPLImageDetailController). When the Watch app is launched from the Glance, actionForUserActivity:context: is called in AAPLInterfaceController. AAPLImageDetailController will be pushed to, as its controller's Identifier string is passed in the userActivity dictionary.

- AAPLButtonDetailController has two examples of how to hide and show UI elements at runtime. First, tapping on button "1" will toggle the hidden property of button "2." When hiding the button, the layout will change to make use of the newly available space. When showing it again, the layout will change to make room for it. The second example is by setting the alpha property of button "2" to 0.0 or 1.0. Tapping on button "3" will toggle this and while button "2" may look invisible, the space it takes up does not change and no layout changes will occur.

- WKInterfaceDevice's screenBounds property is used in AAPLImageDetailController to decide which image resource to load at runtime, depending on the wearer having a 38mm or 42mm Apple Watch. This technique should also be used for setting the height or width of fixed-sized UI elements at runtime, as is needed.

- In AAPLImageDetailController, note the comments where the first image is being sent across to Apple Watch from the WatchKit Extension bundle. The second image is animated and all of the images required for the sequence are stored in the Watch app bundle. Comments are made throughout the sample project where images are used from one bundle or another.

- In the storyboard scene for AAPLGroupDetailController, note the use of nested groups to achieve more sophisticated layouts of images and labels. This is highly encouraged and will be necessary to achieve specific designs.

- AAPLTableDetailController has an example of inserting more rows into a table after the initial set of rows have been added to a table.

- AAPLControllerDetailController shows how to present a modal controller, as well as how to present a controller that does not match the navigation style of your root controller. In this case, the Watch app has a hierarchical navigation style. Using the presentation of a modal controller though, we are able to present a page-based set of controllers.

- AAPLControllerDetailController can present a modal controller. The "Dismiss" text of the modal controller is set in the Title field in the Attributes Inspector of the scene for AAPLPageController.

## Requirements

### Build

Xcode 6.2 or later; iOS 8.2 SDK or later

### Runtime

iOS 8.2 or later

Copyright (C) 2014 Apple Inc. All rights reserved.
