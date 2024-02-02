import SwiftUI

@main
struct MainApp: App {
  
  @State var viewModel: ContentViewModel = .init()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(viewModel)
    }
  }
}
