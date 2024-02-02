import Foundation

struct HighCpuLoaderResult: Sendable {
  var time: TimeInterval
  var count: Int
  
  init(
    time: TimeInterval = 0,
    count: Int = 0
  ) {
    self.time = time
    self.count = count
  }
}
