# BarkBrain - Dog Breed Learning Training App

[中文版本项目介绍](./README_CN.md)
**BarkBrain** - Making dog breed learning simple and fun!


|  |  |  |
|---|---|---|
| ![](https://github.com/user-attachments/assets/fcd1f87a-8d9c-4f60-a7ab-bfd09aafccdc) | ![](https://github.com/user-attachments/assets/407bcf99-422d-4e3d-9124-396253af13e1) | ![](https://github.com/user-attachments/assets/c7464ccd-1db9-4287-90ad-987ece0936a6) |



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
The project adopts a layered testing architecture with three levels: unit tests, performance tests, and UI tests, ensuring code quality and application stability.

### Test File Structure
- **BarkBrainTests**: Core functionality unit tests and performance benchmark tests
- **BarkBrainUITests**: UI functionality tests and app launch tests

### 1. Unit Tests

#### Test Coverage
- **Model Layer Testing**: `Breed`, `GameState` and other data model validation
- **Business Logic Testing**: Training logic, score calculation, state management
- **API Service Testing**: Network requests, data parsing, error handling
- **Caching Mechanism Testing**: Image cache and data cache strategy validation

### 2. Performance Tests

#### Test Metrics
- **API Concurrency Performance**: Performance of multiple simultaneous API requests
- **Image Cache Performance**: Cache operation response time
- **Model Creation Performance**: Efficiency of creating large numbers of data models
- **Memory Usage Efficiency**: Memory allocation and deallocation monitoring

### 3. UI Tests

#### Test Scenarios
- **App Launch Flow**: App startup and main interface loading verification
- **Navigation Functionality**: Page navigation and back functionality
- **Training Flow**: Complete training interaction flow
- **Browse Functionality**: Breed list browsing and detail viewing
- **Performance Monitoring**: Launch time and interface responsiveness

### 4. Test Execution

#### Local Testing
Supports independent execution of all tests, unit tests, UI tests, and performance tests, with detailed test coverage report generation.

### 5. Test Data Management

#### Mock Services
Provides complete Mock API services and test data factories, supporting various test scenario data requirements while ensuring test independence and repeatability.

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
