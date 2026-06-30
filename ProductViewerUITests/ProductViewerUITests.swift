//
//  ProductViewerUITests.swift
//  ProductViewerUITests
//
//  Created by Jigs Sheth on 1/27/22.
//

import XCTest

final class ProductViewerUITests: XCTestCase {
    private enum TestData {
        static let firstProductTitle = "UI Test Product 1"
        static let lastProductTitle = "UI Test Product 10"
        static let selectedProductTitle = "UI Test Product 3"
        static let selectedProductDescription = "Description for UI Test Product 3"
        static let selectedProductRegularPrice = "$3.00"
        static let selectedProductSalePrice = "$1.50"
    }

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launchEnvironment["UI_TESTING"] = "1"
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testScrollProductListTapItemAndVerifyDetailView() throws {
        app.launch()

        dismissErrorAlertIfPresent()

        let firstProduct = app.staticTexts[TestData.firstProductTitle]
        XCTAssertTrue(
            firstProduct.waitForExistence(timeout: 15),
            "First product should appear once UI test data is loaded"
        )

        let scrollContainer = productScrollContainer
        XCTAssertTrue(scrollContainer.exists, "Product list scroll container should exist")

        scrollUntilVisible(TestData.lastProductTitle, in: scrollContainer)
        XCTAssertTrue(app.staticTexts[TestData.lastProductTitle].exists, "Last product should become visible after scrolling")

        scrollUntilVisible(TestData.selectedProductTitle, in: scrollContainer)

        let selectedCell = app.buttons[AccessibilityID.productCell(id: 3)]
        if selectedCell.waitForExistence(timeout: 2) {
            selectedCell.tap()
        } else {
            app.staticTexts[TestData.selectedProductTitle].tap()
        }

        XCTAssertTrue(
            app.navigationBars[TestData.selectedProductTitle].waitForExistence(timeout: 10),
            "Detail navigation title should match the selected product"
        )

        let description = app.staticTexts[TestData.selectedProductDescription]
        XCTAssertTrue(description.waitForExistence(timeout: 5), "Product description should be shown on detail screen")

        XCTAssertTrue(
            app.staticTexts[TestData.selectedProductSalePrice].waitForExistence(timeout: 5),
            "Sale price should be displayed for the selected product"
        )
        XCTAssertTrue(
            app.staticTexts[TestData.selectedProductRegularPrice].exists,
            "Regular price should be displayed for the selected product"
        )

        XCTAssertTrue(app.buttons["add to cart"].exists, "Add to cart button should be visible")
        XCTAssertTrue(app.buttons["add to list"].exists, "Add to list button should be visible")
    }

    private var productScrollContainer: XCUIElement {
        if app.tables[AccessibilityID.productList].exists {
            return app.tables[AccessibilityID.productList]
        }
        if app.collectionViews[AccessibilityID.productList].exists {
            return app.collectionViews[AccessibilityID.productList]
        }
        if app.tables.firstMatch.exists {
            return app.tables.firstMatch
        }
        return app.collectionViews.firstMatch
    }

    private func dismissErrorAlertIfPresent() {
        let retryButton = app.buttons["Retry!"]
        if retryButton.waitForExistence(timeout: 2) {
            retryButton.tap()
        }
    }

    private func scrollUntilVisible(_ label: String, in scrollContainer: XCUIElement, maxSwipes: Int = 6) {
        let target = app.staticTexts[label]
        guard !target.isHittable else { return }

        for _ in 0..<maxSwipes where !target.isHittable {
            scrollContainer.swipeUp(velocity: .fast)
        }

        for _ in 0..<maxSwipes where !target.isHittable {
            scrollContainer.swipeDown(velocity: .fast)
        }

        XCTAssertTrue(target.exists, "\(label) should exist after scrolling")
    }
}

private enum AccessibilityID {
    static let productList = "productList"

    static func productCell(id: Int) -> String {
        "productCell_\(id)"
    }
}
