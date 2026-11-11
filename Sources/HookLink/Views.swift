import SwiftUI
import UniformTypeIdentifiers

// The window, in the look of a file-select screen: one steel-blue panel with a cut corner on a black-to-blue ground, a title strip, the steps as pill buttons down the left
// (the chosen one outlined in teal), the chosen step's page in a dark panel on the right, and a hint line underneath.
enum HLStyle {
    static let teal = Color(red: 0.56, green: 0.90, blue: 0.84), line = Color(red: 0.45, green: 0.54, blue: 0.80), dim = Color(red: 0.66, green: 0.73, blue: 0.92)
    static let ground = LinearGradient(colors: [Color(red: 0, green: 0, blue: 0.016), Color(red: 0.008, green: 0.016, blue: 0.10), Color(red: 0.04, green: 0.10, blue: 0.43), Color(red: 0.07, green: 0.19, blue: 0.66)], startPoint: .top, endPoint: .bottom)
    static let panel = LinearGradient(colors: [Color(red: 0.20, green: 0.28, blue: 0.56), Color(red: 0.11, green: 0.17, blue: 0.42), Color(red: 0.24, green: 0.34, blue: 0.65), Color(red: 0.12, green: 0.19, blue: 0.46), Color(red: 0.08, green: 0.12, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let detail = Color(red: 0.02, green: 0.035, blue: 0.15).opacity(0.90)
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static let outline = Color(red: 0.03, green: 0.05, blue: 0.20)
}
/// The file-select lettering: wide, black-weight letters with a dark navy outline and a drop under them. shaded: the step names' fill, light at the top and grey below
struct Lettering: ViewModifier {
    var size: CGFloat, shaded = false, bright = false, color: Color = .white
    func body(content: Content) -> some View {
        let o = HLStyle.outline
        return content
            .font(.system(size: size, weight: .black, design: .default)).tracking(size * 0.07)
            .foregroundStyle(shaded ? AnyShapeStyle(LinearGradient(colors: bright ? [.white, Color(red: 0.85, green: 1, blue: 0.97)] : [Color(red: 0.90, green: 0.92, blue: 0.97), Color(red: 0.62, green: 0.67, blue: 0.78)], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(color))
            .shadow(color: o, radius: 0, x: 1, y: 0).shadow(color: o, radius: 0, x: -1, y: 0).shadow(color: o, radius: 0, x: 0, y: 1).shadow(color: o, radius: 0, x: 0, y: -1)
            .shadow(color: o.opacity(0.9), radius: 0, x: 1.5, y: 2.5)
    }
}
extension View { func lettering(_ size: CGFloat, shaded: Bool = false, bright: Bool = false, color: Color = .white) -> some View { modifier(Lettering(size: size, shaded: shaded, bright: bright, color: color)) } }
struct CutCorner: Shape {
    var cut: CGFloat = 34
    func path(in r: CGRect) -> Path {
        var p = Path(); p.move(to: CGPoint(x: r.minX + cut, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.addLine(to: CGPoint(x: r.minX, y: r.minY + cut)); p.closeSubpath(); return p
    }
}
/// A step's pill button: steel blue with chunky grey lettering, outlined and glowing in teal when it is the chosen step
struct PillStyle: ButtonStyle {
    var selected = false
    func makeBody(configuration: Configuration) -> some View {
        let shape = UnevenRoundedRectangle(topLeadingRadius: 9, bottomLeadingRadius: 9, bottomTrailingRadius: 20, topTrailingRadius: 20)
        return configuration.label
            .padding(.leading, 18).padding(.trailing, 14).frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
            .background(LinearGradient(colors: selected ? [Color(red: 0.44, green: 0.61, blue: 0.71), Color(red: 0.22, green: 0.35, blue: 0.50)] : [Color(red: 0.28, green: 0.38, blue: 0.62), Color(red: 0.13, green: 0.21, blue: 0.45)], startPoint: .top, endPoint: .bottom))
            .clipShape(shape).overlay(shape.stroke(selected ? Color(red: 0.79, green: 1, blue: 0.96) : HLStyle.line, lineWidth: selected ? 2 : 1))
            .shadow(color: selected ? HLStyle.teal.opacity(0.8) : .clear, radius: 7)
            .opacity(configuration.isPressed ? 0.8 : 1).contentShape(shape)
    }
}

struct ContentView: View {
    @EnvironmentObject var app: HookLink
    @State private var showLog = false

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                HStack {
                    Text("Please select a step.").lettering(25)
                    Spacer()
                    Text("HookLink \(AppInfo.version)").lettering(14, shaded: true)
                }
                .padding(.leading, 52).padding(.trailing, 26).frame(height: 58)
                .background(Color(red: 0.02, green: 0.035, blue: 0.16).opacity(0.65)).overlay(Rectangle().fill(HLStyle.line).frame(height: 1), alignment: .bottom)
                HStack(alignment: .top, spacing: 22) {
                    VStack(spacing: 8) {
                        ForEach(Step.allCases) { s in
                            Button { if !app.busy && app.offered(s) { app.step = s } } label: {
                                HStack { Text(s.title).lettering(17, shaded: true, bright: app.step == s).lineLimit(1).minimumScaleFactor(0.8); Spacer(); Text(status(s)).font(.system(size: 11.5, weight: .bold, design: .rounded)).foregroundStyle(app.step == s ? Color(red: 0.84, green: 1, blue: 0.97) : HLStyle.dim).lineLimit(1) }
                            }
                            .buttonStyle(PillStyle(selected: app.step == s)).disabled(app.busy && app.step != s).opacity(app.offered(s) ? 1 : 0.35)
                            .accessibilityAddTraits(app.step == s ? .isSelected : [])
                        }
                        Spacer(minLength: 8)
                        VersionPanel()
                    }
                    .frame(width: 262)
                    VStack(spacing: 0) {
                        if app.engineUpdate != nil || app.appUpdate != nil || !app.updateMessage.isEmpty { UpdateBanner(); Divider() }
                        if let w = app.work { ProgressCard(w: w).padding(.horizontal, 20).padding(.top, 12) }
                        ScrollView { page.padding(24).frame(maxWidth: 680, alignment: .leading).frame(maxWidth: .infinity, alignment: .leading) }
                        Divider()
                        HStack {
                            Button(showLog ? "Hide details" : "Show details") { showLog.toggle() }.buttonStyle(.link)
                            Spacer()
                            if app.step != .welcome { Button("Back") { app.step = app.step(before: app.step) }.disabled(app.busy) }
                            if app.step != .done { Button("Next") { app.step = app.step(after: app.step) }.keyboardShortcut(.defaultAction).disabled(app.busy || !canGoOn) }
                        }.padding(12)
                        if showLog { LogView().frame(height: 170) }
                    }
                    .background(HLStyle.detail).overlay(Rectangle().stroke(Color(red: 0.31, green: 0.40, blue: 0.62), lineWidth: 1))
                }
                .padding(.leading, 34).padding(.trailing, 26).padding(.vertical, 20)
            }
            .background(HLStyle.panel).clipShape(CutCorner()).overlay(CutCorner().stroke(HLStyle.line, lineWidth: 1))
            Text("Click - Open  \u{2022}  Return - Next").lettering(17, color: Color(red: 0.50, green: 0.88, blue: 0.81))
        }
        .padding(.horizontal, 54).padding(.top, 34).padding(.bottom, 20)
        .background(HLStyle.ground.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .frame(minWidth: 1040, minHeight: 700)
        .task { await app.checkForUpdates() }   // at every launch: quiet when offline
    }

    /// The short note at a pill's right edge: what the step has settled
    func status(_ s: Step) -> String {
        switch s {
        case .mac: return app.macReady ? "Ready" : ""
        case .game: return app.gameChosen ? "Loaded" : ""
        case .phoneModel: return app.isMac ? "This Mac" : app.gpu == "g19p" ? "iPhone 18 Pro" : "iPhone 17"
        case .build: return app.buildOK ? "Done" : app.busy && app.step == .build ? "Building" : ""
        case .copy: return app.copyOK ? "Done" : ""
        default: return ""
        }
    }

    var canGoOn: Bool {
        switch app.step {
        case .mac: return app.macReady
        case .game: return app.gameChosen
        case .build: return app.buildOK
        case .copy: return app.copyOK
        default: return true
        }
    }

    @ViewBuilder var page: some View {
        switch app.step {
        case .welcome: WelcomePage()
        case .mac: MacPage()
        case .game: GamePage()
        case .phoneModel: PhonePage()
        case .build: BuildPage()
        case .install: InstallPage()
        case .copy: CopyPage()
        case .done: DonePage()
        }
    }
}

struct PageTitle: View {
    let title: String, subtitle: String
    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(.white).frame(maxWidth: .infinity)
            HStack(spacing: 10) { Rectangle().fill(HLStyle.line).frame(height: 1); Rectangle().fill(HLStyle.teal).frame(width: 7, height: 7).rotationEffect(.degrees(45)); Rectangle().fill(HLStyle.line).frame(height: 1) }
            Text(subtitle).foregroundStyle(Color(red: 0.81, green: 0.86, blue: 1)).multilineTextAlignment(.center).frame(maxWidth: .infinity)
        }.padding(.bottom, 14)
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "HookLink", subtitle: "Build The Legend of Zelda: Ocarina of Time (Nintendo Switch 2 Edition) for your iPhone or this Mac, from your own copy of the game.")
            Text("HookLink walks you through it:").font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                Label("Checks your Mac has what the build needs", systemImage: "1.circle")
                Label("Builds the iPhone app from your game file (.nup)", systemImage: "2.circle")
                Label("Tells you how to install it with your sideloading tool", systemImage: "3.circle")
                Label("Copies your game files to the phone over a cable", systemImage: "4.circle")
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your game stays yours").font(.headline)
                    Text("HookLink contains no game files, keys or built apps. Everything it makes comes from your own copy and stays on your Mac and your phone. Never share those files.")
                }.frame(maxWidth: .infinity, alignment: .leading).padding(4)
            }
            Text("You need: a Mac with Apple silicon, Xcode 27.2, about 80 GB free, a cable for your iPhone, and your game at update v131072. The first build takes a few hours.")
                .foregroundStyle(.secondary)
            Text("HookLink is a fan-made tool, not affiliated with or endorsed by Nintendo.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

struct MacPage: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(title: "Check your Mac", subtitle: "HookLink looks for the tools the build needs and can install most of them for you.")
            if app.checks.isEmpty { ProgressView().task { await app.runChecks() } }
            ForEach(app.checks) { c in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: c.state == .ok ? "checkmark.circle.fill" : c.state == .warn ? "exclamationmark.triangle.fill" : c.state == .missing ? "xmark.circle.fill" : "circle")
                        .foregroundStyle(c.state == .ok ? .green : c.state == .warn ? .orange : c.state == .missing ? .red : .secondary)
                    VStack(alignment: .leading) { Text(c.name).bold(); Text(c.detail).font(.callout).foregroundStyle(.secondary).textSelection(.enabled) }
                }
            }
            HStack {
                Button("Check again") { Task { await app.runChecks() } }.disabled(app.busy)
                if app.checks.contains(where: { $0.state == .missing }) {
                    Button("Install tools") { Task { await app.installTools() } }.buttonStyle(.borderedProminent).disabled(app.busy)
                }
                if app.busy { ProgressView().controlSize(.small) }
            }.padding(.top, 8)
            HStack {
                Text("Build folder:").bold()
                Text(app.folder.path).textSelection(.enabled).foregroundStyle(.secondary)
                Button("Change…") { pickFolder() }.disabled(app.busy)
            }.padding(.top, 8)
        }
    }
    func pickFolder() {
        let p = NSOpenPanel(); p.canChooseDirectories = true; p.canChooseFiles = false; p.canCreateDirectories = true
        p.message = "Choose a folder on a drive with about 80 GB free"
        if p.runModal() == .OK, let u = p.url { app.folderPath = u.path; Task { await app.runChecks() } }
    }
}

