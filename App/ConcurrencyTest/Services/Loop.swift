import Foundation

enum Loop {
  static func execute() -> HighCpuLoaderResult {
    for _ in 0...Config.loopNumber {
      let _ = 1 + 1
    }
    return HighCpuLoaderResult(
      time: 0,
      count: Config.loopNumber
    )
  }
}
