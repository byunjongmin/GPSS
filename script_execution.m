%% Script for the execution of the GPSS

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

OUTPUT_SUBDIRn = '20240430_1930';
paramFileName = strcat('parameter_',OUTPUT_SUBDIRn,'.txt');

GPSSMain_Hy(paramFileName)

%% Analyze Results using AnalyseResultGeneral function in GPSS

% Preparation: clear figures
clf(figure(2))
clf(figure(3))
clf(figure(4))
% clf(figure(10))
clf(figure(11))
clf(figure(12))
clf(figure(13))
clf(figure(15))
clf(figure(20))
% clf(figure(31))
clf(figure(32))
clf(figure(33))
clf(figure(34))
clf(figure(35))
% clf(figure(36))
% clf(figure(37))
% clf(figure(38))
clf(figure(39))
clf(figure(40))
clf(figure(41))
% clf(figure(42))
clf(figure(43))

% Define ouput directory and input variable file
% 개선할 사항 : 'D:\WorkSpace\Project\GPSS_Data\GPSS2D' 에 저장한 결과도
% 분석할 수 있도록 만들 것

OUTPUT_SUBDIRn = '20240430_1905';
paramFileName = strcat('parameter_',OUTPUT_SUBDIRn,'.txt');

majorOutputs = AnalyseResultGeneral(OUTPUT_SUBDIRn ... % 분석 폴더
    ,paramFileName ... % 분석 결과 변수 파일
    ,1 ... % GRAPH_INTERVAL 모의결과가 기록된 파일에서 그래프를 보여주는 간격
    ,1 ... % startedTimeStepNo 그래프 출력 시점 (예. 초기 지형부터 할 경우, 1)
    ,1 ... % achievedRatio 총 모의기간중 결과가 나온 부분의 비율
    ,1 ... % EXTRACT_INTERVAL (그래프를 보여주는 동안) (2차원) 주요 변수를 저장하는 간격
    ,true ...   % SHOW_GRAPH 주요 결과를 그래프로 보여줄 것인지를 지정함 (예. true, 보여줌; false, 보여주지 않고 기록 저장만 함)
    ,0.5); % pauseTime pause moment for redrawing figures (예. 0.5, 0.5초 쉬었다가 그래프를 보여줌)

% %% Analyze Results using TopoToolbox

% Variables

% output results of TopoToolbox GRIDobj
% [finalSedThick,finalBedElev] = ToGRIDobj(majorOutputs);
[sedThickGRIDobjArray,bedElevGRIDobjArray] = ToGRIDobjArray(majorOutputs);

% critical upslope cells number
criticalUpslopeCellsNo = majorOutputs.criticalUpslopeCellsNo;

% %% Analyze the final result

finalResultNo = majorOutputs.totalExtractTimesNo + 1;

finalDEM = bedElevGRIDobjArray(finalResultNo)  ... % DEM of the final result
            + sedThickGRIDobjArray(finalResultNo);

% Visualize the DEM
% figure(31)
% imagesc(finalDEM); colorbar

figure(32)
[Z,x,y] = GRIDobj2mat(finalDEM); surf(x,y,double(Z))

% Calculate Gradient
G = gradient8(finalDEM);

figure(33);
imageschs(finalDEM,G ...
    ,'ticklabel','nice' ...
    ,'colorbarylabel','Slope [-]'); % 'caxis',[0 0.5]

% Visualize flow accumulation across the DEM
DEMf = fillsinks(finalDEM);
FD = FLOWobj(DEMf,"preprocess","carve");
A = flowacc(FD);

figure(34);
imageschs(finalDEM,sqrt(A) ...
    ,'colormap',flipud(copper) ...
    ,'colorbarylabel','Flow accumulation [sqrt(# of pixels)]'...
    ,'ticklabels','nice');

% Extract drainage basins in the DEM
DB = drainagebasins(FD);
DB = shufflelabel(DB);
nrDB = numel(unique(DB.Z(:)))-1; % nr of drainage basins
STATS = regionprops(DB.Z,'PixelIdxList','Area','Centroid');
figure(35);
imageschs(finalDEM,DB ...
    ,'colorbar',false,'ticklabel','nice');
hold on
for run = 1:nrDB
    if STATS(run).Area*DB.cellsize^2 > 10e6
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

% Calculate flow distance from the oulets
D = flowdistance(FD);
D = D/1000; % from meter to kilometer
% figure(36);
% imageschs(finalDEM,D ...
%     ,'ticklabel','nice' ...
%     ,'colorbarylabel','Flow distance [km]')

% Extract stream network over the DEM

% A = flowacc(FD); % calculate flow accumulation
% Note that flowacc returns the number of cells draining in a cell.
% Here we choose a minimum drainage area of criticalUpslopeCellsNo
W = A>criticalUpslopeCellsNo;
% create an instance of STREAMobj
S = STREAMobj(FD,W);

% figure(37);
% plot(S);
% axis image;

% S = klargestconncomps(S,1);
% figure(38);
% plot(S); axis image;

figure(39);
plotdz(S,finalDEM)

figure(40);
imageschs(finalDEM);
hold on
plot(S,'k')
hold off

% Slope-area relationship of the final results
figure(41)
STATS = slopearea_byun(S,finalDEM,A);

% Calculate normalized channel steepness index
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

% %% Export GPSS results into GIS-SW compatible formats
% 개선할 사항 : 지표 고도외에도 퇴적층 두께를 살펴볼 수도 있음

