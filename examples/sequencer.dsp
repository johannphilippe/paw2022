import("stdfaust.lib");

amp = hslider("amp", 0.2, 0, 1, 0.01);
speed = hslider("speed", 0.2, 0.1, 2, 0.01) : si.smoo;

// Outputs triggers on first output, and velocity (normalized) on second 
sequencer(t, freq) = (res > 0) * (ph != ph'), res
with {
    sz = t : _,!;
    ph = int(os.phasor(sz, freq)); 
    res = t, ph : rdtable;
};
sequ = waveform{1,0,0,0,0,1};
bt = sequencer(sequ, speed) : en.ar(0,0.1), !;

process = os.sawtooth(100) * amp * bt;