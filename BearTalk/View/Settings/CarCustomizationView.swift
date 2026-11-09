import SwiftUI

struct CarCustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataModel.self) var model: DataModel
    let colorSchemeManager: ColorSchemeManager = .shared
    @AppStorage(DefaultsKey.carModelOverride, store: .appGroup) private var carModelOverride = ""
    @State private var paintOverride = ""
    @State private var interiorOverride = ""
    @State private var lookOverride = ""
    @State private var wheelsOverride = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CarView()
                    .padding(.vertical, 8)

                List {
                    Picker("Car", selection: $carModelOverride) {
                        Text("None").tag("")
                        ForEach(CarSceneModel.allCases, id: \.rawValue) { car in
                            Text(car.displayTitle).tag(car.rawValue)
                        }
                    }
                    .onChange(of: carModelOverride) {
                        model.applyAppearanceOverrides()
                        reloadOverrideSelections()
                    }

                    if model.sceneModel != .sapphire {
                        Group {
                            Picker("Color", selection: paintSelection) {
                                if ownsDisplayedCar {
                                    Text("None").tag("")
                                }
                                ForEach(paintOverrideChoices, id: \.overrideStorageKey) { color in
                                    HStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 14, height: 14)
                                        Text(color.title)
                                    }
                                    .tag(color.overrideStorageKey)
                                }
                            }

                            if paintSelection.wrappedValue == PaintColor.custom.overrideStorageKey {
                                ColorPicker("Custom Color", selection: customPaintColor, supportsOpacity: false)
                            }

                            Picker("Interior", selection: interiorSelection) {
                                if ownsDisplayedCar {
                                    Text("None").tag("")
                                }
                                ForEach(Interior.overrideChoices(for: model.sceneModel), id: \.overrideStorageKey) { interior in
                                    HStack {
                                        Circle()
                                            .fill(interior.leatherColor)
                                            .frame(width: 14, height: 14)
                                        Text(interior.title)
                                    }
                                    .tag(interior.overrideStorageKey)
                                }
                            }

                            Picker("Look", selection: lookSelection) {
                                if ownsDisplayedCar {
                                    Text("None").tag("")
                                }
                                ForEach(Look.overrideChoices(for: model.sceneModel), id: \.overrideStorageKey) { look in
                                    Text(look.title).tag(look.overrideStorageKey)
                                }
                            }

                            Picker("Wheels", selection: wheelSelection) {
                                if ownsDisplayedCar {
                                    Text("None").tag("")
                                }
                                ForEach(Wheels.overrideChoices(for: model.sceneModel), id: \.overrideStorageKey) { wheels in
                                    Text(wheels.title).tag(wheels.overrideStorageKey)
                                }
                            }
                        }
                        .id(model.sceneModel)
                    }
                }
            }
            .onAppear {
                model.applyAppearanceOverrides()
                reloadOverrideSelections()
            }
            .onChange(of: model.sceneModel) {
                reloadOverrideSelections()
            }
            .navigationTitle("Car Customization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            dismiss()
                        }
                        .tint(.active)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .preferredColorScheme(colorSchemeManager.currentScheme)
        }
    }

    private var ownsDisplayedCar: Bool {
        model.sceneModel == model.actualSceneModel
    }

    private var paintOverrideChoices: [PaintColor] {
        PaintColor.customSceneModel = model.sceneModel
        return PaintColor.overrideChoices(for: model.sceneModel) + [.custom]
    }

    private var paintSelection: Binding<String> {
        overrideSelection($paintOverride, baseKey: DefaultsKey.carColorOverride)
    }

    private var interiorSelection: Binding<String> {
        overrideSelection($interiorOverride, baseKey: DefaultsKey.interiorOverride)
    }

    private var lookSelection: Binding<String> {
        overrideSelection($lookOverride, baseKey: DefaultsKey.lookOverride)
    }

    private var wheelSelection: Binding<String> {
        overrideSelection($wheelsOverride, baseKey: DefaultsKey.wheelsOverride)
    }

    private var customPaintColor: Binding<Color> {
        let key = DefaultsKey.scoped(DefaultsKey.customPaintColor, model: model.sceneModel)
        return Binding(
            get: {
                let hex = UserDefaults.appGroup.string(forKey: key) ?? "CCCCCC"
                return Color(hex: hex) ?? .gray
            },
            set: { newColor in
                guard let hex = newColor.hexRGB else { return }
                UserDefaults.appGroup.set(hex, forKey: key)
                model.applyAppearanceOverrides()
            }
        )
    }

    private func overrideSelection(_ stored: Binding<String>, baseKey: String) -> Binding<String> {
        Binding(
            get: { stored.wrappedValue },
            set: { newValue in
                stored.wrappedValue = newValue
                let key = DefaultsKey.scoped(baseKey, model: model.sceneModel)
                UserDefaults.appGroup.set(newValue, forKey: key)
                model.applyAppearanceOverrides()
            }
        )
    }

    private func reloadOverrideSelections() {
        paintOverride = readOverride(
            DefaultsKey.carColorOverride,
            choices: paintOverrideChoices,
            preset: PaintColor.preset(for: model.sceneModel)
        )
        interiorOverride = readOverride(
            DefaultsKey.interiorOverride,
            choices: Interior.overrideChoices(for: model.sceneModel),
            preset: Interior.preset(for: model.sceneModel)
        )
        lookOverride = readOverride(
            DefaultsKey.lookOverride,
            choices: Look.overrideChoices(for: model.sceneModel),
            preset: Look.preset(for: model.sceneModel)
        )
        wheelsOverride = readOverride(
            DefaultsKey.wheelsOverride,
            choices: Wheels.overrideChoices(for: model.sceneModel),
            preset: Wheels.preset(for: model.sceneModel)
        )
    }

    private func readOverride<Option: OverrideChoice>(
        _ base: String,
        choices: [Option],
        preset: Option?
    ) -> String {
        let stored = UserDefaults.appGroup.string(forKey: DefaultsKey.scoped(base, model: model.sceneModel)) ?? ""
        let valid = Set(choices.map(\.overrideStorageKey))
        if valid.contains(stored) { return stored }
        let fallback = ownsDisplayedCar ? "" : (preset?.overrideStorageKey ?? "")
        return valid.contains(fallback) ? fallback : ""
    }
}

private protocol OverrideChoice {
    var overrideStorageKey: String { get }
}

extension PaintColor: OverrideChoice {}
extension Interior: OverrideChoice {}
extension Look: OverrideChoice {}
extension Wheels: OverrideChoice {}

#Preview {
    CarCustomizationView()
        .environment(DataModel())
}
