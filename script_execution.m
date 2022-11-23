%% script for the execution of the GPSS

%% Compile GPSS MEX file
mex -v CollapseMex.c
mex -v EstimateDElevByFluvialProcess.c
mex -v EstimateDElevByFluvialProcessBySDS.c
mex -v EstimateUpstreamFlow.c
mex -v EstimateUpstreamFlowBySDS.c
mex -v EstimateSubDTMex.c
mex -v EstimateUpstreamFlow.c
mex -v HillslopeProcessMex.c

% profile on

%% Run GPSS

% GPSSMain_Hy('parameter_20200214_1230.txt')
% GPSSMain_Hy('parameter_20221121_1800.txt')
% GPSSMain_Hy('parameter_20221121_2310.txt')
GPSSMain_Hy('parameter_20221122_1700.txt')
GPSSMain_Hy('parameter_20221122_1823.txt')


%% Analyze Results
AnalyseResultGeneral('20221121_1800','parameter_20221121_1800.txt',1,1,1,1,1);