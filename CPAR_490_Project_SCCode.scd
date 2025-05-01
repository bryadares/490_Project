//Hello User!

//This code is not one-click operational, I do hope you enjoyed the quality of the report though

//Stick with me here

//First, evaluate the functions below, this can be done by clicking to the right of the open parenthesis below and entering, ctyl+enter (on windows)

//Then- Meet me further down. There will be comments that say, STOP HERE. Happy scrolling!! (you're looking for somewhere around line 1082 <3)

(
//0 - key pattern
//1 - strengths
//2 - calculated strength
//3 - subsets: strongest,weakest,on1,notOn1,synCon(max)
//4 - prim and secondary layrs
//5 - melody notes
//6 - 3 layers as dur data
//7 - symCon

Event.addEventType(
	\newGrid, {
		~in = [[0,0,0,0,0,0,0,0,0,0,0,0],[],0, [nil,nil,nil,nil,nil,nil],[nil,nil,nil],[nil,nil],[nil,nil,nil],[nil]];
	}
);

//resets onsets everytime
Event.addEventType(
	\mEven1, {
		var copy = ~in.copy;
		var out = Array.fill(copy[0].size, {arg i; 0});
		var unit = copy[0].size/~n;
		var id = nil;


		~n do: {|i|
			id = (unit * i).round;
			out[id] = 1;
		};

		~in[0] = out;
	}
);

Event.addEventType(
	\from3t4, {
		var out0 = Array.fill(16, {arg i; "Y"});
		var out1 = Array.fill(16, {arg i; "Y"});
		var out2 = Array.fill(16, {arg i; "Y"});
		var copy = ~in.copy;
		var ins = 0;
		var flags = 0;

		//makes sure is in triple
		if(copy[0].size/3 !=  (copy[0].size/3).round)
		{
			"not divisible by 3".postln;
		}{
			//loops on current length
			copy[0].size do: {|i|
				("i:" + i).postln;
				//determines if this is the insert index
				if(i == 0){ins = 0;}{
					ins = i/3;
				};

				("ins:" + ins).postln;
				//checks for insert index
				if(ins == ins.round){
					"ins!".postln;
					//insert index!

					//before insert
					out0[i+flags] = copy[0][i];
					out1[i+flags] = copy[4][0][i];
					out2[i+flags] = copy[4][1][i];

					//insert
					flags = flags + 1;

					out0[i + flags] = 0;
					out1[i + flags] = 0;
					out2[i + flags] = 0;

				}{
					"not ins".postln;
					//not insert index :(
					out0[i+flags] = copy[0][i];
					out1[i+flags] = copy[4][0][i];
					out2[i+flags] = copy[4][1][i];
				};

			};
		};

		~in[0] = out0;
		~in[4][0] = out1;
		~in[4][1] = out2;

});

//labels how "strong" a pulse is within the meter

Event.addEventType(
	\labStr, {
		var inBuf = ~in[1];
		var out = Array.fill(~in[0].size, {arg i; nil});
		var l = 0;
		var factor = 0;
		var half = out.size/2;
		var jLoop = 0;

		//loop up to square root
		(out.size) do: {|i|

			factor = i;

			//"new".postln;
			//(out.size.mod(factor) == 0).postln;
			//("i:" + i).postln;

			//subdivision index, found by moving from 1 -> 1/2 max, looking for factors, factor is the factor
			if(out.size.mod(factor) == 0){

				//loop, when factor is a factor, divides the grid into size/factor pieces, jLoop
				//Ex: factor = 4, grid.size is 12, so chunks size 3, marking the start with the strength
				//12/1k = 12j; 12/2k = 6j

				if(factor == 0){jLoop = 0}{
					jLoop = out.size/factor;
				};
				//("jLoop:" + (jLoop)).postln;

				//loop, handles each of the jLoop chunks of size factor, assigning a strength
				//value at the start, and iterating past the remaining indices of the chunk
				//l is the strength value, iterated each time a factor is found, increasing strength as factor
				//size increases
				l = l + 1;
				jLoop do: {|j|
					out[(j * factor)] = l;
				};


			};

		};


		//("out:" + out).postln;
		~in[1] = out;
	};
);



//rotates an input grid by shift indeces (in[0] will end up at in[shift])
Event.addEventType(
	\rotate, {
		var copy = ~in.copy;
		var out = Array.fill(copy[0].size, {arg i; nil});
		var out1 = Array.fill(copy[4][0].size, {arg i; nil});
		var out2 = Array.fill(copy[4][1].size, {arg i; nil});
		var shift = ~shift;

		out.size do: {|i|
			out[(i + shift).wrap(0,(out.size-1))] = copy[0][i];
			out1[(i + shift).wrap(0,(out1.size-1))] = copy[4][0][i];
			out2[(i + shift).wrap(0,(out2.size-1))] = copy[4][1][i];
		};

		//"check".postln;
		~in[0] = out;
		~in[4][0] = out1;
		~in[4][1] = out2;
		//"check".postln;
		(\type: \evalStr, in: ~in).play;
		//"check".postln;
		(\type: \ons2dur, in: ~in).play;
	};
);


//evalutes how "strong" onsets in given rhythm are, returning an integer
Event.addEventType(
	\evalStr, {
		var out = 0;

		//"evalStr".postln;
		if(~in[0].size != ~in[1].size){
			"evalStr: in[0] != in[1]".postln;
		}
		{
			//loop, uses onsets to retrive strength values, and sums them in out
			~in[0].size do: {|i|
				//"check".postln;
				if(~in[0][i] == 1)
				{
					out = out + ~in[1][i];
				};

			};
		};

		//out.postln;
		~in[2] = out;
	};
);

//outputs a list of possible shifts that result in onesets in the "strongest" way
Event.addEventType(
	\strongest, {
		var copy = ~in.copy;
		var out = [];
		var curMax = 0;

		//"strongest".postln;
		//copy.postln;

		if(copy[0].size != copy[1].size){
			"strongest: in[0] != in[1]".postln;
		}
		{
			//"".postln;
			//"a".postln;
			//loop, iterates through every possible starting index
			copy[0].size do: {|i|
				//"".postln;
				//"b".postln;

				copy[2] = 0;
				//"?".postln;
				(\type: \rotate, in: copy, shift: 1).play;
				//"?".postln;
				(\type: \evalStr, in: copy).play;
				//"?".postln;
				//"check0".postln;
				//("[0]:" + copy[0]).postln;
				//("i:" + i + " str:" + copy[2]).postln;

				if(curMax < copy[2])
				{
					//"".postln;
					//"c".postln;
					curMax = copy[2];
					out = [].add(i+1);
				}
				{
					//"".postln;
					//"d".postln;
					if(curMax == copy[2]){
						out = out.add((i+1).wrap(0,(copy[0].size-1)));
					}{};
				};
				//("curMax:" + curMax).postln;
				//("out:" + out).postln;
			};
		};


		//places in the subset 2d array at code for this type; 0
		~in[3][0] = out;
	};
);


//outputs a list of possible shifts that result in onesets in the "strongest" way
Event.addEventType(
	\weakest, {
		var copy = ~in.copy;
		var out = [];
		var curMin = inf;

		//"weakest".postln;
		//copy.postln;

		if(copy[0].size != copy[1].size){
			"weakest: in[0] != in[1]".postln;
		}
		{
			//"".postln;
			//"a".postln;
			//loop, iterates through every possible starting index
			copy[0].size do: {|i|
				//"".postln;
				//"b".postln;

				copy[2] = 0;
				(\type: \rotate, in: copy, shift: 1).play;
				(\type: \evalStr, in: copy).play;
				//("[0]:" + copy[0]).postln;
				//("i:" + i + " str:" + copy[2]).postln;

				if(curMin > copy[2])
				{
					//"".postln;
					//"c".postln;
					curMin = copy[2];
					out = [].add(i+1);
				}
				{
					//"".postln;
					//"d".postln;
					if(curMin == copy[2]){
						out = out.add((i+1).wrap(0,11));
					}{};
				};
				//("curMin:" + curMin).postln;
				//("out:" + out).postln;
			};
		};

		//places in the subset 2d array at code for this type; 1
		~in[3][1] = out;
	};
);

//Gives a list of shift values that result in a pattern with an onset on beat 1
Event.addEventType(
	\shiftsOn1, {
		var copy = ~in.copy;
		var ct = copy[0].sum;
		var rotBuf = Array.fill(copy[0].size, {arg i; 0});
		var idBuf = nil;
		//holds all onset ids
		var id = Array.fill(ct, {arg i; 0});

		//puts onset ids in id
		id.size do: {|i|
			rotBuf = copy[0].copy;

			i do: {
				//removes onssets based on progress
				idBuf = rotBuf.detectIndex({arg item, i; item == 1;});
				rotBuf[idBuf] = 0;
			};
			//finds next ons in pattern
			idBuf = rotBuf.detectIndex({arg item, i; item == 1;});

			//puts in id
			id[i] = idBuf;

		};

		//id.postln;
		~in[3][2] = id;
		~in[3][3] = Array.fill(copy[0].size, {arg i; i}).removeAll(id);
	};
);

//gives intersection of specified sets: 0 = strongest, 1 = weakest, 2 = starts on 1, 3 = does not start on 1, 4 = max synCon, 5 = output indices;
//sets input should be an array of indexes, Ex: [0,2]
Event.addEventType(
	\interSet, {
		var copy = ~in.copy;
		var sets = ~sets;
		var out = Array.fill(~in[0].size, {arg i; i});

		sets.size do: {|i|
			switch(sets[i],
				0, {out = out.sect(copy[3][0])},
				1, {out = out.sect(copy[3][1])},
				2, {out = out.sect(copy[3][2])},
				3, {out = out.sect(copy[3][3])},
				4, {out = out.sect(copy[3][4])}
			);

		};

		//if no intersection is found, currently just does not transform
		if(out.isEmpty){
			out = [0];
			"No Intersection found, defaulting to no shifts".postln;
		};

		~in[3][5] = out;

	};
);

//makes an onset pattern on the beat
Event.addEventType(
	\onB, {
		var copy = ~in.copy;
		var n = 8;

		//clears copy so meven1 wworks
		copy[0] = Array.fill(copy[0].size, {arg i; 0});
		if(copy[0].size == 16){n = 8;}{n = 4;};

		(\type: \mEven1, in: copy, n: n).play;


		~in[4][0] = copy[0];

	};
);

//makes an onset pattern on the subdivision (every other pulse)
Event.addEventType(
	\onSubd, {
		var copy = ~in.copy;
		var n = 0;

		//clears copy so meven1 wworks
		copy[0] = Array.fill(copy[0].size, {arg i; 0});

		n = copy[0].size/2;
		if(copy[0].size == 16){n = 16;};

		(\type: \mEven1, in: copy, n: n).play;

		//copy.postln;
		~in[4][1] = copy[0];

	};
);

//makes an onset pattern on every other beat (half time)
Event.addEventType(
	\onHalfB, {
		var copy = ~in.copy;
		var n = 8;

		//clears copy so meven1 wworks
		copy[0] = Array.fill(copy[0].size, {arg i; 0});
		if(copy[0].size == 16){n = 4;}{n = 2;};

		(\type: \mEven1, in: copy, n: n).play;


		~in[4][0] = copy[0];

	};
);

//makes an onset pattern on a 3:2 polyrhythm
Event.addEventType(
	\on32, {
		var copy = ~in.copy;
		var n = 0;
		var buf3 = nil;
		var buf2 = nil;

		//clears copy so meven1 wworks
		copy[0] = Array.fill(copy[0].size, {arg i; 0});

		//3
		n = 6;
		(\type: \mEven1, in: copy, n: n).play;
		//rotates to get a tresillo
		if(copy[0].size == 16){copy[0] = copy[0].rotate(3)};
		buf3 = copy[0].copy;

		//2
		n = 4;
		(\type: \mEven1, in: copy, n: n).play;
		buf2 = copy[0].copy;

		buf2.size do: {|i|
			if((buf3[i] == 1).or(buf2[i] == 1))
			{copy[0][i] = 1;}
			{copy[0][i] = 0;};
		};
		//"32".postln;
		//copy[0].postln;
		~in[4][1] = copy[0];

	};
);


//melodic layer
//goal is to make a melodic layer to compliment the key pattern through a hocketed structure
//I'll need, the onsets i want sound on
//chords to pull notes from
//rules that goven notes
//chords:
//we're working w two measure cells
//perhaps 3 chords per cell, tonic, sub/dom,sub/dom
//each can be each 1/2, 1 measure length, adding up to 2

Event.addEventType (
	\mel3, {
		var out = [nil,nil,nil];
		var outDur = [1,1,1];
		var scale = if(rrand(0,1)==1){Scale.major.degrees.asArray;}{Scale.minor.degrees.asArray};
		var key = rrand(60,71);
		//chord type, 0 tonic, 1 subdom, 2 dom
		var ctype = nil;
		var tonic = [0,2,4];
		//all possible notes for 4 and 6 chord
		var subD = [0,2,3,5];
		//all possible notes for 5 and 7 chord
		var dom = [1,3,4,6];
		var rand = rrand(0,1);
		var buff = Array.new(scale.size);

		//puts scale in midi around middle C
		key.postln;
		//fix
		scale = scale.do({arg item, i; buff[i-1] = (item + key)});
		scale = buff;
		scale.postln;

		//gets a tonic chord note
		out[0] = scale[tonic[rrand(0,2)]];
		ctype = 0;
		if(rand == 1){ctype = 1;}{ctype = 2;};

		//gets second note
		rand = rrand(0,1);
		if(ctype == 1){
			out[1] = scale[subD[rrand(0,3)]];
			//could go dom or subdom
			if(rand==1){ctype = 1;}{ctype = 2;};
		}{
			out[1] = scale[dom[rrand(0,3)]];
			//stays dom, ctype = 2
		};

		//gets third note
		rand = rrand(0,1);
		if(ctype == 1){
			out[2] = scale[subD[rrand(0,3)]];
		}{
			out[2] = scale[dom[rrand(0,3)]];
		};


		~in[5][0] = out;

		//generates note lengths
		outDur[rrand(0,2)] = 2;
		~in[5][1] = outDur;

	};
);

//design a syncopation ordering mechanism
//maybe a no symmetry mech

//converts onset data to duration data
Event.addEventType(
	\ons2dur, {
		var copy = ~in.copy;
		var out0 = Array.fill(copy[0].size, {arg i; Rest});
		var out1 = Array.fill(copy[4][0].size, {arg i; Rest});
		var out2 = Array.fill(copy[4][1].size, {arg i; Rest});
		var len = 1;

		//determines the length of each cell considering meter
		//if{triple}{duple}
		if(out0.size == 12){len = 0.33}{len = 0.5};

		//converts 1s to length in time, 0s to rests
		out0.size do: {|i|
			//"ons2dur1".postln;
			//keypattern
			if(copy[0][i] == 1)
			{
				out0[i] = len;
			}{
				out0[i] = Rest(len);
			};

			//primary layer
			if(copy[4][0][i] == 1)
			{
				out1[i] = len;
			}{
				out1[i] = Rest(len);
			};

			//secondary layer
			if(copy[4][1][i] == 1)
			{
				out2[i] = len;
			}{
				out2[i] = Rest(len);
			};
		};

		//"ons2dur2".postln;
		~in[6][0] = out0;
		~in[6][1] = out1;
		~in[6][2] = out2;
	};
);

//returns indices that have positive sync contours (starts in 1 needs to be found)
//need to think if this is provable, approach is only functional
//stores possible shifts for max synCon in [7][1]
Event.addEventType(
	\synCon, {
		var copy = ~in.copy;
		var cons = Array.fill(copy[3][2].size, {arg i; 0});
		var consBuf = nil;
		var rotBuf = Array.fill(copy[0].size, {arg i; 0});
		//number of ons
		var ct = (copy[0].sum);
		//-2 bc doesnt use first or last onset for calc, holds strengths of non downb onsets
		var strBuf = Array.fill(ct - 1, {arg i; 0});
		var idBuf = nil;
		//holds all onset ids
		var id = Array.fill(ct, {arg i; 0});
		var holder = nil;
		//holds values of shifts to achieve max synCon
		var maxShi = [];
		var maxCon = nil;


		//puts onset ids in id
		id.size do: {|i|
			rotBuf = copy[0].copy;

			i do: {
				//removes onssets based on progress
				idBuf = rotBuf.detectIndex({arg item, i; item == 1;});
				rotBuf[idBuf] = 0;
			};
			//finds next ons in pattern
			idBuf = rotBuf.detectIndex({arg item, i; item == 1;});

			//puts in id
			id[i] = idBuf;

		};

		//removes downbeat id
		id.remove(0);
		//id.postln;

		//goes through each start on 1
		copy[3][2].size do: {|i|
			//" ".postln;
			//"i".postln;

			//gets current onset downbeat version based on shifts on 1
			rotBuf = copy[0].copy;
			rotBuf = rotBuf.rotate(copy[3][2][i].neg);
			//rotBuf.postln;
			//updates id so onsets ids match
			holder = id.copy;
			holder.size do: {|j|
				holder[j] = (holder[j] + copy[3][2][i]).wrap(0,(copy[0].size-1));
			};
			//("h:"+holder).postln;

			strBuf.size do: {|j|
				//"j0".postln;
				//for each non-down beat onsets, gets strength
				strBuf[j] = copy[1][holder[j]];
			};
			//strBuf.postln;

			//consBuf holds the slopes in this pattern (size - 1)
			consBuf = Array.fill(strBuf.size-1, {arg i; 0});
			//consBuf.postln;

			consBuf.size do: {|j|
				//"j1".postln;
				//j.postln;
				//(strBuf[(j+1)] - strBuf[j]).postln;
				//(holder[(j+1)] - holder[j]).postln;
				//uses strengths so find slopes for each index
				consBuf[j] = (
					//diff in strength
					(strBuf[(j+1)] - strBuf[j])
					///
					//diff in ids
					//(holder[(j+1)] - holder[j])
				);
				//consBuf.postln;
			};

			//gets slope avg for this shift
			cons[i] = consBuf.sum/consBuf.size;
			//cons.postln;
		};

		~in[7][0] = cons;

		maxCon = cons.maxItem;
		holder = cons.copy;

		//gets shifts for max synCon
		holder.occurrencesOf(maxCon) do: {|i|

			//gets id of max val
			idBuf = holder.detectIndex({ arg item, i; item == maxCon;});

			//puts in array
			maxShi = maxShi.add(idBuf);

			//remomves that val so more can be found
			holder = -inf;


		};

		//edge case where no max (idk)
		if(maxShi.isEmpty){maxShi = [];};

		~in[3][4] = maxShi;
	};
);

//holder function
//duple = 0 - triple, 1 - duple (no insertion), 2 - duple (insertion)
//onsets
//lay_32 = For secondary layer: 0 - every other subdivision, 1 - 3:2 polyrhythm
//shifts = [PI_D, PI_Ss, PI_Ss_Id, G_D, G_Ss, G_Ss_Id] (direct shifts done after subset shifts)
//
Event.addEventType(
	\mRhy, {
		var out = nil;
		var array = [];

		//"mRhy".postln;
		//initializes grid (in 12/8)
		out = (type: \newGrid, in: out).play.at('in');
		//out.postln;
		//"a".postln;
		if(~poly==1){
			(\type: \on32, in: out).play;
		}{
			(\type: \onSubd, in: out).play;
		};
		if(~halfTime==1){
			(\type: \onHalfB, in: out).play;
		}{
			(\type: \onB, in: out).play;
		};
		//
		//# maximally even onsets
		(\type: \mEven1, in: out, n: ~onsets).play;
		//
		//strength intialization
		(\type: \labStr, in: out).play;
		(\type: \evalStr, in: out).play;

		//"b".postln;
		//shifts pre insertion duple
		if((~shifts[0] != nil).or(~shifts[1] != nil))
		{
			if((~shifts[1] != nil).and(~shifts[2] != nil)){
				//Subset Shift case
				//handles subset based shift, "XX"
				//finds subsets
				(\type: \strongest, in: out).play;
				(\type: \weakest, in: out).play;
				(\type: \shiftsOn1, in: out).play;
				(type: \synCon, in: out).play;

				//retrieves wanted intersection
				(\type: \interSet, in: out, sets: ~shifts[1]).play;
				//out[3][5].postln;
				(\type: \rotate, in: out, shift: out[3][5][~shifts[2]]).play;

				if(~poly==1){
					(\type: \on32, in: out).play;
				}{
					(\type: \onSubd, in: out).play;
				};
				if(~halfTime==1){
					(\type: \onHalfB, in: out).play;
				}{
					(\type: \onB, in: out).play;
				};
				//"b1".postln;
				//out[0].postln;
			};

			if(~shifts[0] != nil){
				//handles direct shift
				(\type: \rotate, in: out, shift: ~shifts[0]).play;

				if(~poly==1){
					(\type: \on32, in: out).play;
				}{
					(\type: \onSubd, in: out).play;
				};
				if(~halfTime==1){
					(\type: \onHalfB, in: out).play;
				}{
					(\type: \onB, in: out).play;
				};
			};

			//updates strength
			(\type: \evalStr, in: out).play;
		};

		//"c".postln;
		////handles duples cases
		if(~duple!=0){

			if(~duple==2){
				//handles insertion case
				(\type: \from3t4, in: out).play;
				//"c0".postln;
			}{

				//handles NON-insertion case
				//"c3".postln;
				(\type: \from3t4, in: out).play;
				(\type: \mEven1, in: out, n: ~onsets).play;
			};

			//updates other layers
			if(~poly==1){
				(\type: \on32, in: out).play;
			}{
				(\type: \onSubd, in: out).play;
			};
			if(~halfTime==1){
				(\type: \onHalfB, in: out).play;
			}{
				(\type: \onB, in: out).play;
			};

			//updates/asigns strength values
			(\type: \labStr, in: out).play;
			(\type: \evalStr, in: out).play;
		};


		//"d".postln;
		//shifts post insertion duple/normal triple
		if((~shifts[3] != nil).or(~shifts[4] != nil))
		{
			if((~shifts[4] != nil).and(~shifts[5] != nil)){
				//Subset Shift case
				//handles subset based shift, "XX"
				//finds subsets
				(\type: \strongest, in: out).play;
				(\type: \weakest, in: out).play;
				(\type: \shiftsOn1, in: out).play;
				(type: \synCon, in: out).play;

				//retrieves wanted intersection
				(\type: \interSet, in: out, sets: ~shifts[4]).play;
				//out[3][5].postln;
				(\type: \rotate, in: out, shift: out[3][5][~shifts[5]]).play;

				if(~poly==1){
					(\type: \on32, in: out).play;
				}{
					(\type: \onSubd, in: out).play;
				};
				if(~halfTime==1){
					(\type: \onHalfB, in: out).play;
				}{
					(\type: \onB, in: out).play;
				};
			};

			if(~shifts[3] != nil){
				//handles direct shift
				(\type: \rotate, in: out, shift: ~shifts[3]).play;

				if(~poly==1){
					(\type: \on32, in: out).play;
				}{
					(\type: \onSubd, in: out).play;
				};
				if(~halfTime==1){
					(\type: \onHalfB, in: out).play;
				}{
					(\type: \onB, in: out).play;
				};
			};

			//updates strength
			(\type: \evalStr, in: out).play;
		};

		//"e".postln;
		//converts to durations
		(\type: \ons2dur, in: out).play;

		//tempo
		//"f".postln;

		~in[0] = out;
	};
);

//takes an an array of rhythms and creates sequences for pset/ppar
//potentially can add halving rhythms
Event.addEventType(
	\arr, {
		var copy = ~in.copy;
		var out0 = [];
		var out1 = [];
		var out2 = [];
		var out3 = [];
		var out4 = [];
		var out5 = [];
		var out = [[nil,nil,nil],[nil,nil,nil]];

		//for each rhythm, gathers timing data
		copy.size do: {|i|
			//"i".postln;
			//i.postln;
			//binary vals
			out0 = out0 ++ copy[i][0];
			out1 = out1 ++ copy[i][4][0];
			out2 = out2 ++ copy[i][4][1];

			//dur vals
			out3 = out3 ++ copy[i][6][0];
			out4 = out4 ++ copy[i][6][1];
			out5 = out5 ++ copy[i][6][2];
		};

		//places val in output
		out = [[out0,out1,out2],[out3,out4,out5]];

		~out[0] = out;
	};
);

//can later be expanded into a holder function
~arrRand = {|randomize,duple,onsets,halfTime,poly,shifts,repeats,recall|

	var holder = 0;
	var tracker = [];
	var meter = 0;
	var buf = nil;
	var out = nil;


	//if no recall is input, makes it empty, else assigns vals
	//recall is not implemented
	recall = [];
	if((recall.isEmpty).not)
	{
		tracker = recall;
	}{
		//handles if recall is empty, and thus gives random vals

		if(randomize == 1)
		{

			//meter
			holder = rrand(0,99);
			tracker = tracker ++ holder;

			if(holder < 60)
			{
				//duple
				holder = rrand(0,99);
				tracker = tracker ++ holder;
				meter = 16;

				if(holder < 66){duple = 1;}{duple = 2;};
			}{
				//triple
				duple = 0;
				meter = 12;
			};

			//# of onsets
			holder = rrand(0,1);
			tracker = tracker ++ holder;
			if(holder == 1)
			{
				//sets to an interesting case
				holder = rrand(0,5);
				tracker = tracker ++ holder;
				onsets = [3,5,5,5,7,7].at(holder);
			}
			{
				//more variety, might not be so syncopated though
				meter = meter/2;
				holder = rrand(0,(meter/2)).asInteger;
				tracker = tracker ++ holder;

				//gives range of 2->2 + half of meter
				onsets = (2 + holder).asInteger;

				meter = meter * 2;
			};

			//halfTime
			holder = rrand(0,1);
			tracker = tracker ++ holder;
			halfTime = holder.copy.asInteger;

			//poly
			holder = rrand(0,1);
			tracker = tracker ++ holder;
			poly = holder.copy.asInteger;

			//shifts, oh boy
			holder = rrand(0,99);
			tracker = tracker ++ holder;

			if(holder < 60)
			{
				holder = rrand(0,99);
				tracker = tracker ++ holder;

				//shifts


				if(duple == 2){
					//insertion
					//tracker.size - 2 is the index for below
					holder = rrand(0,9);
					buf = holder.copy;
					tracker = tracker ++ holder;
					//
					holder = rrand(0,3);
					tracker = tracker ++ holder;
					shifts = [
						[nil,nil,nil,nil,[0,2,4],0],
						[nil,nil,nil,nil,[0,2,4],0],
						[nil,nil,nil,nil,[1,3],0],
						[nil,nil,nil,buf,nil,nil],
					].at(holder);
				}{
					//tracker.size - 2 is the index for below
					holder = rrand(0,9);
					tracker = tracker ++ holder;
					//
					holder = rrand(0,3);
					tracker = tracker ++ holder;

					//triple + pre-insertion
					shifts = [
						[nil,[0,2,4],0,nil,nil,nil],
						[nil,[0,2,4],0,nil,nil,nil],
						[nil,[1,3],0,nil,nil,nil],
						//direct shift
						[buf,nil,nil,nil,nil,nil],
					].at(holder);
				};

			}
			{
				shifts = [nil,nil,nil,nil,nil,nil];
			};

			holder = rrand(0,1);
			tracker = tracker ++ holder;

			repeats = (2 * (holder + 1));
		};
	};

	//tracker.postln;
	out = [randomize,duple,onsets,halfTime,poly,shifts,repeats];
};

~insts = [\hm, \m, \mm, \s0, \s1, \sL];
b = ~insts.collect{|val| Buffer.read(s,(val++".wav").resolveRelative)};

// a very simple sample-playing instrument.
SynthDef(\playBuf,

	{ |buffer, rate = 1, start = 0, dur = 0.25, amp = 1, pan = 0|
		var sig = PlayBuf.ar(1,buffer, rate, startPos: start, loop: 0);
		var env = EnvGen.kr(Env.linen(0.01,0.32,0.01,level:amp),doneAction:2);
		Out.ar(0, Pan2.ar(sig, pan, env));
	}
).add;
);

