import Foundation

func simpleLoop() -> HighCpuLoaderResult {
  for _ in 0...loopNumber {
    let _ = 1 + 1
  }
  return HighCpuLoaderResult(
    time: 0,
    count: loopNumber
  )
}
