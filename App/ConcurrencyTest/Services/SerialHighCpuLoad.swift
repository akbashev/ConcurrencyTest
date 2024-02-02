import Foundation
import ConcurrencyUtils

actor SerialHighCpuLoad: WithSpecifiedExecutor {

  nonisolated let executor: any SpecifiedExecutor

  init(threadName: String) {
    self.executor = NaiveQueueExecutor(name: threadName)
  }
  
  func loop() -> HighCpuLoaderResult { simpleLoop() }
  
  func execute() async -> HighCpuLoaderResult {
    await withTaskGroup(of: HighCpuLoaderResult.self) { group in
      for _ in 1...Config.loopCount {
        group.addTask { await self.loop() }
      }
      return await group.reduce(into: HighCpuLoaderResult(), {
        $0.count = $0.count + $1.count
      })
    }
  }
}
