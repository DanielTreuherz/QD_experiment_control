(* ::Package:: *)

BeginPackage["ExperimentControl`"]
(*NucDyn44c11.vi, NucDyn45c11.vi, NucDyn46c11.vi
v27 for NucDyn47c11*)


PrintLine=Function[list,Block[{str},str=ToString[list[[1]]];Do[str=str<>"\t"<>ToString[NumberForm[N[list[[Il]]],14,ExponentFunction->(Null&)]],{Il,2,Length[list]}];str]];

(*add textblock to programme string, e.g. block of commands*)
ADDBLOCK[ProgS_,TxtBlk_]:=ProgS<>"\n"<>TxtBlk;

(*Commands*)
NULL[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"0","NULL"}];
(*just to add a line to a program that can be used later for analysis*)
(*LABEL[ProgS_,CommandN_,Param1_,Param2_,Param3_,Param4_,Param5_:0,Param6_:0,Param7_:0,Param8_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"76","LABEL",Param1,Param2,Param3,Param4,Param5,Param6,Param7,Param8}];*)
LABEL[ProgS_,CommandN_,Params__]:=ProgS<>"\n"<>PrintLine[Flatten[{CommandN,"76","LABEL",Params}]];


(*-Princeton CCD-*)
(*Exposure. Winspec or Lightfield*)
EXP::usage="::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n exp: Exposure, ms,\n FrameCnt: Integer,\n SyncMode: 0-async, 1-ext. trig.,\n SPEFile: 0-*.txt, 1-*.spe format,\n Timeout: CCD acquisition minimum timeout in ms";
EXP[ProgS_,CommandN_,
fileN_(*Int. File number*),
exp_(*Real. Exposure, ms*),
FrameCnt_(*Int.*),
SyncMode_(*0-async, 1-external trg*),
SPEFile_(*Bool: Spe or txt format*),
MinTimeout_:60000(*ms*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1","EXP",fileN,exp,FrameCnt,SyncMode,SPEFile,MinTimeout}];
(*Start async exposition*)
EXPASYNC::usage="::Parameters::\n ProgS,\n CommandN,\n exp: Exposition, ms,\n FrameCnt: Integer,\n SyncMode: 0-async, 1-ext. trig.";
EXPASYNC[ProgS_,CommandN_,exp_,FrameCnt_,SyncMode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"36","EXPASYNC",exp,FrameCnt,SyncMode}];
(*Wait for async exp to finish and save file*)
EXPREAD::usage="::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n SPEFile: 0-*.txt, 1-*.spe format";
EXPREAD[ProgS_,CommandN_,fileN_,SPEFile_]:=ProgS<>"\n"<>PrintLine[{CommandN,"37","EXPREAD",fileN,SPEFile}];
FOCUSSTOP::usage="Stops Winspec focusing.";
FOCUSSTOP[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1030","FOCUSSTOP"}];

(*-Andor CCD-*)
(*Exposition*)
ANDREXP::usage="::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n exp: Exposition, ms,\n FrameCnt: Integer,\n SyncMode: 0-async, 1-ext. trig.";
ANDREXP[ProgS_,CommandN_,
fileN_(*Int. File number*),
exp_(*Real. Exposition, ms*),
FrameCnt_(*Int.*),
SyncMode_(*0-async, 1-external trg*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1067","ANDREXP",fileN,exp,FrameCnt,SyncMode}];
ANDRADC::usage="::Parameters::\n ProgS,\n CommandN,\n ADCGainInd: 0-1, 1-1.7,\n ADCHorSpeedInd: 0-100kHz, 2-33kHz";
ANDRADC[ProgS_,CommandN_,ADCGainInd_(*0..1*),ADCHorSpeedInd_(*0..2*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1108","ANDRADC",ADCGainInd,ADCHorSpeedInd}];


(*-CCD remote-*)
(*Exposition*)
EXPREM::usage="Acquire and save spectrum from remote computer (C11 Pylon).\n::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n exp: Exposition, ms,\n FrameCnt: Integer,\n CCDSelect: Select CCD 1 - Double in C11 (local), 11 - Single 0.5mm in C11, 12 - Single 0.7mm in C11, 18 - Double in C18, 180 - Andor 0.5 m";
EXPREM[ProgS_,CommandN_,
fileN_(*Int. File number*),
exp_(*Real. Exposition, ms*),
FrameCnt_(*Int.*),
CCDSelect_(*C11 or C18*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"60","EXPREM",fileN,exp,FrameCnt,CCDSelect}];
LFRSTART::usage="Close and reopen LightField.\n ::Parameters::\n ProgS,\n CommandN";
LFRSTART[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"115","LFRSTART"}];

(*Andor Shamrock spectrometer*)
ANDRWL::usage="::Parameters::\n ProgS,\n CommandN,\n Grating: 1- 300 \!\(\*SuperscriptBox[\(mm\), \(-1\)]\),2- 1200 \!\(\*SuperscriptBox[\(mm\), \(-1\)]\),\n Wl: Wavelength (nm)";
ANDRWL[ProgS_,CommandN_,Grating_(*Int.*),Wl_(*0-async, 1-external trg*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1069","ANDRWL",Grating,Wl}];

(*Timestamp*)
TSTMP[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"38","TSTMP"}];

(*Param meas*)
PMEAS::usage="Acquire optical power measurement::Parameters::\n ProgS,\n CommandN,\n DeviceID: 1-FMGS 1 into Pexc, 2-FMGS 2 into Amplitude, 3-P16-120 into Pexc,\n AvgCount: Number of power measurements, 0 - 1 mmt, 1 by default.";
PMEAS[ProgS_,CommandN_,DeviceID_:3,AvgCount_:1]:=ProgS<>"\n"<>PrintLine[{CommandN,"2","PMEAS",DeviceID,AvgCount}];
POFFS::usage="::Parameters::\n ProgS,\n CommandN,\n DeviceID: 1-FMGS 1 into Pexc, 2-FMGS 2 into Amplitude, 3-P16-120 into Pexc,\n State: Offset setting, >0 - toggles (!) offset correction state. No light should be incident on powermeter when doing offset correction. Power meter reset cancels offset correction. <=0 - switches off ofset correction";
POFFS[ProgS_,CommandN_,DeviceID_:3,State_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"1092","POFFS",DeviceID,State}];
PSTABMEAN::usage="::Parameters::\n ProgS,\n CommandN,\n DeviceID: 1-FMGS 1 into Pexc, 2-FMGS 2 into Amplitude, 3-P16-120 into Pexc,\n MmtTime: Min time to measure power continiously (default 1 s),\n MinItt: Min number of power mmt itterations (default 5), \n RelDevTol: Relative deviation tolerance, used to exclude mmts deviating from mean too much (default 0.1),\n FiltMethod: 0 - Max deviation, works if Pump duty is >50%, 1 - Min power, requires Pump power > Probe power";
PSTABMEAN[ProgS_,CommandN_,DeviceID_:3,MmtTime_:1,MinItt_:5,RelDevTol_:0.1,FiltMethod_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"1066","PSTABMEAN",DeviceID,MmtTime,MinItt,RelDevTol,FiltMethod}];

HEMEAS[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"28","HEMEAS"}];
TEMPMEAS[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"29","TEMPMEAS"}];
WLMEAS::usage="::Parameters::\n ProgS,\n CommandN,\n Units, only for WS7/WSU: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV.";
WLMEAS[ProgS_,CommandN_,Units_(*only for WS7/WSU: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"10","WLMEAS",Units}];
WLMINMAX::usage="Measure wavlength multiple times and save minimum and maximum. Helps to detect unreliable measurements. \n::Parameters::\n ProgS,\n CommandN,\n Units, only for WS7/WSU: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV.";
WLMINMAX[ProgS_,CommandN_,Units_(*only for WS7/WSU: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV*),Repeats_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1064","WLMINMAX",Units,Repeats}];
WLMMREM::usage="Measure WS7/WSU wavlength multiple times and save minimum and maximum (helps to detect unreliable measurements). Works with remote wl meter and supports switch. \n::Parameters::\n ProgS,\n CommandN,\n Units: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV.,\n Repeats: numberof WL measurements,\n Channel: 1 or 2,\n Server: 0 - local computer, 18 - c18andor,\n Retries: number of times to try calling the remote VI";
WLMMREM[ProgS_,CommandN_,Units_(*0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV*),Repeats_,Channel_,Server_,Retries_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1071","WLMMREM",Units,Repeats,Channel,Server,Retries}];
WLAUTOCAL[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1029","WLAUTOCAL"}];
WLEXP::usage="Set exposure type and time for  WS7/WSU. Works with remote wl meter and supports switch. \n::Parameters::\n ProgS,\n CommandN,\n Channel: 1 or 2,\nExpAuto: 0 - manual, 1 - auto exposure, \n Exp1 - if manual set exposure in (ms), \n Exp2 - extra exposure for 2nd intereferometer, \n Server: 0 - local computer, 18 - c18andor,\n Retries: number of times to try calling the remote VI";
WLEXP[ProgS_,CommandN_,Channel_,ExpAuto_,Exp1_,Exp2_,Server_,Retries_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1107","WLEXP",Channel,ExpAuto,Exp1,Exp2,Server,Retries}];


(*Delay*)
DEL::usage="::Parameters::\n ProgS,\n CommandN,\n delay: Delay, ms";
DEL[ProgS_,CommandN_,delay_(*Real. ms*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"3","DEL",delay}];
(*Pause execution*)
PAUSE[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"49","PAUSE"}];

(*BField*)
(*Set persistent field*)
BSET::usage="Set persistent field.\n ::Parameters::\n ProgS,\n CommandN,\n Bfield: Field, T,\n BPrecision: Precision, T";
BSET[ProgS_,CommandN_,
Bfield_(*Real. Tesla*),
BPrecision_(*Real. Tesla*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"4","BSET",Bfield,BPrecision}];
(*Go to field and leave current source on*)
BSETFST::usage="Set field with current supply ON.\n ::Parameters::\n ProgS,\n CommandN,\n Bfield: Field, T,\n BPrecision: Precision, T";
BSETFST[ProgS_,CommandN_,Bfield_,BPrecision_]:=ProgS<>"\n"<>PrintLine[{CommandN,"11","BSETFST",Bfield,BPrecision}];
(*Switch off current and leave magnet in persistent mode*)
BOFF::usage="Set persistent mode switching current supply OFF";
BOFF[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"12","BOFF"}];

(*Plate move*)
PLMOV::usage="Rotate waveplate.\n ::Parameters::\n ProgS,\n CommandN,\n Axis: Integer,\n Angle: Real";
PLMOV[ProgS_,CommandN_,Axis_,Angle_]:=ProgS<>"\n"<>PrintLine[{CommandN,"5","PLMOV",Axis,Angle}];

(*Filter move (linear APT stage)*)
FILMOV::usage="Move filter (linear APT stage).\n ::Parameters::\n ProgS,\n CommandN,\n MotorN: Integer motor number, 1,2,...,\n Pos: Real position";
FILMOV[ProgS_,CommandN_,
MotorN_(*Int*),
Pos_(*Real. mm*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"6","FILMOV ",MotorN,Pos}];

(*Plate move*)
PLMOVAPT::usage="Move plate (rotation APT stage).\n ::Parameters::\n ProgS,\n CommandN,\n MotorN: Integer motor number, 1,2,...,\n Pos: Real position";
PLMOVAPT[ProgS_,CommandN_,
MotorN_(*Int*),
Pos_(*Real. Degree*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1121","PLMOVAPT ",MotorN,Pos}];

FLIPMOV::usage="Move filter flipper (Thorlabs).\n ::Parameters::\n ProgS,\n CommandN,\n FlipperN: Integer flipper number (1),\n Pos: Int position 1 or 2";
FLIPMOV[ProgS_,CommandN_,
FlipperN_(*Int*),
Pos_(*Int 1 or 2*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"144","FLIPMOV ",FlipperN,Pos}];

FILSETPOW::usage="Set filter position to get desired power measured with FMGS.\n ::Parameters::\n ProgS,\n CommandN,\n MotorN: Integer motor number - 1 or 2,\n PmeterID: 1-FMGS 1, 2-FMGS 2, 3-P16-120,\n TargetPow - target power(uW), \n PowRelTolerance - relative precision with which target will be sought, \n dPdParam - slope of the Log10 of power dependence on filter position control Parameter, \n ParamMin - min value for filter control Parmeter, \n ParamMax - maximum value, \n TimeDelay - delay after chaning laser Parameter (ms), \n PMmtTime - Min power measurement time, increase to get reliable power reading in pump probe, \n StepFactor - Scales the step calculated from dPdParam and Power difference. Must be <0.5, optimal 0.3,\n FiltMethod: 0 - Max deviation, works if Pump duty is >50%, 1 - Min power, requires Pump power > Probe power";
FILSETPOW[ProgS_,CommandN_,MotorN_(*Int*),PmeterID_,TargetPow_,PowRelTolerance_,dPdParam_(*slope*),ParamMin_,ParamMax_,TimeDelay_(*ms*),PMmtTime_(*s*),StepFactor_,FiltMethod_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"1063","FILSETPOW",MotorN,PmeterID,TargetPow,PowRelTolerance,dPdParam(*slope*),ParamMin,ParamMax,TimeDelay(*ms*),PMmtTime(*s*),StepFactor,FiltMethod}];

(*Write to log file*)
LOGPAR[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"7","LOGPAR"}];
(*Copy logfile, so it can be accessed w/o disrupting the program*)
COPYLOG[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1036","COPYLOG"}];

(*TTi TGA generators*)
(*Old style, obsolete*)
TGA1244::usage="Obsolete.";
TGA1244[ProgS_,CommandN_,Period_,Ch1del_,Ch1width_,Ch2del_,Ch2width_,Ch3del_,Ch3width_,Ch2TrainQ_,Ch2del2_,Ch2width2_]:=ProgS<>"\n"<>PrintLine[{CommandN,"8","TGA1244",Period,Ch1del,Ch1width,Ch2del,Ch2width,Ch3del,Ch3width,Ch2TrainQ,Ch2del2,Ch2width2}];
(*new*)
TGAINI::usage="TGA initialize";
TGAINI[ProgS_,CommandN_,Device_]:=ProgS<>"\n"<>PrintLine[{CommandN,"59","TGAINI",Device}];
TGAMODE::usage="TGA generator mode.\n ::Parameters::\n ProgS,\n CommandN,\n Device,\n Channel: 0-1(1242) or 0-3 (1244),\n Mode: 0-cont., 1-gated, 2-trig'd,\n TrigSource: 0-int., 1-ext., 2-manual,\n TrigSlope: 0-pos, 1-neg (both slopes in fact for 1242/1244, device bug),\n BurstCnt: Integer, <1000000 for 1242/1244,\n IntPeriod: Internal trigger period";
TGAMODE[ProgS_,CommandN_,Device_,Channel_,Mode_(*0-cont,1-gate,2-trig*),TrigSource_(*0-int,1-ext,2-manual*),TrigSlope_(*0-pos,1-neg (both slopes in fact!!!)*),BurstCnt_,IntPeriod_]:=ProgS<>"\n"<>PrintLine[{CommandN,"21","TGAMODE",Device,Channel,Mode,TrigSource,TrigSlope,BurstCnt,IntPeriod}];
TGAPUL::usage="TGA pulse.\n ::Parameters::\n ProgS,\n CommandN,\n Device,\n Channel: 0-1(1242) or 0-3 (1244),\n Period: sec,\n Delay: sec,\n Width: sec";
TGAPUL[ProgS_,CommandN_,Device_,Channel_,Period_,Delay_,Width_]:=ProgS<>"\n"<>PrintLine[{CommandN,"22","TGAPUL",Device,Channel,Period,Delay,Width}];
TGAPULTRN::usage="TGA pulse train.\n ::Parameters::\n ProgS,\n CommandN,\n Device,\n Channel: 0-1(1242) or 0-3 (1244),\n Period: sec,\n Delay: sec,\n Width: sec,\n PulseCnt: Number of pulses,\n PulseN: Number of this pulse,\n BaseVoltage: Volts,\n Ampl: Amplitude, Volts,\n MakeTrn: Make pulse train";
TGAPULTRN[ProgS_,CommandN_,Device_,Channel_,Period_,Delay_,Width_,PulseCnt_,PulseN_,BaseVoltage_,Ampl_,MakeTrn_]:=ProgS<>"\n"<>PrintLine[{CommandN,"30","TGAPULTRN",Device,Channel,Period,Delay,Width,PulseCnt,PulseN,BaseVoltage,Ampl,MakeTrn}];
TGAWFM::usage="TGA set waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Device,\n Channel: 0-1(1242) or 0-3 (1244),\n OnOff: Output, 0-ON, 1-OFF, 2-No change,\n Func: Function, 0-sine,1-square,2-triang,3-dc,4-posramp,5-negramp,6-cos,7-havsin,8-havcos,9-sinc,10-pulse,11-pulstrn,12-arb,13-seq,\n Ampl(<0 automatically changes output sence),\n Offset,\n QFreqOrPeriod: 0-set freq, 1-set period,\n FreqPeriod: Frequency or period value, for pulse set 40MHz";
TGAWFM[ProgS_,CommandN_,Device_,Channel_,OnOff_(*0-On, 1-Off, 2-No change*),Func_(*0-sine, 10-pulse*),Ampl_,Offset_,QFreqOrPeriod_(*0-Freq,1-Per*),FreqPeriod_(*set 40MHz for pulse!*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"23","TGAWFM",Device,Channel,OnOff,Func,Ampl,Offset,QFreqOrPeriod,FreqPeriod}];
TGAOUT::usage="TGA output.\n ::Parameters::\n ProgS,\n CommandN,\n Device,\n Channel: 0-1(1242) or 0-3 (1244),\n OnOff: Output, 1-ON, 0-OFF,\n OutputSense: 0-Normal, 1-Inv(amplitude is inverted, offset - not!), 2-No change(set up by TGAWFM from amplitude)";
TGAOUT[ProgS_,CommandN_,Device_,Channel_,OnOff_,OutputSense_(*0-Normal, 1-Inv, 2-No change*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"40","TGAOUT",Device,Channel,OnOff,OutputSense}];
TGATRG::usage="TGA manual trigger";
TGATRG[ProgS_,CommandN_,Device_]:=ProgS<>"\n"<>PrintLine[{CommandN,"41","TGATRG",Device}];
TGACLK::usage="TGA configure reference clock 10 MHz. Default is input with automatic sensing of external 10MHz source. \n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Source: 0-in, 1-out, 2-master, 3-slave";
TGACLK[ProgS_,CommandN_,DeviceID_,Source_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1095","TGACLK",DeviceID,Source}];

(*ITC LD controller*)
ILDSET::usage="Set ITC-502 current.\n ::Parameters::\n ProgS,\n CommandN,\n ISet: Current, mA";
ILDSET[ProgS_,CommandN_,ISet_]:=ProgS<>"\n"<>PrintLine[{CommandN,"9","ILDSET",ISet}];
TEMPLDSET::usage="Set ITC-502 temperature.\n ::Parameters::\n ProgS,\n CommandN,\n TempSet: Temp, C,\n Accuracy: absolute deviation between set and actual temp., when waiting is finished,\n DiffAccuracy: difference between consequent values of act. temp., when waiting is finished. This is needed, since there is a bias in absolute temp. reading and set value that prevents convergence.";
TEMPLDSET[ProgS_,CommandN_,TempSet_,Accuracy_,DiffAccuracy_]:=ProgS<>"\n"<>PrintLine[{CommandN,"48","TEMPLDSET",TempSet,Accuracy,DiffAccuracy}];
ILDRAMP::usage="Obsolete.";
ILDRAMP[ProgS_,CommandN_,IStart_,StepCnt_,ILDStep_,TimeStep_]:=ProgS<>"\n"<>PrintLine[{CommandN,"20","ILDRAMP",IStart,StepCnt,ILDStep,TimeStep}];

(*Tektronix AFG generator*)
(*For the future version it is better to suppres AFGSIN, AFGSINSWP, AFGARBWFM, AFGDC, AFGPUL and introduce AFGWFM, AFGSWEEP, AFGTRGCONF*)
AFGSIN::usage="AFG sine.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Freq: Hz,\n Ampl: V,\n Gated: 0-cont,1-cont";
AFGSIN[ProgS_,CommandN_,DeviceID_,Channel_,Freq_,Ampl_,Gated_(*1-gated, 0-continious*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"18","AFGSIN",DeviceID,Channel,Freq,Ampl,Gated}];
AFGSINSWP::usage="AFG sine frequency sweep.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n StartFreq: Hz,\n StopFreq: Hz,\n Ampl: V,\n SweepTime: 1ms - 300s (1ms or 4 digit resolution),\n HoldTime: 0ms - 300s (1ms or 4 digit),\n RetTime: 0ms - 300s (1ms or 4 digit),\n SweepMode: 0-repeated,1-trig,\n TrigSlope: 0-pos,1-neg";
AFGSINSWP[ProgS_,CommandN_,DeviceID_,Channel_,StartFreq_,StopFreq_,Ampl_,SweepTime_,HoldTime_,RetTime_,SweepMode_(*0-rep, 1 -triggered*),TrigSlope_(*0 - positive*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"27","AFGSINSWP",DeviceID,Channel,StartFreq,StopFreq,Ampl,SweepTime,HoldTime,RetTime,SweepMode,TrigSlope}];
AFGARBWFM::usage="AFG arb. waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Freq,\n Ampl,\n Offset,\n WFMSlot: 0-user1,4-EMEM,\n BurstCnt: 0-inf burst,-1-continious,\n TrigSlope: 0-pos,1-neg";
AFGARBWFM[ProgS_,CommandN_,DeviceID_,Channel_,Freq_,Ampl_,Offset_,WFMSlot_,BurstCnt_,TrigSlope_]:=ProgS<>"\n"<>PrintLine[{CommandN,"26","AFGARBWFM",DeviceID,Channel,Freq,Ampl,Offset,WFMSlot(*0-user1,4-EMEM*),BurstCnt(*0 - inf burst, -1 - continious*),TrigSlope}];(*Set emem as main waveform*)
AFGDC::usage="AFG DC.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Ampl,\n Offset";
AFGDC[ProgS_,CommandN_,DeviceID_,Channel_,Ampl_,Offset_]:=ProgS<>"\n"<>PrintLine[{CommandN,"17","AFGDC",DeviceID,Channel,Ampl,Offset}];
(*Proper commands*)
AFGINI::usage="AFG init.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID";
AFGINI[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"13","AFGINI",DeviceID}];
AFGOUT::usage="AFG output ON/OFF.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n State: 0-OFF, 1-ON,\n Impedance: Z, Ohm, no change if Z<0,\n Polarity: 0-normal, 1-inverted (amplitude is inverted, offset - not!)";
AFGOUT[ProgS_,CommandN_,DeviceID_,Channel_,State_,Impedance_,Polarity_(*0-norm,1-inv*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"14","AFGOUT",DeviceID,Channel,State,Impedance,Polarity}];
AFGPUL::usage="AFG pulse. Full setup including burst parameters. Amplitude is for TTL levels.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Period: sec,\n Delay,\n Width,\n BurstCnt: 0-inf. burst, -1 - continious,\n TrigSlope: 0-pos, 1-neg";
AFGPUL[ProgS_,CommandN_,DeviceID_,Channel_,Period_,Delay_,Width_,BurstCnt_(*0 - inf burst, -1 - continious*),TrigSlope_(*0 - positive*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"15","AFGPUL",DeviceID,Channel,Period,Delay,Width,BurstCnt,TrigSlope}];
AFGFM::usage="AFG frequency modulation.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n OnOff,\n Source: 0-int, 1-ext,\n PeakDeviation: Hz,\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-nramp,5-noise,\n ModulFreq: Hz";
AFGFM[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Source_(*0-internal*),PeakDeviation_,ModulWFM_(*0-sine,2-triag,5-noise*),ModulFreq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"19","AFGFM",DeviceID,Channel,OnOff,Source,PeakDeviation,ModulWFM,ModulFreq}];
AFGAM::usage="AFG amplitude modulation.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n OnOff,\n Source: 0-int, 1-ext,\n Depth: 0-120%,\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-nramp,5-noise,6-user1,7-user2,8-user3,9-user4,10-emem,\n ModulFreq: Hz";
AFGAM[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Source_(*0-internal*),Depth_,ModulWFM_(*0-sine,2-triag,6-user1,10-emem*),ModulFreq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"31","AFGAM",DeviceID,Channel,OnOff,Source,Depth,ModulWFM,ModulFreq}];
AFGFSK::usage="AFG FSK modulation.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n OnOff,\n Source: 0-int, 1-ext,\n HopFreq: Hz,\n InternalFSKFreq: Hz";
AFGFSK[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Source_(*0-internal*),HopFreq_,InternalFSKFreq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"39","AFGFSK",DeviceID,Channel,OnOff,Source(*0-interanl*),HopFreq,InternalFSKFreq}];
AFGARBINI::usage="AFG erase EMEM arb. waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n WFMLength: 2-131072";
AFGARBINI[ProgS_,CommandN_,DeviceID_,WFMLength_]:=ProgS<>"\n"<>PrintLine[{CommandN,"24","AFGARBINI",DeviceID,WFMLength}];
AFGARBLINE::usage="AFG add line to arb. waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n X1: 1-WFMLen,\n Y1: 0-16382,\n X2: 1-WFMLen,\n Y2: 0-16382";
AFGARBLINE[ProgS_,CommandN_,DeviceID_,X1_(*1-Len*),Y1_(*0-16382*),X2_(*1-Len*),Y2_(*0-16382*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"25","AFGARBLINE",DeviceID,X1,Y1,X2,Y2}];
AFGARBLOAD::usage="AFG load arb. waveform from file.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n WFMSlot: 0-user1,1-user2,2-user3,3-user4,4-EMEM,\n WFMFile: Column number in the WFM file (starting from 0),\n WFMLen";
AFGARBLOAD[ProgS_,CommandN_,DeviceID_,WFMSlot_(*0-user1,4-EMEM*),WFMFile_(*number of the column*),WFMLen_(*length of the WFM*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"32","AFGARBLOAD",DeviceID,WFMSlot,WFMFile,WFMLen}];
AFGARBCOPY::usage="AFG copy arb. waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n WFMSlotSour: 0-user1,1-user2,2-user3,3-user4,4-EMEM,\n WFMSlotDest";
AFGARBCOPY[ProgS_,CommandN_,DeviceID_,WFMSlotSour_(*0-user1,4-EMEM*),WFMSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"51","AFGARBCOPY",DeviceID,WFMSlotSour(*0-user1,4-EMEM*),WFMSlotDest}];
AFGTRG::usage="AFG Force trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID";
AFGTRG[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"16","AFGTRG",DeviceID}];
AFGABORT::usage="AFG abort trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID";
AFGABORT[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1102","AFGABORT",DeviceID}];
AFGMODIF::usage="AFG Output modifier.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n OnOff: 0-off,>0-on,\n Modifier: 0-noise,1-ext,2-both,\n NoiseLevel: 0-100%";
AFGMODIF[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Modifier_(*0-noise,1-ext,2-both*),NoiseLevel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"33","AFGMODIF",DeviceID,Channel,OnOff,Modifier,NoiseLevel}];
AFGSETPHASE::usage="AFG Set phase.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Phase: phase, radian";
AFGSETPHASE[ProgS_,CommandN_,DeviceID_,Channel_,Phase_]:=ProgS<>"\n"<>PrintLine[{CommandN,"34","AFGSETPHASE",DeviceID,Channel,Phase}];
AFGINITPHASE::usage="AFG Initialize phase.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1";
AFGINITPHASE[ProgS_,CommandN_,DeviceID_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"35","AFGINITPHASE",DeviceID,Channel}];
(*new functions*)
AFGWFM::usage="AFG waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Func: 0-sin,1-squar,2-pulse,3-ramp,4-noise,5-dc,6-sinc,7-gauss,8-lorenz,9-exprise,10-expdec,11-haversin,12-arb1..,15-arb4,16-emem,\n Ampl,\n Offset,\n Freq: Frequency";
AFGWFM[ProgS_,CommandN_,DeviceID_,Channel_,Func_(*0-sine, 2-pulse, 12-ARB1*),Ampl_,Offset_,Freq_(*real*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"53","AFGWFM",DeviceID,Channel,Func,Ampl,Offset,Freq}];
AFGPULCONF::usage="AFG pulse. Only time parameters. Use AFGPUL for full setup.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n Period: sec,\n Delay,\n Width";
AFGPULCONF[ProgS_,CommandN_,DeviceID_,Channel_,Period_,Delay_,Width_]:=ProgS<>"\n"<>PrintLine[{CommandN,"54","AFGPULCONF",DeviceID,Channel,Period,Delay,Width}];
AFGTRGCONF::usage="AFG configure trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n TrigSource: 1-ext,3-int,\n TrigSlope: 0-pos,1-neg,\n TrigPeriod: Internal trig period 1us-500s";
AFGTRGCONF[ProgS_,CommandN_,DeviceID_,TrigSource_,TrigSlope_,TrigPeriod_]:=ProgS<>"\n"<>PrintLine[{CommandN,"55","AFGTRGCONF",DeviceID,TrigSource,TrigSlope,TrigPeriod}];
AFGBURST::usage="AFG configure burst.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n State: 0-off(continious),>0-on,\n Mode: 0-trig,1-gate,\n BurstCount: 1-1000000,0-inf burst,\n BurstDelay: 0-85sec, for triged burst";
AFGBURST[ProgS_,CommandN_,DeviceID_,Channel_,State_,Mode_,BurstCount_,BurstDelay_]:=ProgS<>"\n"<>PrintLine[{CommandN,"56","AFGBURST",DeviceID,Channel,State,Mode,BurstCount,BurstDelay}];
AFGFSWEEP::usage="AFG frequency sweep.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Channel: Channel number 0 or 1,\n State: 0-off,>0-on,\n StartFreq: Hz,\n StopFreq: Hz,\n SweepTime: 1ms - 300s (1ms or 4 digit resolution),\n HoldTime: 0ms - 300s (1ms or 4 digit),\n RetTime: 0ms - 300s (1ms or 4 digit),\n SweepMode: 0-repeated,1-trig";
AFGFSWEEP[ProgS_,CommandN_,DeviceID_,Channel_,State_,StartFreq_,StopFreq_,SweepTime_,HoldTime_,RetTime_,SweepMode_(*0-rep, 1 -triggered*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"57","AFGFSWEEP",DeviceID,Channel,State,StartFreq,StopFreq,SweepTime,HoldTime,RetTime,SweepMode}];
AFGCLK::usage="AFG configure reference clock 10 MHz.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Source: 0-int, 1-ext";
AFGCLK[ProgS_,CommandN_,DeviceID_,Source_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1093","AFGCLK",DeviceID,Source}];


(*Agielent 81150 generator*)
AGIINI::usage="AGI Initialize.\n ::Parameters::\n ProgS,\n CommandN";
AGIINI[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"42","AGIINI"}];
AGIERARB::usage="AGI erase all arb wfms.\n ::Parameters::\n ProgS,\n CommandN";
AGIERARB[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"47","AGIERARB"}];
AGIOUT::usage="AGI Output.\n ::Parameters::\n ProgS,\n CommandN, \n Channel: Channel number 0 or 1,\n State: 0-off,>0-on,\n Impedance: 0.3Ohm-1MOhm, load impedance used to calculate amplitudes,\n SourImpedance: 5hm or 5Ohm, internal impedance,\n Polarity: 0-norm,1-inverted,\n Connector: 0-normal,1-complimentary(inv)";
AGIOUT[ProgS_,CommandN_,Channel_,State_,Impedance_,SourImpedance_,Polarity_(*0-norm,1-inv*),Connector_(*0-norm,1-inverted*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"44","AGIOUT",Channel,State,Impedance,SourImpedance,Polarity,Connector}];
AGIWFM::usage="AGI waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n Func: 0-sin,1-squar,2-pulse,3-ramp,4-noise,5-dc,6-arb1..,9-arb4,10-sinc,11-gauss,12-exprise,13-expfall,14-haversin,15-cardiac,16-negramp,17-volatile,\n Ampl,\n Offset,\n QFreqOrPeriod: Whether the next parameter is frequency(0) or period(1),\n FreqPeriod: Frequency or period, if <=0 than take the value from the register with this number.";
AGIWFM[ProgS_,CommandN_,Channel_,Func_(*0-sine, 2-pulse, 6-ARB1*),Ampl_,Offset_,QFreqOrPeriod_(*0-Freq,1-Per*),FreqPeriod_(*real*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"43","AGIWFM",Channel,Func,Ampl,Offset,QFreqOrPeriod,FreqPeriod}];
AGIAM::usage="AGI config AM.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n OnOff: modulation state, 0-off,>0-on,\n Source: 0-internal,1-channel,2-ext,\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-neg. ramp,5-noise,6-arb1..,9-arb4,10-sinc,11-gauss,12-exprise,13-expfall,14-haversin,15-cardiac,16-negramp,17-volatile,\n Depth: 0-120%,\n ModulFreq: internal freq,\n CarrierSupp: 0-disabled,>0-suppressed carrier,\n ExtRange: +-2.5V or +-5V,\n ExtImpedance: 50 Ohm or 10 kOhm";
AGIAM[ProgS_,CommandN_,Channel_,OnOff_,Source_(*0-internal,1-channel,2-ext*),ModulWFM_(*0-sine,6-ARB1*),Depth_,ModulFreq_,CarrierSupp_,ExtRange_,ExtImpedance_]:=ProgS<>"\n"<>PrintLine[{CommandN,"45","AGIAM",Channel,OnOff,Source,ModulWFM,Depth,ModulFreq,CarrierSupp,ExtRange,ExtImpedance}];
AGIFM::usage="AGI config FM. FM modulation cuases phase noise!\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n OnOff: modulation state, 0-off,>0-on,\n Source: 0-internal,1-channel,2-ext,\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-neg. ramp,5-noise,6-arb1..,9-arb4,10-sinc,11-gauss,12-exprise,13-expfall,14-haversin,15-cardiac,16-negramp,17-volatile,\n Deviation: Deviation Hz.,\n ModulFreq: internal freq,\n ExtRange: +-2.5V or +-5V,\n ExtImpedance: 50 Ohm or 10 kOhm";
AGIFM[ProgS_,CommandN_,Channel_,OnOff_,Source_(*0-internal,1-channel,2-ext*),ModulWFM_(*0-sine,6-ARB1*),Deviation_(*Hz*),ModulFreq_,ExtRange_,ExtImpedance_]:=ProgS<>"\n"<>PrintLine[{CommandN,"58","AGIFM",Channel,OnOff,Source,ModulWFM,Deviation,ModulFreq,ExtRange,ExtImpedance}];
AGIPM::usage="AGI config PM. \n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n OnOff: modulation state, 0-off,>0-on,\n Source: 0-internal,1-channel,2-ext,\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-neg. ramp,5-noise,6-arb1..,9-arb4,10-sinc,11-gauss,12-exprise,13-expfall,14-haversin,15-cardiac,16-negramp,17-volatile,\n Deviation: Deviation Deg.,\n ModulFreq: internal freq,\n ExtRange: +-2.5V or +-5V,\n ExtImpedance: 50 Ohm or 10 kOhm";
AGIPM[ProgS_,CommandN_,Channel_,OnOff_,Source_(*0-internal,1-channel,2-ext*),ModulWFM_(*0-sine,6-ARB1*),Deviation_(*Deg*),ModulFreq_,ExtRange_,ExtImpedance_]:=ProgS<>"\n"<>PrintLine[{CommandN,"64","AGIPM",Channel,OnOff,Source,ModulWFM,Deviation,ModulFreq,ExtRange,ExtImpedance}];
AGISWEEP::usage="AGI freq sweep.\n ::Parameters::\n ProgS,\n CommandN, \n Channel: Channel number 0 or 1,\n OnOff: sweep state, 0-off,>0-on,\n Spacing: 0-linear,1-log,\n SweepTime: 100us-500sec,\n StartF,\n StopF,\n IdleF: 0-start freq,1-stop freq,2-dc";
AGISWEEP[ProgS_,CommandN_,Channel_,OnOff_,Spacing_(*0-linear,1-log*),SweepTime_,StartF_,StopF_,IdleF_(*0-start freq, 1-stop*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"52","AGISWEEP",Channel,OnOff,Spacing(*0-linear,1-log*),SweepTime,StartF,StopF,IdleF}];
AGITRGCONF::usage="AGI configure trigger.\n ::Parameters::\n ProgS,\n CommandN, \n Channel: Channel number 0 or 1,\n Source: 0-contin,1-int,2-ext,3-software,\n TrigMode: 0-trg,1-gate,\n TrigSlope: 0-pos,1-neg,2-either,\n IntFreq,\n TrgLevel: trigger level, Volts,\n TrgImpedance: input impedance, 50 Ohm or 10 kOhm";
AGITRGCONF[ProgS_,CommandN_,Channel_,Source_(*0-contin,1-int,2-ext,3-software*),TrigMode_(*0-trg,1-gate*),TrigSlope_(*0-pos,1-neg,2-either*),IntFreq_,TrgLevel_(*Volts*),TrgImpedance_(*ohms*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"50","AGITRGCONF",Channel,Source,TrigMode,TrigSlope,IntFreq,TrgLevel,TrgImpedance}];
AGIARBLOAD::usage="AGI load arb wfm.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: 0-ARB1..,3-ARB4,4-VOLATILE,\n WFMFile: number of the column in the wfm file, or number of the file,\n WFMLen: 2-2^19,\n UseSplitFiles: 0-waveforms as columns in one file,1-each wfm in a separte file with name NAME_nn, where nn is a wfm number";
AGIARBLOAD[ProgS_,CommandN_,WFMSlot_(*0-ARB1,3-ARB4,4-VOLATILE*),WFMFile_(*number of the column*),WFMLen_(*length of the WFM*),UseSplitFiles_(*1=True*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"46","AGIARBLOAD",WFMSlot,WFMFile,WFMLen,UseSplitFiles}];
AGIPUL::usage="AGI81150 set pulse parameters. Pulse period must be set first using AGIWFM.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n Del: delay (s),\n width (s).";
AGIPUL[ProgS_,CommandN_,Channel_,Del_,Width_]:=ProgS<>"\n"<>PrintLine[{CommandN,"114","AGIPUL",Channel,Del,Width}];


