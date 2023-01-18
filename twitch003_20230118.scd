// Greetings!

(
~n = 100;
SynthDef(\additive, {
    var n, seq, freq, freqs, sig, env, envs, atks, rels,
    amps, comb, combEnv, combMod, combOffset;
    n = ~n;
    seq = (1..n);
    freq = \freq.kr(440);
    freqs = freq * seq;
    amps = (1 / seq).pow(\dampen.kr(1.0));
    combOffset = Env.asr(\combAtk.kr(2.0), 1, \combRel.kr(2.0), \combCrv.kr(0)).kr(0, \gate.kr(1));
    combEnv = \combEnv.kr(pi) * \combEnvDir.kr(1).neg;
    combOffset = combOffset.linlin(0, 1, 0, combEnv) + \combOffset.kr(0);
    combMod = \combMod.kr(pi) * \combModDir.kr(1).neg;
    combOffset = LFTri.kr(\combRate.kr(0.1)).range(-1, 1) * combMod + combOffset;
    comb = sin(seq.linlin(1, n, 1, \teeth.kr(8) * pi) + combOffset).abs;
    comb = comb.pow(\toothWidth.kr(1));
    comb = comb.linlin(0, 1, \combDepth.kr(-60), 0).dbamp;
    comb = 1.blend(comb, \combAmt.kr(1));
    atks = \atks.kr(0!n);
    rels = \rels.kr(1!n);
    envs = Env.asr(atks, 1, rels, 0).ar(0, \gate.kr(1));
    amps = amps * envs * comb;
    sig = SinOsc.ar(freqs);
    sig = sig.collect{|snd, i|
        Select.ar(freqs[i] > (SampleRate.ir / 2), [snd, DC.ar(0) * snd])
    };
    sig = sig * amps;
    sig = sig.sum;
    env = Env.asr(\atk.kr(1), 1, \rel.kr(1), 0).ar(2, \gate.kr(1));
    sig = sig * env;
    sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), sig);
}).add;

// The following drum SynthDefs are from Yoshinosuke Horiuchi's SC-808 project (https://www.patreon.com/posts/sc-808-free-40121526)

SynthDef.new(\bd, {
	arg decay=30, amp=2, gate=0, tone=56;
	var fenv, env, trienv, sig, sub, punch, pfenv;
	env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225),doneAction:2);
	trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230),doneAction:0);
	fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
	pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
	punch = SinOsc.ar(pfenv, pi/2) * env * 2;
	punch = HPF.ar(punch, 350);
	sig = (sig + sub + punch) * 2.5;
	sig = Limiter.ar(sig, 0.5) * amp;
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\sn, {
	arg amp=2, tone=340, tone2=189, snappy=0.3, gate=0, amp2=1;
	var noiseEnv, atkEnv, sig, noise, osc1, osc2, sum;
	noiseEnv = EnvGen.kr(Env.perc(0.001, 4.2, 1, -115), doneAction:2);
	atkEnv = EnvGen.kr(Env.perc(0.001, 0.8,curve:-95), doneAction:0);
	noise = WhiteNoise.ar;
	noise = HPF.ar(noise, 1800);
	noise = LPF.ar(noise, 8850);
	noise = noise * noiseEnv * snappy;
	osc1 = SinOsc.ar(tone2, pi/2) * 0.6;
	osc2 = SinOsc.ar(tone, pi/2) * 0.7;
	sum = (osc1+osc2) * atkEnv * amp2;
    sig = Pan2.ar((noise + sum) * amp * 2.5, \pan.kr(0));
	sig = HPF.ar(sig, 340);
	Out.ar(0, sig);
}).add;

SynthDef.new(\claves, {
	arg amp=1;
	var  env, sig;
	env = EnvGen.kr(Env.new([1, 1, 0], [0, 0.1], -20), doneAction:2);
	sig = SinOsc.ar(2500, pi/2) * env * amp;
    sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(0, sig);
}).add;

