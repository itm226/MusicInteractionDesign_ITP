
//Evaluate this block of code to set up the server.
//Subsequently, evaluate all blocks of code or individual lines in order.

/*This is a workspace, not a program. It represents the stopping point of

a free improvisation that was live coded. As a result, everything here,

of course, can be changed or fiddled with or whatever. This is just a

big messy fiddle if a fiddle were both made out of play-dough and

constrained by a rigid, strict syntax.*/

(
var oscStuff, makeBuffer;
s.options.sampleRate = 48e3;
s.options.memSize = 2.pow(21);
s.options.numInputBusChannels = 2;

oscStuff = {
	["/b_set", "/b_setn", "/b_inf"].do{|string|
		var name = string.split($_);
		name = name[1].asSymbol;
		OSCdef(name, {|...args| args.postln}, string);

	};
	//"OSC stuff set up!".postln; "".postln;
};

s.boot;
ServerTree.add(oscStuff);
)

(
p = ProxySpace.push(s, clock: TempoClock.default);
s.sendMsg("/b_alloc", 0, s.sampleRate * 25)
~o.play;
~o.fadeTime_(4.0);
~o.source = ~n;
)

(
~rec[0] = {
	var in = (SoundIn.ar(0) * 3).clip(0.0, 1.0) * 4;
	BufWr.ar(in, 0, Phasor.ar(0, BufRateScale.kr(0), 0, BufFrames.kr(0)), loop: \loop.kr(1));
}
)

(
~impulserate.fadeTime_(rrand(0.5, 3.0));
~impulserate = {LFNoise1.kr(LFNoise2.kr(0.01).range(0.05, 0.5)).exprange(3.0, 25.0)};
~impulse = {Impulse.kr(~impulserate.kr)};
)

(
~n.reshaping = \elastic;
~n.fadeTime_(2.0);
~n[0] = {
	var impulse = ~impulse.kr;
	var buf = 0;
	var bufdur = BufDur.kr(0);
	var sig = TGrains.ar(
		2,
		impulse,
		buf,
		LFNoise1.kr(0.05).range(0.25, 2.5),
		bufdur * LFSaw.kr((1/bufdur) * \scrubRateRatio.kr(1, 0.1)).range(0, 1),
		LFNoise2.kr(0.05).exprange(0.01, 0.2),
		TRand.kr(-1.0, 1.0, impulse) * LFNoise1.kr(0.05).range(0.0, 1.0);
	);
	sig.flat * 4;
};

~n[1] = \filterIn -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 9.99, LFNoise1.kr(0.05).range(0.1, 9.99));
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.0125, 0.9875));
	delay + in;
};

~n[2] = \filterIn -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 17.5, LFNoise1.kr(1/40).range(1/20, 17.5));
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.0125, 0.9875));
	delay + in;
};

~n[3] = \filter -> {|in|
	var n = 5;
	Splay.ar(BPF.ar(in, {LFNoise1.kr(rrand(0.01, 0.1)).range(250, 4000)} ! n, mul: (2/3) * n, rq: 0.3333333));
};

~n[4] = \filter -> {|in|
	GVerb.ar(in.sum * 0.5, 24.0, 3.0) * 0.5;
};
~n.set(\wet3, 0.5, \wet4, 0.225);
)

s.sendMsg("/b_alloc", 1, s.sampleRate *25);
(
~rec2[0] = {
	var in = SoundIn.ar(0, 1) * 2 + (~n.ar.sum * 0.25);
	BufWr.ar(in, 1, Phasor.ar(0, BufRateScale.kr(1), 0, BufFrames.kr(1)));
};
)

(
~e.reshaping = \elastic;
~e.fadeTime_(2.0);
~e[0] = {
	var impulse = ~impulse.kr;
	var buf = 0;
	var bufdur = BufDur.kr(0);
	var sig = TGrains.ar(
		2,
		impulse,
		buf,
		LFNoise1.kr(LFNoise2.kr(0.025).range(0.05, 4.0)).range(0.125, 2.5),
		bufdur * LFSaw.kr((1/bufdur) * LFNoise1.kr(LFNoise2.kr(0.01).exprange(0.05, 4.0))).range(0, 1),
		LFNoise2.kr(0.05).exprange(0.01, 0.2),
		TRand.kr(-1.0, 1.0, impulse) * LFNoise1.kr(0.05).range(0.0, 1.0);
	);
	sig.flat * 4;
};

~e[1] = \filterIn -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 30, LFNoise1.kr(0.05).exprange(1/40, 29.99));
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.5, 0.9875));
	delay + in;
};

~e[2] = \filterIn -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 17.777, 17.777);
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.5, 0.9875));
	delay + in;
};

~e[3] = \filter -> {|in|
	Splay.ar(
		BPF.ar(in,
			LFNoise2.kr(rrand(0.01, 0.1))
			.range(250, 6000),
			mul: (2/3), rq: 0.3333333));
};

~e[4] = \filter -> {|in|
	GVerb.ar(in.sum * 0.5, 24.0, 3.0)
};
~e.set(\wet3, 1.0, \wet4, 0.225);

~e[5] = \filterIn -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 19.923456777777777,19.923456777777777 );
	LocalOut.ar(delay * LFNoise1.kr(0.05).exprange(0.001, 0.9875));
	delay + in;
};
~e.set(\wet5, 1.0);
)

(
~o[0] = {
	(~n.ar * LFNoise1.kr(0.05).range(0.0, 0.75))
	+ (~e.ar * LFNoise1.kr(0.0498765).range(0.0, 0.25)) * 1
};

~o[1] = \filter -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 31, LFNoise1.kr(0.005).range(5.0, 31.0));
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.0, \feedbackMax1.kr(0.5, 1)));
	delay + in;
};

~o[2] = \filter -> {|in|
	var local = LocalIn.ar(2) + in;
	var delay = DelayN.ar(local, 15.777, LFNoise1.kr(LFNoise2.kr(0.005).range(0.01, 0.1)).range(1/20, 15.77));
	LocalOut.ar(delay * LFNoise1.kr(0.05).range(0.0, \feedbackMax2.kr(0.5, 1)));
	delay + in;
};

~o[3] = \filter -> {|in|
	JPverb.ar(in.sum, 8.0, 0.25, 20.0, high: 0.8, lowcut: 80, highcut: 7500)
};
~o.set(\wet3, 0.125/1.5);
~o.xset(\wet1, 0.275, \wet2, 0.75);
)

~impulserate = {LFNoise2.kr(LFNoise2.kr(0.0025).range(0.005, 0.125)).exprange(0.25, 35.0)}
