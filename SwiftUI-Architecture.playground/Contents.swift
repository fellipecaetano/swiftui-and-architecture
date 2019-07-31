import SwiftUI
import PlaygroundSupport
import Combine

struct ContentView: View {
  @ObjectBinding var state: AppState

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: self.state)) {
          Text("Contador")
        }

        NavigationLink(destination: FavoritePrimesView(state: self.state)) {
          Text("Favoritos")
        }
      }
      .navigationBarTitle("Números primos")
    }
  }
}

struct CounterView: View {
  @ObjectBinding var state: AppState
  @State var isModalVisible = false

  var body: some View {
    VStack {
      Spacer()

      HStack {
        Spacer()

        Button(action: {
          self.state.count = max(1, self.state.count - 1)
        }) {
          Text("-")
            .font(.system(size: 48))
            .foregroundColor(Color(white: 0.5))
        }

        Spacer()

        Text("\(self.state.count)")
          .font(.system(size: 48))

        Spacer()

        Button(action: {
          self.state.count += 1
        }) {
          Text("+")
            .font(.system(size: 48))
            .foregroundColor(Color(white: 0.5))
        }

        Spacer()
      }

      Spacer()

      Button(action: {
        self.isModalVisible = true
      }) {
        Text("Verificar")
          .foregroundColor(Color.blue)
      }

      Spacer()
    }
    .sheet(isPresented: self.$isModalVisible) {
      PrimeVerificationModalView(state: self.state)
    }
    .navigationBarTitle("Contador", displayMode: .inline)
  }
}

struct PrimeVerificationModalView: View {
  @ObjectBinding var state: AppState

  var body: some View {
    return VStack {
      if isPrime(self.state.count) {
        Text("\(self.state.count) é primo! 🎉")
          .padding(.bottom, 24)

        if self.state.favoritePrimes.contains(self.state.count) {
          Button(action: {
            self.state.favoritePrimes.removeAll {
              $0 == self.state.count
            }
          }) {
            Text("Remover dos favoritos")
          }
        } else {
          Button(action: {
            self.state.favoritePrimes.append(self.state.count)
          }) {
            Text("Adicionar aos favoritos")
          }
        }
      } else {
        Text("\(self.state.count) não é primo... ☹️")
      }
    }
  }
}

struct FavoritePrimesView: View {
  @ObjectBinding var state: AppState

  var body: some View {
    List {
      ForEach(self.state.favoritePrimes) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        self.state.favoritePrimes.remove(atOffsets: indexSet)
      }
    }
    .navigationBarTitle("Favoritos", displayMode: .inline)
  }
}

class AppState: BindableObject {
  let willChange = PassthroughSubject<Void, Never>()

  var count = 1 {
    willSet {
      willChange.send()
    }
  }

  var favoritePrimes: [Int] = [] {
    willSet {
      willChange.send()
    }
  }
}

private func isPrime (_ p: Int) -> Bool {
  if p <= 1 {
    return false
  }

  if p <= 3 {
    return true
  }

  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 {
      return false
    }
  }

  return true
}

PlaygroundPage.current.liveView = UIHostingController(
  rootView: ContentView(state: AppState())
)