SynthDef.new(\hat, {
	arg decay=0.42, amp=1, pan=0;
	var sig, sighi,siglow, sum, env, osc1, osc2, osc3, osc4, osc5, osc6;
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -30),doneAction:2);
	osc1 = LFPulse.ar(203.52);
	osc2 = LFPulse.ar(366.31);
	osc3 = LFPulse.ar(301.77);
	osc4 = LFPulse.ar(518.19);
	osc5 = LFPulse.ar(811.16);
	osc6 = LFPulse.ar(538.75);
	sighi = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    siglow = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    sighi = BPF.ar(sighi, 8900, 1);
    sighi = HPF.ar(sighi, 9000);
    siglow = BBandPass.ar(siglow, 8900, 0.8);
    siglow = BHiPass.ar(siglow, 9000, 0.3);
    sig = BPeakEQ.ar((siglow+sighi), 9700, 0.8, 0.7);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(0, sig);
}).add;

SynthDef.new(\cymbal, {
	arg decay=2, amp=20, pan=0, gate=0, tone=0.002;
	var sig, sig1,sig2, sig2a, sig2b, sig3, env1, env2, env2b, env3, osc1, osc2, osc3, osc4, osc5, osc6, sum;
	env1 = EnvGen.kr(Env.perc(0.3, decay, curve:-3), doneAction:2);
	env2 = EnvGen.kr(Env.new([0, 0.6, 0], [0.1, decay*0.7], -5), doneAction:0);
	env2b = EnvGen.kr(Env.new([0, 0.3, 0], [0.1, decay*20], -120), doneAction:0);
	env3 = EnvGen.kr(Env.new([0, 1, 0], [0, decay*5], curve:-150), doneAction:0);
	osc1 = LFPulse.ar(203.52) * 0.6;
	osc2 = LFPulse.ar(366.31) * 0.6;
	osc3 = LFPulse.ar(301.77) * 0.6;
	osc4 = LFPulse.ar(518.19) * 0.6;
	osc5 = LFPulse.ar(811.16) * 0.6;
	osc6 = LFPulse.ar(538.75) * 0.6;
	sig = osc1 + osc2 + osc3 + osc4 + osc5 +osc6;
	sig1 = BLowShelf.ar(sig, 2000, 1, 5);
	sig1 = BPF.ar(sig1, 3000);
	sig1 = BPeakEQ.ar(sig1, 2400, 0.5, 5);
	sig1 = BHiPass.ar(sig1, 1550, 0.7);
	sig1 = LPF.ar(sig1, 3000);
	sig1 = BLowShelf.ar(sig1, 1000, 1, 0);
	sig1 = sig1 * env1 * tone;
	sig2 = BLowShelf.ar(sig, 990, 2, -5);
	sig2 = BPF.ar(sig2, 7400);
	sig2 = BPeakEQ.ar(sig2, 7200, 0.5, 5);
	sig2 = BHiPass4.ar(sig2, 6800, 0.7);
	sig2 = BHiShelf.ar(sig2, 10000, 1, -4);
	sig2a = sig2 * env2 * 0.3;
	sig2b = sig2 * env2b * 0.6;
	sig3 = BLowShelf.ar(sig, 990, 2, -15);
	sig3 = BPF.ar(sig3, 6500);
	sig3 = BPeakEQ.ar(sig3, 7400, 0.35, 10);
	sig3 = BHiPass4.ar(sig3, 10500, 0.8, 2);
	sig3 = sig3 * env3;
	sum = sig1 + sig2a + sig2b + sig3;
	sum = LPF.ar(sum, 4000);
	sum = Pan2.ar(sum, 0);
	sum = sum * amp;
	Out.ar(0, sum);
}).add;

SynthDef(\verb, {
    var sig = In.ar(\out.kr(0), 2);
    var verb = NHHall.ar(sig);
    verb = DelayN.ar(verb, 0.05, 0.05);
    sig = sig.blend(verb, \wet.kr(0.2));
    ReplaceOut.ar(\out.kr(0), sig);
}).add;
)

