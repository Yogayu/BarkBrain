# BarkBrain - Dog Breed Learning Training App

[中文版本项目介绍](./README_CN.md)

**BarkBrain** - Making dog breed learning simple and fun!

An iOS app for learning dog breeds that helps users learn and identify different dog breeds. Through image recognition training, breed browsing, and progress tracking, it provides a complete dog breed learning experience.

## Product Features and Modules

### Core Feature Modules

#### 1. Learn Module
- **Breed Browsing**: Browse the complete list of dog breeds and view detailed information
- **Image Recognition Training**: Training mode where users guess breed names from images
- **Learning Progress Tracking**: Record learning history and achievements
- **Quick Statistics**: Display today's learning data, winning streaks, etc.

#### 2. Training Module
- **Image to Name Training**: Core training feature that displays breed images for users to select the correct name
- **Real-time Feedback**: Audio and haptic feedback for correct/incorrect answers

#### 3. Data Management Module
- **Local Data Storage**: Use CoreData to store user progress and breed information
- **API Data Synchronization**: Get latest breed data and images from Dog CEO API
- **Cache Management**: Image caching and data preloading to optimize loading speed

#### 4. User Progress Module
- **Learning Statistics**: Number of breeds learned, training sessions, accuracy rate, etc.
- **Achievement System**: Track achievements like winning streaks, learning days, etc.

## Technical Overview

### Technology Stack

1. SwiftUI + MVVM Architecture

- Declarative UI development with clean and maintainable code
- Native performance advantages for smooth user experience

2. CoreData Data Persistence
- Apple's officially recommended data persistence solution, no third-party libraries needed

#### 3. Dog CEO API
- Free and stable dog breed data source
- RESTful API design standards
- No authentication required, simple integration

## Code Module Design

### Module Architecture Flow

### Core Module Details

#### 1. Data Management Module (DataManager)
**Functions:**
- Unified data access interface
- Dog breed data initialization and synchronization
- User progress management
- CoreData operation encapsulation

**Main Flow:**
```swift
// Data initialization flow
1. Check if local data exists
2. Fetch breed list from API
3. Parse and store to CoreData
4. Preload key image resources
```

#### 2. Image Cache Module (ImageCacheManager)
**Functions:**
- Multi-level caching strategy (memory + disk)
- Smart preloading mechanism
- Cache capacity management
- Asynchronous network image loading

**Caching Strategy:**
```swift
// Three-tier cache architecture
1. Memory Cache (NSCache) - 100MB
2. Disk Cache (URLCache) - 500MB  
3. Network Request - Dog CEO API
```

#### 3. Training Module (TrainingViewModel)
**Functions:**
- Training question generation and management
- Answer logic processing
- Progress tracking and statistics
- Audio and haptic feedback

**Training Flow:**

#### 4. API Service Module (DogAPIService)
**Functions:**
- RESTful API request encapsulation
- Error handling and retry mechanism
- Response cache management
- Data model conversion

**API Integration Flow:**
```swift
// API request processing flow
1. Build request URL and parameters
2. Check local cache
3. Send network request
4. Parse JSON response
5. Update cache
6. Return business model
```

## Performance Optimization

### Image Loading and Cache Optimization

#### Implementation Principle
**Multi-level Cache Architecture:**
```swift
// Cache tier design
Memory Cache (NSCache)
- Capacity limit: 100MB
- Count limit: 100 images


Disk Cache (URLCache)
- Capacity limit: 500MB
- Auto cleanup mechanism
- Persistent storage

Network Layer
- Asynchronous loading
- Request deduplication
- Error retry
```

**Core Implementation:**
```swift
class ImageCacheManager {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: URLCache
    
    func loadImageData(from url: String) async throws -> UIImage {
        // 1. Check memory cache
        if let cachedImage = memoryCache.object(forKey: key) {
            return cachedImage
        }
        
        // 2. Load from network/disk cache
        let (data, _) = try await session.data(from: imageURL)
        let image = UIImage(data: data)
        
        // 3. Store to memory cache
        memoryCache.setObject(image, forKey: key, cost: data.count)
        return image
    }
}
```


#### Why Choose This Implementation

**Advantages:**
1. **Excellent Performance**: Memory cache provides millisecond-level access speed
2. **Controllable Capacity**: Automatic memory usage management
3. **Persistence**: Disk cache remains effective after app restart

**Comparison with Other Solutions:**

| Solution | Advantages | Disadvantages | Use Cases |
|----------|------------|---------------|----------|
| Pure Memory Cache | Fastest speed | Lost on restart, high memory pressure | Small apps |
| Pure Disk Cache | Good persistence | Slow access speed | Large file caching |
| Multi-level Cache | Balanced performance and persistence | Complex implementation | Image-intensive apps |
| Third-party Library (SDWebImage) | Feature-rich | Adds dependency | Rapid development |

## Testing Strategy

### Testing Architecture Design

### Test File Structure

