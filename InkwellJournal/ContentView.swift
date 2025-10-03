import SwiftUI
import Combine

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showColon = true
    @State private var showingSettings = false
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack {
                Text(timeString)
                    .font(.system(size: 80, weight: .thin, design: .monospaced))
                    .onReceive(timer) { _ in
                        currentTime = Date()
                        showColon.toggle()
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
            SettingsView()
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
