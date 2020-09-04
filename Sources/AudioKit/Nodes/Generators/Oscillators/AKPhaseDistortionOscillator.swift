// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
public class AKPhaseDistortionOscillator: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(generator: "pdho")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: akGetParameterAddress("AKPhaseDistortionOscillatorParameterFrequency"),
        range: 0 ... 20_000,
        unit: .hertz,
        flags: .default)

    /// Frequency in cycles per second
    @Parameter public var frequency: AUValue

    public static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: akGetParameterAddress("AKPhaseDistortionOscillatorParameterAmplitude"),
        range: 0 ... 10,
        unit: .generic,
        flags: .default)

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

    public static let phaseDistortionDef = AKNodeParameterDef(
        identifier: "phaseDistortion",
        name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
        address: akGetParameterAddress("AKPhaseDistortionOscillatorParameterPhaseDistortion"),
        range: -1 ... 1,
        unit: .generic,
        flags: .default)

    /// Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    @Parameter public var phaseDistortion: AUValue

    public static let detuningOffsetDef = AKNodeParameterDef(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: akGetParameterAddress("AKPhaseDistortionOscillatorParameterDetuningOffset"),
        range: -1_000 ... 1_000,
        unit: .hertz,
        flags: .default)

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    public static let detuningMultiplierDef = AKNodeParameterDef(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: akGetParameterAddress("AKPhaseDistortionOscillatorParameterDetuningMultiplier"),
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKPhaseDistortionOscillator.frequencyDef,
             AKPhaseDistortionOscillator.amplitudeDef,
             AKPhaseDistortionOscillator.phaseDistortionDef,
             AKPhaseDistortionOscillator.detuningOffsetDef,
             AKPhaseDistortionOscillator.detuningMultiplierDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKPhaseDistortionOscillatorDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: The waveform of oscillation
    ///   - frequency: Frequency in cycles per second
    ///   - amplitude: Output Amplitude.
    ///   - phaseDistortion: Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable = AKTable(.sine),
        frequency: AUValue = 440,
        amplitude: AUValue = 1,
        phaseDistortion: AUValue = 0,
        detuningOffset: AUValue = 0,
        detuningMultiplier: AUValue = 1
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.phaseDistortion = phaseDistortion
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