```
BarkBrainTests/
├── BarkBrainTests.swift           # Core functionality unit tests
└── Performance/
    └── PerformanceTests.swift     # Performance benchmark tests

BarkBrainUITests/
├── BarkBrainUITests.swift         # Main UI functionality tests
└── BarkBrainUITestsLaunchTests.swift  # App launch tests
```

### 1. Unit Tests

#### Test Coverage
- **Model Layer Testing**: `Breed`, `GameState` and other data models
- **Business Logic Testing**: Training logic, score calculation, state management
- **API Service Testing**: Network requests, data parsing, error handling
- **Caching Mechanism Testing**: Image cache, data cache strategies

#### Core Test Cases
```swift
// Model testing example
func testBreedModelInitialization() {
    let breed = Breed(name: "labrador", subBreeds: ["chocolate", "yellow"])
    XCTAssertEqual(breed.displayName, "Labrador")
    XCTAssertEqual(breed.subBreeds.count, 2)
}

// Game state testing example
func testGameStateScoreTracking() {
    var gameState = GameState()
    gameState.recordAnswer(isCorrect: true)
    XCTAssertEqual(gameState.correctAnswers, 1)
    XCTAssertEqual(gameState.accuracy, 1.0)
}

// API service testing example
func testDogAPIServiceSuccess() async throws {
    let mockService = MockDogAPIService()
    let response = try await mockService.fetchBreeds()
    XCTAssertFalse(response.message.isEmpty)
}
```

### 2. Performance Tests

#### Test Metrics
- **API Concurrency Performance**: Test performance of multiple simultaneous API requests
- **Image Cache Performance**: Test cache operation response time
- **Model Creation Performance**: Test performance of creating large numbers of data models
- **Memory Usage Efficiency**: Monitor memory allocation and deallocation

#### Performance Benchmarks
```swift
// API concurrency performance test
func testAPIConcurrentRequestsPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        // Execute 10 concurrent API requests
        let expectation = XCTestExpectation(description: "Concurrent API requests")
        // Test implementation...
    }
}

// Cache performance test
func testImageCachePerformance() {
    measure(metrics: [XCTClockMetric()]) {
        // Execute 100 cache operations
        for i in 0..<100 {
            imageCache.setImage(testImage, forKey: "test_\(i)")
        }
    }
}
```


### 3. UI Tests

#### Test Scenarios
- **App Launch Flow**: Verify normal app startup and main interface loading
- **Navigation Functionality**: Test navigation between pages and back functionality
- **Training Flow**: Complete training interaction flow testing
- **Browse Functionality**: Breed list browsing and detail viewing
- **Performance Monitoring**: Launch time and interface responsiveness

#### Main Test Cases
```swift
// App launch test
func testAppLaunchAndBasicNavigation() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Verify main interface elements
    XCTAssertTrue(app.navigationBars["Bark Brain"].waitForExistence(timeout: 10.0))
    XCTAssertTrue(app.staticTexts["Today's Stats"].waitForExistence(timeout: 5.0))
}

// Training flow test
func testTrainingFlow() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Start training
    let trainingButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Image to Name Training'")).firstMatch
    trainingButton.tap()
    
    // Verify training interface
    XCTAssertTrue(app.navigationBars["Image to Name Training"].waitForExistence(timeout: 10.0))
    XCTAssertTrue(app.buttons["Exit"].exists)
}
```

### 4. Test Execution and Continuous Integration

#### Local Test Execution
```bash
# Run all tests
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15'

# Run unit tests only
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainTests

# Run UI tests only
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainUITests

# Run performance tests
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainTests/PerformanceTests
```


#### Test Reports
```bash
# Generate test coverage report
xcodebuild test -scheme BarkBrain -enableCodeCoverage YES -destination 'platform=iOS Simulator,name=iPhone 15'

# View coverage report
xcrun xccov view --report DerivedData/BarkBrain/Logs/Test/*.xcresult
```

### 5. Test Data and Mocks

#### Mock Service Design
```swift
// Mock API service
class MockDogAPIService: DogAPIServiceProtocol {
    var shouldReturnError = false
    
    func fetchBreeds() async throws -> DogBreedsResponse {
        if shouldReturnError {
            throw APIError.networkError
        }
        return DogBreedsResponse(message: ["labrador": [], "poodle": ["toy", "standard"]])
    }
}

// Test data factory
struct TestDataFactory {
    static func createTestBreed() -> Breed {
        return Breed(name: "testBreed", subBreeds: ["sub1", "sub2"])
    }
    
    static func createTestGameState() -> GameState {
        var gameState = GameState()
        gameState.recordAnswer(isCorrect: true)
        return gameState
    }
}
```

## Quick Start

### Environment Requirements
- iOS 17.0+
- Xcode 15.0+

### Installation and Setup
```bash
# Clone the project
git clone git@github.com:Yogayu/BarkBrain.git
cd BarkBrain

# Open the project
open BarkBrain.xcodeproj

# Run the project
Cmd + R
```