import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var availableSources: [(name: String, id: String)] = []
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            bindingsSection
            timingSection
            languagesSection
            permissionsSection
        }
        .padding(30)
        .frame(width: 480, height: 620)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .controlBackgroundColor).opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            loadInputSources()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.linearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "globe")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            
            Text("MacLangTools")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Switch language with Option key taps")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var bindingsSection: some View {
        GroupBox {
            VStack(spacing: 16) {
                bindingRow(
                    icon: "2.circle.fill",
                    label: "Double tap",
                    binding: $settings.doubleTapLanguage,
                    color: .blue
                )
                
                Divider()
                
                bindingRow(
                    icon: "3.circle.fill",
                    label: "Triple tap",
                    binding: $settings.tripleTapLanguage,
                    color: .green
                )
                
                Divider()
                
                bindingRow(
                    icon: "4.circle.fill",
                    label: "Quadruple tap",
                    binding: $settings.quadTapLanguage,
                    color: .orange
                )
            }
            .padding(12)
        } label: {
            Label("Key Bindings", systemImage: "keyboard")
                .font(.headline)
        }
    }
    
    private func bindingRow(icon: String, label: String, binding: Binding<String>, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("", selection: binding) {
                Text("— Not set —").tag("")
                ForEach(availableSources, id: \.id) { source in
                    Text(source.name).tag(source.name)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 180)
        }
    }
    
    private var timingSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Tap interval")
                    Spacer()
                    Text("\(Int(settings.tapInterval * 1000)) ms")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $settings.tapInterval, in: 0.15...0.6, step: 0.05)
                
                HStack {
                    Text("Faster")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Slower")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
        } label: {
            Label("Speed", systemImage: "timer")
                .font(.headline)
        }
    }
    
    private var languagesSection: some View {
        GroupBox {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(availableSources, id: \.id) { source in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(languageColor(for: source.name))
                                .frame(width: 8, height: 8)
                            
                            Text(source.name)
                                .font(.system(.body, design: .rounded))
                            
                            Spacer()
                            
                            Text(source.id.components(separatedBy: ".").last ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .frame(height: 80)
            .padding(8)
        } label: {
            Label("Available Layouts", systemImage: "list.bullet")
                .font(.headline)
        }
    }
    
    private var permissionsSection: some View {
        HStack {
            Image(systemName: "exclamationmark.shield")
                .foregroundColor(.orange)
            
            Text("Accessibility permission required")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Open Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 4)
    }
    
    private func languageColor(for name: String) -> Color {
        let lowercased = name.lowercased()
        if lowercased.contains("russian") || lowercased.contains("русск") {
            return .blue
        } else if lowercased.contains("english") || lowercased.contains("abc") || lowercased.contains("u.s.") {
            return .green
        } else if lowercased.contains("ukrainian") {
            return .yellow
        }
        return .gray
    }
    
    private func loadInputSources() {
        let manager = InputSourceManager()
        availableSources = manager.listAvailableInputSources()
    }
}