% 출력 디렉터리 만들기
DATA_DIR = 'data';      % 입출력 파일을 저장하는 최상위 디렉터리
OUTPUT_DIR = 'output';  % 출력 파일을 저장할 디렉터리
OUTPUT_SUBDIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR,OUTPUT_SUBDIRn);

EXPORT_DIR = 'Export';  % 2차 분석을 위한 결과 폴더
mkdir(OUTPUT_SUBDIR_PATH,EXPORT_DIR);

OUTPUT_SUBDIR_RASTER_PATH = fullfile(OUTPUT_SUBDIR_PATH,EXPORT_DIR);
EXPORT_RASTERGRID_DIR = 'Raster';  % 2차 분석을 위한 결과 폴더
mkdir(OUTPUT_SUBDIR_RASTER_PATH,EXPORT_RASTERGRID_DIR);


finalResultNo = majorOutputs.totalExtractTimesNo + 1;

for i=1:finalResultNo

    % surface elevation data
    ithDEM = bedElevGRIDobjArray(i) + sedThickGRIDobjArray(i);

    % Export into ESRI ascii raster type data
    ithDEMFileName = strcat(num2str(i),'_DEM.asc');
    EXPORT_RASTERGRID_PATH = fullfile(OUTPUT_SUBDIR_RASTER_PATH,EXPORT_RASTERGRID_DIR,ithDEMFileName);
    
    GRIDobj2ascii(ithDEM,EXPORT_RASTERGRID_PATH)
    % 주의 : GRIDobj2geotiff(ithDEM,EXPORT_RASTERGRID_PATH)을 사용하는 것이 쉽지 않음

end

% %% 점이적 경관 확인하기

clf(figure(52))
clf(figure(53))

extractNo = finalResultNo; % 추출할 단면 개수
pauseTime = 1;
maxElev = 500;

finalResultNo = majorOutputs.totalExtractTimesNo + 1;
intervalNo = round(finalResultNo/extractNo);
for i=1:intervalNo:finalResultNo

    % surface elevation
    ithDEM = bedElevGRIDobjArray(i) + sedThickGRIDobjArray(i);
    
    % flow accumulation
    DEMf = fillsinks(ithDEM);
    FD = FLOWobj(DEMf,"preprocess","carve");
    A = flowacc(FD);
    % Note that flowacc returns the number of cells draining in a cell.
    % Here we choose a minimum drainage area of criticalUpslopeCellsNo
    W = A > criticalUpslopeCellsNo;
    % create an instance of STREAMobj
    S = STREAMobj(FD,W);
    St = trunk(S); % only for a main trunk
    
    figure(52)

    % Draw the maintrunk for the domain
    subplot(2,1,1)
    imageschs(ithDEM ... % DEM for making hillshade
            ,ithDEM ... % coloring matrix (or GRIDobj)
            ,'caxis',[0 maxElev]); % a vector for defining elevation range 
    hold on
    plot(St,'k') % Draw the maintrunk
   
    % Draw the longitudinal profile of the main trunk
    subplot(2,1,2)
    plotdz(St,ithDEM)
    hold on
    ylim([0 maxElev])
    legend('Location','eastoutside')

    pause(pauseTime) % pause redrawing figure for n seconds

    
    % Draw slope-area relationship
    figure(53)
    STATS = slopearea_byun(S,ithDEM,A);

    pause(pauseTime) % pause redrawing figure for n seconds


end


% %% GPSS 모의 결과를 시간에 따른 동영상으로 저장하기

DATA_DIR = 'data';      % 입출력 파일을 저장하는 최상위 디렉터리
OUTPUT_DIR = 'output';  % 출력 파일을 저장할 디렉터리
OUTPUT_SUBDIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR,OUTPUT_SUBDIRn);
EXPORT_DIR = 'Export';  % 2차 분석을 위한 결과 폴더
mkdir(OUTPUT_SUBDIR_PATH,EXPORT_DIR);

exportVideoFileName = 'DEM_changes.avi';
EXPORT_FILE_PATH = fullfile(OUTPUT_SUBDIR_PATH,EXPORT_DIR,exportVideoFileName);

% Use a VideoWriter object to create a video file from an array
v = VideoWriter(EXPORT_FILE_PATH); % create a VideoWriter object
open(v); % open the file associated with v for writing

% Draw an initial plot
h = figure(61);
initDEM = bedElevGRIDobjArray(1) + sedThickGRIDobjArray(1);
% surface plot for GRIDobj
surf(initDEM ... % digital elevation model (GRIDobj)
    ,initDEM ... % grid to define color (GRIDobj)
    ,'exaggerate',10) % height exaggeration, default = 1
title('Initial Plot');
clim([0 maxElev])
zlim([0 maxElev])
colorbar


frame = getframe(h); % Capture figure as movie frame
writeVideo(v, frame); % Write the captured frame to the file

% Make changes in figures and record them
for i=2:finalResultNo

    ithDEM = bedElevGRIDobjArray(i) + sedThickGRIDobjArray(i);
    % surface plot for GRIDobj
    surf(ithDEM ... % digital elevation model (GRIDobj)
        ,ithDEM ... % grid to define color (GRIDobj)
    ,'exaggerate',10) % height exaggeration, default = 1
    title(['Change ' num2str(i)]);
    clim([0 maxElev])
    zlim([0 maxElev])
    colorbar
    
    drawnow; % Update figures to see the modified graph immediately
    frame = getframe(h); % Capture figure as movie frame
    writeVideo(v, frame); % Write the captured frame to the file

end

close(v); % Close the video writer object






