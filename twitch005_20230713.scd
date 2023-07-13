(
SynthDef(\addy, {
    var n, harms, det, sig, saw, square, tri, three, amps, freqs, base;
    n = 500;
    harms = (1..n);
    base = harms.reciprocal;
    saw = base * \saw.kr(0);
    square = base * [1, 0] * \square.kr(0);
    tri = base.pow(2) * [1, 0] * \tri.kr(0);
    three = base * [1, 0, 0] * \three.kr(0);
    amps = saw + square + tri + three;
    amps = amps.normalizeSum * base.sum;
    freqs = \freq.kr(40, \lg.kr(0.2)) * harms;
    det = LFNoise2.kr(0.5!2).bipolar(0.1).midiratio;
    sig = freqs.collect{|freq, i|
        SinOsc.ar(freq * det) * (amps[i] * (freq < 22050)).max(0.000001)
    };
    sig = sig.sum * \amp.kr(0.1);
    sig = RLPF.ar(sig, \ffreq.kr(1000, \lg.kr), \rq.kr(0.5, \lg.kr));
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;
)

(
SynthDef(\kick, {
    var sig, nois, mod, env;
    mod = SinOsc.ar(\modFreq.kr(4.55), \modPhase.kr(pi/7)) * Env([1, 0], 0.3, -4).ar * \idx.kr(50);
    sig = SinOsc.ar(\freq.kr(50) * Env([10, 1], 0.4, -16).ar, mod);
    env = Env.perc(0.01, 0.3).ar(2);
    nois = LPF.ar(WhiteNoise.ar(0.5), 4000) * Env([1, 0], 0.1, -4).ar;
    sig = sig + nois;
    sig = sig.blend((sig * \tanh.kr(10)).tanh, \dist.kr(0.5));
    sig = sig * env * \amp.kr(0.3);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\snare, {
    var sig, env, freqenv;
    sig = RHPF.ar(WhiteNoise.ar, 4000, 0.6);
    freqenv = Env([0.03, 0.02], 0.2, -10).ar;
    sig = sig.blend(MembraneCircle.ar(WhiteNoise.ar(0.1), freqenv, 0.99999), 0.7);
    sig = LPF.ar(sig, 12000);
    env = Env.perc(0.001, 0.3, 1, 2).ar(2);
    sig = sig.blend((sig * \tanh.kr(10)).tanh, \dist.kr(0.5));
    sig = sig * env * \amp.kr(0.9);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;
)

(
var synth, controls, root;

synth = Synth(\addy, [amp: 0.025]);
controls = [\square, \tri, \three];
root = 4;

controls.do{|controlName|
    Pdef(controlName,
        Pbind(
            \type, \set,
            \dur, 1/8,
            \id, synth.nodeID,
            \args, [controlName],
            controlName, Pn(Pshuf([0, 0, 0, 0, 1, 1, 1, 0], 4), inf),
            // \lag, Pwhite(0, 1) / 16
        )
    ).play;
};

Pdef(\freq,
    Pbind(
        \type, \set,
        \dur, 1/2,
        \id, synth.nodeID,
        \args, #[\freq, \lg],
        \scale, Scale.minorPentatonic,
        \dummy, Pn(Pshuf((0..5), 4), inf, \deg),
        \root, root,
        \degree, Pshuf((0..5), inf),
        \octave, Pgate(Pwhite(3, 4), inf, \deg) - 1,
        \lag, Pwhite(0, 1) / 4,
        \lg, Pexprand(0.01, 0.3),
        // \freq, Pexprand(50, 400).round(40)
    )
).play;

Pdef(\ffreq,
    Pbind(
        \type, \set,
        \dur, 1/8,
        \id, synth.nodeID,
        \args, #[\ffreq, \rq],
        \ffreq, Pexprand(400, 18000),
        \rq, Pexprand(0.05, 0.5)
        // \freq, Pexprand(50, 400).round(40)
    )
).play;

Pdef(\kickpat,
    Pbind(
        \instrument, \kick,
        \dur, 1/2,
        \octave, 2,
        \root, root,
        \tanh, Psine.range(1.0, 10, 3.14, 1.0.rand),
        \dist, Psine.range(0.0, 1.0, 4, 1.0.rand),
        \amp, 0.8 * Pfunc{|ev| ev.dist.linlin(0, 1, 1, 0.4)},
    )
).play;

Pdef(\snarepat,
    Pbind(
        \instrument, \snare,
        \dur, 1/2,
        \yes, Pseq([\, 1], inf),
        \octave, 2,
        \root, root,
        \tanh, Psine.range(1.0, 4, 3.14, 1.0.rand),
        \dist, Psine.range(0.2, 0.6, 4, 1.0.rand),
        \amp, 0.3 * Pfunc{|ev| ev.dist.linlin(0, 1, 1, 0.4)},
    )
).play;
)
