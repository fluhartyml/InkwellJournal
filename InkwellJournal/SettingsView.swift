import SwiftUI

struct SettingsView: View {
    @Binding var backgroundShade: Double
    @Binding var fontScale: Double
    @Binding var fontColorShade: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Slider(value: $fontScale, in: 0.6...4.0)
                    .padding()
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .black]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)

                Slider(value: $fontColorShade, in: 0...1)
                    .padding()
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black, .white]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)

                Slider(value: $backgroundShade, in: 0...1)
                    .padding()
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .black]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 1 - backgroundShade))
                    .frame(width: 150, height: max(48, fontScale * 64))
                    .overlay(
                        Text(Date.now, format: .dateTime.hour().minute())
                            .font(.system(size: 40 * fontScale, weight: .thin, design: .monospaced))
                            .foregroundColor(Color(white: fontColorShade))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    )
                    .padding(.top)

                Spacer()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restore Defaults") {
                        backgroundShade = 0.5
                        fontScale = 1.0
                        fontColorShade = 0.0
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var shade: Double = 0.5
    @State static var scale: Double = 1.0
    @State static var fontColorShade: Double = 0.0
    static var previews: some View {
        SettingsView(backgroundShade: $shade, fontScale: $scale, fontColorShade: $fontColorShade)
    }
}
