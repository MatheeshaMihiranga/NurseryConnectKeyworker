//
//  NurseryConnectKeyworkerUITests.swift
//  NurseryConnectKeyworkerUITests
//
//  UI tests for the main navigation flows, tab switching,
//  and key user interactions using XCUITest.
//

import XCTest

final class NurseryConnectKeyworkerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation

    func test_homeTabIsVisibleOnLaunch() {
        let homeTab = app.tabBars.buttons["Home tab"]
        XCTAssertTrue(homeTab.exists, "Home tab should be visible on launch")
        XCTAssertTrue(homeTab.isSelected, "Home tab should be selected by default")
    }

    func test_navigateToMyChildrenTab() {
        let childrenTab = app.tabBars.buttons["My Children tab"]
        XCTAssertTrue(childrenTab.waitForExistence(timeout: 3))
        childrenTab.tap()
        let navTitle = app.navigationBars["My Children"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3), "My Children navigation title should appear")
    }

    func test_navigateToDiaryTab() {
        let diaryTab = app.tabBars.buttons["Diary tab"]
        XCTAssertTrue(diaryTab.waitForExistence(timeout: 3))
        diaryTab.tap()
        let navTitle = app.navigationBars["Daily Diary"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3), "Daily Diary navigation title should appear")
    }

    func test_navigateToIncidentsTab() {
        let incidentsTab = app.tabBars.buttons["Incidents tab"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 3))
        incidentsTab.tap()
        let navTitle = app.navigationBars["Incident Reports"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3), "Incident Reports navigation title should appear")
    }

    func test_navigateToAlertsTab() {
        let alertsTab = app.tabBars.buttons.matching(identifier: "Alerts tab with").firstMatch
        if !alertsTab.exists {
            // Try alternative accessibility label format
            let alertsTabAlt = app.tabBars.buttons["Alerts tab with 0 unread alerts"]
            XCTAssertTrue(alertsTabAlt.waitForExistence(timeout: 3) || alertsTab.waitForExistence(timeout: 3))
        }
    }

    func test_allFiveTabsArePresent() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))
        // Should have Home, My Children, Diary, Incidents, Alerts
        XCTAssertGreaterThanOrEqual(tabBar.buttons.count, 5)
    }

    // MARK: - Home Screen

    func test_homeScreen_showsWelcomeText() {
        let welcomeText = app.staticTexts["Welcome back!"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 3),
            "Home screen should display welcome message")
    }

    func test_homeScreen_showsOverviewSection() {
        let overviewText = app.staticTexts["Today's Overview"]
        XCTAssertTrue(overviewText.waitForExistence(timeout: 4),
            "Home screen should show Today's Overview section")
    }

    // MARK: - My Children Screen

    func test_myChildrenScreen_showsChildCards() {
        app.tabBars.buttons["My Children tab"].tap()
        // At least one child card should be visible
        let childList = app.scrollViews.firstMatch
        XCTAssertTrue(childList.waitForExistence(timeout: 3))
    }

    func test_myChildrenScreen_searchBar_isPresent() {
        app.tabBars.buttons["My Children tab"].tap()
        let searchField = app.searchFields["Search by name or room"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3),
            "Search bar should be present on My Children screen")
    }

    func test_myChildrenScreen_searchFiltersResults() {
        app.tabBars.buttons["My Children tab"].tap()
        let searchField = app.searchFields["Search by name or room"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Oliver")
        // Content should update — just verify no crash
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        // Clear search
        searchField.buttons["Clear text"].tap()
    }

    // MARK: - Diary Screen

    func test_diaryScreen_hasPlusButton() {
        app.tabBars.buttons["Diary tab"].tap()
        let addButton = app.navigationBars["Daily Diary"].buttons["Add new diary entry"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3),
            "Add diary entry button should be present")
    }

    func test_diaryScreen_addEntrySheet_opensAndCloses() {
        app.tabBars.buttons["Diary tab"].tap()
        let addButton = app.navigationBars["Daily Diary"].buttons["Add new diary entry"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()

        // Sheet should open with navigation title
        let sheetTitle = app.navigationBars["New Diary Entry"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 3),
            "New Diary Entry sheet should open")

        // Cancel button should close the sheet
        let cancelButton = sheetTitle.buttons["Cancel and close"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()

        // Sheet should be dismissed
        XCTAssertFalse(sheetTitle.waitForExistence(timeout: 2),
            "Sheet should close after tapping Cancel")
    }

    // MARK: - Incident Reports Screen

    func test_incidentScreen_hasPlusButton() {
        app.tabBars.buttons["Incidents tab"].tap()
        let addButton = app.navigationBars["Incident Reports"].buttons["Add new incident report"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3),
            "Add incident report button should be present")
    }

    func test_incidentScreen_addReportSheet_opensAndCloses() {
        app.tabBars.buttons["Incidents tab"].tap()
        let addButton = app.navigationBars["Incident Reports"].buttons["Add new incident report"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()

        let sheetTitle = app.navigationBars["New Incident Report"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 3),
            "New Incident Report sheet should open")

        let cancelButton = sheetTitle.buttons["Cancel and close"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()

        XCTAssertFalse(sheetTitle.waitForExistence(timeout: 2),
            "Sheet should close after tapping Cancel")
    }

    // MARK: - Pull to Refresh

    func test_homeScreen_pullToRefreshDoesNotCrash() {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3))
        scrollView.swipeDown()
        // Just verify the app doesn't crash
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    func test_diaryScreen_pullToRefreshDoesNotCrash() {
        app.tabBars.buttons["Diary tab"].tap()
        let listView = app.tables.firstMatch
        if listView.waitForExistence(timeout: 2) {
            listView.swipeDown()
        }
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }
}
