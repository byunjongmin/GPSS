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
OUTPUT_SUBDIRn = '20240424_2030';
paramFileName = strcat('parameter_',OUTPUT_SUBDIRn,'.txt');

GPSSMain_Hy(paramFileName)

%% Analyze Results

% Preparation

% clear figures
clf(figure(3))
clf(figure(4))
clf(figure(10))
clf(figure(11))
clf(figure(12))
clf(figure(13))
clf(figure(15))
clf(figure(20))
clf(figure(31))
clf(figure(32))
clf(figure(33))
clf(figure(34))
clf(figure(35))
clf(figure(36))
clf(figure(37))
clf(figure(38))
clf(figure(39))
clf(figure(40))
clf(figure(41))
clf(figure(42))
clf(figure(43))

% ouput directory and input variable file
% 추후 다음 폴더 'D:\WorkSpace\Project\GPSS_Data\GPSS2D' 에 저장한 것도
% 분석할 수 있도록 만들 것
OUTPUT_SUBDIRn = '20240425_2040';
paramFileName = strcat(OUTPUT_DIRn,'parameter_',OUTPUT_SUBDIRn,'.txt');

majorOutputs = AnalyseResultGeneral(OUTPUT_SUBDIRn,paramFileName,1,1,1,1,1);

%% Analyze Results using TopoToolbox

% Variables

% output results of TopoToolbox GRIDobj
[finalSedThick,finalBedElev] = ToGRIDobj(majorOutputs);
% critical upslope cells number
criticalUpslopeCellsNo = majorOutputs.criticalUpslopeCellsNo;

% Vizualize the final result

% DEM
finalDEM = finalBedElev + finalSedThick;

figure(31)
imagesc(finalDEM); colorbar

figure(32)
[Z,x,y] = GRIDobj2mat(finalDEM); surf(x,y,double(Z))

% Gradient
G = gradient8(finalDEM);

figure(33);
imageschs(finalDEM,G ...
    ,'ticklabel','nice' ...
    ,'colorbarylabel','Slope [-]'); % 'caxis',[0 0.5]

% Flow accumulation
DEMf = fillsinks(finalDEM);
FD = FLOWobj(DEMf,"preprocess","carve");
A = flowacc(FD);

figure(34);
imageschs(finalDEM,sqrt(A) ...
    ,'colormap',flipud(copper) ...
    ,'colorbarylabel','Flow accumulation [sqrt(# of pixels)]'...
    ,'ticklabels','nice');

% Drainage basin
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

% Flow distance
D = flowdistance(FD);
D = D/1000; % from meter to kilometer
figure(36);
imageschs(finalDEM,D ...
    ,'ticklabel','nice' ...
    ,'colorbarylabel','Flow distance [km]')

% Stream network

% A = flowacc(FD); % calculate flow accumulation
% Note that flowacc returns the number of cells draining in a cell.
% Here we choose a minimum drainage area of criticalUpslopeCellsNo
W = A>criticalUpslopeCellsNo;
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

% Slope-area relationship
figure(41)
STATS = slopearea_byun(S,finalDEM,A);

% Normalized steepness index
g = gradient(S,finalDEM);
a = getnal(S,A)*A.cellsize^2;
ksn = g./(a.^STATS.theta);

% figure(42);
% plotc(S,ksn)
% colormap(jet)
% h = colorbar;
% h.Label.String = 'ksn';
% box on
% axis image

ksna = aggregate(S,ksn,'seglength',1000);
figure(43); clf;
plotc(S,ksna)
% caxis([0 100])
colormap(jet)
h = colorbar;
h.Label.String = 'KSN';
box on
axis image