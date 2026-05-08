# ProductViewer

A SwiftUI sample app that displays a list of products with detail views, demonstrating modern Swift patterns like async/await networking, MVVM, custom styling, and accessibility.

## Features

- SwiftUI interface with product list and detail views
- MVVM architecture (`ProductViewModel`, `ProductViewModelImpl`)
- Async/await data loading via `ProductService.fetchProducts()`
- Reusable UI components:
  - `ButtonView` with a custom `SquishableButtonStyle`
  - `ProductViewCell` and `ProductCellViewWithNavigation`
- Design helpers:
  - `Color` extensions (`lightBlack`, `random`)
  - Currency symbol handling via `CurrencySymbol`
- Navigation with `NavigationLink` and hidden row separators for a clean look
- Accessibility identifiers on key controls (e.g., Add to Cart / Add to List buttons)

## Screenshots

Add screenshots or GIFs here to showcase the product list and detail flows.

## Requirements

- Xcode 14 or later
- iOS 15 or later
- Swift 5.5+ (async/await)

## Getting Started

1. Open the Xcode project/workspace in the repository.
2. Build and run the app on an iOS simulator or device.
3. The app will load products asynchronously and present them in a list. Tap a product to see its details.

## Architecture

- Models: `Product` (and related types)
- Views: SwiftUI views for list, cells, and detail screens
- ViewModels: `ProductViewModel` protocol and `ProductViewModelImpl` implementation
- Repository: `ProductRepository` and `ProductRepositoryImpl` (cache-first orchestration)
- Local store: `ProductJSONLocalStore` (Codable JSON cache for offline support)
- Remote service: `ProductService` provides `fetchProducts()`
- Freshness: `Product.updatedAt` is used to decide whether remote data is newer

Data flow:

```mermaid
flowchart TD
    A["UIView / SwiftUI View<br/>ProductListView, ProductDetailView"]
    B["ViewModel Layer<br/>ProductViewModel (protocol)<br/>ProductViewModelImpl"]
    C["Repository Layer<br/>ProductRepositoryImpl"]
    D["Local Cache<br/>ProductJSONLocalStore"]
    E["Remote Service<br/>ProductService"]
    F["Remote API<br/>Products Endpoint"]
    G["Model Layer<br/>Product + updatedAt"]

    A -->|"onAppear / pull-to-refresh"| B
    B -->|"loadCachedProducts() / refreshProductsFromRemote()"| C
    C -->|"Read cached products first"| D
    D -->|"Cached [Product]"| C
    C -->|"Return cached data"| B
    B -->|"Publish cached state immediately"| A
    C -->|"Background refresh"| E
    E -->|HTTP request| F
    F -->|JSON response| E
    E -->|"Decoded [Product]"| C
    C -->|"Compare by id + updatedAt, merge, de-duplicate"| D
    D -->|"Cache changed -> notify via new read"| C
    C -->|"Updated [Product]"| B
    B -->|"Publish only when cache changes"| A
```

- `View` never calls the network directly; it only interacts with the `ViewModel`.
- `ViewModel` always renders local cache first for fast startup and offline support.
- `Repository` fetches remote data in the background and merges by `id` + `updatedAt`.
- Local cache is the source of truth for UI updates; UI refreshes only when cache changes.
- Duplicate products are prevented by de-duplication during merge.
- If offline, cached data still renders and refresh failures are handled gracefully.

Sequence flow (request/response over time):

```mermaid
sequenceDiagram
    autonumber
    participant V as UIView / SwiftUI View
    participant VM as ProductViewModelImpl
    participant R as ProductRepositoryImpl
    participant L as ProductJSONLocalStore
    participant S as ProductService
    participant API as Remote Products API

    V->>VM: onAppear() / user refresh action
    VM->>R: loadCachedProducts()
    R->>L: loadProducts()
    L-->>R: cached [Product]
    R-->>VM: cached [Product]
    VM->>V: Render cached products immediately

    par Background refresh
        VM->>R: refreshProductsFromRemote()
        R->>S: fetchProducts()
        S->>API: HTTP GET /products
        API-->>S: JSON payload
        S-->>R: remote [Product]
        R->>R: compare by id + updatedAt, de-duplicate
        alt Remote has new/updated products
            R->>L: saveProducts(merged)
            L-->>R: save success
            R-->>VM: cache changed = true
            VM->>R: getProducts()
            R->>L: loadProducts()
            L-->>R: updated cached [Product]
            R-->>VM: updated [Product]
            VM->>V: Re-render with updated cache
        else No changes
            R-->>VM: cache changed = false
            VM->>V: Keep current UI unchanged
        end
    and Offline / request failure
        S-->>R: network error
        R-->>VM: refresh failed (no cache write)
        VM->>V: Keep cached UI + optional error message
    end
```

