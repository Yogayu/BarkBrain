# BarkBrain - 犬种学习训练应用
**BarkBrain** - 让学习犬种变得简单有趣！

一个学习犬种的 iOS 应用，帮助用户学习和识别不同的犬种。通过图片识别训练、犬种浏览和进度跟踪，提供完整的犬种学习体验。

## 产品功能和模块

### 核心功能模块

#### 1. 学习模块
- **犬种浏览**: 浏览完整的犬种列表，查看详细信息
- **图片识别训练**: 通过图片猜测犬种名称的训练模式
- **学习进度跟踪**: 记录学习历史和成就
- **快速统计**: 显示今日学习数据、连胜记录等

#### 2. 训练模块
- **图片转名称训练**: 核心训练功能，显示犬种图片让用户选择正确名称
- **实时反馈**: 答题正确/错误的音效和触觉反馈

#### 3. 数据管理模块
- **本地数据存储**: 使用 CoreData 存储用户进度和犬种信息
- **API 数据同步**: 从 Dog CEO API 获取最新犬种数据和图片
- **缓存管理**: 图片缓存和数据预加载，优化加载速度

#### 4. 用户进度模块
- **学习统计**: 已学习犬种数、训练次数、准确率等
- **成就系统**: 连胜记录、学习天数等成就跟踪

## 技术概览

### 技术选型

1. SwiftUI + MVVM 架构

- 声明式 UI 开发，代码简洁易维护
- 原生性能优势，流畅的用户体验

2. CoreData 数据持久化
- Apple 官方推荐的数据持久化方案，无需第三方库

#### 3. Dog CEO API
- 免费且稳定的犬种数据源
- RESTful API 设计规范
- 无需认证，集成简单

## 代码模块设计

### 核心模块详解

#### 1. 数据管理模块 (DataManager)
**功能:**
- 统一的数据访问接口
- 犬种数据初始化和同步
- 用户进度管理
- CoreData 操作封装

**主要流程:**
```swift
// 数据初始化流程
1. 检查本地数据是否存在
2. 从 API 获取犬种列表
3. 解析并存储到 CoreData
4. 预加载关键图片资源
```

#### 2. 图片缓存模块 (ImageCacheManager)
**功能:**
- 多级缓存策略 (内存 + 磁盘)
- 智能预加载机制
- 缓存容量管理
- 网络图片异步加载

**缓存策略:**
```swift
// 三级缓存架构
1. Memory Cache (NSCache) - 100MB
2. Disk Cache (URLCache) - 500MB  
3. Network Request - Dog CEO API
```

#### 3. 训练模块 (TrainingViewModel)
**功能:**
- 训练题目生成和管理
- 答题逻辑处理
- 进度跟踪和统计
- 音效和触觉反馈

**训练流程:**

#### 4. API 服务模块 (DogAPIService)
**功能:**
- RESTful API 请求封装
- 错误处理和重试机制
- 响应缓存管理
- 数据模型转换

**API 集成流程:**
```swift
// API 请求处理流程
1. 构建请求 URL 和参数
2. 检查本地缓存
3. 发送网络请求
4. 解析 JSON 响应
5. 更新缓存
6. 返回业务模型
```

## 性能优化内容

### 图片加载与缓存优化

#### 实现原理
**多级缓存架构:**
```swift
// 缓存层级设计
Memory Cache (NSCache)
- 容量限制: 100MB
- 数量限制: 100张图片


Disk Cache (URLCache)
- 容量限制: 500MB
- 自动清理机制
- 持久化存储

Network Layer
- 异步加载
- 请求去重
- 错误重试
```

**核心实现:**
```swift
class ImageCacheManager {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: URLCache
    
    func loadImageData(from url: String) async throws -> UIImage {
        // 1. 检查内存缓存
        if let cachedImage = memoryCache.object(forKey: key) {
            return cachedImage
        }
        
        // 2. 从网络/磁盘缓存加载
        let (data, _) = try await session.data(from: imageURL)
        let image = UIImage(data: data)
        
        // 3. 存储到内存缓存
        memoryCache.setObject(image, forKey: key, cost: data.count)
        return image
    }
}
```


#### 为什么选择这种实现

**优势:**
1. **性能优异**: 内存缓存提供毫秒级访问速度
2. **容量可控**: 自动管理内存使用
3. **持久化**: 磁盘缓存在应用重启后仍然有效

**与其他方案对比:**

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| 纯内存缓存 | 速度最快 | 重启丢失，内存压力大 | 小型应用 |
| 纯磁盘缓存 | 持久化好 | 访问速度慢 | 大文件缓存 |
| 多级缓存 | 平衡性能和持久化 | 实现复杂 | 图片密集应用 |
| 第三方库 (SDWebImage) | 功能丰富 | 增加依赖 | 快速开发 |

## 测试策略

### 测试架构设计

### 测试文件结构

