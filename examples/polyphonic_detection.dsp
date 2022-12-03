declare name            "polyphonic_detection";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2022";

import("stdfaust.lib");

/*
	poly_detector : A polyphonic pitch detector based on parallel bandpass filters 

	Input Arguments : 
	* thresh : threshold detection - when the RMS level of a band crosses the threshold, it will output the RMS of the band, else 0 
	* rms_avg : RMS average (duration in seconds) 
        * sig : input signal

	Output : 
	* N_BANDS parallel signals. Value of each signal is the RMS of the band if this RMS level is above threshold, else 0. Bandpass filters frequencies are MIDI notes from 20 to (20 + N_BANDS)
*/

// Increase N_FILTER for more accuracy, reduce it to increase processing speed
N_FILTER = 4;
// From midi note 20 to 20 + 105 (125)
N_BANDS = 105;


poly_detector(thresh, rms_avg, sig) = par(n, N_BANDS, chain(20 + n))
with {
	// Precision of filters is 1/4 tone up and down of the center frequency
        filter(note) = fi.bandpass(1, ba.midikey2hz(note - 0.5), ba.midikey2hz(note + 0.5));
	// Sequential butterworth bandpass filter
        band( note) = seq(n, N_FILTER, filter(note));

	// RMS detection
        detect(band) = 0, brms : select2( (brms > thresh) )
        with {
                brms = band : an.rms_envelope_rect(rms_avg);
        };

	// Filters the input signal, and calls RMS detection
        chain(note) = detect(bnd)
        with {
            bnd = sig : band(note) : fi.dcblocker;
        };
};


synt(note, atq, rel, amp) = os.sawtooth(ba.midikey2hz(note)) * env * amp
with {
        env = (amp > 0) : en.are(atq, rel);
};

rms_avg = hslider("rms", 0.01, 0.0001, 0.1, 0.00001);
atq =  hslider("attack", 0.1, 0.05, 1, 0.01);
rel = hslider("release", 0.1, 0.01, 3, 0.01);
threshold = hslider("thresh", 0.001, 0.0001, 1, 0.0001);
process = _ : poly_detector(threshold, rms_avg) : par(n, N_BANDS, synt(n + 20, atq, rel)) :> _;