Entity diagram (classes, structs, enums, and relationships):

```mermaid
classDiagram
    direction TB

    class ProductViewerApp
    class ProductListView
    class ProductCellViewWithNavigation
    class ProductViewCell
    class ProductInfoCellView
    class ProductDetailView
    class ProductImageView
    class LoadingView
    class ButtonView
    class PriceView
    class MultilineTextView
    class SquishableButtonStyle

    class ProductViewModel {
        <<protocol>>
    }
    class ProductViewModelImpl

    class ProductRepository {
        <<protocol>>
    }
    class ProductRepositoryImpl

    class ProductLocalStore {
        <<protocol>>
    }
    class ProductJSONLocalStore

    class ProductService {
        <<protocol>>
    }
    class ProductServiceImpl

    class Products
    class Product
    class Price
    class CurrencySymbol {
        <<enumeration>>
    }
    class APIConstants {
        <<enumeration>>
    }
    class ProductServiceError {
        <<enumeration>>
    }
    class ProductLocalStoreError {
        <<enumeration>>
    }

    ProductViewerApp --> ProductListView
    ProductListView --> ProductViewModelImpl
    ProductListView --> ProductCellViewWithNavigation
    ProductListView --> LoadingView

    ProductCellViewWithNavigation --> ProductViewCell
    ProductViewCell --> ProductInfoCellView
    ProductViewCell --> PriceView
    ProductViewCell --> ProductDetailView

    ProductDetailView --> ProductImageView
    ProductDetailView --> ButtonView
    ProductDetailView --> PriceView
    ProductDetailView --> MultilineTextView
    ButtonView --> SquishableButtonStyle

    ProductViewModelImpl ..|> ProductViewModel
    ProductViewModelImpl --> ProductRepository
    ProductRepositoryImpl ..|> ProductRepository
    ProductRepositoryImpl --> ProductLocalStore
    ProductRepositoryImpl --> ProductService
    ProductJSONLocalStore ..|> ProductLocalStore
    ProductServiceImpl ..|> ProductService
    ProductServiceImpl --> APIConstants
    ProductServiceImpl --> ProductServiceError
    ProductJSONLocalStore --> ProductLocalStoreError

    Products --> Product
    Product --> Price
    Product --> Price : salePrice
    Price --> CurrencySymbol
    ProductViewModelImpl --> Product
    ProductRepositoryImpl --> Product
    ProductJSONLocalStore --> Product
    ProductServiceImpl --> Products
```

Interview walkthrough (quick talking points):

- "The `View` stays thin: it only captures user intent and renders state."
- "`ProductViewModelImpl` orchestrates cache-first loading through `ProductRepository`."
- "UI renders local data first, then remote refresh runs in the background."
- "`ProductRepositoryImpl` merges by `id` + `updatedAt`, and avoids duplicates."
- "`ProductJSONLocalStore` is the UI source of truth, enabling offline support."
- "`ProductService` remains isolated for network calls and easy mocking in tests."
- "The UI updates only when the local cache actually changes."

## Offline Behavior

Use the following QA checklist to validate cache-first and offline support:

1. **Prime cache (online setup)**
   - Launch the app with internet enabled.
   - Wait for products to load.
   - Kill the app from the app switcher.

2. **Warm launch in Airplane Mode**
   - Enable Airplane Mode.
   - Reopen the app.
   - Expected: product list appears immediately from local cache.
   - Expected: no crash; optional non-blocking refresh error message may appear.

3. **Cold launch in Airplane Mode (no cache)**
   - Delete the app (or clear simulator data) to remove local cache.
   - Keep Airplane Mode enabled.
   - Launch the app.
   - Expected: no stale/duplicate items.
   - Expected: empty/loading state with graceful error handling (no crash).

4. **Return online after offline usage**
   - Disable Airplane Mode.
   - Pull to refresh.
   - Expected: app fetches remote data, merges by `id` + `updatedAt`, updates cache.
   - Expected: UI changes only if cache content actually changed.

5. **Pull-to-refresh expectations**
   - Online with unchanged backend data: list remains visually unchanged.
   - Online with changed backend data: updated/new products appear once cache is written.
   - Offline: existing cached list stays visible; refresh failure is handled gracefully.