struct GamePage: View {
    @EnvironmentObject var app: HookLink
    @State private var dropTarget = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Choose your game", subtitle: "Your own dump of Ocarina of Time (Nintendo Switch 2 Edition), as a .nup file, with update v131072.")
            RoundedRectangle(cornerRadius: 12).strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(dropTarget ? Color.accentColor : .secondary)
                .frame(height: 140)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: app.gameChosen ? "checkmark.circle.fill" : "arrow.down.doc").font(.largeTitle).foregroundStyle(app.gameChosen ? .green : .secondary)
                        Text(app.gameChosen ? (app.nupPath as NSString).lastPathComponent : "Drop your .nup here").bold()
                        Button("Choose…") { pick() }
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: $dropTarget) { items in
                    _ = items.first?.loadObject(ofClass: URL.self) { url, _ in if let url { Task { @MainActor in app.chooseGame(url) } } }
                    return true
                }
            Text("HookLink checks the game when the build starts and stops if it is not the supported version.").font(.callout).foregroundStyle(.secondary)
        }
    }
    func pick() {
        let p = NSOpenPanel(); p.canChooseFiles = true; p.canChooseDirectories = true; p.allowsMultipleSelection = false
        p.message = "Choose your game's .nup file"
        if p.runModal() == .OK, let u = p.url { app.chooseGame(u) }
    }
}

