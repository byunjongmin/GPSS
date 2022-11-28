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
% GPSSMain_Hy('parameter_20221122_1700.txt')
% GPSSMain_Hy('parameter_20221122_1823.txt')
% GPSSMain_Hy('parameter_20221125_1920.txt')
% GPSSMain_Hy('parameter_20221125_1925.txt')
GPSSMain_Hy('parameter_20221127_1510.txt')


%% Analyze Results

% clear figures
clf(figure(3))
clf(figure(4))
clf(figure(10))
clf(figure(11))
clf(figure(12))
clf(figure(13))
clf(figure(15))
clf(figure(20))

majorOutputs = AnalyseResultGeneral('20221121_1800','parameter_20221121_1800.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221121_2310','parameter_20221121_2310.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221122_1700','parameter_20221122_1700.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221123_1600','parameter_20221123_1600.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221123_1915','parameter_20221123_1915.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221123_1920','parameter_20221123_1920.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221125_1840','parameter_20221125_1840.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221125_1903','parameter_20221125_1903.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221125_1920','parameter_20221125_1920.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221127_1510','parameter_20221127_1510.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221127_1515','parameter_20221127_1515.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221127_1523','parameter_20221127_1523.txt',1,1,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221127_1525','parameter_20221127_1525.txt',1,0.8,1,1,1);
% majorOutputs = AnalyseResultGeneral('20221128_0630','parameter_20221128_0630.txt',1,0.8,1,1,1);

%% Analyze Results using TopoToolbox

[finalSedThick,finalBedElev] = ToGRIDobj(majorOutputs);
finalDEM = finalBedElev + finalSedThick;

% gradient
G = gradient8(finalDEM);
figure(33);
imageschs(finalDEM,G ...
    ,'ticklabel','nice' ...
    ,'colorbarylabel','Slope [-]'); % 'caxis',[0 0.5]

% flow accumulation
DEMf = fillsinks(finalDEM);
FD = FLOWobj(DEMf);
A = flowacc(FD);
figure(34);
imageschs(finalDEM,dilate(sqrt(A),ones(5)) ...
    ,'colormap',flipud(copper) ...
    ,'colorbarylabel','Flow accumulation [sqrt(# of pixels)]'...
    ,'ticklabels','nice');

% drainage basin
DB = drainagebasins(FD);
DB = shufflelabel(DB);
nrDB = numel(unique(DB.Z(:)))-1; % nr of drainage basins
STATS = regionprops(DB.Z,'PixelIdxList','Area','Centroid');
figure(35);
imageschs(finalDEM,DB ...
    ,'colorbar',false,'ticklabel','nice');
hold on
for run = 1:nrDB;
    if STATS(run).Area*DB.cellsize^2 > 10e6;
        [x,y] = ind2coord(DB,...
        sub2ind(DB.size,...
        round(STATS(run).Centroid(2)),...
        round(STATS(run).Centroid(1))));
        text(x,y,...
        num2str(round(STATS(run).Area * DB.cellsize^2/1e6)),...
        'BackgroundColor',[1 1 1]);
    end
end
hold off

% flow distance
D = flowdistance(FD);
D = D/1000; % from meter to kilometer
figure(36);
imageschs(finalDEM,D ...
    ,'ticklabel','nice' ...
    ,'colorbarylabel','Flow distance [km]')

% stream network

% A = flowacc(FD); % calculate flow accumulation
% Note that flowacc returns the number of cells draining
% in a cell. Here we choose a minimum drainage area of 10000 cells.
W = A>2;
% create an instance of STREAMobj
S = STREAMobj(FD,W);

figure(37);
plot(S);
axis image;

S = klargestconncomps(S,1);
figure(38);
plot(S); axis image;

figure(39);
plotdz(S,finalDEM)

figure(40);
imageschs(finalDEM);
hold on
plot(S,'k')
hold off

% slope-area relationship
figure(41)
STATS = slopearea(S,finalDEM,A);


g = gradient(S,finalDEM);
a = getnal(S,A)*A.cellsize^2;
ksn = g./(a.^STATS.theta);

% normalized steepness index
figure(42);
plotc(S,ksn)
colormap(jet)
caxis([0 100])
h = colorbar;
h.Label.String = 'KSN';
box on
axis image

ksna = aggregate(S,ksn,'seglength',1000);
figure(43)
plotc(S,ksna)
caxis([0 100])
h = colorbar;
colormap(jet)
h.Label.String = 'KSN';
box on
axis image

