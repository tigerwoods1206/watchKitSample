/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The test case class for the `List` class.
            
*/

#if os(iOS)
import ListerKit
#elseif os(OSX)
import ListerKitOSX
#endif

import XCTest

class ListTests: XCTestCase {
    // MARK: Properties

    // `items` is initialized again in setUp().
    var items = [ListItem]()
    
    var color = List.Color.Green

    // Both of these lists are initialized in setUp().
    var list: List!

    // MARK: Setup
    
    override func setUp() {
        super.setUp()

        items = [
            ListItem(text: "zero", completed: false),
            ListItem(text: "one", completed: false),
            ListItem(text: "two", completed: false),
            ListItem(text: "three", completed: true),
            ListItem(text: "four", completed: true),
            ListItem(text: "five", completed: true)
        ]

        list = List(color: color, items: items)
    }
    
    // MARK: Initializers
    
    func testDefaultInitializer() {
        list = List()

        XCTAssertEqual(list.color, List.Color.Gray, "The default list color is Gray.")
        XCTAssertTrue(isEmpty(list.items), "A default list has no list items.")
    }
    
    func testColorAndItemsDesignatedInitializer() {
        XCTAssertEqual(list.color, color)

        XCTAssertTrue(list.items == items)
    }

    func testColorAndItemsDesignatedInitializerCopiesItems() {
        for (index, item) in enumerate(list.items) {
            XCTAssertFalse(items[index] === item, "ListItems should be copied in List's init().")
        }
    }
    
    // MARK: NSCopying
    
    func testCopyingLists() {
        let listCopy = list.copy() as? List

        XCTAssertNotNil(listCopy)
        
        if listCopy != nil {
            XCTAssertEqual(list, listCopy!)
        }
    }
    
    // MARK: NSCoding

    func testEncodingLists() {
        let archivedListData = NSKeyedArchiver.archivedDataWithRootObject(list)

        XCTAssertTrue(archivedListData.length > 0)
    }
    
    func testDecodingLists() {
        let archivedListData = NSKeyedArchiver.archivedDataWithRootObject(list)
        
        let unarchivedList = NSKeyedUnarchiver.unarchiveObjectWithData(archivedListData) as? List

        XCTAssertNotNil(unarchivedList)

        if list != nil {
            XCTAssertEqual(list, unarchivedList!)
        }
    }

    // MARK: Equality
    
    func testIsEqual() {
        let listOne = List(color: .Gray, items: items)
        let listTwo = List(color: .Gray, items: items)
        let listThree = List(color: .Green, items: items)
        let listFour = List(color: .Gray, items: [])

        XCTAssertEqual(listOne, listTwo)
        XCTAssertNotEqual(listTwo, listThree)
        XCTAssertNotEqual(listTwo, listFour)
    }

    // MARK: Archive Compatibility
    
    /**
        Ensure that the runtime name of the `List` class is "AAPLList". This is to ensure compatibility
        with the Objective-C version of the app that archives its data with the `AAPLList` class.
    */
    func testClassRuntimeNameForArchiveCompatibility() {
        let classRuntimeName = NSStringFromClass(List.self)

        XCTAssertNotNil(classRuntimeName, "The List class should be an @objc subclass.")

        if classRuntimeName != nil {
            XCTAssertEqual(classRuntimeName!, "AAPLList", "List should be archivable with the ObjC version of Lister.")
        }
    }
}