struct PhonePage: View {
    @EnvironmentObject var app: HookLink
    private func chooseIcon() {
        let p = NSOpenPanel(); p.allowedContentTypes = [.png, .jpeg]; p.allowsMultipleSelection = false; p.prompt = "Use this icon"
        if p.runModal() == .OK, let u = p.url { app.appIcon = u.path }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Choose device", subtitle: "The app is built for your device's graphics chip, so it starts quickly and runs smoothly.")
            Picker("", selection: $app.gpu) {
                ForEach(PhoneModel.all) { m in
                    Text(m.name + (m.tested ? "  (tested)" : "  (not tested yet)")).tag(m.id)
                }
            }.pickerStyle(.radioGroup).labelsHidden()
            if app.isMac {
                Text("Builds a Mac app you open with a double click. The game files go inside it, so there is nothing to install or copy afterwards. Not tested yet: the game wants a lot of memory, so a Mac with 16 GB or more is the safer choice. Please report how it runs.").foregroundStyle(.orange)
            } else if let m = PhoneModel.all.first(where: { $0.id == app.gpu }), !m.tested {
                Text("This model has not been tested yet. It should work; please report how it runs.").foregroundStyle(.orange)
            }
            Text("iPhone Duo uses the same chip but has not been tested yet. Other iPhones are not supported yet: the game needs a recent iPhone's memory and graphics.").font(.callout).foregroundStyle(.secondary)
            GroupBox("Name and icon (optional)") {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("App name (leave empty for the game's own name)", text: $app.appName).textFieldStyle(.roundedBorder)
                    HStack(spacing: 10) {
                        if !app.appIcon.isEmpty, let im = NSImage(contentsOfFile: app.appIcon) {
                            Image(nsImage: im).resizable().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(app.appIcon.isEmpty ? "Choose an icon\u{2026}" : "Change icon\u{2026}") { chooseIcon() }
                        if !app.appIcon.isEmpty { Button("Use the game's icon") { app.appIcon = "" } }
                    }
                    Text("Any PNG or JPEG. Changing these needs a new build, but not new game files, and your saves stay.").font(.caption).foregroundStyle(.secondary)
                }.padding(6)
            }
        }
    }
}