(
Pdef(\addy, Pbind(*[
    instrument: \additive,
    // degree: Pshuf((0..8).scramble[..3], inf),
    degree: 0,
    harmonic: Pwhite(1, 10),
    legato: 0.5,
    octave: 4,
    atk: 0.02, rel: 1,
    dur: Pwrand([2, Pseq([1, 1]), Pn(1/2, 4)], [1,2,3].normalizeSum, inf),
    // atks: Array.fill(~n, {|i| i.linlin(1, ~n, 0.5, 5)}),
    combOffset: pi/2,
    combAtk: 0.5,
    combRel: 0.5,
    combAmt: 0.98,
    combEnv:3pi,
    combEnvDir: Prand([1, -1], inf),
    combMod: 4pi,
    combModDir: Prand([1, -1], inf),
    combRate: Pexprand(0.01, 0.4),
    combDepth: -40,
    combAtk: Pexprand(0.05, 1.0),
    combRel: Pwhite(0.2, 4.0),
    teeth: Pwhite(1.0, 16),
    toothWidth: Pwhite(0.1, 10),
    dampen: Pwhite(0.3, 1.3),
    amp: Pkey(\dampen).linlin(0.3, 1.3, 0.1, 0.5) * 0.5,
    pan: Pwhite(-1.0, 1),
    finish: {|ev|
        while({ev.freq > 600}, {ev.freq = ev.freq / 2})
    }
])).play;
// Pdef(\addy2).clear;
Pdef(\addy2, Pbind(*[
    instrument: \additive,
    legato: 1,
    degree: 0,
    harmonic: 1,
    octave: 2,
    pan: 0,
    dur: 8,
    atk: 1,
    rel: 1,
    combAtk: 4,
    combRel: 4,
    combOffset: pi/2,
    combAmt: 0.98,
    combEnv: Pwhite(0, 8pi),
    combEnvDir: Prand([1, -1], inf),
    combMod: Pwhite(0, 7pi),
    combModDir: Prand([1, -1], inf),
    combRate: Pexprand(0.01, 0.04) * 3,
    combDepth: -80,
    teeth: Pwhite(1.0, 4),
    toothWidth: Pwhite(0.5, 2),
    dampen: Pwhite(0.5, 0.8),
    amp: Pkey(\dampen).linlin(0.3, 1.3, 0.1, 0.5) * 0.4,
])).play;

Pdef(\kick, Pbind(*[
    instrument: \bd,
    dur: 1/4,
    yes: Pseq([
        1, \, \, \,
        \, 1, \, \,
        1, \, \, 1,
        \, \, \, 1
    ], inf),
    decay: 4,
    amp: 1.7
])).play;

Pdef(\snare, Pbind(*[
    instrument: \sn,
    dur: 1/8,
    yes: Pseq([
        \, Pwrand([\, 1], [8, 1].normalizeSum),
        \, Pwrand([\, 1], [8, 1].normalizeSum),
        1, Pwrand([\, 1], [8, 1].normalizeSum),
        \, Pwrand([\, 1], [8, 1].normalizeSum)
    ], inf),
    amp: Pseq([1, 1/2], inf) * 0.5,
    pan: -0.3
])).play;

Pdef(\hat, Pbind(*[
    instrument: \hat,
    dur: 1/8,
    amp: Pseq([1/2, 1/4, 1, 1/4], inf) * 0.4,
    pan: 0.3
])).play;

Pdef(\claves, Pbind(*[
    instrument: \claves,
    dur: 1/8,
    yes: Pbjorklund(5, 16, inf, -2).collect{|i| if(i == 0){\}{i}},
    amp: 0.3,
    pan: Pwhite(-1.0, 1.0)
])).play;

Pdef(\cymbal, Pbind(*[
    instrument: \cymbal,
    dur: 16,
    amp: 5,
    decay: 8
])).play;
)

~verb = Synth.tail(nil, \verb);
~verb.set(\wet, 0.05);

(
~syn = Synth(\additive, [
    freq: 60,
    atks: Array.fill(~n, {|i| i.linlin(1, ~n, 0.5, 5)}),
    atk: 0,
    combOffset: pi/2,
    combAtk: 0.5,
    combRel: 0.5,
    combAmt: 0.98,
    combEnv: 4pi,
    combEnvDir: 1,
    combMod: pi,
    combModDir: -1,
    combRate: 0.04,
    combDepth: -40,
    combAtk: 0.5,
    combRel: 1.0,
    teeth: 3,
    toothWidth: 0.5,
    dampen: 0.7,
    amp: 0.2
]);
)
(
~syn.set(
    \combDepth, -40,
    \teeth, 3,
    \toothWidth, 0.5,
    \combRange, 4pi,
    \combRate, 0.1,
    \combAmt, 1,
    \combDepth, -100,
    \freq, 60,
    \dampen, 0.7,
    \amp, 0.2
);
)
~syn.release;

// Ok, bye!