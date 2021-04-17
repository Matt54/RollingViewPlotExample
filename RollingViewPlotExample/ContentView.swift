//
//  ContentView.swift
//  RollingViewPlotExample
//
//  Created by Matt Pfeiffer on 4/17/21.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct OscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.5
    var rampDuration: AUValue = 1
}

class OscillatorConductor: ObservableObject {

    let engine = AudioEngine()

    @Published var data = OscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var boostingNode = Mixer()
    var osc = Oscillator()
    var reducingNode = Mixer()

    init() {
        boostingNode.volume = 4.0
        reducingNode.volume = 0.5
        boostingNode.addInput(osc)
        reducingNode.addInput(boostingNode)
        engine.output = reducingNode
    }

    func start() {
        osc.amplitude = 0.2
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct ContentView: View {
    @ObservedObject var conductor = OscillatorConductor()
    
    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            NodeRollingView(conductor.reducingNode)
        }
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
