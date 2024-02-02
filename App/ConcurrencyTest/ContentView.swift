import Foundation
import SwiftUI

struct ContentView: View {
  
  @Environment(ContentViewModel.self) private var viewModel
  
  @State var animationOffset: AnimationOffset = .up(
    rotation: .degrees(-10),
    offset: .init(width: 0, height: 2)
  )
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 16) {
        HStack {
          Image(systemName: "sailboat.fill")
            .foregroundColor(.primary)
            .font(.largeTitle)
            .fontWeight(.regular)
            .multilineTextAlignment(.center)
            .rotationEffect(animationOffset.rotation, anchor: .bottom)
          Spacer()
          Button {
            viewModel.executeAll()
          } label: {
            Text("Execute all")
              .font(.headline)
          }.disabled(viewModel.disabled)
        }
        Divider()
        ForEach(ContentViewModel.Action.allCases) { action in
          Button {
            viewModel.execute(action)
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(action.title)
                  .font(.headline)
                Text(action.subtitle)
                  .multilineTextAlignment(.leading)
                  .font(.subheadline)
                  .foregroundStyle(Color.secondary)
              }
              Spacer()
              VStack(alignment: .trailing) {
                Group {
                  if let result = viewModel.results[action] {
                    Text("Time: \(result.time)")
                    Text("Count: \(result.count)")
                  } else {
                    Text("Time: -")
                    Text("Count: -")
                  }
                }
                .font(.footnote)
                .foregroundStyle(Color.secondary)
              }
            }
          }.disabled(viewModel.disabled)
          Divider()
        }
      }
      .padding()
      .onAppear() {
        withAnimation(self.repeatingAnimation) {
          switch self.animationOffset {
          case .down:
            self.animationOffset = .up(
              rotation: .degrees(-10),
              offset: .init(width: 0, height: 2)
            )
          case .up:
            self.animationOffset = .down(
              rotation: .degrees(10),
              offset: .init(width: 0, height: -2)
            )
          }
        }
      }
    }
  }
}

extension ContentView {
  
  enum AnimationOffset {
    case up(rotation: Angle, offset: CGSize)
    case down(rotation: Angle, offset: CGSize)
    
    var rotation: Angle {
      switch self {
      case let .up(rotation, _):
        return rotation
      case let .down(rotation, _):
        return rotation
      }
    }
    
    var offset: CGSize {
      switch self {
      case let .up(_, offset):
        return offset
      case let .down(_, offset):
        return offset
      }
    }
  }
  
  var repeatingAnimation: Animation {
    Animation
      .easeInOut(duration: 3) //.easeIn, .easyOut, .linear, etc...
      .repeatForever(autoreverses: true)
  }
}

