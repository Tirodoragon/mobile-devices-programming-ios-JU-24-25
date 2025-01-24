//
//  ShoppingListUITests.swift
//  ShoppingListUITests
//
//  Created by Tirodoragon on 1/24/25.
//

import XCTest

final class ShoppingListUITests: XCTestCase {
    var app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launchArguments.append("--reset-state")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    @MainActor
    func testFailedLoginShowsErrorMessageInvalid() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("wronguser")
        
        passwordField.tap()
        passwordField.typeText("wrongpassword")
        
        loginButton.tap()
        
        let errorMessage = app.staticTexts["Invalid username or password."]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed for invalid credentials")
    }
    
    @MainActor
    func testFailedLoginShowsErrorMessageRequired() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("")
        
        loginButton.tap()
        
        let errorMessage = app.staticTexts["Username and password are required."]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed if both fields are not filled in")
    }
    
    @MainActor
    func testSuccessfulLogin() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        XCTAssertTrue(app.navigationBars["Categories"].exists, "User should navigate to Categories screen on successful login")
    }
    
    @MainActor
    func testRegisterWithExistingUser() throws {
        app.buttons["Don't have an account? Register here"].tap()
        
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        let registerButton = app.buttons["Register"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("user")
        
        registerButton.tap()
        
        let errorMessage = app.staticTexts["Username already exists."]
        XCTAssertTrue(errorMessage.exists, "Error message should appear for already existing username")
    }
    
    @MainActor
    func testSuccessfulRegister() throws {
        app.buttons["Don't have an account? Register here"].tap()
        
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        let registerButton = app.buttons["Register"]
        
        usernameField.tap()
        usernameField.typeText("user2")
        
        passwordField.tap()
        passwordField.typeText("user2")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("user2")
        
        registerButton.tap()
        
        let successMessage = app.staticTexts["Registration successful! You can now log in."]
        XCTAssertTrue(successMessage.exists, "Success message should appear that logging in is now possible")
    }
    
    @MainActor
    func testCategoriesLoadSuccessfully() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let navigationTitle = app.staticTexts["Categories"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 10), "The navigation title Categories should be visible.")
        
        let firstCategory = app.staticTexts["Electronics"]
        XCTAssertTrue(firstCategory.waitForExistence(timeout: 10), "Category list should appear after loading.")
        
        let categoryDescription = app.staticTexts["Devices and gadgets"]
        XCTAssertTrue(categoryDescription.exists, "Category description should be visible in the list.")
    }
    
    @MainActor
    func testLogout() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let logoutButton = app.buttons["Logout"]
        logoutButton.tap()
        
        let loginTitle = app.staticTexts["Login"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 10), "The login title should be visible.")
    }
    
    @MainActor
    func testProductsLoadSuccessfully() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let categoryTitle = app.staticTexts["Electronics"]
        XCTAssertTrue(categoryTitle.waitForExistence(timeout: 10), "The category title Electronics should be visible.")
        
        let productTitle = app.staticTexts["Laptop"]
        XCTAssertTrue(productTitle.waitForExistence(timeout: 10), "Product title should appear in the products list.")
        
        let productPrice = app.staticTexts["$3499.99"]
        XCTAssertTrue(productPrice.waitForExistence(timeout: 10), "Product price should appear in the products list.")
    }
    
    @MainActor
    func testProductLoadSuccessfully() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let productTitle = app.staticTexts["Laptop"]
        productTitle.tap()
        
        let productName = app.staticTexts["Laptop"]
        XCTAssertTrue(productName.waitForExistence(timeout: 10), "Product name should appear in the product list.")
        
        let productPrice = app.staticTexts["$3499.99"]
        XCTAssertTrue(productPrice.waitForExistence(timeout: 10), "Product price should appear in the product details.")
        
        let productDescription = app.staticTexts["High-performance laptop with 16GB RAM"]
        XCTAssertTrue(productDescription.waitForExistence(timeout: 10), "Product description should appear in the product details.")
    }
    
    @MainActor
    func testAddingProductNotVisibleForUsers() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let addProduct = app.buttons["plus"]
        XCTAssertFalse(addProduct.exists, "Add button should not be visible for users.")
    }
    
    @MainActor
    func testAddingProductLoadSuccessfully() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("admin")
        
        passwordField.tap()
        passwordField.typeText("admin")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let addProduct = app.buttons["plus"]
        XCTAssertTrue(addProduct.waitForExistence(timeout: 10), "Add button should be visible for admin.")
        addProduct.tap()
        
        let viewTitle = app.staticTexts["Add Product"]
        XCTAssertTrue(viewTitle.waitForExistence(timeout: 10), "The navigation title Add Product should be visible.")
        
        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.exists, "Name text field should be visible.")
        
        let descriptionField = app.textFields["Description"]
        XCTAssertTrue(descriptionField.exists, "Description text field should be visible.")
        
        let priceField = app.textFields["Price"]
        XCTAssertTrue(priceField.exists, "Price text field should be visible.")
        
        let selectImageButton = app.buttons["Select Image"]
        XCTAssertTrue(selectImageButton.exists, "Select Image button should be visible.")
        
        let saveProductButton = app.buttons["Save Product"]
        XCTAssertTrue(saveProductButton.exists, "Save Product button should be visible.")
        
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should be visible.")
    }
    
    @MainActor
    func testAddingProduct() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("admin")
        
        passwordField.tap()
        passwordField.typeText("admin")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let addProduct = app.buttons["plus"]
        addProduct.tap()
        
        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText("Test Product")
        
        let descriptionField = app.textFields["Description"]
        descriptionField.tap()
        descriptionField.typeText("This is a test product description.")
        
        let priceField = app.textFields["Price"]
        priceField.tap()
        priceField.typeText("9.99")
        
        let selectImageButton = app.buttons["Select Image"]
        selectImageButton.tap()
        
        let saveProductButton = app.buttons["Save Product"]
        XCTAssertTrue(saveProductButton.waitForExistence(timeout: 10), "Save Product button should be visible after image selection.")
        saveProductButton.tap()
        saveProductButton.tap()
        
        let productListTitle = app.staticTexts["Electronics"]
        XCTAssertTrue(productListTitle.waitForExistence(timeout: 10), "The category title Electronics should be visible.")
        
        let addedProductName = app.staticTexts["Test Product"]
        XCTAssertTrue(addedProductName.waitForExistence(timeout: 10), "The added product should appear in the product list.")
        
        let addedProductPrice = app.staticTexts["$9.99"]
        XCTAssertTrue(addedProductPrice.waitForExistence(timeout: 10), "The added product price should appear in the product list.")
        
        addedProductName.tap()
        let addedProductDescription = app.staticTexts["This is a test product description."]
        XCTAssertTrue(addedProductDescription.waitForExistence(timeout: 10), "The added product description should appear in the product details.")
    }
    
    @MainActor
    func testCancelAddingProduct() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("admin")
        
        passwordField.tap()
        passwordField.typeText("admin")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let addProduct = app.buttons["plus"]
        addProduct.tap()
        
        let cancelButton = app.buttons["Cancel"]
        cancelButton.tap()
        
        let productListTitle = app.staticTexts["Electronics"]
        XCTAssertTrue(productListTitle.waitForExistence(timeout: 10), "The category title Electronics should be visible.")
    }
    
    @MainActor
    func testAddingProductToCart() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let productTitle = app.staticTexts["Laptop"]
        productTitle.tap()
        
        let addToCartButton = app.buttons["Add to Cart"]
        addToCartButton.tap()
        
        app.tabBars.buttons["Cart"].tap()
        
        XCTAssertTrue(productTitle.waitForExistence(timeout: 10), "Product name should appear in the cart.")
    }
    
    @MainActor
    func testEmptyCart() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        app.tabBars.buttons["Cart"].tap()
        
        let emptyCart = app.staticTexts["Your cart is empty."]
        XCTAssertTrue(emptyCart.waitForExistence(timeout: 10), "The empty cart message should be visible.")
    }
    
    @MainActor
    func testEmptyOrders() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        app.tabBars.buttons["Orders"].tap()
        
        let emptyOrders = app.staticTexts["No orders available."]
        XCTAssertTrue(emptyOrders.waitForExistence(timeout: 10), "The no orders available message should be visible.")
    }
    
    @MainActor
    func testEmptyPaidOrders() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        app.tabBars.buttons["Paid Orders"].tap()
        
        let emptyPaidOrders = app.staticTexts["No paid orders available."]
        XCTAssertTrue(emptyPaidOrders.waitForExistence(timeout: 10), "The no paid orders available message should be visible.")
    }
    
    @MainActor
    func testAddingProductsInCart() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let productTitle = app.staticTexts["Laptop"]
        productTitle.tap()
        
        let addToCartButton = app.buttons["Add to Cart"]
        addToCartButton.tap()
        
        app.tabBars.buttons["Cart"].tap()
        
        let addProduct = app.buttons["plus.circle"]
        addProduct.tap()
        
        let productQuantity = app.staticTexts["2"]
        
        XCTAssertTrue(productQuantity.waitForExistence(timeout: 10), "Product quantity should be 2 after adding.")
    }
    
    @MainActor
    func testRemovingProductsInCart() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let productTitle = app.staticTexts["Laptop"]
        productTitle.tap()
        
        let addToCartButton = app.buttons["Add to Cart"]
        addToCartButton.tap()
        addToCartButton.tap()
        addToCartButton.tap()
        
        app.tabBars.buttons["Cart"].tap()
        
        let addProduct = app.buttons["minus.circle"]
        addProduct.tap()
        
        let productQuantity = app.staticTexts["2"]
        
        XCTAssertTrue(productQuantity.waitForExistence(timeout: 10), "Product quantity should be 2 after removing.")
    }
    
    @MainActor
    func testClearingCart() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        usernameField.tap()
        usernameField.typeText("user")
        
        passwordField.tap()
        passwordField.typeText("user")
        
        loginButton.tap()
        
        let firstCategory = app.staticTexts["Electronics"]
        firstCategory.tap()
        
        let productTitle = app.staticTexts["Laptop"]
        productTitle.tap()
        
        let addToCartButton = app.buttons["Add to Cart"]
        addToCartButton.tap()
        
        app.tabBars.buttons["Cart"].tap()
        
        let addProduct = app.buttons["Clear Cart"]
        addProduct.tap()
        
        let emptyCart = app.staticTexts["Your cart is empty."]
        XCTAssertTrue(emptyCart.waitForExistence(timeout: 10), "The empty cart message should be visible.")
    }
}
