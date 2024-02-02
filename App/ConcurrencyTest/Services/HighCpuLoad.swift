import Foundation

class HighCpuLoad {
    
  func loop() -> HighCpuLoaderResult { simpleLoop() }
  
  func execute() async -> HighCpuLoaderResult {
    await withTaskGroup(of: HighCpuLoaderResult.self) { group in
      for _ in 1...loopCount {
        group.addTask { self.loop() }
      }
      return await group.reduce(into: HighCpuLoaderResult(), {
        $0.count += $1.count
      })
    }
    
  }
}