struct BuildPage: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Build", subtitle: "HookLink builds the \(app.isMac ? "Mac" : "iPhone") app from your game. The first build takes a few hours; you can keep using your Mac.")
            if app.buildOK {
                Label("The app is ready", systemImage: "checkmark.seal.fill").font(.title2).foregroundStyle(.green)
                HStack { Text(app.product.path).textSelection(.enabled).foregroundStyle(.secondary); Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([app.product]) } }
            } else if app.busy {
                Text("The progress is shown above. You can keep using your Mac.").foregroundStyle(.secondary)
                Button("Stop") { app.cancel() }
            } else {
                Button("Start the build") { Task { await app.build() } }.buttonStyle(.borderedProminent).controlSize(.large)
                    .disabled(!app.gameChosen)
            }
            if !app.buildError.isEmpty { Text(app.buildError).foregroundStyle(.red) }
            if !app.damagedFiles.isEmpty {
                Text("Your dump has \(app.damagedFiles.count) damaged file(s). The build goes on; those textures may look wrong in the game. Dumping the game again fixes it.").foregroundStyle(.orange)
                ForEach(app.damagedFiles, id: \.self) { Text($0).font(.caption.monospaced()).foregroundStyle(.secondary) }
            }
            Text("Keep your Mac plugged in. It will not sleep while HookLink builds.").font(.callout).foregroundStyle(.secondary)
        }
    }
}

