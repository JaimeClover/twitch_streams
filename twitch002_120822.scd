// hi

// how about some Ndefs?
b = Buffer.alloc(s, 44100 * 10, 2);
(
var fund = 55;

Ndef(\ocean).fadeTime_(10);
Ndef(\ocean, {
    var sig, sig2;
    var n = 8;
    sig = PinkNoise.ar(0.2 ! n);
    sig = BLowPass.ar(sig,
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).exprange(400, 2000),
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.3, 1.5),
    ).blend(sig,
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.0, 0.3)
    );
    sig2 = WhiteNoise.ar(0.2 ! n);
    sig2 = BHiPass.ar(sig,
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).exprange(400, 2000),
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.3, 1.5),
    ).blend(sig2,
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.0, 0.3)
    );
    sig = sig.blend(sig2,
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.0, 0.6)
    );
    sig = sig * SinOsc.kr(
        freq: SinOsc.kr(0.5, {Rand(-pi, pi)}!n).range(0.03, 0.3),
        phase: {Rand(-pi, pi)}
    ).range(0, 1);
    sig = Pan2.ar(sig, SinOsc.kr(
        freq: SinOsc.kr(0.5, {Rand(-pi, pi)}!n).range(0.03, 0.3),
        phase: {Rand(-pi, pi)}!n
    ) * 0.7);
    sig = (sig.sum * SinOsc.kr(0.1).range(1, 3)).tanh * 0.3;
    sig.postln;
    sig = sig.blend(
        JPverb.ar(sig, 7.0, 0.3),
        LFNoise1.kr(0.11).range(0.02, 0.4)
    );
    sig = LeakDC.ar(sig);
}).play;

Ndef(\blah).fadeTime_(10);
Ndef(\blah, {
    var n = 6;
    var freq = LFNoise0.kr(5!n).exprange(fund, fund * 2.pow(4)).round(fund);
    var sig = Squine.ar(
        freq,
        SinOsc.kr(0.14).unipolar,
        SinOsc.kr(0.1).unipolar,
    );
    var env = Env.perc(
        LFNoise0.kr(3!n).exprange(0.001, 0.1),
        LFNoise0.kr(3!n).exprange(0.1, 2.8),
        curve: -9
    ).ar(0,
        Dust.ar(SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(1, 1))
    );
    sig = MoogFF.ar(sig,
        (SinOsc.kr(0.2, {Rand(-pi, pi)}!n).exprange(1, 20) * freq).clip(20, 21000),
        SinOsc.kr(0.27, {Rand(-pi, pi)}!n).range(0.4, 4)
    );
    sig = Pan2.ar(sig,
        SinOsc.kr(
            0.12!n,
            {Rand(-pi, pi)}!n
        )
    );
    sig = sig * env * 0.1;
    sig = (sig.sum * SinOsc.kr(0.1).range(1, 3)).tanh * 0.9;
    sig = sig.blend(CombC.ar(sig, 0.9,
        SinOsc.kr(0.01).range(0.5, 0.8),
        SinOsc.kr(0.1).range(4, 8)
    ), 0.3);
    sig = sig.blend(
        JPverb.ar(sig, 7.0, 0.3),
        LFNoise1.kr(0.11).range(0.02, 0.5)
    );
    sig = LeakDC.ar(sig);
}).play;

