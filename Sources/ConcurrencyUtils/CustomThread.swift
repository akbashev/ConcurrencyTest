import Foundation

/// First time writing some thread 🫠 Not sure if it's correct and optimal, but seems like working.
public class CustomThread: Thread, @unchecked Sendable {
  private let condition = NSCondition()
  private var tasks = [() -> Void]()
  
  public init(name: String) {
    super.init()
    self.start()
    self.name = name
  }
  
  override public func main() {
    while true {
      self.condition.lock()
      while self.tasks.isEmpty {
        self.condition.wait()
      }
      let task = self.tasks.removeFirst()
      self.condition.unlock()
      task()
    }
  }
  
  public func execute(task: @escaping () -> Void) {
    self.condition.lock()
    self.tasks.append(task)
    self.condition.signal()
    self.condition.unlock()
  }
}
