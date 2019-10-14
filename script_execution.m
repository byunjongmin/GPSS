% script for the execution of the GPSS

mex -v CollapseMex.c
mex -v EstimateDElevByFluvialProcess.c
mex -v EstimateDElevByFluvialProcessBySDS.c
mex -v EstimateSubDTMex.c
mex -v EstimateUpstreamFlow.c
mex -v HillslopeProcessMex.c

profile on
GPSSMain_Hy('parameter_20160306_1208.txt')