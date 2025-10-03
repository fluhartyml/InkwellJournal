import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Settings coming soon")
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
