import("stdfaust.lib");

amp = hslider("amp", 0.2, 0, 1, 0.01);
speed = hslider("speed", 0.2, 0.1, 2, 0.01) : si.smoo;
noise_amt = hslider("noise_amount", 1, 1, 4, 0.1) : si.smoo;
naive_impl(fq) = (_, ma.SR/fq : fmod) ~+(1.0) : <=(1.0);
accent(modulo, beat) = _~+( is ) : %(modulo) : ==(0) : &(is)
with {
    is = beat > beat';
};

phasor_impl(fq, phase) = incr/smps
with {
    incr = _~+(1.0) : +(offset) : _, smps : fmod;
    offset = (1.0 - phase) * smps;
    smps = ma.SR/fq;
};

phasor(fq) = phasor_impl(fq, 0);
phasor_ph(fq, phase) = phasor_impl(fq, phase);

metro_impl(fq, phase) = incr<=1.0
with {
    offset = (1.0-phase) * smps;
    incr = _~+(1.0) : +(offset) : _,smps : fmod;
    smps = ma.SR/fq; 
};

metro(fq) = metro_impl(fq, 0);
metro_swing(fq, swing) = metro_impl(fq,0) | metro_impl(fq, swing);
drunk_metro_acc(fq, noise_amt) = bt, acc
with {
    trig = metro(fq)|(fq!=fq')|os.impulse;
    frq = fq + (no.noise * noise_amt) : ba.sAndH(trig);
    bt = metro(frq);
    acc_mod = int(abs(no.noise*noise_amt))+1;
    acc = accent(acc_mod, bt);
};

euclidian(onset, div, pulses, rotation, phasor) = (euclid' != euclid) & (phase' != phase)
with {
    phase = ((phasor + rotation) * div), 1.0 : / : *(pulses) : int;
    euclid = int((onset/pulses) * phase);
};

ph = phasor(speed);

synt = os.sawtooth(100) * (euclidian(3,3,5,0, ph):en.are(0,0.3))
    + os.sawtooth(200) * (euclidian(2,2,5, 0, ph):en.are(0,0.2))
    + os.sawtooth(500) * (euclidian(3, 3, 13, 0, ph ) : en.are(0,0.1))
    , 
    os.sawtooth(300) * (euclidian(3,3,7,0,ph) : en.are(0,0.3))
    + os.sawtooth(400)* (euclidian(5,3,8, 0,ph) : en.are(0,0.1))
    + os.sawtooth(50) * (euclidian(2, 2, 13, 0, ph) : en.are(0, 0.6));


process = synt : _*amp, _*amp;