struct InstallPage: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Install", subtitle: "Install the app on your iPhone with your sideloading tool (for example iLoader, Sideloadly or AltStore).")
            VStack(alignment: .leading, spacing: 10) {
                Label("Open your sideloading tool and sign in with your Apple Account.", systemImage: "1.circle")
                Label("Choose HookLink-OcarinaOfTime.ipa from your build folder.", systemImage: "2.circle")
                Label("If it offers Increased Memory Limit, turn it on.", systemImage: "3.circle")
                Label("Install it. Updating later? Install over the old one; your saves and game files stay. Never delete the game first: that deletes its saves. Back them up on the Play step to be safe.", systemImage: "4.circle")
                Label("Don't open the game yet: it needs its game files first.", systemImage: "5.circle")
            }
            Button("Show the app in Finder") { NSWorkspace.shared.activateFileViewerSelecting([app.ipa]) }
            Text("Your phone needs Developer Mode on (Settings → Privacy & Security → Developer Mode) for the next step.").font(.callout).foregroundStyle(.secondary)
        }
    }
}

struct CopyPage: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Copy game files", subtitle: "Plug your iPhone into this Mac with a cable, unlock it, and tap Trust if it asks.")
            HStack {
                Button("Find my iPhone") { Task { await app.findDevices() } }.disabled(app.busy)
                if app.busy && app.copyStatus.isEmpty { ProgressView().controlSize(.small) }
            }
            if app.devices.isEmpty {
                Text("No iPhone found yet.").foregroundStyle(.secondary)
            } else {
                Picker("iPhone", selection: $app.device) { ForEach(app.devices) { d in Text("\(d.name) (\(d.model))").tag(Optional(d)) } }
                    .frame(maxWidth: 420)
                if let d = app.device {
                    if !d.developerMode { Text("Turn on Developer Mode: Settings → Privacy & Security → Developer Mode, then restart the phone.").foregroundStyle(.orange) }
                    if app.bundleID.isEmpty {
                        Text("The game is not installed on this iPhone yet. Install it first (previous step), then click Find my iPhone again.").foregroundStyle(.orange)
                    } else {
                        Label("Game found on \(d.name)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("Before copying: Settings → Display & Brightness → Auto-Lock → Never, and keep the phone unlocked. Set it back afterwards.")
                            .font(.callout).foregroundStyle(.secondary)
                        HStack {
                            Button("Copy game files to my iPhone") { Task { await app.copyToPhone() } }.buttonStyle(.borderedProminent).controlSize(.large).disabled(app.busy)
                            Button("Copy with Finder instead") { app.prepareFinderCopy() }.disabled(app.busy)
                        }
                        if app.finderMode { FinderSteps() }
                    }
                }
            }
            ForEach(Array(app.copyStatus.enumerated()), id: \.offset) { _, s in Text(s) }

            Text("This copies the game files from your own dump and the iPhone resolution file made from them. You only do this once per phone.").font(.callout).foregroundStyle(.secondary)
        }
    }
}

