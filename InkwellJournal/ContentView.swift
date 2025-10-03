import SwiftUI
import Combine

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showColon = true
    @State private var showingSettings = false
    @State private var backgroundShade: Double = 0
    @State private var fontScale: Double = 1.0
    @State private var fontColorShade: Double = 0.0

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 1 - backgroundShade).ignoresSafeArea()
                VStack {
                    Text(timeString)
                        .font(.system(size: 80 * fontScale, weight: .thin, design: .monospaced))
                        .foregroundColor(Color(white: fontColorShade))
                        .onReceive(timer) { _ in
                            currentTime = Date()
                            showColon.toggle()
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(backgroundShade: $backgroundShade, fontScale: $fontScale, fontColorShade: $fontColorShade)
        }
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = showColon ? "HH:mm" : "HH mm"
        return formatter.string(from: currentTime)
    }
}

#Preview {
    ContentView()
}