t = TempoClock.default; // the default clock
t.tempo = 120/60; // 120 beats per minute
)


//STOP HERE//

//this downhere is your playground

//key of rhytmic object
//0 - key pattern
//1 - strengths
//2 - calculated strength
//3 - subsets: strongest,weakest,on1,notOn1,synCon(max), int
//4 - prim and secondary layers
//5 - melody notes
//6 - 3 layers as dur data
//7 - symCon

//build generator function - USE THESE AS INPUTS WHERE IT SAYS MANUAL INPUT
//duple = 0 - triple, 1 - duple (no insertion), 2 - duple (insertion)
//onsets
//lay_32 = For secondary layer: 0 - every other subdivision, 1 - 3:2 polyrhythm
//shifts = [PI_D, PI_Ss, PI_Ss_Id, G_D, G_Ss, G_Ss_Id] (direct shifts done after subset shifts)
//shifts(cont'd) for subsets: 0 - strongest, 1 - weakest, 2 - start on 1, 3 - does not start on 1
//shifts(cont'd) for subsets: 4 - max syncopation contour

(
//MANUAL INPUT
~duple = 1;
~onsets = 5;
~halfTime = 1;
~poly = 1;
~shifts = [nil,nil,nil,nil,[4],0];
~repeats = 1;
//name
~rhy1 =

//dont mess with this part
(type: \mRhy, in: [nil], duple: ~duple, onsets: ~onsets, halfTime: ~halfTime, poly: ~poly,
shifts: ~shifts).play.at('in').at(0);

//if you want to sequence rhythms, the last field in the manual inputs, is a name. it must be of the format ~__
//don't mess with the  =  sign or anything else, just the characters where rhy1 are by default
//below, if you want to include an already generated rhythm in your composition, just plop its name into the array.
//EX: [~rhy1,~rhy2]
//NOTE: running manual input overwrites whatever object was stored to a name, so you need to name the rhythms you want to keep with unique names
~arrangement = [~rhy1];

//When you're ready to generate your rhythm, click here and do ctrl+enter again
)