struct DonePage: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageTitle(title: "Play", subtitle: app.isMac ? "Open the game on this Mac." : "Open the game on your iPhone.")
            if app.isMac {
                HStack {
                    Button("Open the game") { NSWorkspace.shared.open(app.macApp) }.buttonStyle(.borderedProminent).controlSize(.large).disabled(!FileManager.default.fileExists(atPath: app.macApp.path))
                    Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([app.macApp]) }
                }
                Text("The Mac app holds your game files: keep it on this Mac and never share it. Its saves are in its own folder in your Library, and its settings window opens before the game starts.").font(.callout).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("• The first start shows \"Preparing shaders\" and can take a few minutes. Later starts take seconds.")
                Text("• If the first session after installing feels slow, close the game fully (swipe it away) and open it again: the next start runs at full speed.")
                Text("• A new area can stutter the first time you enter it. The next start prepares it, and it runs smoothly after that.")
                Text("• The phone gets warm in long sessions; it runs best unplugged and not in a case.")
            }
            if !app.isMac { SavesBox() }
            if !app.isMac { GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Small game files").font(.headline)
                    Text("Updates can change a few small files, like the iPhone resolution file. HookLink checks them when your iPhone is plugged in and sends only what changed. Your 24 GB of game files and your saves aren't touched.").font(.callout).foregroundStyle(.secondary)
                    HStack {
                        Button("Check small game files") { Task { await app.updateSmallFiles() } }.disabled(app.busy)
                        if !app.smallFilesStatus.isEmpty { Text(app.smallFilesStatus).foregroundStyle(.secondary) }
                    }
                }.padding(6)
            }
            .task { await app.updateSmallFiles(auto: true) } }
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Something wrong?").font(.headline)
                    Text("Plug in your iPhone and click Get game log. It saves the game's log on your Desktop; attach it to an issue on HookLink's GitHub page with your iPhone model and where you were in the game. The log holds no game files.")
                    HStack {
                        Button("Get game log") { Task { await app.fetchLog() } }.disabled(app.busy)
                        Link("Report a problem", destination: URL(string: "https://github.com/dsi-hub/HookLink/issues/new/choose")!)
                        Link("Discord", destination: URL(string: "https://discord.gg/bSrN5kEScg")!)
                        if app.busy { ProgressView().controlSize(.small) }
                    }
                    if !app.logStatus.isEmpty { Text(app.logStatus).foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(4)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Help everyone's game run smoother").font(.headline)
                    Text("Every area you play adds to your phone's pipeline list: the graphics setups it had to prepare. Shared lists go into the next update, so other players' games prepare those areas ahead of time instead of stuttering. The list holds identifiers and settings only, never game files or anything personal.")
                    HStack {
                        Button("Share my pipeline list") { Task { await app.sharePipelines() } }.disabled(app.busy)
                        if app.busy { ProgressView().controlSize(.small) }
                    }
                    if !app.shareStatus.isEmpty { Text(app.shareStatus).foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(4)
            }
        }
    }
}

struct LogView: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(Array(app.log.enumerated()), id: \.offset) { i, l in Text(l).font(.system(.caption, design: .monospaced)).textSelection(.enabled).id(i) }
                }.padding(8)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .onChange(of: app.log.count) { _, n in proxy.scrollTo(n - 1, anchor: .bottom) }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        Form {
            TextField("Engine folder (for development)", text: $app.enginePathSetting)
            Text("Leave empty to use the engine HookLink downloads.").font(.caption).foregroundStyle(.secondary)
        }.padding(20).frame(width: 520)
    }
}


/// The Finder way to copy the game files, step by step, then HookLink checks them and does the rest
struct FinderSteps: View {
    @EnvironmentObject var app: HookLink
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("Copy with Finder").font(.headline)
                Text("Finder uses another way to reach your iPhone, so it works when the cable copy keeps stopping.").foregroundStyle(.secondary)
                Label("A Finder window shows romfs.img, your game files (about 26 GB). It takes no extra disk space.", systemImage: "1.circle")
                Label("Open a second Finder window and click your iPhone in the sidebar, under Locations.", systemImage: "2.circle")
                Label("Click the Files tab, and find The Legend of Zelda: Ocarina of Time.", systemImage: "3.circle")
                Label("Drag romfs.img onto the game's name. If Finder asks, choose Replace.", systemImage: "4.circle")
                Label("Wait for Finder's progress to finish (15 to 25 minutes). Keep the phone unlocked, and don't open the game yet.", systemImage: "5.circle")
                HStack {
                    Button("Show romfs.img in Finder") { app.prepareFinderCopy() }
                    Button("Finder is done: check and finish") { Task { await app.copyToPhone(viaFinder: true) } }
                        .buttonStyle(.borderedProminent).disabled(app.busy)
                }
                Text("HookLink then checks the game files arrived whole, and copies and checks the resolution file.").font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(4)
        }
    }
}