```
BarkBrainTests/
├── BarkBrainTests.swift           # 核心功能单元测试
└── Performance/
    └── PerformanceTests.swift     # 性能基准测试

BarkBrainUITests/
├── BarkBrainUITests.swift         # 主要 UI 功能测试
└── BarkBrainUITestsLaunchTests.swift  # 应用启动测试
```

### 1. 单元测试 (Unit Tests)

#### 测试覆盖内容
- **模型层测试**: `Breed`、`GameState` 等数据模型
- **业务逻辑测试**: 训练逻辑、分数计算、状态管理
- **API 服务测试**: 网络请求、数据解析、错误处理
- **缓存机制测试**: 图片缓存、数据缓存策略

#### 核心测试用例
```swift
// 模型测试示例
func testBreedModelInitialization() {
    let breed = Breed(name: "labrador", subBreeds: ["chocolate", "yellow"])
    XCTAssertEqual(breed.displayName, "Labrador")
    XCTAssertEqual(breed.subBreeds.count, 2)
}

// 游戏状态测试示例
func testGameStateScoreTracking() {
    var gameState = GameState()
    gameState.recordAnswer(isCorrect: true)
    XCTAssertEqual(gameState.correctAnswers, 1)
    XCTAssertEqual(gameState.accuracy, 1.0)
}

// API 服务测试示例
func testDogAPIServiceSuccess() async throws {
    let mockService = MockDogAPIService()
    let response = try await mockService.fetchBreeds()
    XCTAssertFalse(response.message.isEmpty)
}
```

### 2. 性能测试 (Performance Tests)

#### 测试指标
- **API 并发性能**: 测试同时发起多个 API 请求的性能
- **图片缓存性能**: 测试缓存操作的响应时间
- **模型创建性能**: 测试大量数据模型创建的性能
- **内存使用效率**: 监控内存占用和释放

#### 性能基准
```swift
// API 并发性能测试
func testAPIConcurrentRequestsPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        // 并发执行 10 个 API 请求
        let expectation = XCTestExpectation(description: "Concurrent API requests")
        // 测试实现...
    }
}

// 缓存性能测试
func testImageCachePerformance() {
    measure(metrics: [XCTClockMetric()]) {
        // 执行 100 次缓存操作
        for i in 0..<100 {
            imageCache.setImage(testImage, forKey: "test_\(i)")
        }
    }
}
```


### 3. UI 测试 (UI Tests)

#### 测试场景
- **应用启动流程**: 验证应用正常启动和主界面加载
- **导航功能**: 测试页面间的导航和返回
- **训练流程**: 完整的训练交互流程测试
- **浏览功能**: 犬种列表浏览和详情查看
- **性能监控**: 启动时间和界面响应性能

#### 主要测试用例
```swift
// 应用启动测试
func testAppLaunchAndBasicNavigation() throws {
    let app = XCUIApplication()
    app.launch()
    
    // 验证主界面元素
    XCTAssertTrue(app.navigationBars["Bark Brain"].waitForExistence(timeout: 10.0))
    XCTAssertTrue(app.staticTexts["Today's Stats"].waitForExistence(timeout: 5.0))
}

// 训练流程测试
func testTrainingFlow() throws {
    let app = XCUIApplication()
    app.launch()
    
    // 启动训练
    let trainingButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Image to Name Training'")).firstMatch
    trainingButton.tap()
    
    // 验证训练界面
    XCTAssertTrue(app.navigationBars["Image to Name Training"].waitForExistence(timeout: 10.0))
    XCTAssertTrue(app.buttons["Exit"].exists)
}
```

### 4. 测试运行和持续集成

#### 本地测试运行
```bash
# 运行所有测试
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15'

# 只运行单元测试
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainTests

# 只运行 UI 测试
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainUITests

# 运行性能测试
xcodebuild test -scheme BarkBrain -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BarkBrainTests/PerformanceTests
```


#### 测试报告
```bash
# 生成测试覆盖率报告
xcodebuild test -scheme BarkBrain -enableCodeCoverage YES -destination 'platform=iOS Simulator,name=iPhone 15'

# 查看覆盖率报告
xcrun xccov view --report DerivedData/BarkBrain/Logs/Test/*.xcresult
```

### 5. 测试数据和 Mock

#### Mock 服务设计
```swift
// Mock API 服务
class MockDogAPIService: DogAPIServiceProtocol {
    var shouldReturnError = false
    
    func fetchBreeds() async throws -> DogBreedsResponse {
        if shouldReturnError {
            throw APIError.networkError
        }
        return DogBreedsResponse(message: ["labrador": [], "poodle": ["toy", "standard"]])
    }
}

// 测试数据工厂
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

## 快速开始

### 环境要求
- iOS 17.0+
- Xcode 15.0+

### 安装运行
```bash
# 克隆项目
git clone git@github.com:Yogayu/BarkBrain.git
cd BarkBrain

# 打开项目
open BarkBrain.xcodeproj

# 运行项目
Cmd + R
```s