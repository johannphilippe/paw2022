
declare name            "polyphonic_detection";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2022";

import("stdfaust.lib");

mpulse(smps_dur, trig) = pulsation
with {
    count = ba.countdown(smps_dur, trig > 0 );
    //count =  -(1)~_, smps_dur : select2(trig);
    pulsation = 0, 1 : select2(count > 0);
};
mpulse_dur(duration, trig) = mpulse(ba.sec2samp(duration), trig);

line(time, sig) = res
letrec {
	'changed = (sig' != sig) | (time' != time);
	'steps = ma.SR * time;
	'cntup = ba.countup(steps ,changed);  
	'diff = ( sig - res);
	'inc = diff / steps : ba.sAndH(changed);
	'res = res, res + inc : select2(cntup <  steps);
};


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
N_FILTER = 3;
// From midi note 20 to 20 + 105 (125)
N_BANDS = 105;

poly_detector(thresh, rms_avg,atq, rel, sig) = 0 : seq(n, N_BANDS, chain(20 + n))
with {
	// Precision of filters is 1/4 tone up and down of the center frequency
        //filter(note) = fi.resonbp(ba.midikey2hz(note), 1000, 0.005) ; //fi.bandpass(1, ba.midikey2hz(note - 0.5), ba.midikey2hz(note + 0.5));
        
        filter(note) = fi.bandpass(1, ba.midikey2hz(note - 0.5), ba.midikey2hz(note + 0.5));

	// Sequential butterworth bandpass filter
        band( note) = seq(n, N_FILTER, filter(note));

        oscilo(note, amp) = (os.osc(ba.midikey2hz(note) ) + (os.osc(ba.midikey2hz(note) * 0.5) *0.5 ) ) : *(env) : *(itp_amp)
        with {
            trig = amp : mpulse_dur(atq);
            env = trig : en.are(atq, rel);
            itp_amp = amp : ba.sAndH(amp > 0) : line(0.1);
        };
	// Filters the input signal, and calls RMS detection
        chain(note) = +(syn)
        with {
            syn = sig : band(note) : fi.dcblocker : detect : oscilo(note);
            detect(band) = 0, brms : select2(brms > thresh) 
            with {
                brms = band : an.rms_envelope_rect(rms_avg);
            };
        };

};

reverberate(mix, sig) = sig : re.mono_freeverb(0.8, 0.8, 0.4, 1) : _ * mix + sig * (1 - mix);

rms_avg = hslider("rms", 0.01, 0.0001, 1, 0.00001);
atq =  hslider("attack", 0.1, 0.05, 1, 0.01);
rel = hslider("release", 0.1, 0.01, 3, 0.01);
threshold = hslider("thresh", 0.001, 0.0001, 1, 0.0001);
mix = hslider("drymix", 0, 0, 1, 0.01) : si.smoo;
process = _ <: poly_detector(threshold, rms_avg, atq, rel), _ : reverberate(0.4), _ * mix;
