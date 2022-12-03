import("stdfaust.lib");

amp = hslider("amp", 0.2, 0, 1, 0.01);
speed = hslider("speed", 1, 0.1, 10, 0.01) : si.smoo;

 
// Tempo adjusts so each step is equivalent
swing_sequencer(t,tswing, size, freq) = ((res > 0) * (ph != ph')) | swing, res
with {
    ph = int(os.phasor(size, freq / size));
    sw = tswing, ph : rdtable; 
    phstep = os.hs_phasor(1, freq, sw != sw');
    swing = 0, 1 : select2(cond) : ba.impulsify
    with {
        cond = (phstep >= sw) & (phstep' <= sw);
    };
    
    res = t, ph : rdtable;
};

sequ = waveform{1,0,0,1,0,1};
swing = waveform{0.33, 0,0,0.7,0, 0.66};
bt = swing_sequencer(sequ, swing, 6, 3) : en.are(0,0.3),!;

process = os.sawtooth(100) * amp * bt;