(
//randomize here
//IF YOU WANT RANDOM OUTPUT, simple
~hold = ~arrRand.value(1,~duple,~onsets,~halfTime,~poly,~shifts,~repeats);
~randomize;
~duple = ~hold[1];
~onsets = ~hold[2];
~halfTime = ~hold[3];
~poly = ~hold[4];
~shifts = ~hold[5];
~repeats =~hold[6];
//name
~rhy0 =

(type: \mRhy, in: [nil], duple: ~duple, onsets: ~onsets, halfTime: ~halfTime, poly: ~poly,
shifts: ~shifts).play.at('in').at(0);

//NOTE: you can combine compositions with random and non-random rhythms, you just need unique names and to put'em in the array below
~arrangement = [~rhy0];
//When you're ready to generate your rhythm, click here and do ctrl+enter again
)

(
//FOR SOUND: click into here and do ctrl+enter one last time, and your composition will sing!!!
~comp = (type: \arr, in: ~arrangement, out: [nil]).play.at('out').at(0);
//(type: \var, in: ~comp, vr: 0.0).play;
// ~comp[0][2].postln;
~rate0 = 2;
~amp0 = 1;
~layK = Pbind(\instrument, \playBuf, \dur, Pseq(~comp[1][0], 1), \buffer, b[2], \amp, Pseq(Array.fill(~comp[1][0].size, {arg i; ~comp[0][0][i] * ~amp0}), inf), \rate, Array.fill(~comp[1][0].size, {arg i; ~rate0}));

~rate1 = 0.5;
~amp1 = 0.25;

~layP = Pbind(\instrument, \playBuf, \dur, Pseq(~comp[1][1], 1), \buffer, b[1], \amp, Pseq(Array.fill(~comp[1][1].size, {arg i; ~comp[0][1][i] * ~amp1}), inf), \rate, Array.fill(~comp[1][1].size, {arg i; ~rate1}));

~rate2 = 1;
~amp2 = 0.5;
~layS = Pbind(\instrument, \playBuf, \dur, Pseq(~comp[1][2], 1), \buffer, b[3], \amp, Pseq(Array.fill(~comp[1][2].size, {arg i; ~comp[0][2][i] * ~amp2}), inf), \rate, Array.fill(~comp[1][2].size, {arg i; ~rate2}));

Ppar([~layK,~layP,~layS], ~repeats).play
)

//Thanks for looking at my program!!
//If there are any issues or questions, you can reach me at bvalladares.work@gmail.com