(*C11 commands. Use command number >1001!!!!*)

(*RS SMB100A Microwave Generator*)
SMBWFM::usage="SMB100 waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Freq: MHz,\n Amplitude: dbm,\n ALC State: 0-auto,1-off,2-on";
SMBWFM[ProgS_,CommandN_,Freq_,Amplitude_(*dbm*),ALCState_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1001","SMBWFM",Freq,Amplitude(*dbm*),ALCState}];
SMBOUT::usage="SMB100 output.\n ::Parameters::\n ProgS,\n CommandN,\n OnOff: 0-off,1-on";
SMBOUT[ProgS_,CommandN_,OnOff_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1002","SMBOUT",OnOff}];
SMBPULSE::usage="SMB100 pulse modulation.\n ::Parameters::\n ProgS,\n CommandN,\n Period: us,\n Width: us,\n Delay: us,\n Source: 0-internal,1-external,\n OnOff: 0-off,1-on,\n TrgImpedance: <=50 - 50 ohm, >50 - 10kOhm";
SMBPULSE[ProgS_,CommandN_,Period_(*us*),Width_(*us*),Delay_(*us*),Source_,OnOff_,TrgImpedance_:50]:=ProgS<>"\n"<>PrintLine[{CommandN,"1003","SMBPULSE",Period,Width,Delay,Source,OnOff,TrgImpedance}];
SMBPULSE2::usage="SMB100 pulse modulation 2.\n ::Parameters::\n ProgS,\n CommandN,\n Period: us,\n Width: us,\n Delay: us,\n Source: 0-internal(uses internal pulse generator and TrgSrc settings),1-external(EXT MOD gates mw),\n OnOff: 0-off,1-on,\n TrgImpedance: <=50 - 50 ohm, >50 - 10kOhm,\n TrgSrc: 0-cont,1-ext,2-gated,3-single, \n TrgPol: 0 or other-norm, 1-inverted";
SMBPULSE2[ProgS_,CommandN_,Period_(*us*),Width_(*us*),Delay_(*us*),Source_,OnOff_,TrgImpedance_,TrgSrc_,TrgPol_]:=ProgS<>"\n"<>PrintLine[{CommandN,"2005","SMBPULSE2",Period,Width,Delay,Source,OnOff,TrgImpedance,TrgSrc,TrgPol}];

(*Agilent EXA N9010A*)
EXASET::usage="EXA Set Parameters (should be depricated).\n ::Parameters::\n ProgS,\n CommandN,\n CtrFreq: MHz,\n FreqSpan: Hz,\n Bandwisth: Hz";
EXASET[ProgS_,CommandN_,CtrFreq_(*MHz*),FreqSpan_(*Hz*),BWidth_(*Hz*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1005","EXASET",CtrFreq,FreqSpan,BWidth}];
EXAFSET::usage="EXA set frequency parameters.\n ::Parameters::\n ProgS,\n CommandN,\n FreqCent: Hz,\n FreqSpan: Hz,\n Bandwisth: Hz,\n FreqPts: Number of x-points 1-40001";
EXAFSET[ProgS_,CommandN_,FreqCent_(*Hz*),FreqSpan_(*Hz*),BWidth_(*Hz*),FreqPts_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1009","EXASFET",FreqCent,FreqSpan,BWidth,FreqPts}];
EXAMEAN::usage="EXA mean amplitude.\n ::Parameters::\n ProgS,\n CommandN,\n StartPixel,\n FinalPixel,\n DelayFactor: x times Sweep Time";
EXAMEAN[ProgS_,CommandN_,StartPixel_,FinalPixel_,DelayFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1006","EXAMEAN",StartPixel,FinalPixel,DelayFactor}];
EXAMAX::usage="EXA Max amplitude - fast measurement using analyzer built-in maths.\n ::Parameters::\n ProgS,\n CommandN,\n SingleShot: 0-continious, 1-single shot (this parameter changes EXA setting same as EXACONT)";
EXAMAX[ProgS_,CommandN_,SingleShot_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"1007","EXAMAX",SingleShot}];
EXACONT::usage="EXA measurement mode.\n ::Parameters::\n ProgS,\n CommandN, \n State: 0-single shot,1-continious";
EXACONT[ProgS_,CommandN_,State_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1008","EXACONT",State}];
EXASPEC::usage="EXA measure and save spectrum.\n ::Parameters::\n ProgS,\n CommandN,\n fileN: ,\n SingleShot: 0-continious, 1-single shot (this parameter changes EXA setting same as EXACONT)";
EXASPEC[ProgS_,CommandN_,fileN_(*Int. File number*),SingleShot_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1024","EXASPEC",fileN,SingleShot}];


(*Agilent 33220A generator*)
AGI3INI::usage="AGI 33220A Initialize.\n ::Parameters::\n ProgS,\n CommandN";
AGI3INI[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1010","AGI3INI"}];
AGI3OUT::usage="AGI 33220A Output.\n ::Parameters::\n ProgS,\n CommandN, \n Polarity: 0-norm,1-inverted,\n State: 0-off,>0-on";
AGI3OUT[ProgS_,CommandN_,Polarity_(*0-norm,1-inv*),State_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1011","AGI3OUT",Polarity,State}];
AGI3WFM::usage="AGI 33220A waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Func: 0-sin,1-squar,2-pulse,3-ramp,4-noise,5-dc,6-user (arb wfm must be first selected separately via FUNC:USER),\n Ampl,\n Offset,\n Freq/Period: 0-freq,1-period,\n Freq in Hz or Period in s. Period is documented for pulse only, but works e.g. for square,\n Pulse Width in s, short pulses >20ns with 10ns step";
AGI3WFM[ProgS_,CommandN_,Func_(*0-sine, 1-square, 2-pulse,...*),Ampl_(*Vpp*),Offset_(*V*),FreqPer_(*0-freq,1-period*),Freq_(*Hz/s*),PulseWidth_(*s*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1012","AGI3WFM",Func,Ampl,Offset,FreqPer,Freq,PulseWidth}];
AGI3SELARB::usage="AGI 33220A select user waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Func: 0-EXP_RISE,1-EXP_FALL,2-NEG_RAMP,3-SINC,4-CARDIAC,5-VOLATILE,x>=6 - ARB(x-5), i.e. 6 is ARB1. Up to 4 user ARBs can be defined.";
AGI3SELARB[ProgS_,CommandN_,Func_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1101","AGI3SELARB",Func}];
AGI3ERARB::usage="AGI 33220A erase all user defined arbs.\n ::Parameters::\n ProgS,\n CommandN";
AGI3ERARB[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1096","AGI3ERARB"}];
AGI3DC::usage="AGI 33220A DC.\n ::Parameters::\n ProgS,\n CommandN,\n DC Voltage in V";
AGI3DC[ProgS_,CommandN_,DCVolt_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1013","AGI3DC",DCVolt}];
AGI3BURS::usage="AGI 33220A burst mode.\n ::Parameters::\n ProgS,\n CommandN,\n Burst On/Off,\n BurstMod: 0-trig, 1-gated,\n Burst Cycles,\n Trigger Source: 0-Int,1-Ext,2-Man,\n Trg/Gate Polarity: 0-positive,1-negative,\n Internal Period,\n Phase between -360 and 360 deg with 0.1 deg resolution";
AGI3BURS[ProgS_,CommandN_,OnOff_(*0-off,1-on*),Mode_(*0-trigger,1-gated*),NCycles_(*1-50000*),TrigSrc_(*0-Int/1-Ext/2-Man*),Polarity_(*0-pos,1-neg*),IntPeriod_(*s*),Phase_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1014","AGI3BURS",OnOff,Mode,NCycles,TrigSrc,Polarity,IntPeriod,Phase}];
AGI3TRG::usage="AGI 33220A. Manual trigger. \n ::Parameters::\n ProgS,\n CommandN";
AGI3TRG[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1031","AGI3TRG"}];
AGI3ARBVOL::usage="AGI 33220A load arb wfm from computer into device memory. The range of sample values is -1..+1, single precision float. Unit does not automatically rescale WFMs to fill the dynamic range.\n ::Parameters::\n ProgS,\n CommandN, \n DestWFMNumber: positive number x, WFM will be loaded into ARBx for x=1..4 or to Volatile for x=0,\n WFMSource: 0- waveforms as columns in one file,1- each wfm in a separte file with name NAME_nn, where nn is a wfm number,2- programmatic array of numbers,\n SrcWFMNumber: number of the column in the source wfm file, or number of the file, or number of the RAM WFM slot,\n SrcWFMLen: Length of the segment to be loaded, the remaining samples of the source WFM are ignored,\n RescFactor: rescaling factor to multiply src WFM before loading. Can be used to adapt old WFMs.";
AGI3ARBVOL[ProgS_,CommandN_,DestWFMNumber_(*positive number x*),WFMSource_,SrcWFMNumber_(*number of the column*),SrcWFMLen_(*length of the source WFM*),RescFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1097","AGI3ARBVOL",DestWFMNumber,WFMSource,SrcWFMNumber,SrcWFMLen,RescFactor}];


(*TTi TG5011 AWG*)
TG5INI::usage="TG5011 Initialize.\n ::Parameters::\n ProgS,\n CommandN";
TG5INI[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1023","TG5INI"}];
TG5OUT::usage="TG5011 Output.\n ::Parameters::\n ProgS,\n CommandN,\n State: 0-off,1-on, \n Polarity: 0-norm,1-inverted,\n Load: 0-open,1-50ohm,2-600ohm";
TG5OUT[ProgS_,CommandN_,State_,Polarity_(*0-norm,1-inv*),Load_(*0-open, 1-50ohm*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1015","TG5OUT",State,Polarity,Load}];
TG5WFM::usage="TG5011 Waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Func: 0-sin,1-squar,2-triangle,3-dc,4-ramp,10-pulse,12-arb,14-noise,\n Arb WF: 0-arb1,1-arb2,2-arb3,3-arb4,\n Ampl,\n Offset,\n Freq/Period?: 0-Freq,1-Period,\n Freq/Period in Hz/sec,\n Phase 0.1 deg resolution";
TG5WFM[ProgS_,CommandN_,Func_(*0-sine, 2-pulse, 6-ARB1*),Arb_(*0-ARB1...*),Ampl_,Offset_,QFrePer_(*0-freq, 1-period*),FreqPer_(*Hz/s*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1016","TG5WFM",Func,Arb,Ampl,Offset,QFrePer,FreqPer}];
TG5BURS::usage="TG5011 Burst.\n ::Parameters::\n ProgS,\n CommandN,\n State: 0-OFF,1-NCycle,2-Gated,3-Inf,\n TrigSrc: 0-Int,1-ext,2-manual,\n TrigPol: 0-pos,1-neg,\n BurstCnt: 1-1048575,\n IntPeriod in sec,\n Phase in degrees";
TG5BURS[ProgS_,CommandN_,State_(*0-OFF,1-NCycle,2-Gated,3-Inf*),TrigSrc_(*0-Int,1-ext,2-manual*),TrigPol_(*0-pos,1-neg*),BurstCnt_,IntPeriod_(**),Phase_(**)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1019","TG5BURS",State,TrigSrc,TrigPol,BurstCnt,IntPeriod,Phase}];
TG5DC::usage="OBSOLETE, use TG5WFM! TG5011 DC.\n ::Parameters::\n ProgS,\n CommandN,\n DC Voltage in V";
TG5DC[ProgS_,CommandN_,DCVolt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1017","TG5DC",DCVolt}];
TG5PUL::usage="TG5011 pulse.\n ::Parameters::\n ProgS,\n CommandN,\n Period: sec,\n Delay: sec,\n Width: sec";
TG5PUL[ProgS_,CommandN_,Period_,Delay_,Width_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1018","TG5PUL",Period,Delay,Width}];
TG5TRG::usage="TG5011. Manual trigger. \n ::Parameters::\n ProgS,\n CommandN";
TG5TRG[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1058","TG5TRG"}];
TGACLK::usage="TGA configure reference clock 10 MHz. Default is input with automatic sensing of external 10MHz source. \n ::Parameters::\n ProgS,\n CommandN,\n DeviceID,\n Source: 0-in, 1-out, 2-master, 3-slave";
TG5CLK[ProgS_,CommandN_,Source_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1094","TG5CLK",Source}];
TG5ARBSZ::usage="TG5011 resize ARB wfm.\n ::Parameters::\n ProgS,\n CommandN,\n DestWFMNumber: 0..3 for ARB1..ARB4,\n WFMLen: 128k is possible for ARB1 and ARB3. For ARB2 and ARB4 max length is 64k";
TG5ARBSZ[ProgS_,CommandN_,DestWFMNumber_,WFMLen_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1098","TG5ARBSZ",DestWFMNumber,WFMLen}];
TG5ARBDEF::usage="TG5011 define ARB wfm.\n ::Parameters::\n ProgS,\n CommandN,\n DestWFMNumber: 0..3 for ARB1..ARB4,\n InterpolateQ: 0-repeat, 1-interpolate";
TG5ARBDEF[ProgS_,CommandN_,DestWFMNumber_,InterpolateQ_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1099","TG5ARBDEF",DestWFMNumber,InterpolateQ}];
TG5ARBVOL::usage="TG5011 load arb wfm from computer into device memory. The range of sample values is -1..+1, single precision float. Unit does not automatically rescale WFMs to fill the dynamic range.\n ::Parameters::\n ProgS,\n CommandN, \n DestWFMNumber: positive number x, WFM will be loaded into ARB1..ARB4 for x=0..3,\n WFMSource: 0- waveforms as columns in one file,1- each wfm in a separte file with name NAME_nn, where nn is a wfm number,2- programmatic array of numbers,\n SrcWFMNumber: number of the column in the source wfm file, or number of the file, or number of the RAM WFM slot,\n SrcWFMLen: Length of the segment to be loaded, the remaining samples of the source WFM are ignored,\n RescFactor: rescaling factor to multiply src WFM before loading. Can be used to adapt old WFMs.";
TG5ARBVOL[ProgS_,CommandN_,DestWFMNumber_(*positive number x*),WFMSource_,SrcWFMNumber_(*number of the column*),SrcWFMLen_(*length of the source WFM*),RescFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1100","TG5ARBVOL",DestWFMNumber,WFMSource,SrcWFMNumber,SrcWFMLen,RescFactor}];



(*Keithley 230 Voltage Source*)
K230INI::usage="Keithley 230 Initialize.\n ::Parameters::\n ProgS,\n CommandN,\n ILimit: 0-2mA, 1-20mA, 2-100mA";
K230INI[ProgS_,CommandN_,ILim_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1020","K230INI",ILim}];
K230OUT::usage="Keithley 230 Output.\n ::Parameters::\n ProgS,\n CommandN,\n State: 0-off,1-on";
K230OUT[ProgS_,CommandN_,State_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1021","K230OUT",State}];
K230VOLT::usage="Keithley 230 Set Voltage.\n ::Parameters::\n ProgS,\n CommandN,\n Voltage in V";
K230VOLT[ProgS_,CommandN_,Volts_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1022","K230VOLT",Volts}];

(*Keithley 486 Picoammeter*)
K486INI::usage="Keithley 486 Initialize.\n ::Parameters::\n ProgS,\n CommandN";
K486INI[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1025","K486INI"}];
K486READ::usage="Keithley 486 Read Current.\n ::Parameters::\n ProgS,\n CommandN";
K486READ[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1026","K486READ"}];
IVCURVE::usage="I-V-Curve with Keithleys 230 and 486.\n ::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n Start Voltage in V,\n End Voltage in V,\n Voltage Steps in V,\n N Averages,\n Delay btw Samples in ms,\n ILimit: 0-2mA, 1-20mA, 2-100mA";
IVCURVE[ProgS_,CommandN_,fileN_(*Int. File number*),Volt0_(*V*),Volt1_(*V*),VoltStep_(*V*),AvgN_,Delay_(*ms*),ILim_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1027","IVCURVE",fileN,Volt0,Volt1,VoltStep,AvgN,Delay,ILim}];

(*Agilent B29xx SMU*)
B29OUT::usage="Agilent B29xx  Output.\n ::Parameters::\n ProgS,\n CommandN,\n Channel,\n State: 0-off,1-on";
B29OUT[ProgS_,CommandN_,Channel_,State_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1048","B29OUT",Channel,State}];
B29ILIM::usage="Agilent B29xx Set current limit.\n ::Parameters::\n ProgS,\n CommandN,\n Channel,\n CurrentLim: Current limit in A";
B29ILIM[ProgS_,CommandN_,Channel_,CurrentLim_(*A*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1049","B29ILIM",Channel,CurrentLim}];
B29INTTIME::usage="Agilent B29xx set integration time.\n ::Parameters::\n ProgS,\n CommandN,\n Channel,\n IntTime: integration time 8.0e-6..2.0 s";
B29INTTIME[ProgS_,CommandN_,Channel_,IntTime_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1050","B29INTTIME",Channel,IntTime}];
B29VOLT::usage="Agilent B29xx set Voltage.\n ::Parameters::\n ProgS,\n CommandN,\n Channel,\n Voltage: Output voltage in V";
B29VOLT[ProgS_,CommandN_,Channel_,Voltage_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1051","B29VOLT",Channel,Voltage}];
B29SWEEPVOLT::usage="Agilent B29xx sweep to Voltage.\n ::Parameters::\n ProgS,\n CommandN,\n Channel 1 or 2,\n Voltage: Target voltage in V,\n Step: Step size in V,\n Delay: time to delay between steps in ms";
B29SWEEPVOLT[ProgS_,CommandN_,Channel_,Voltage_(*V*),Step_(*V*),Delay_(*ms*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1061","B29SWEEPVOLT",Channel,Voltage,Step,Delay}];
B29MEASIV::usage="Agilent B29xx read voltage and current.\n ::Parameters::\n ProgS,\n CommandN,\n Channel";
B29MEASIV[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1052","B29MEASIV",Channel}];
B29IVCURVE::usage="I-V-Curve with B29xx. The voltage sweep is performed up and down, starting and ending at lower voltages.\n ::Parameters::\n ProgS,\n CommandN,\n fileN: Integer file number,\n Start Voltage in V,\n End Voltage in V,\n Voltage Steps in V,\n N Averages,\n Delay btw Samples in ms,\n ILimit: 0-2mA, 1-20mA, 2-100mA,\n IntegrTime: integration time (s), optimal is 40 ms or a multiple of.";
B29IVCURVE[ProgS_,CommandN_,Channel_,fileN_(*Int. File number*),VoltStart_(*V*),VoltEnd_(*V*),VoltStep_(*V*),AvgN_,Delay_(*ms*),ILim_,IntegrTime_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1103","B29IVCURVE",Channel,fileN,VoltStart,VoltEnd,VoltStep,AvgN,Delay,ILim,IntegrTime}];



K6487SWEEPV::usage="Keithley 6487 sweep to target Voltage. This command activates the output\n ::Parameters::\n ProgS,\n CommandN,\n Channel 1 or 2 (not in use),\n Voltage: Target voltage in V,\n Step: Step size in V,\n Delay: time to delay between steps in ms";
K6487SWEEPV[ProgS_,CommandN_,Channel_,Voltage_(*V*),Step_(*V*),Delay_(*ms*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1070","K6487SWEEPV",Channel,Voltage,Step,Delay}];




(*Step motor to change TiSp Wavelength*)
TISPWL::usage="TiSp set wavelength.\n ::Parameters::\n ProgS,\n CommandN,\n MotorNumber, \n Position in mm";
TISPWL[ProgS_,CommandN_,MotorNumber_,Position_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1028","TISPWL",MotorNumber,Position}];
TISPWSSET::usage="Set Ti:Sp biref filter position to get desired wavlength measured with WS7.\n ::Parameters::\n ProgS,\n CommandN,\n TargetWL - target laser emission wavlength(energy/frequency), \n WLTolerance - precision with which target will be sought, \n dWLdParam - slope of the WL dependence on laser control Parameter, \n Units: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV, \n ParamMin - min value for laser control Parmeter, \n ParamMax - maximum value, \n TimeDelay - delay after changing laser Parameter (ms), \n StepFactor - Scales the step calculated from dWLdParam and WL difference. Must be <0.5, optimal 0.15";
TISPWSSET[ProgS_,CommandN_,TargetWL_,WLTolerance_,dWLdParam_(*slope*),Units_,ParamMin_,ParamMax_,TimeDelay_(*ms*),StepFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1068","TISPWSSET",TargetWL,WLTolerance,dWLdParam(*slope*),Units,ParamMin,ParamMax,TimeDelay(*ms*),StepFactor}];



(*Matisse*)
MATSWL::usage="Matisse set wavelength using bifi only. Control loops will be left unlocked.\n ::Parameters::\n ProgS,\n CommandN,\n Server: 0 - local computer, 20 - c11magnres20,\n LaserNumber=1, \n Target wavelength in nm, \n Retries: number of times to try calling the remote VI, \n ThinEtalon: 0..148038 motor position. Unchanged if outside range, \n PiezoEtalon: -1..+1. Unchanged if outside range, \n SlowPiezo: 0..+0.7 Unchanged if outside range";
MATSWL[ProgS_,CommandN_,Server_,LaserNumber_,WlBiFi_(*nm*),Retries_,ThinEtalon_:60000,PiezoEtalon_:0.,SlowPiezo_:0.04]:=ProgS<>"\n"<>PrintLine[{CommandN,"1104","MATSWL",Server,LaserNumber,WlBiFi,Retries,ThinEtalon,PiezoEtalon,SlowPiezo}];
MATWSSET::usage="Run Matisse GoTo function. Requires WS7 running on the same PC as Matisse. WS7 exposure must be set to Automatic.\n ::Parameters::\n ProgS,\n CommandN,\n Server: 0 - local computer, 20 - c11magnres20,\n LaserNumber=1,\n Target - target laser emission wavlength(energy/frequency), \n Units: 0- nm Vac, 1- nm air, 2- THz, \n Retries: number of times to try calling the remote VI, \n TimeOut - timeout in seconds";
MATWSSET[ProgS_,CommandN_,Server_,LaserNumber_,Target_,Units_,Retries_,TimeOut_:240]:=ProgS<>"\n"<>PrintLine[{CommandN,"1106","MATWSSET",Server,LaserNumber,Target,Units,Retries,TimeOut}];



(*ANC350 positioner*)
ANC35SET::usage="ANC350 set channel parameters.\n ::Parameters::\n ProgS,\n CommandN,\n Axis number: 2 - x axis, 1 - y axis, 0 - z axis,\n Step amplitude,\n Frequency, \n Avgs - numbr of averages";
ANC35SET[ProgS_,CommandN_,Axis_,Amplitude_(*V*),Freq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1054","ANC35SET",Axis,Amplitude,Freq}];
ANC35STEP::usage="ANC350 single step.\n ::Parameters::\n ProgS,\n CommandN,\n Axis number: 2 - x axis, 1 - y axis, 0 - z axis,\n Step direction: >0 - Positive, \[LessEqual]0 - negative";
ANC35STEP[ProgS_,CommandN_,Axis_,Direction_(*>0 - Positive, \[LessEqual]0 - negative*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1053","ANC35STEP",Axis,Direction}];
ANC35ABS::usage="ANC350 moved to desired position.\n ::Parameters::\n ProgS,\n CommandN,\n Axis number: 2 - x axis, 1 - y axis, 0 - z axis,\n AbsPosition: desired abs position,\n MaxItt: max itterations before terminating,\n Tolerance: tolerance of desired position";
ANC35ABS[ProgS_,CommandN_,Axis_,AbsPosition_,MaxItt_:100,Tolerance_:0.1]:=ProgS<>"\n"<>PrintLine[{CommandN,"1062","ANC35ABS",Axis,AbsPosition,MaxItt,Tolerance}];
ANC35READ::usage="ANC350 read coordinates.\n ::Parameters::\n ProgS,\n CommandN";
ANC35READ[ProgS_,CommandN_,Avgs_:1]:=ProgS<>"\n"<>PrintLine[{CommandN,"1055","ANC35READ",Avgs}];


(*Agilent 33600 generator*)
A33INI::usage="AGI 33600 Initialize.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602)";
A33INI[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"65","A33INI",DeviceID}];
A33WFM::usage="AGI 33600 waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n Func: 0-sin,1-squar,2-pulse,3-ramp,4-noise,5-dc,6-PRBS,7-triangle\n Ampl,\n Offset,\n Freq: Frequency/bandwidth for noise/bitrate for PRBS, if <=0 than take the value from the register with this number.,\n Phase: -360..+360deg,\n LogFreq: >=1-log the frequency, <=0-no logging.";
A33WFM[ProgS_,CommandN_,DeviceID_,Channel_,Func_(*0-sine, 2-pulse*),Ampl_,Offset_,Freq_(*real*),Phase_:0,LogFreq_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"66","A33WFM",DeviceID,Channel,Func,Ampl,Offset,Freq,Phase,LogFreq}];
A33PUL::usage="AGI 33600 set pulse params.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n Period: sec,\n Width: in sec ,\n LeadEdge: in sec, 4ns default,\n TrailEdge: in sec, 4ns default";
A33PUL[ProgS_,CommandN_,DeviceID_,Channel_,Period_(*s*),Width_,LeadEdge_:4*10^-9,TrailEdge_:4*10^-9(*s*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1079","A33PUL",DeviceID,Channel,Period,Width,LeadEdge,TrailEdge}];
A33ERARB::usage="AGI 33600 erase all arb wfms for certain channel.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1";
A33ERARB[ProgS_,CommandN_,DeviceID_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"67","A33ERARB",DeviceID,Channel}];
A33ARBVOL::usage="AGI 33600 load arb wfm from computer into volatile memory. y-range -32767..+32767\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1, \n WFMSlot: positive number x, WFM will be named ARBx,\n WFMFile: number of the column in the wfm file, or number of the file,\n WFMLen: 8-4M,\n WFMSource: 0-waveforms as columns in one file,1-each wfm in a separte file with name NAME_nn, where nn is a wfm number,2-programmatic array of numbers";
A33ARBVOL[ProgS_,CommandN_,DeviceID_,Channel_,WFMSlot_(*positive number x*),WFMFile_(*number of the column*),WFMLen_(*length of the WFM*),WFMSource_]:=ProgS<>"\n"<>PrintLine[{CommandN,"68","A33ARBVOL",DeviceID,Channel,WFMSlot,WFMFile,WFMLen,WFMSource}];
A33ARB::usage="AGI 33600 waveform.\n Sometimes shows error message - it's ok, it's just phase sync command\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601),\n Channel: Channel number 0 or 1,\n ARBNumber: Positive N - selects wfm from volatile (Wfm must be loaded first). Negative - selects wfm loaded from non-vol memory, wfm must be first loaded into volatile from intern. file!\n Ampl,\n Offset,\n QFreqSRPer: Whether the next parameter is frequency(0), sampl. rate(1) or period(2),\n FreqSRPer,\n Filter: Filter mode - off(0), step(1), normal(2),\n Phase -360..+360 deg, NC if outside range - use in burst mode,\n AdvMode: Normal(0), Each point is triggered(1)";
A33ARB[ProgS_,CommandN_,DeviceID_,Channel_,ARBNumber_,Ampl_,Offset_,QFreqSRPer_(*real*),FreqSRPer_,Filter_,Phase_,AdvMode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"69","A33ARB",DeviceID,Channel,ARBNumber,Ampl,Offset,QFreqSRPer,FreqSRPer,Filter,Phase,AdvMode}];
A33TRGCONF::usage="AGI 33600 configure trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602), \n Channel: Channel number 0 or 1,\n Source: 0-immediate (burst period),1-timer,2-extern.,3-software,\n TrigSlope: 0-pos,1-neg,\n IntPeriod,\n TrgLevel: trigger level, 0.9-3.8 Volts,\n TrgDelay: 0-1000 sec, 4ns resolution";
A33TRGCONF[ProgS_,CommandN_,DeviceID_,Channel_,Source_,TrigSlope_(*0-pos,1-neg*),IntPeriod_,TrgLevel_(*Volts*),TrgDelay_]:=ProgS<>"\n"<>PrintLine[{CommandN,"70","A33TRGCONF",DeviceID,Channel,Source,TrigSlope,IntPeriod,TrgLevel,TrgDelay}];
A33BURST::usage="AGI 33600 configure burst.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n State: 0-off(continious),>0-on,\n Mode: 0-trig,1-gate,\n BurstCount: 1-100M,0-inf burst,\n IntPeriod,\n BurstPhase: -360..+360 deg. Phase is not a delay!,\n GatePolarity: 0-positive, >0-negative";
A33BURST[ProgS_,CommandN_,DeviceID_,Channel_,State_,Mode_,BurstCount_,IntPeriod_,BurstPhase_,GatePolarity_]:=ProgS<>"\n"<>PrintLine[{CommandN,"71","A33BURST",DeviceID,Channel,State,Mode,BurstCount,IntPeriod,BurstPhase,GatePolarity}];
A33OUT::usage="AGI 33600 Output.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602), \n Channel: Channel number 0 or 1,\n State: 0-off,>0-on,\n Impedance: 1Ohm-10kOhm, load impedance used to calculate amplitudes,\n Polarity: 0-norm,1-inverted,\n Mode: 0-normal, 1-output is gated by ext trig input";
A33OUT[ProgS_,CommandN_,DeviceID_,Channel_,State_,Impedance_,Polarity_(*0-norm,1-inv*),Mode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"72","A33OUT",DeviceID,Channel,State,Impedance,Polarity,Mode}];
A33PSYNC::usage="AGI 33600 Sync phase.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602), \n ArbQ: 1 if sync is for Arb waveforms, 0 if for other waveforms";
A33PSYNC[ProgS_,CommandN_,DeviceID_,ArbQ_]:=ProgS<>"\n"<>PrintLine[{CommandN,"75","A33PSYNC",DeviceID,ArbQ}];
A33TRG::usage="AGI 33600 Force trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602)";
A33TRG[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"77","A33TRG",DeviceID}];
A33AM::usage="AGI 33600 config AM.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n OnOff: modulation state, 0-off,>0-on,\n Source: 0-internal,1-ext,2-channel,3-channel2(1-3 not implemented),\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-nramp,5-noise,6-PRBS,7-ARB(needs to be implemented),\n Depth: 0-120%,\n ModulFreq: internal freq,\n CarrierSupp: 0-disabled,>0-suppressed carrier";
A33AM[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Source_(*0-internal,1-ext*),ModulWFM_(*0-sine*),Depth_,ModulFreq_,CarrierSupp_]:=ProgS<>"\n"<>PrintLine[{CommandN,"78","A33AM",DeviceID,Channel,OnOff,Source,ModulWFM,Depth,ModulFreq,CarrierSupp}];
A33FM::usage="AGI 33600 config FM.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n OnOff: modulation state, 0-off,>0-on,\n Source: 0-internal,1-ext,2-channel,3-channel2(1-3 not implemented),\n ModulWFM: 0-sin,1-squar,2-triag,3-ramp,4-nramp,5-noise,6-PRBS,7-ARB(needs to be implemented),\n DevFreq: 1uHz - 60 MHz,\n ModulFreq: internal freq 1uHz - max for this wfm as carrier, 800kHz for triag";
A33FM[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_,Source_(*0-internal,1-ext*),ModulWFM_(*0-sine*),DevFreq_,ModulFreq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1111","A33FM",DeviceID,Channel,OnOff,Source,ModulWFM,DevFreq,ModulFreq}];
A33SWEEP::usage="AGI 33600 frequency sweep.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (33600 or 33601 or 33602),\n Channel: Channel number 0 or 1,\n State: 0-off,>0-on,\n StartFreq: Hz,\n StopFreq: Hz,\n SweepTime: 1ms - 250ks (lin)/500s(log),\n HoldTime: 0 - 3600s,\n RetTime: 0 - 3600s,\n SweepSpacing: 0-lin,1-log";
A33SWEEP[ProgS_,CommandN_,DeviceID_,Channel_,State_,StartFreq_,StopFreq_,SweepTime_,HoldTime_,RetTime_,SweepSpacing_(*0-lin, 1 -log*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1042","A33SWEEP",DeviceID,Channel,State,StartFreq,StopFreq,SweepTime,HoldTime,RetTime,SweepSpacing}];



(*Agilent 33600 generator*)
BNC577INI::usage="BNC577 Initialize.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1)";
BNC577INI[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1112","BNC577INI",DeviceID}];
BNC577OUT::usage="BNC577 Output.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1), \n Channel: Channel number 1-8 for physical channels, or 0 for RUN/STOP. Caution: doing RUN tunrs on all the channels with default pulses. After resetting the device, need to explicitly turn off every individual channel. Then doing RUN tunrs on only the requrired channels.,\n State: 0-off,>0-on";
BNC577OUT[ProgS_,CommandN_,DeviceID_,Channel_,State_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1113","BNC577OUT",DeviceID,Channel,State}];
BNC577SETOUT::usage="BNC577 Output.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1), \n Channel: Channel number 1-8 for physical channels, 0 not allowed,\n OutLevel: 0-TTL,1-adjustable,2 and 3 not implemented. Also controls physical output impedance (50Ohm for TTL), \n Ampl: output Amplitude if level is set to adjustable (2.0-20.0 V),\n Polarity: 0-norm,>0-inv. Inversion is logical, the signal is always within [0,Ampl], \n MUXCode: Binary coded mask for multiplexing. -1 means 1:1 correspondance of logical and physical channels; 0 means no output; 255 means all 8 channels OR-d toghether";
BNC577SETOUT[ProgS_,CommandN_,DeviceID_,Channel_,OutLevel_,Ampl_,Polarity_(*0-norm,1-inv*),MUXCode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1114","BNC577SETOUT",DeviceID,Channel,OutLevel,Ampl,Polarity,MUXCode}];
BNC577T0::usage="BNC577 T0 system period.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1),\n Period: 50 ns to 999.999995 s";
BNC577T0[ProgS_,CommandN_,DeviceID_,Period_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1115","BNC577T0",DeviceID,Period}];
BNC577TCH::usage="BNC577 set timing for a channel.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1), \n Channel: Channel number 1-8 for physical channels.,\n Delay: 0 to 999.99999999975 s, resolution is better than 0.5 ns, \n Width: 5ns to 999.99999999975 s, \n WaitCnt: 1..1E7 int. number of cycles to wait before starting the output";
BNC577TCH[ProgS_,CommandN_,DeviceID_,Channel_,Delay_,Width_,WaitCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1116","BNC577TCH",DeviceID,Channel,Delay,Width,WaitCnt}];
BNC577MODE::usage="BNC577 set mode for T0 or a channel.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1), \n Channel: Channel number 1-8 for physical channels, or 0 for T0 (unit level).,\n Mode: 0-Normal(continuous),1-Single,2-Burst,3-Duty Cycle , \n BurstCnt: 1..1E7 Burst mode only, \n OnCnt: 1..1E7 for Duty Cycle mode only, \n OffCnt: 1..1E7 for Duty Cycle mode only ";
BNC577MODE[ProgS_,CommandN_,DeviceID_,Channel_,Mode_,BurstCnt_,OnCnt_,OffCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1117","BNC577MODE",DeviceID,Channel,Mode,BurstCnt,OnCnt,OffCnt}];
BNC577SETTRG::usage="BNC577 set mode for trigger and gate.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1), \n ExtMode: 0-Disabled(continuous),1-Trig'd,2-Gated,3-Trig'd&Gate, \n TRGEdge: >0-rising, <=0-falling, \n TRGLevel: 0.2..15V, \n GateMode: 0-Disabled,1-Pulse inhibit,2-Output inhibit,3-Channel, \n GateLogic: >0-High, <=0-Low, \n GateLevel: 0.2..15V";
BNC577SETTRG[ProgS_,CommandN_,DeviceID_,ExtMode_,TRGEdge_,TRGLevel_,GateMode_,GateLogic_,GateLevel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1118","BNC577SETTRG",DeviceID,ExtMode,TRGEdge,TRGLevel,GateMode,GateLogic,GateLevel}];
BNC577TRG::usage="BNC577 forced (software) trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1)";
BNC577TRG[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1119","BNC577TRG",DeviceID}];
BNC577ARM::usage="BNC577 ARM (Resets all channel counters simultaneously when the channels are in eithersingle shot or burst mode).\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID (not implemented yet - use 1)";
BNC577ARM[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1120","BNC577ARM",DeviceID}];


(*ASY synthesizer*)
ASYWFM::usage="ASY synthesizer waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Freq: frequency in kHz, integer,\n SaveToNonvol: 0-hop mode,1-save to nonvolatile memory";
ASYWFM[ProgS_,CommandN_,Freq_(*kHz*),SaveToNonvol_(*0-hop mode, 1-save*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1032","ASYWFM",Freq,SaveToNonvol}];
ASYOUT::usage="ASY synthesizer output.\n ::Parameters::\n ProgS,\n CommandN,\n Output: 1-output on, 0-off";
ASYOUT[ProgS_,CommandN_,Output_(*1-on, 0-off*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1033","ASYOUT",Output}];


(*RAM waveforms*)
RWFMINI::usage="Initialize RAM waveform.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n WFMLen: waveform length";
RWFMINI[ProgS_,CommandN_,WFMSlot_,WFMLen_]:=ProgS<>"\n"<>PrintLine[{CommandN,"73","RWFMINI",WFMSlot,WFMLen}];
RWFMBLK::usage="Set block of values in RAM waveform.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n X1: start x value (0..WFMLen-1),\n X2: end x value (0..WFMLen-1),\n Y: y-value for the whole block";
RWFMBLK[ProgS_,CommandN_,WFMSlot_,X1_,X2_,Y_]:=ProgS<>"\n"<>PrintLine[{CommandN,"74","RWFMBLK",WFMSlot,X1,X2,Y}];
RWFMHARMS::usage="Generate sum of harmonics with min crest factor and save in RAM waveform.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n WFMLen: Waveform length,\n RescCoeffMin: Min value for scaled WFM (-32767 for Agilent33600),\n RescCoeffMax: Max value for scaled WFM (+32767 for Agilent33600),\n ModeCnt: number of harmonics, there should be exactly the same number of {ModeN,ModeAmpl} pairs given in the next parameter, \n ModeParamList: A list of {Mode number, Mode amplitude} pairs";
RWFMHARMS[ProgS_,CommandN_,WFMSlot_,WFMLen_,RescCoeffMin_,RescCoeffMax_,ModeCnt_,ModeParamList_(*{{ModeN,ModeAmpl},{},{}...}*)]:=ProgS<>"\n"<>PrintLine[Flatten[{CommandN,"1065","RWFMHARMS",WFMSlot,WFMLen,RescCoeffMin,RescCoeffMax,ModeCnt,Flatten[ModeParamList]}]];
RWFMLINE::usage="Set block of values in RAM waveform to linear interpolation from {X1,Y1} to {X2,Y2}.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n X1: start x value (0..WFMLen-1),\n X2: end x value (0..WFMLen-1),\n Y1: y-value for X1,\n Y2: y-value for X2";
RWFMLINE[ProgS_,CommandN_,WFMSlot_,X1_,X2_,Y1_,Y2_]:=ProgS<>"\n"<>PrintLine[{CommandN,"82","RWFMLINE",WFMSlot,X1,X2,Y1,Y2}];
RWFMPUL2::usage="Set block of values in RAM waveform to a harmonic pulse. Envelope consists of Cos rise, const level, and Cos fall. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n XStart: start x - first sample of the rising edge (0..WFMLen-1),\n XRise: Length (samples) of the segement corresponding to rising edge (can be 0),\n XPulse: Length of the const amplitude segment (can be 0),\n XFall: Length of the segement corresponding to falling edge (can be 0),\n Amplitude: amplitude, real,\n Frequency: Carrier frequency in units of sampling rate S, must be <=0.5,\n Phase: Carrier phase with respect to the start of the waveform in radians,\n PhaseCorr: integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index";
RWFMPUL2[ProgS_,CommandN_,WFMSlot_,XStart_,XRise_,XPulse_,XFall_,Amplitude_,Freq_,Phase_,PhaseCorr_]:=ProgS<>"\n"<>PrintLine[{CommandN,"109","RWFMPUL2",WFMSlot,XStart,XRise,XPulse,XFall,Amplitude,Freq,Phase,PhaseCorr}];
RWFMPULMF::usage="Set block of values in RAM waveform to a multifrequency (MF) harmonic pulse. Envelope for each harmonic consists of Cos rise, const level, and Cos fall. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index,\n RegSlotSrc: index of the 1st 1D register array with mode parameters. Each 1D register should contain {XStart,XRise,XPulse,XFall,Amplitude,Freq,Phase,TrackedModeIndex(starting from 0)},\n ModeCnt: number of modes,\n RationalizeFreq: >0- rationalize frequencies using given int parameter, <0- rationalize frequencies using tot duration of each harmonic, =0- use exact frequencies,\n AccPhaseOutReg1D: if >=0 number of 1D register to store accumulated phases, if <0 don't store.";
RWFMPULMF[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,RegSlotSrc_,ModeCnt_,RationalizeFreq_,AccPhaseOutReg1D_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1076","RWFMPULMF",WFMSlot,PhaseCorr,RegSlotSrc,ModeCnt,RationalizeFreq,AccPhaseOutReg1D}];
RWFMSWPMF::usage="Set block of values in RAM waveform to a multifrequency (MF) sweep pulse. Envelope for each harmonic consists of Cos rise, const level, and Cos fall. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index,\n RegSlotSrc: index of the 1st 1D register array with mode parameters. Each 1D register should contain {XStart,XRise,XPulse,XFall,Amplitude,Freq init, Freq fin, Phase},\n ModeCnt: number of modes.";
RWFMSWPMF[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,RegSlotSrc_,ModeCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1078","RWFMSWPMF",WFMSlot,PhaseCorr,RegSlotSrc,ModeCnt}];
RWFMSWPMFPRT::usage="Set block of values in RAM waveform to a multifrequency (MF) sweep pulse. Envelope for each harmonic consists of Cos rise, const level, and Cos fall. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index,\n xGenStart - Starting index of the WFM chunk to generate,\n xGenLen - Length of the WFM chunk to generate,\n RegSlotSrc: index of the 1st 1D register array with mode parameters. Each 1D register should contain {XRise,XPulse,XFall,Amplitude,Freq init, Freq fin, Phase},\n ModeCnt: number of modes.";
RWFMSWPMFPRT[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,xGenStart_,xGenLen_,RegSlotSrc_,ModeCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1082","RWFMSWPMFPRT",WFMSlot,PhaseCorr,xGenStart,xGenLen,RegSlotSrc,ModeCnt}];
RWFMPULMFENV::usage="Set block of values in RAM waveform to a multifrequency (MF) harmonic pulse. Envelope for each harmonic consists of multiple modes. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index,\n RegSlotSrc: index of the 1st 1D register array with mode parameters. Each 1D register should contain {XStart,XCont,Freq,TrackedModeIndex(starting from 0),EnvModeCnt,quadruplets of {Ampl,xi,phi,rho} for each envelope mode},\n HarmCnt: number of carrier harmonics.";
RWFMPULMFENV[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,RegSlotSrc_,HarmCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1081","RWFMPULMFENV",WFMSlot,PhaseCorr,RegSlotSrc,HarmCnt}];
RWFMSWPMFMSPRT::usage="Set block of values in RAM waveform to a multi-segment multifrequency (MF) sweep pulse. Each segment consists of multiple carriers. Integer offset for phase correction.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: Integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index (not implemented),\n xGenStart - Starting index of the WFM chunk to generate,\n xGenLen - Length of the WFM chunk to generate,\n RegSlotSrc: index of the 1st 1D register array with segment parameters. Each 1D register should contain XSegmLen, CarrierCnt, triplets of {Ampl init, Freq init, Phase} for each carrier (Phase starting from 2nd segment is phase jump, last segment phase is not used),\n SegmCnt: number of segments in the sweep sequence,\n AccPhaseOutReg1D: if >=0 number of 1D register to store accumulated phases, if <0 don't store.";
RWFMSWPMFMSPRT[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,xGenStart_,xGenLen_,RegSlotSrc_,SegmCnt_,AccPhaseOutReg1D_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1083","RWFMMSWPMFPRT",WFMSlot,PhaseCorr,xGenStart,xGenLen,RegSlotSrc,SegmCnt,AccPhaseOutReg1D}];
RWFMSWPMFMSPAR::usage="Set block of values in RAM waveform to a multi-segment multifrequency (MF) sweep pulse. Each segment consists of multiple carriers. Integer offset for phase correction. This vi automatically splits waveform into chunks and generates them in parallel - designed for fast genration of long wfms when large RAM is available.\n ::Parameters::\n ProgS,\n CommandN, \n WFMSlot: number of the waveform (starts from 0),\n PhaseCorr: Integer phase correction will be added as 2*pi*Freq*PhaseCorr to the phase - for uploading WFMs to a specified index (not implemented),\n xChunkLen - Max length of the WFM chunk to generate,\n RegSlotSrc: index of the 1st 1D register array with segment parameters. Each 1D register should contain XSegmLen, CarrierCnt, triplets of {Ampl init, Freq init, Phase} for each carrier (Phase starting from 2nd segment is phase jump, last segment phase is not used),\n SegmCnt: number of segments in the sweep sequence,\n AccPhaseOutReg1D: if >=0 number of 1D register to store accumulated phases, if <0 don't store.";
RWFMSWPMFMSPAR[ProgS_,CommandN_,WFMSlot_,PhaseCorr_,xChunkLen_,RegSlotSrc_,SegmCnt_,AccPhaseOutReg1D_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1091","RWFMMSWPMFPAR",WFMSlot,PhaseCorr,xChunkLen,RegSlotSrc,SegmCnt,AccPhaseOutReg1D}];




(*Register operations*)
REGINI::usage="Initialize register array.\n ::Parameters::\n ProgS,\n CommandN,\n Val: double value,\n Size: integer";
REGINI[ProgS_,CommandN_,Val_,Size_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1072","REGINI",Val,Size}];
REGSET::usage="Assign register to a given value.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotDest: number of the register slot (starts from 0),\n Val: double value";
REGSET[ProgS_,CommandN_,RegSlotDest_,Val_]:=ProgS<>"\n"<>PrintLine[{CommandN,"100","REGSET",RegSlotDest,Val}];
REGCOPY::usage="Copy src register to dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc: number of the register source slot (starts from 0), \n RegSlotDest: number of the destination register";
REGCOPY[ProgS_,CommandN_,RegSlotSrc_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"106","REGCOPY",RegSlotSrc,RegSlotDest}];
REGADD::usage="Add src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGADD[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"101","REGADD",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGSUB::usage="Subtract src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGSUB[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"102","REGSUB",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGMUL::usage="Multiply src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGMUL[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"103","REGMUL",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGDIV::usage="Divide src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGDIV[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"104","REGDIV",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGMIN::usage="Find minimum of src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGMIN[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"107","REGMIN",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGMAX::usage="Find maximum of src registers 1 and 2, and place result in a dest register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc1: number of the 1st register source slot (starts from 0), \n RegSlotSrc2: number of the 2nd register source slot ,\n RegSlotDest: number of the destination register";
REGMAX[ProgS_,CommandN_,RegSlotSrc1_,RegSlotSrc2_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"108","REGMAX",RegSlotSrc1,RegSlotSrc2,RegSlotDest}];
REGTSTMP::usage="Assign current timestamp to a register.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotDest: number of the register slot (starts from 0)";
REGTSTMP[ProgS_,CommandN_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"105","REGTSTMP",RegSlotDest}];
REGTOLOG::usage="Save register value in the Amplitude(2) local variable for logging.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc: number of the source register slot (starts from 0), \n VarDest: 1 - Amplitude, 2 - Amplitude2";
REGTOLOG[ProgS_,CommandN_,RegSlotSrc_,VarDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1077","REGTOLOG",RegSlotSrc,VarDest}];

REG1DINI::usage="Initialize 1D register array with a given value. All previous data is erased.\n ::Parameters::\n ProgS,\n CommandN,\n Val: double value,\n Size1: Number of registers, integer,\n Size2: Length of each register, integer";
REG1DINI[ProgS_,CommandN_,Val_,Size1_,Size2_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1073","REGINI",Val,Size1,Size2}];
REG1DRESZ::usage="Resize 1D register array - final sizes are max of desired and previous. Previous data is always preserved.\n ::Parameters::\n ProgS,\n CommandN,\n Size1: Number of registers, integer,\n Size2: Length of each register, integer";
REG1DRESZ[ProgS_,CommandN_,Size1_,Size2_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1088","REG1DRESZ",Size1,Size2}];
REG1DSET1D::usage="Assign 1D register to a given set of 1D values.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotDest: number of the register slot (starts from 0),\n DataLen: Expected number of elements to use for assignment. DataLen elements following the DataLen value will be used for assignment,\n Vals: values to assign.";
REG1DSET1D[ProgS_,CommandN_,RegSlotDest_,DataLen_,Vals__]:=ProgS<>"\n"<>PrintLine[Flatten[{CommandN,"1074","REG1DSET1D",RegSlotDest,DataLen,Vals}]];
REGTOREG1D::usage="Copy src 0D register to dest 1D register element.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc: number of the 0D register source slot (starts from 0), \n RegSlotDest: number of the destination 1D register, \n RegColDest: column number in the destination 1D register (starts from 0)";
REGTOREG1D[ProgS_,CommandN_,RegSlotSrc_,RegSlotDest_,RegColDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1075","REGTOREG1D",RegSlotSrc,RegSlotDest,RegColDest}];
REG1DTOREG1DV::usage="Copy element of src 1D register to dest 1D register element.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc: number of the 1D register source slot (starts from 0),\n RegColSrc: column number in the source 1D register (starts from 0),\n RegSlotDest: number of the destination 1D register, \n RegColDest: column number in the destination 1D register (starts from 0)";
REG1DTOREG1DV[ProgS_,CommandN_,RegSlotSrc_,RegColSrc_,RegSlotDest_,RegColDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1089","REG1DTOREG1DV",RegSlotSrc,RegColSrc,RegSlotDest,RegColDest}];
REG1DTOREG1DR::usage="Copy all elements of src 1D register to dest 1D register element.\n ::Parameters::\n ProgS,\n CommandN, \n RegSlotSrc: number of the 1D register source slot (starts from 0),\n RegSlotDest: number of the destination 1D register.";
REG1DTOREG1DR[ProgS_,CommandN_,RegSlotSrc_,RegSlotDest_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1090","REG1DTOREG1DV",RegSlotSrc,RegSlotDest}];


(*MSO3000 Scope*)
MSOCHAN::usage="MSO3000 set channel parameters.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1-4,\n Range: Full range in Volts,\n Offset: Offset in Volts,\n Coupling: 0-DC, 1-AC,\n Impedance: 0-1M, 1-50ohm,\n ..Other parameters can be implemented as well";
MSOCHAN[ProgS_,CommandN_,Channel_(**),Range_(*V*),Offset_(*V*),Coupling_:0,Impedance_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"1034","MSOCHAN",Channel,Range,Offset,Coupling,Impedance}];
MSOFID::usage="MSO3000 measure FID NMR/ESR.\n ::Parameters::\n ProgS,\n CommandN,\n fileN: ,\n TotAverages: total averages for on and off resonance,\n RefTimeStart: absolute (countd from trigger) time of the start of the window used to determine the phase of the signal,\n RefTimeEnd:,\n VThresh: threshold voltage on the modulation channel to save trace as on or off resonance.";
MSOFID[ProgS_,CommandN_,fileN_(*Int. File number*),TotAverages_(*total for on and off resonance*),RefTimeStart_(*s*),RefTimeEnd_,VThresh_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1035","MSOFID",fileN,TotAverages,RefTimeStart,RefTimeEnd,VThresh}];
MSOAPDTR::usage="MSO3000 measure APD signal time trace.\n ::Parameters::\n ProgS,\n CommandN,\n fileN: ,\n SoftAverages: software averages,\n ScopeAverages: 1-8192 hardware (scope) averages, at 1 scope is in Normal mode,\n SampleDecimation: 1-128 decimation factor for time samples, 1 - all points collected, 2- every second, etc.,\n APDPulseAmpl: expected amplitude of the APD pulse.,\n APDPulseBkg: bkg voltage of the APD output.,\n ForceOnRes: all traces will be treated as on-resonance";
MSOAPDTR[ProgS_,CommandN_,fileN_(*Int. File number*),SoftAverages_(*Software averages*),ScopeAverages_(*Hardware (oscilloscope) averages*),SampleDecimation_,APDPulseAmpl_(*V*),APDPulseBkg_(*V*),ForceOnRes_:1]:=ProgS<>"\n"<>PrintLine[{CommandN,"1043","MSOAPDTR",fileN,SoftAverages,ScopeAverages,SampleDecimation,APDPulseAmpl,APDPulseBkg,ForceOnRes}];
MSOTIME::usage="MSO3000 set timing parameters.\n ::Parameters::\n ProgS,\n CommandN, \n Mode: 0-MAIN, 1-WINDOW, 2-XY, 3- Roll,\n Range: Full range in s,\n Position: Offset in s,\n ..Other parameters can be implemented as well";
MSOTRG::usage="MSO3000 general trigger parameters.\n ::Parameters::\n ProgS,\n CommandN, \n Sweep: 0-NORM, 1-AUTO,\n Mode: 0 - EDGE | GLIT | PATT | TV | DEL | EBUR (nth edge burst) | OR | RUNT | SHOL | TRAN | SBUS1 | SBUS2 | 11-USB. Each mode then has its own settings,\n Holdoff: Holdoff time in s,\n ..Other parameters can be implemented as well";
MSOTRG[ProgS_,CommandN_,Sweep_(**),Mode_(*V*),Holdoff_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1044","MSOTRG",Sweep,Mode,Holdoff}];
MSOEDGTRG::usage="MSO3000 edge trigger parameters.\n ::Parameters::\n ProgS,\n CommandN, \n SrcType: 0-CHANNEL,1-DIGITAL,EXTERNAL,LINE,4-WGEN,\n SrcChan: channel number if source is analog (from 1) or digital (from 0),\n Edge: 0-POS,1-NEG,2-EITHER,3-ALTERNATE, \n Level - TRG level in V,\n ..Other parameters can be implemented as well";
MSOEDGTRG[ProgS_,CommandN_,SrcType_(**),SrcChan_(**),Edge_(**),Level_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1045","MSOEDGTRG",SrcType,SrcChan,Edge,Level}];
MSOEBURSTRG::usage="MSO3000 Nth edge trigger parameters.\n ::Parameters::\n ProgS,\n CommandN, \n SrcType: 0-CHANNEL,1-DIGITAL,\n SrcChan: channel number if source is analog (from 1) or digital (from 0),\n Edge: 0-POS,1-NEG, \n Level - TRG level in V, \n IdleTime - 10ns - 10s,\n NEdge - The number of edges in burst,\n ..Other parameters can be implemented as well";
MSOEBURSTRG[ProgS_,CommandN_,SrcType_(**),SrcChan_(**),Edge_(**),Level_(*V*),IdleTime_,NEdge_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1047","MSOEBURSTRG",SrcType,SrcChan,Edge,Level,IdleTime,NEdge}];
MSOTIME[ProgS_,CommandN_,Mode_,Range_(*s*),Position_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1039","MSOTIME",Mode,Range,Position}];
MSOMEASCLR::usage="MSO3000 clear front panel measurements. Needed to use counter via remote\n ::Parameters::\n ProgS,\n CommandN";
MSOMEASCLR[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1040","MSOMEASCLR"}];
MSOCOUNT::usage="MSO3000 Start counting and measure the number of pulses.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1-4";
MSOCOUNT[ProgS_,CommandN_,Channel_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1041","MSOCOUNT",Channel}];

(*DLC Pro laser*)
DLCVOFFS::usage="DLC Pro laser piezo voltage offset.\n ::Parameters::\n ProgS,\n CommandN,\n DLCID - laser number 1,2,...,\n Offset voltage (V)";
DLCVOFFS[ProgS_,CommandN_,DLCID_,VOffs_(*V*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1037","DLCVOFFS",DLCID,VOffs}];
DLCEMMIT::usage="DLC Pro laser enable emission.\n ::Parameters::\n ProgS,\n CommandN,\n DLCID - laser number 1,2,...,\n On (>1), Off (<=0). Note that this is not the same as the front panel button. For emission need front panel button AND this software enable command.";
DLCEMMIT[ProgS_,CommandN_,DLCID_,Emmission_(*On (>1), Off (<=0)*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1038","DLCEMMIT",DLCID,Emmission}];
DLCWSSET::usage="Set DLC Pro laser piezo voltage to get desired wavlength measured with WS7.\n ::Parameters::\n ProgS,\n CommandN,\n DLCID - laser number 1,2,...,\n TargetWL - target laser emission wavlength(energy), \n WLTolerance - precision with which target will be sought, \n dWLdParam - slope of the WL dependence on laser control Parameter, \n Units: 0- nm Vac, 1- nm air, 2- THz, 3- cm-1, 4- eV, \n ParamMin - min value for laser control Parmeter, \n ParamMax - maximum value, \n TimeDelay - delay after chaning laser Parameter (ms), \n StepFactor - Scales the step calculated from dWLdParam and WL difference. Must be <0.5, optimal 0.15";
DLCWSSET[ProgS_,CommandN_,DLCID_,TargetWL_,WLTolerance_,dWLdParam_(*slope*),Units_,ParamMin_,ParamMax_,TimeDelay_(*ms*),StepFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1046","DLCWSSET",DLCID,TargetWL,WLTolerance,dWLdParam(*slope*),Units,ParamMin,ParamMax,TimeDelay(*ms*),StepFactor}];
(*DLC Pro laser MOT option*)
DLMOTSETPOS::usage="DL Pro laser head with MOT option. Set motor position.\n ::Parameters::\n ProgS,\n CommandN,\n MotorNumber, \n Position (integer), \n BacklashCorr - >0 always approach target position from lower values, \n MinPos - minimum position to coerece (integer), \n MaxPos - maximum position to coerece (integer)";
DLMOTSETPOS[ProgS_,CommandN_,MotorNumber_,Position_(*int*),BacklashCorr_,MinPos_:172570(*int*),MaxPos_:394747(*int*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1080","DLMOTSETPOS",MotorNumber,Position,BacklashCorr,MinPos,MaxPos}];


NI6501INI::usage="Initialize NI6501 counter and start counting. This command must be given while timing gate is LO, and must be followed by timing gate HI. \n ::Parameters::\n ProgS,\n CommandN,\n Device ID: 1 or 2 to select the counter";
NI6501INI[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1056","NI6501INI",DeviceID}];
NI6501READ::usage="Read NI6501 counter. This command must be given while timing gate is LO. \n ::Parameters::\n ProgS,\n CommandN,\n Device ID: 1 or 2 to select the counter";
NI6501READ[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1057","NI6501READ",DeviceID}];


(*Rigol 5000 generator*)
DGINI::usage="Rigol DG5000 Initialize.\n ::Parameters::\n ProgS,\n CommandN";
DGINI[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"62","DGINI"}];
DGOUT::usage="Rigol DG5000 Output.\n ::Parameters::\n ProgS,\n CommandN, \n Channel: Channel number 0 or 1,\n State: 0-off,>0-on,\n Impedance: 1 Ohm-10 kOhm, load impedance used to calculate amplitudes,\n Polarity: 0-norm,1-inverted";
DGOUT[ProgS_,CommandN_,Channel_,State_,Impedance_,Polarity_(*0-norm,1-inv*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"61","DGOUT",Channel,State,Impedance,Polarity}];
DGWFM::usage="Rigol DG5000 waveform.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n Func: 0-sin,1-squar,2-pulse,3-ramp,4-noise,5-dc,6-SINC,7-GAUS,8-EXPR,9-EXPF,10-HAVERSINE,11-CARDIAC,12-LORENTZ,13-ARBPULSE,14-DUALTONE,15-USER\n Ampl,\n Offset,\n QFreqOrPeriod: Whether the next parameter is frequency(0) or period(1),\n FreqPeriod: Frequency or period";
DGWFM[ProgS_,CommandN_,Channel_,Func_(*0-sine, 2-pulse, 6-ARB1*),Ampl_,Offset_,QFreqOrPeriod_(*0-Freq,1-Per*),FreqPeriod_(*real*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"63","DGWFM",Channel,Func,Ampl,Offset,QFreqOrPeriod,FreqPeriod}];
DGPUL::usage="Rigol DG5000 set pulse params.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n Period: sec,\n Delay: in sec ,\n Width: in sec. Min = 4ns, Max = Period-12ns ,\n LeadEdge: in sec, 2.5ns-1ms, 2.5ns default,\n TrailEdge: in sec, 2.5ns default";
DGPUL[ProgS_,CommandN_,Channel_,Period_(*s*),Delay_,Width_,LeadEdge_:2.5*10^-9,TrailEdge_:2.5*10^-9(*s*)]:=ProgS<>"\n"<>PrintLine[{CommandN,"1059","DGPUL",Channel,Period,Delay,Width,LeadEdge,TrailEdge}];
DGBURST::usage="Rigol DG5000 configure burst.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: Channel number 0 or 1,\n State: 0-off(continious),>0-on,\n Mode: 0-trig,1-gate,2-infinite,\n BurstCount: 1-100M,0-inf burst,\n TrigSrc: 0-int,1-ext,2-manual,\n TrigPol: trigger/gate polarity. 0-positive, 1-negative, \n BurstDel: burst delay. 0-85ns, \n IntPeriod: in sec";
DGBURST[ProgS_,CommandN_,Channel_,State_,Mode_,BurstCount_,TrigSrc_,TrigPol_,BurstDel_,IntPeriod_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1060","DGBURST",Channel,State,Mode,BurstCount,TrigSrc,TrigPol,BurstDel,IntPeriod}];
DGTRG::usage="Rigol DG5000. Manual trigger. \n ::Parameters::\n ProgS,\n CommandN";
DGTRG[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1105","DGTRG"}];
DGARBVOL::usage="Rigol DG5000 load arb wfm from computer into device memory. The range of sample values in the input WFM is -1..+1, single precision float. Unit does not automatically rescale WFMs to fill the dynamic range. With rescale=8191 and offset=8192, the -1..+1 input WFM fills the DAC range \n ::Parameters::\n ProgS,\n CommandN, \n DestWFMNumber: Not used, wfm is uploaded into volatile,\n WFMSource: 0- waveforms as columns in one file,1- each wfm in a separte file with name NAME_nn, where nn is a wfm number,2- programmatic array of numbers,\n SrcWFMNumber: number of the column in the source wfm file, or number of the file, or number of the RAM WFM slot,\n SrcWFMLen: Length of the segment to be loaded, the remaining samples of the source WFM are ignored, must be a multiple of 2^14 Sa,\n RescFactor: rescaling factor to multiply src WFM before loading. Can be used to adapt old WFMs,\n WFMOffset: ARB offset.";
DGARBVOL[ProgS_,CommandN_,DestWFMNumber_(*positive number x*),WFMSource_,SrcWFMNumber_(*number of the column*),SrcWFMLen_(*length of the source WFM*),RescFactor_,WFMOffset_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1109","DGARBVOL",DestWFMNumber,WFMSource,SrcWFMNumber,SrcWFMLen,RescFactor,WFMOffset}];
DGCLK::usage="Rigol DG5000 configure reference clock 10 MHz.\n ::Parameters::\n ProgS,\n CommandN,\n Source: 0-int, 1-ext";
DGCLK[ProgS_,CommandN_,Source_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1110","DGCLK",Source}];



(*Tektronix AWG 5200 arb wfm generator*)
AWG52ARB::usage="AWG5200 config arb waveform.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Channel: Channel number 1 or 2,\n ARBNumber: >0 for WFM and <0 for Sequence - selects wfm from volatile memory (Wfm must be loaded first),\n Path: 0- DC high bandwith, 1- AC direct,\n Mode: 0- cont, 1-trig'd, 2- cont trig'd, 3-gated. Affects only WFM output, for Seq adjust WAIT of the 1st step,\n Ampl: 25-750mV for DCHB,  89.34..355.7mVpp for AC Dir,\n Offset: -2..2V,\n TRGSource: 0- A, 1- B, 2- internal,\n WaitValue: 0- wait at 0, 1- wait at first point. Only for trig'd/gated modes,\n SeqTrack: Track number for sequence playout only";
AWG52ARB[ProgS_,CommandN_,DeviceID_,Channel_,ARBNumber_,Path_,Mode_,Ampl_,Offset_,TRGSource_,WaitValue_,SeqTrack_]:=ProgS<>"\n"<>PrintLine[{CommandN,"84","AWG52ARB",DeviceID,Channel,ARBNumber,Path,Mode,Ampl,Offset,TRGSource,WaitValue,SeqTrack}];
AWG52CLK::usage="AWG5200 config clock.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n SRate: Sampling rate 298 S/s.. 2.5 GS/s,\n Source: 0- internal, 1- ext fixed, 2- ext var Ref, 3- ext clock,\n ClkOutput: >0 Clock Output,\n SyncClkOutput: >0 Sync Clock Output";
AWG52CLK[ProgS_,CommandN_,DeviceID_,SRate_,Source_,ClkOutput_,SyncClkOutput_]:=ProgS<>"\n"<>PrintLine[{CommandN,"85","AWG52CLK",DeviceID,SRate,Source,ClkOutput,SyncClkOutput}];
AWG52DAC::usage="AWG5200 config DAC.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Resolution: 12-16bit, remaining bits are markers,\n Mode: 0- NRZ, 1- Mix, 2- RZ";
AWG52DAC[ProgS_,CommandN_,DeviceID_,Resolution_,Mode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"86","AWG52DAC",DeviceID,Resolution,Mode}];
AWG52INI::usage="AWG5200 reset.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200";
AWG52INI[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"87","AWG52INI",DeviceID}];
AWG52MODE::usage="AWG5200 config instrument mode.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Mode: 0- AWG, 1- Function generator";
AWG52MODE[ProgS_,CommandN_,DeviceID_,Mode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"88","AWG52MODE",DeviceID,Mode}];
AWG52OUT::usage="AWG5200 output On/Off.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Channel: Channel number 1 or 2,\n OnOff: >0 On";
AWG52OUT[ProgS_,CommandN_,DeviceID_,Channel_,OnOff_]:=ProgS<>"\n"<>PrintLine[{CommandN,"89","AWG52OUT",DeviceID,Channel,OnOff}];
AWG52TRGCONF::usage="AWG5200 configure trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Channel: 0- A, 1- B,\n Slope: 0- positive, 1- negative,\n IntPeriod: 1us..10s,\n TrgLevel: -5..+5V,\n Impedance: 50 or 1000 ohm ,\n Mode: 0- Sync(slow), 1- Async(fast). TRG B is locked to Sync (can be changed only in AWG5208). In Async mode some TRG events are lost!";
AWG52TRGCONF[ProgS_,CommandN_,DeviceID_,Channel_,Slope_,IntPeriod_,TrgLevel_,Impedance_,Mode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"90","AWG52TRGCONF",DeviceID,Channel,Slope,IntPeriod,TrgLevel,Impedance,Mode}];
AWG52ABORT::usage="AWG5200 abort trigger.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Channel: 0- A, 1- B";
AWG52ABORT[ProgS_,CommandN_,DeviceID_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"91","AWG52ABORT",DeviceID,Channel}];
AWG52TRG::usage="AWG5200 force trigger event.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n Channel: 0- A, 1- B";
AWG52TRG[ProgS_,CommandN_,DeviceID_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"92","AWG52TRG",DeviceID,Channel}];
AWG52RUN::usage="AWG5200 Run or Stop WFM output.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n RunStop: >0 RUN";
AWG52RUN[ProgS_,CommandN_,DeviceID_,RunStop_]:=ProgS<>"\n"<>PrintLine[{CommandN,"93","AWG52RUN",DeviceID,RunStop}];
AWG52ERARB::usage="AWG5200 delete all arb WFMs from volatile memory.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n VIType: >=0 - VISA, <0 - IVI.";
AWG52ERARB[ProgS_,CommandN_,DeviceID_,VIType_]:=ProgS<>"\n"<>PrintLine[{CommandN,"94","AWG52ERARB",DeviceID,VIType}];
AWG52ERSEQ::usage="AWG5200 delete all sequences from volatile memory.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200";
AWG52ERSEQ[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1084","AWG52ERSEQ",DeviceID}];
AWG52INIARB::usage="AWG5200 init arb WFMs in volatile memory under name ARBx. All sample values are initialized to 0. If WFM exists it will be overwritten.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n ARBNumber: WFM number >1,\n WFMLen: Waveform length, up to 2GS,\n VIType: >=0 - VISA, <0 - IVI.";
AWG52INIARB[ProgS_,CommandN_,DeviceID_,ARBNumber_,WFMLen_,VIType_]:=ProgS<>"\n"<>PrintLine[{CommandN,"95","AWG52INIARB",DeviceID,ARBNumber,WFMLen,VIType}];
AWG52INISEQ::usage="AWG5200 init sequence in volatile memory under name SEQx. \n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n SEQNumber: WFM number >1,\n SEQLen: seq length (number of steps),\n TrackNumber: number of tracks";
AWG52INISEQ[ProgS_,CommandN_,DeviceID_,SEQNumber_,SEQLen_,TrackNumber_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1085","AWG52INISEQ",DeviceID,SEQNumber,SEQLen,TrackNumber}];
AWG52SSTPAR::usage="AWG5200 set parameters for a sequence step. \n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n SEQNumber: WFM number >1,\n SEQStep: seq step number,\n Repeats: number of repeats for this step, inf if <=0,\n GOTO: 0 - NEXT, -1 - LAST, -2 - END, >0 - step number,\n JMPInp: Jump input 0-OFF, 1-Trg A, 2-TRG B, 3-Trg internal,\n JMPTO: 0 - NEXT, -1 - LAST, -2 - END, >0 - step number,\n WAIInp: Jump input 0-OFF, 1-Trg A, 2-TRG B, 3-Trg internal";
AWG52SSTPAR[ProgS_,CommandN_,DeviceID_,SEQNumber_,SEQStep_,Repeats_,GOTO_,JMPInp_,JMPTO_,WAIInp_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1086","AWG52SSTPAR",DeviceID,SEQNumber,SEQStep,Repeats,GOTO,JMPInp,JMPTO,WAIInp}];
AWG52SSTWFM::usage="AWG5200 set WFM for a sequence step. \n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n SEQNumber: WFM number >1,\n SEQStep: seq step number,\n TrackNumber: number of tracks,\n ARBNumber: >0 number of arb wfm, <0 number of subsequence";
AWG52SSTWFM[ProgS_,CommandN_,DeviceID_,SEQNumber_,SEQStep_,TrackNumber_,ARBNumber_]:=ProgS<>"\n"<>PrintLine[{CommandN,"1087","AWG52SSTWFM",DeviceID,SEQNumber,SEQStep,TrackNumber,ARBNumber}];
AWG52ARBVOL::usage="AWG5200 load arb wfm from computer into volatile memory under name ARBx. The range of sample values is -1..+1, single precision float. WFM must first be initialized with AWG52INIARB. AWG5200 does not automatically rescale WFMs to fill the dynamic range.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID, \n DestWFMNumber: positive number x, WFM will be loaded into ARBx,\n WFMSource: 0- waveforms as columns in one file,1- each wfm in a separte file with name NAME_nn, where nn is a wfm number,2- programmatic array of numbers,\n SrcWFMNumber: number of the column in the source wfm file, or number of the file, or number of the RAM WFM slot,\n SrcWFMLen: Length of the segment to be loaded, the remaining samples of the source WFM are ignored,\n DestWFMInd: Offset index in the destination waveform (0- start of the dest waveform). Can be used for fast generation of long WFMs with small number of nonzero samples,\n RescFactor: rescaling factor to multiply src WFM before loading. Can be used to adapt old WFMs,\n VIType: >=0 - VISA, <0 - IVI.";
AWG52ARBVOL[ProgS_,CommandN_,DeviceID_,DestWFMNumber_(*positive number x*),WFMSource_,SrcWFMNumber_(*number of the column*),SrcWFMLen_(*length of the source WFM*),DestWFMInd_(*length of the source WFM*),RescFactor_,VIType_]:=ProgS<>"\n"<>PrintLine[{CommandN,"96","AWG52ARBVOL",DeviceID,DestWFMNumber,WFMSource,SrcWFMNumber,SrcWFMLen,DestWFMInd,RescFactor,VIType}];
AWG52OPC::usage="AWG5200 *OPC? query, which can be used for synchronization.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 5200,\n VIType: >=0 - VISA, <0 - IVI, not implemented yet.";
AWG52OPC[ProgS_,CommandN_,DeviceID_,VIType_:1]:=ProgS<>"\n"<>PrintLine[{CommandN,"110","AWG52OPC",DeviceID,VIType}];


(*M8190 ARB WFM Generator*)
M8190TRACEDEFNEWQ::usage="M8190 Define a new segment & length\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Segment Length: Granularity 48 or 64 samples in 14 or 12 bit mode, length must be >= x5 granularity, \n Initial value";
M8190TRACEDEFNEWQ[ProgS_,CommandN_,Channel_,SegLength_,InitValue_]:=ProgS<>"\n"<>PrintLine[{CommandN,"120","M8190TRACEDEFNEWQ",Channel,SegLength,InitValue}];
M8190DAC::usage="M8190 Change DAC Settings \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Mode, 0 - DNRZ, 1 - NRZ, 2 - RZ, 3 - DOUB,  \n Resolution, 0 - 12-bit, 1 - 14-bit,  \n Output Path, 0 - DAC, 1 - DC, 2 - AC";
M8190DAC[ProgS_,CommandN_,Channel_,Mode_,Resolution_,OutputPath_]:=ProgS<>"\n"<>PrintLine[{CommandN,"121","M8190DAC",Channel,Mode,Resolution,OutputPath}];
M8190VOLT::usage="M8190 Change output voltage settings  \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Amplitude +0.35 .. +0.7(V), \n Offset -0.02 .. +0.02 (V)";
M8190VOLT[ProgS_,CommandN_,Channel_,Voltage_,Offset_]:=ProgS<>"\n"<>PrintLine[{CommandN,"122","M8190VOLT",Channel,Voltage,Offset}];
M8190CONFTRIG::usage="M8190 Configure Trigger Setting - Don't use, use individual commands instead. \n ::Parameters::\n ProgS,\n CommandN,\n Advancement Source: Select system controlling triggers, 0 - TRIG, 1 - EVEN, 2 - INT, \n Internal Frequency (Hz), \n Trigger Source, 0 - EXT, 1 - INT, \n Trigger Mode (V), 0 - Triggered, 1 - Gated, 2 - Continuous, \n Trigger Level (V), \n Input Impedence, 0 - Low, 1 - High, \n Trigger Polarity, 0 - Positive, 1 - Negative, 2 - Either, \n Event Level (V), Event Impedence, 0 - Low, 1 - High, \n Event Polarity, 0 - Positive, 1 - Negative, 2 - Either, \n Trigger HWD Ch1, 0 - True, 1 - False, \n Trigger HWD Ch2, 0 - True, 1 - False";
M8190CONFTRIG[ProgS_,CommandN_,AdvSource_,IntFreq_,TRGSource_,TRGMode_,TRGLev_,InpImp_,TRGPol_,TRGHWD1_,TRGHWD2_]:=ProgS<>"\n"<>PrintLine[{CommandN,"123","M8190CONFTRIG",AdvSource,IntFreq,TRGSource,TRGMode,TRGLev,InpImp,TRGPol,TRGHWD1,TRGHWD2}];
M8190OUTPUT::usage="M8190 Turn output On/Off\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2,\n OutputSelect (effective only for DC option): 0 - Normal (affects both dir and inv connectors in DAC mode), 1 - Complementary, \n OutputEnable: 0- Off, 1 - On";
M8190OUTPUT[ProgS_,CommandN_,Channel_,OutputSelect_,OutputEnable_]:=ProgS<>"\n"<>PrintLine[{CommandN,"124","M8190OUTPUT",Channel,OutputSelect,OutputEnable}];
M8190WFMTYPE::usage="M8190 Change WFM Mode for each channel \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2,\n Mode, 0 - ARB, 1 - Sequence, 2 - Scenario";
M8190WFMTYPE[ProgS_,CommandN_,Channel_,Mode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"125","M8190WFMTYPE",Channel,Mode}];
M8190INITIMM::usage="M8190 Start signal generation (play) on a specific channel after waveforms are set \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2";
M8190INITIMM[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"126","M8190INITIMM",Channel}];
M8190TRACESEL::usage="M8190 Trace or sequence selection for a specific channel (select arb waveform to output). \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Ass\:0443\:0435Number: number of WFM (from 0) or SEQ (from 0) to play out, \n AssetType: 0 - ARB WFM (default), 1 - SEQuence";
M8190TRACESEL[ProgS_,CommandN_,Channel_,AssetNumber_,AssetType_:0]:=ProgS<>"\n"<>PrintLine[{CommandN,"127","M8190TRACESEL",Channel,AssetNumber,AssetType}];
M8190TRACEADV::usage="M8190 Trace advancement mode for a specific channel \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Select Trace Advancement Mode: 0 - Auto (use this when there is no sequencing), 1 - Cond, 2 - Rep, 3 - Sing";
M8190TRACEADV[ProgS_,CommandN_,Channel_,AdvMode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"128","M8190TRACEADV",Channel,AdvMode}];
M8190SAMPLEFREQ::usage="M8190 Sample frequency and reference clock settings \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n Sample Clock Source: 0 - INT, 1 - EXT, \n Reference Clock Source: 0 - INT, 1 - EXT, \n Internal Sample Frequency (Hz), \n External Sample Frequency (Hz), \n Reference Clock Input Frequency (Hz)";
M8190SAMPLEFREQ[ProgS_,CommandN_,Channel_,SampleClkSource_,RefClkSource_,IntSampFreq_,ExtSampFreq_,RefClkInputFreq_]:=ProgS<>"\n"<>PrintLine[{CommandN,"129","M8190SAMPLEFREQ",Channel,SampleClkSource,RefClkSource,IntSampFreq,ExtSampFreq,RefClkInputFreq}];
M8190TRACEDELALL::usage="M8190 Delete all stored traces for a specific channel \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2";
M8190TRACEDELALL[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"130","M8190TRACEDELALL",Channel}];
M8190ARBVOLLOAD::usage="M8190 load arb wfm from computer into volatile memory. Uses adapted AWG5200 VI  + command\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2, \n DestWFMNumber: positive number x, WFM will be loaded into ARBx,\n WFMSource: 0- waveforms as columns in one file,1- each wfm in a separte file with name NAME_nn, where nn is a wfm number,2- programmatic array of numbers,\n SrcWFMNumber: number of the column in the source wfm file, or number of the file, or number of the RAM WFM slot,\n SrcWFMLen: Length of the segment to be loaded, the remaining samples of the source WFM are ignored,\n DestWFMInd: Offset index in the destination waveform (0- start of the dest waveform). Can be used for fast generation of long WFMs with small number of nonzero samples,\n RescFactor: rescaling factor to multiply src WFM before loading. Can be used to adapt old WFMs";
M8190ARBVOLLOAD[ProgS_,CommandN_,Channel_,DestWFMNumber_(*positive number x*),WFMSource_,SrcWFMNumber_(*number of the column*),SrcWFMLen_(*length of the source WFM*),DestWFMInd_(*length of the source WFM*),RescFactor_]:=ProgS<>"\n"<>PrintLine[{CommandN,"131","M8190ARBVOLLOAD",Channel,DestWFMNumber,WFMSource,SrcWFMNumber,SrcWFMLen,DestWFMInd,RescFactor}];
M8190OPC::usage="M8190 *OPC? query, which can be used for synchronization.\n ::Parameters::\n ProgS,\n CommandN,";
M8190OPC[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"132","M8190OPC"}];
M8190ABORT::usage="M8190 abort trigger.\n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2";
M8190ABORT[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"133","M8190ABORT",Channel}];
M8190TRGLEV::usage="M8190 Configure Trigger Setting \n ::Parameters::\n ProgS,\n CommandN,\n Internal Frequency (Hz), \n Trigger Level threshold -5..+5 (V), \n Input Impedence, 0 - Low (50 Ohm), 1 - High (1 kOhm),\n Trigger Polarity, 0 - Positive, 1 - Negative, 2 - Either,\n Event Level threshold -5..+5 (V),\n Event Impedence, 0 - Low, 1 - High,\n Event Polarity, 0 - Positive, 1 - Negative, 2 - Either";
M8190TRGLEV[ProgS_,CommandN_,IntFreq_,TRGLev_,TRGImp_,TRGPol_,EVENLev_,EVENImp_,EVENPol_]:=ProgS<>"\n"<>PrintLine[{CommandN,"134","M8190TRGLEV",IntFreq,TRGLev,TRGImp,TRGPol,EVENLev,EVENImp,EVENPol}];
M8190CONFADV::usage="M8190 Configure Advancement event settings \n ::Parameters::\n ProgS,\n CommandN,\n Advancement Source: 0 - TRIG, 1 - EVEN, 2 - INT,\n Advance Event Hardware Disable (Disabling one disables both) : 0 - HWDisable Off, 1 - HWDisable On";
M8190CONFADV[ProgS_,CommandN_,AdvSource_,ADVHWD_]:=ProgS<>"\n"<>PrintLine[{CommandN,"135","M8190CONFADV",AdvSource,ADVHWD}];
M8190CONFENAB::usage="M8190 Configure Enable Event Setting \n ::Parameters::\n ProgS,\n CommandN,\n Enable Source: 0 - TRIG, 1 - EVEN,\n Enable Event 1 Hardware Disable (Disabling one disables both) : 0 - HWDisable Off, 1 - HWDisable On, \n Enable Event 2 Hardware Disable : 0 - HWDisable Off, 1 - HWDisable On";
M8190CONFENAB[ProgS_,CommandN_,EnabSource_,ENABHWD_]:=ProgS<>"\n"<>PrintLine[{CommandN,"136","M8190CONFENAB",EnabSource,ENABHWD}];
M8190CONFTRIG::usage="M8190 Configure Trigger Setting \n ::Parameters::\n ProgS,\n CommandN,\n Trigger Event Source: 0 - TRIG, 1 - INT,\n Enable Trigger Hardware Disable : 0 - HWDisable Off, 1 - HWDisable On";
M8190CONFTRIG[ProgS_,CommandN_,TRGSource_,TRGHWD_]:=ProgS<>"\n"<>PrintLine[{CommandN,"137","M8190CONFTRIG",TRGSource,TRGHWD}];
M8190TRIGMODE::usage="M8190 Configure Trigger Setting \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2,\n Trigger Mode: 0 - Triggered, 1 - Gated, 2 - Continuous";
M8190TRIGMODE[ProgS_,CommandN_,Channel_,TRGMode_]:=ProgS<>"\n"<>PrintLine[{CommandN,"138","M8190CONFTRIG",Channel,TRGMode}];
M8190TRIG::usage="M8190 Send trigger/begin command in Triggered mode to channel \n ::Parameters::\n ProgS,\n CommandN, \n Channel: 1 - Ch1, 2 - Ch2";
M8190TRIG[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"139","M8190TRIG",Channel}];
M8190GATE::usage="M8190 Send Gate Open/Closed (On/Off) in Gated mode to channel \n ::Parameters::\n ProgS,\n CommandN, \n Channel: 1 - Ch1, 2 - Ch2, \n Gate: True - Open, False - Closed";
M8190GATE[ProgS_,CommandN_,Channel_,Gate_]:=ProgS<>"\n"<>PrintLine[{CommandN,"140","M8190GATE",Channel,Gate}];
M8190ADV::usage="M8190 Send Advancement command to channel \n ::Parameters::\n ProgS,\n CommandN, \n Channel: 1 - Ch1, 2 - Ch2";
M8190ADV[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"141","M8190ADV",Channel}];
M8190ENAB::usage="M8190 Send Enable command to channel  \n ::Parameters::\n ProgS,\n CommandN, \n Channel: 1 - Ch1, 2 - Ch2";
M8190ENAB[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"142","M8190ENAB",Channel}];
M8190INIT::usage="M8190 Initialise: Can take up to 20 secs \n ::Parameters::\n ProgS,\n CommandN";
M8190INIT[ProgS_,CommandN_]:=ProgS<>"\n"<>PrintLine[{CommandN,"143","M8190INIT"}];
M8190SEQSTEP::usage="M8190 add or modify a step in the sequence table \n ::Parameters::\n ProgS,\n CommandN, \n Channel: 1 - Ch1, 2 - Ch2,\n SeqTabInd - Sequence table entry ID to be made/modified Starting from 0, \n SegmID - ID of generated waveform to be used in sequence entry starting from 1, \n SegmLoopCnt - number of times a segment is repeated, \n StartAddress - starting address within the WFM to bue used at this sequence step, \n EndAddress - 4294967295 to use full waveform, \n MarkerNewSeq - 0 - normal sequence entry, 1 - entry is the start of the sequence ,\n MarkerEndSeq - 0 - normal sequence entry, 1 - entry is the end of the sequence, \n SeqLoopCnt - number of times the whole sequence is repeated";
M8190SEQSTEP[ProgS_,CommandN_,Channel_,SeqTabInd_,SegmID_,SegmLoopCnt_,StartAddress_,EndAddress_,MarkerNewSeq_,MarkerEndSeq_,SeqLoopCnt_]:=ProgS<>"\n"<>PrintLine[{CommandN,"145","M8190SEQSTEP",Channel,SeqTabInd,SegmID,SegmLoopCnt,StartAddress,EndAddress,MarkerNewSeq,MarkerEndSeq,SeqLoopCnt}];
M8190SEQDELALL::usage="M8190 Delete all stored sequences for a specific channel \n ::Parameters::\n ProgS,\n CommandN,\n Channel: 1 - Ch1, 2 - Ch2";
M8190SEQDELALL[ProgS_,CommandN_,Channel_]:=ProgS<>"\n"<>PrintLine[{CommandN,"146","M8190SEQDELALL",Channel}];

(*
:TRIGger[:SEQuence][:STARt]:BEGin[1|2][:IMMediate] - immediate trigger (software)
Trigger: 1 via for trigger amplitudes etc
3 vis:
1 for trig/gate of the channels
1 for adv event
1 for enable event*)



VISAOPEN::usage="Open VISA connection.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 33600 - AGI33600";
VISAOPEN[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"97","VISAOPEN",DeviceID}];
VISACLOSE::usage="Close VISA connection.\n ::Parameters::\n ProgS,\n CommandN,\n DeviceID: 33600 - AGI33600";
VISACLOSE[ProgS_,CommandN_,DeviceID_]:=ProgS<>"\n"<>PrintLine[{CommandN,"98","VISACLOSE",DeviceID}];


EndPackage[]
