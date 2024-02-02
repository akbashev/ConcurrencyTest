import ConcurrencyUtils
import SwiftUI

@Observable
class ContentViewModel {

  private let thread: CustomThread = .init(name: "Simple thread")
  private let highCpuLoad: HighCpuLoad = .init()
  private let service: Service = .init()
  private let servicePool: ServicePool = .init()
  private let serialService: SerialService = .init()
  private let serialPool: SerialServicePool = .init()
  
  var disabled: Bool = false
  var results: [Action: HighCpuLoaderResult] = [:]

  func execute(_ action: Action) {
    Task {
      await self.disable()
      await self.update(.none, for: action)
      do {
        let begin = Date()
        var result = await switch action {
        case .mainThread: self.mainThread()
        case .customThread: self.customThread()
        case .asyncTask: await self.asyncTask()
        case .multipleAsyncTasks: try self.multipleAsyncTask()
        case .simpleActor: try self.simpleActor()
        case .workerPool: try self.workerPool()
        case .serialActor: try self.serialActor()
        case .serialWorkerPool: try self.serialWorkerPool()
        }
        result.time = Date().timeIntervalSince(begin)
        await self.update(result, for: action)
      } catch {
        print(error)
      }
      await self.enable()
    }
  }
  
  func executeAll() {
    self.results.removeAll()
    Task {
      await self.disable()
      for action in Action.allCases {
        do {
          let begin = Date()
          var result = await switch action {
          case .mainThread: self.mainThread()
          case .customThread: self.customThread()
          case .asyncTask: await self.asyncTask()
          case .multipleAsyncTasks: try self.multipleAsyncTask()
          case .simpleActor: try self.simpleActor()
          case .workerPool: try self.workerPool()
          case .serialActor: try self.serialActor()
          case .serialWorkerPool: try self.serialWorkerPool()
          }
          result.time = Date().timeIntervalSince(begin)
          await self.update(result, for: action)
        } catch {
          print(error)
        }
      }
      await self.enable()
    }
  }
  
  @MainActor
  func update(_ result: HighCpuLoaderResult?, for action: Action) {
    self.results[action] = result
  }
  
  @MainActor
  func enable() {
    self.disabled = false
  }
  
  @MainActor
  func disable() {
    self.disabled = true
  }
}

extension ContentViewModel {
  enum Action: String, Hashable, Identifiable, CaseIterable {
    var id: String { self.rawValue }
    
    case mainThread
    case customThread
    case asyncTask
    case multipleAsyncTasks
    case simpleActor
    case workerPool
    case serialActor
    case serialWorkerPool
    
    var title: String {
      switch self {
      case .mainThread: "Main Thread"
      case .customThread: "Custom Thread"
      case .asyncTask: "Async task"
      case .multipleAsyncTasks: "Multiple async tasks"
      case .simpleActor: "Simple actor"
      case .workerPool: "Worker pool"
      case .serialActor: "Serial actor"
      case .serialWorkerPool: "Serial worker pool"
      }
    }
    
    var subtitle: String {
      switch self {
      case .mainThread: "Runs one loop on main thread."
      case .customThread: "Runs \(loopCount) loops on custom thread."
      case .asyncTask: "Runs \(loopCount) loops in one async task."
      case .multipleAsyncTasks: "Runs \(loopCount) loops, \(multipleExecutionCount) times in simple tasks."
      case .simpleActor: "Runs \(loopCount) loops, \(multipleExecutionCount) times wrapped in actor."
      case .workerPool: "Runs \(loopCount) loops, \(multipleExecutionCount) times using \(workerPoolCount) workers."
      case .serialActor: "Runs \(loopCount) loops, \(multipleExecutionCount) times on one thread."
      case .serialWorkerPool: "Runs \(loopCount) loops, \(multipleExecutionCount) times using \(serialWorkerPoolCount) workers, each having separate thread."
      }
    }
  }
}

extension ContentViewModel {

  @MainActor
  func mainThread() -> HighCpuLoaderResult {
    self.highCpuLoad.loop()
  }
  
  private func customThread() async -> HighCpuLoaderResult {
    await withCheckedContinuation { continuation in
      thread.execute {
        var result = HighCpuLoaderResult()
        for _ in 1...multipleExecutionCount {
          let next = self.highCpuLoad.loop()
          result.count += next.count
        }
        continuation.resume(returning: result)
      }
    }
  }
  
  private func asyncTask() async -> HighCpuLoaderResult {
    await self.highCpuLoad.execute()
  }
  
  private func multipleAsyncTask() async throws -> HighCpuLoaderResult {
    try await self.executeMultiple {
      await self.highCpuLoad.execute()
    }
  }
  
  private func simpleActor() async throws -> HighCpuLoaderResult {
    try await self.executeMultiple {
      await self.service.execute()
    }
  }
  
  private func workerPool() async throws -> HighCpuLoaderResult {
    try await self.executeMultiple {
      try await self.servicePool.execute()
    }
  }
  
  private func serialActor() async throws -> HighCpuLoaderResult {
    try await self.executeMultiple {
      await self.serialService.execute()
    }
  }
  
  private func serialWorkerPool() async throws -> HighCpuLoaderResult {
    try await self.executeMultiple {
      try await self.serialPool.execute()
    }
  }
  
  private func executeMultiple(_ task: @escaping () async throws -> (HighCpuLoaderResult)) async throws -> HighCpuLoaderResult {
    do {
      return try await withThrowingTaskGroup(of: HighCpuLoaderResult.self) { group in
        for _ in 1...multipleExecutionCount {
          group.addTask { try await task() }
        }
        return try await group.reduce(into: HighCpuLoaderResult(), {
          $0.count = $0.count + $1.count
        })
      }
    } catch {
      print(error)
      throw error
    }
  }
}