Ndef(\bass).fadeTime_(10);
Ndef(\bass, {
    var n = 4;
    var sig, env, grainrate, freq;
    var trig = Impulse.kr(0) + Dust.kr(1);
    freq = Demand.kr(trig!n, 0, Drand((1..8), inf)).lag(0.001);
    freq = fund * freq;
    freq = freq * LFNoise1.kr(4).bipolar(0.1).midiratio;
    sig = LFSaw.ar(freq);
    sig = BLowPass4.ar(sig,
        (SinOsc.kr(0.1!n, {Rand(-pi, pi)}!n).range(1, 8) * freq).clip(20, 20000),
        SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.04, 0.4)
    );
    env = LFNoise1.kr(0.2).range(0.1, 0.6);
    sig = sig * env;
    sig = Decimator.ar(sig,
        SinOsc.kr(0.3, {Rand(-pi, pi)}!n).range(3000, 20000),
        SinOsc.kr(0.3, {Rand(-pi, pi)}!n).range(4, 12)
    ).blend(sig, SinOsc.kr(0.1, {Rand(-pi, pi)}!n).range(0.0, 1.0));
    sig = PitchShift.ar(sig, 0.2, LFNoise0.kr(0.2!n).exprange(0.5, 2)).blend(
        sig, SinOsc.kr(0.3, {Rand(-pi, pi)}!n).range(0.0, 1.0)
    );
    sig = Pan2.ar(sig,
        SinOsc.kr(
            0.12!n,
            {Rand(-pi, pi)}!n
        )
    );
    sig = sig.sum;
    grainrate = 10;
    sig = GrainIn.ar(1, Impulse.ar(grainrate), 1/grainrate, sig).blend(
        sig, SinOsc.kr(0.3).range(0.0, 1.0)
    );
    sig = sig.blend(
        JPverb.ar(sig, 4.0, 0.3),
        LFNoise1.kr(0.11).range(0.2, 0.5)
    );
    sig = LeakDC.ar(sig);
    sig * 0.1;
}).play;
)
(
SynthDef(\playbuf, {|buf|
    var decay = \decay.kr(10.0);
    var sig = PlayBuf.ar(2, buf, \rate.kr(1.0), 1, \start.kr(0.0));
    var env = Env.adsr(\atk.kr(0.1), \dec.kr(0.1), \sus.kr(1), \rel.kr(0.1), curve: \crv.kr(-4)).ar(2, \gate.kr(1));
    var freq = 200;
    sig = RLPF.ar(sig, (freq * env.pow(2).linlin(0, 1, \cfmin.kr(1), \cfmax.kr(16))).clip(20, 20000),
        Rand(0.1, 0.9)
    );
    sig = Decimator.ar(sig, 5000, 6).blend(sig, Rand(0.6, 0.9));
    sig = FreqShift.ar(sig, env.linlin(0, 1, -150, 150));
    sig = sig * env;
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(0.3));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\comb, {
    var sig = In.ar(\in.kr(0), 2);
    sig = CombN.ar(sig, 1.0, \del.kr(0.125), \dec.kr(6)).blend(sig, \dry.kr(0.6));
    Out.ar(\out.kr(0), sig);
}).add;
)
(
var n = 1;
Pdef(\buf, Pbind(\instrument, \playbuf,
    \rate, (Pwhite(-12, 12).midiratio * 2.pow(Pwhite(-4, 4) / 2)).clump(n),
    \dur, 1/8,
    \start, Pfunc{b.numFrames.rand},
    \legato, Pwhite(0.1, 0.5),
    \atk, Pexprand(0.0001, 0.001).clump(n),
    \rel, Pwhite(0.01, 0.3).clump(n),
    \cfmin, Pwhite(1, 4),
    \cfmax, Pwhite(8, 16).clump(n),
    \yes, Pn(Plazy{
        Pbjorklund(3, 8, 4, 8.rand).collect{|i| if(i == 0){\}{i}}
    }),
    \amp, Pwhite(0.5, 1.0) * Array.geom(n, 1, 0.5) * 0.5,
    \pan, Pwhite(-1.0, 1.0).clump(n) * 0.5,
    \lag, Array.series(n, 0, 1/2),
    \out, ~combbus
)).play;
)

~combbus = Bus.audio(s, 2);

~comb = Synth.tail(nil, \comb, [in: ~combbus]);
~comb.set(\dec, 2, \del, 0.25, \dry, 0.3);
~comb.free;

~rec = {RecordBuf.ar(In.ar(0, 2), b, loop: 0, doneAction: 2); Silent.ar}.play(addAction: \addToTail);
~rec.free;
b.play;


// okay...I think that's enough.

Ndef.clear(30);

Pdef(\buf).stop;
