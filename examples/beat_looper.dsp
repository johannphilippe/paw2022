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

beat_looper(SIZE, record, read_speed) = looper : *(read_cond)
with {
    looper = rwtable(SIZE, 0.0, recindex, _, readindex);
    recindex = (+(1) : %(SIZE)) ~ *(record);
    read_cond = read_speed>0;
    readindex = read_speed/float(ma.SR) : (+ : ma.frac) ~ _ : *(float(SIZE)) : int : *(read_cond);
};

origin_beat = euclidian(3, 3, 5, 0, ph)
with {
    ph = phasor(speed);
};

rec = checkbox("record");
rspeed = hslider("read_speed", 0, 0, 4, 0.01) : si.smoo;
loop = origin_beat : beat_looper(48000*5, rec, rspeed);
env1 = origin_beat : en.ar(0,0.3);
env2 = loop : en.ar(0,0.3);
process = os.sawtooth(100) * amp * env1, os.sawtooth(150) * amp * env2;

