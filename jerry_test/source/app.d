import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;

import step0, step1, step2, step3, step4, step6, step7, step8, step9;

void main()
{ 
	RunStep0();
	RunStep1();
	RunStep2();
	RunStep3();
	RunStep4();
	RunStep6();
	RunStep7();
	RunStep8();
	RunStep9();
	 
	writeln("\n\n\nPress ENTER to exit.");
	//readln();
}
