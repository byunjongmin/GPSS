% =========================================================================
%> @section INTRO AnalyseFinalResult
%>
%> 서로 다른 조건의 모의실험 결과를 비교하여 분석하는 함수.
%> AnalyseResult 함수의 출력변수 majorOutputs를 읽어들임.
%>
%> 분석 내용
%>  - 1. 최종 모의결과 고도비교
%>  - 2. 대표 유역을 선정하고, 이의 하천종단곡선, 분수계고도분포, 힙소메트리곡선, 
%>    Area-Slope, Elevation-Slope 분산도를 작성함
%>  - 3. 소규모 횡단상의 고도 변화
%>
%> @version 0.02
%> @see 
%> @retval
%>
%> @param OUTPUT_SUBDIR             : 최종 모의결과가 저장된 디렉터리 (*주의:셀,열우선 정리. 예{'100831_1501';'100831_1507';'100831_1513'})
%> @param mRows                     : 모형 영역 행 개수
%> @param nCols                     : 모형 영역 열 개수
%>
%> * Example
%> - AnalyseFinalResult({'100831_1501';'100831_1507';'100831_1513'},102,52)
%>
% =========================================================================
function AnalyseFinalResult(OUTPUT_SUBDIRs,mRows,nCols)
%
% function AnalyseFinalResult
%

%--------------------------------------------------------------------------
DATA_DIR = 'data';                  % 입출력 파일을 저장하는 최상위 디렉터리
OUTPUT_DIR = 'output';              % 출력 파일을 저장할 디렉터리
[totalSubDirs,tmpNCols]= size(OUTPUT_SUBDIRs);

sedimentThick = zeros(mRows,nCols,totalSubDirs);
bedrockElev = zeros(mRows,nCols,totalSubDirs);
upslopeArea = zeros(mRows,nCols,totalSubDirs);
transportMode = zeros(mRows,nCols,totalSubDirs);
facetFlowSlope = zeros(mRows,nCols,totalSubDirs);

% OUTPUT_SUBDIRs 디렉터리 수만큼 최종 모의결과를 읽어들이고, 이를 3차원 배열로 저장함
for ithSubDir = 1:totalSubDirs
    
    % A. 출력 디렉터리에 있는 최종 모의결과를 불러옴
    ithOutputSubdir = OUTPUT_SUBDIRs{ithSubDir,1};
    matFileName = strcat('s',ithOutputSubdir,'.mat');
    MAT_FILE_PATH = fullfile(DATA_DIR,OUTPUT_DIR,ithOutputSubdir,matFileName);
    load(MAT_FILE_PATH)

    % 변수표기 간략화
    Y = majorOutputs.Y;
    X = majorOutputs.X;
    Y_INI = majorOutputs.Y_INI;
    Y_MAX = majorOutputs.Y_MAX;
    X_INI = majorOutputs.X_INI;
    X_MAX = majorOutputs.X_MAX;
    dX = majorOutputs.dX;
    totalExtractTimesNo = majorOutputs.totalExtractTimesNo;
    
    upperCrossProfileY = majorOutputs.upperCrossProfileY;
    middleCrossProfileY = majorOutputs.middleCrossProfileY;
    lowerCrossProfileY = majorOutputs.lowerCrossProfileY;

    lastSedimentThick ...   % 초기 지형 고려
        = majorOutputs.sedimentThick(:,:,totalExtractTimesNo + 1);
    lastBedrockElev ...     % 초기 퇴적층 두께 고려
        = majorOutputs.bedrockElev(:,:,totalExtractTimesNo + 1);
    lastUpslopeArea ...
        = majorOutputs.upslopeArea(:,:,totalExtractTimesNo);
    lastTransportMode ...
        = majorOutputs.transportMode(:,:,totalExtractTimesNo);
    lastFacetFlowSlope ...
        = majorOutputs.facetFlowSlope(:,:,totalExtractTimesNo);

    % 메모리 청소
    clear('majorOutputs.Y' ...
        ,'majorOutputs.X' ...
        ,'majorOutputs.Y_INI' ...
        ,'majorOutputs.Y_MAX' ...
        ,'majorOutputs.X_INI' ...
        ,'majorOutputs.X_MAX' ...
        ,'majorOutputs.dX' ...
        ,'majorOutputs.totalExtractTimesNo' ...
        ,'majorOutputs.sedimentThick' ...
        ,'majorOutputs.bedrockElev' ...
        ,'majorOutputs.upslopeArea' ...
        ,'majorOutputs.transportMode' ...
        ,'majorOutputs.facetFlowSlope' ...
        ,'majorOutputs.upperCrossProfileY' ...
        ,'majorOutputs.middleCrossProfileY' ...
        ,'majorOutputs.lowerCrossProfileY');

    sedimentThick(:,:,ithSubDir) = lastSedimentThick;
    bedrockElev(:,:,ithSubDir) = lastBedrockElev;
    upslopeArea(:,:,ithSubDir) = lastUpslopeArea;
    transportMode(:,:,ithSubDir) = lastTransportMode;
    facetFlowSlope(:,:,ithSubDir) = lastFacetFlowSlope;
    
end
%--------------------------------------------------------------------------

% 상수 및 변수 정의
ROOT2 = 1.41421356237310;           % sqrt(2)

% 운반환경 분류 상수
% ALLUVIAL_CHANNEL = 1;               % 충적 하도
BEDROCK_CHANNEL = 2;                % 기반암 하상 하도
BEDROCK_EXPOSED_HILLSLOPE = 3;      % 기반암이 노출된 사면
SOIL_MANTLED_HILLSLOPE = 4;         % 전토층으로 덮힌 사면

% 이웃 셀의 좌표를 구하기 위한 offset. 하천종단곡선 좌표를 구하기 위해 필요함
% * 주의: 동쪽에 있는 이웃 셀부터 반시계 방향임
offsetY = [0; -1; -1; -1; 0; 1; 1; 1];
offsetX = [1; 1; 0; -1; -1; -1; 0; 1];

endXAxisDistance = X * dX;          % 그래프 X 축 끝 거리
endYAxisDistance = Y * dX;          % 그래프 Y 축 끝 거리

axisXDistance = 0.5*dX:dX:endXAxisDistance-0.5*dX;  % X 축 거리 좌표

%--------------------------------------------------------------------------
% 1. 최종 모의결과 고도 비고

figure(01)
set(gcf,'Color',[1 1 1])

% 최종 모의결과를 연속적으로 보여주기 위해 일정한 간격으로 배열함
spacing = 1;                % 간격

mergedElev ...              % 간격을 고려한 연속된 고도 자료 변수 초기화
    = NaN(Y,X*totalSubDirs + (totalSubDirs - 1) * spacing);

% 일정한 간격으로 배열하기 위한 변수 초기화
xIni = 1;                   % DEM 시작 X 좌표
xEnd = X;                   % DEM 끝 X 좌표

for ithSubDir = 1:totalSubDirs
    
    % 출력 시기를 결정할 경우
    mergedElev(:,xIni:xEnd) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    xIni = X*ithSubDir + ithSubDir + spacing;               % 다음 DEM 시작 X 좌표
    
    xEnd = xIni + X - spacing;                      % 다음 DEM 끝 X 좌표
    
end

% surfl 함수를 만들기 위한 격자
endXAxisDistanceForMergedElev ...
    = (X*totalSubDirs + (totalSubDirs - 1) * spacing) * dX;

[meshgridXForMergedElev,meshgridYForMergedElev] ...
    = meshgrid(0.5*dX:dX:endXAxisDistanceForMergedElev-0.5*dX ...
    ,0.5*dX:dX:endYAxisDistance-0.5*dX);

% surfl 그래프
surf(meshgridXForMergedElev,meshgridYForMergedElev,mergedElev)

view(150,50)

set(gca,'DataAspectRatio',[1 1 0.25] ...
    ,'ZLim',[0 1500] ...
    ,'Xlim',[0 endXAxisDistanceForMergedElev])

set(gca,'YTick',0:endYAxisDistance/6:endYAxisDistance ...
    ,'YTickLabel',{'30 Km','','20','','10','','0'} ...
    ,'XTick',[] ...
    ,'XTickLabel',[])

grid(gca,'on')

shading interp

colormap(demcmap(mergedElev))               % PPT 용
% colormap(flipud(gray))                    % 출판용

%--------------------------------------------------------------------------
% 2. 대표 유역을 선정하고, 이의 하천종단곡선, 힙소메트리곡선, Area-Slope
%    Elevation-Slope 분산도를 작성함

% 변수 정의
endColor = 256;
cMap = colormap(jet(endColor));           % plot 색 그라디언트
hypsometricIntegral = zeros(totalSubDirs,1);    % 힙소메트리 적분값


figure(9);
set(gcf,'Color',[1 1 1])

% subplot 초기화
subplotM = totalSubDirs;
subplotN = 1;

XMin = 0.1;
XMax = 0.95;
YMin = 0.1;     % * 주의: 0.1 보다 작을 경우 문제가 마지막 그래프가 작성되지 않음
YMax = 0.95;
XGap = 0.02;
YGap = 0.02;

XSize = (XMax - XMin) / subplotN;
YSize = (YMax - YMin) / subplotM;

XBox = XSize - XGap;
YBox = YSize - YGap;

hSP1 = subplot(3,1,1);
set(hSP1,'Position',[XMin,YMax - YSize*1,XBox,YBox])
hold on

hSP2 = subplot(3,1,2);
set(hSP2,'Position',[XMin,YMax - YSize*2,XBox,YBox])
hold on

hSP3 = subplot(3,1,3);
hold on
set(hSP3,'Position',[XMin,YMax - YSize*3,XBox,YBox])

figure(10);
set(gcf,'Color',[1 1 1])

subplotM = 1;
subplotN = totalSubDirs;

XMin = 0.1;
XMax = 0.95;
YMin = 0.1;     % * 주의: 0.1 보다 작을 경우 문제가 마지막 그래프가 작성되지 않음
YMax = 0.95;
XGap = 0.04;
YGap = 0.02;

XSize = (XMax - XMin) / subplotN;
YSize = (YMax - YMin) / subplotM;

XBox = XSize - XGap;
YBox = YSize - YGap;

hSP4 = subplot(1,3,1);
set(hSP4,'Position',[XMin + XSize*0,YMin,XBox,YBox])
hold on

hSP5 = subplot(1,3,2);
set(hSP5,'Position',[XMin + XSize*1,YMin,XBox,YBox])
hold on

hSP6 = subplot(1,3,3);
hold on
set(hSP6,'Position',[XMin + XSize*2,YMin,XBox,YBox])

for ithSubDir = 1:totalSubDirs
        
    % 1) 가장 넓은 유역 분지를 찾아서 이를 대표 유역으로 정의함
    isProper = false;    
    iterationNo = 0;
    GOTTEN_ZERO = 0;
    
    % (1) watershed 함수를 이용하여 유역을 구분함
    
    ithSubDirElev = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    watersheds = watershed(ithSubDirElev);                   % 유역 구분

    % 유역구분한 것 보기
    figure(101)
    rgb = label2rgb(watersheds,'jet','w','shuffle');
    imshow(rgb,'initialMagnification','fit')

    watershedTable = tabulate(watersheds(:));

    sortedWatershedTable = sortrows(watershedTable,-2);
    
    % i 번째 유역면적
    ithSubDirUpslopeArea = upslopeArea(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    % (2) 적합한 대표 유역을 선정할 때까지 반복함
    % * 주의: 좌우로 연결된 경우라면 모형영역을 세 개를 합쳐서 while문 사용을
    %   피할 수 있음
    while isProper == false
        
        iterationNo = iterationNo + 1;

        modeWatershedNo = sortedWatershedTable(iterationNo + GOTTEN_ZERO,1);

        % * 주의: 초기 지형은 watershed 함수로 구분되는 유역이 많음.
        % * 주의: 앞으로 table에서 0이 있는 행을 빼버리자!
        if modeWatershedNo == 0

            GOTTEN_ZERO = 1;
            modeWatershedNo = sortedWatershedTable(iterationNo + GOTTEN_ZERO,1);

        end

        representDrainage = watersheds == modeWatershedNo;      % 대표 유역(논리)

        repDrainCoord = find(watersheds == modeWatershedNo);    % 대표 유역 색인    

        % A. bwboundaries 함수를 이용하여 대표 유역 경계 좌표 및 색인을 구함
        % * 주의: 이웃 셀 연결 개수를 4개로 하는 것이 보다 낳은 것 같음. 또한 대표
        %   유역의 테두리에 해당함. 즉 유역 외부가 아님.

        % repDrainBoundary = bwboundaries(representDrainage,4);   % 대표 유역 경계 좌표 추출
        % * 주의: 유역을 확장 시키지 않으면 유역 내부의 경계를 추출하게 됨
        % repDrainBoundary = bwboundaries(imdilate(representDrainage,ones(3,3)));
        repDrainBoundary = bwboundaries(imdilate(representDrainage,[0 1 0; 1 1 1; 0 1 0]));

        repDrainBoundary1 = repDrainBoundary{1};
        repDrainBoundaryY = repDrainBoundary1(:,1);             % 대표 유역 경계 Y 좌표
        repDrainBoundaryX = repDrainBoundary1(:,2);             % 대표 유역 경계 X 좌표

        repDrainBoundaryCoord ...                               % 대표 유역 경계 선형 좌표
            = sub2ind([Y X],repDrainBoundaryY,repDrainBoundaryX);

        % 유역 경계 보기
        % figure(102)
        % plot(repDrainBoundaryX,repDrainBoundaryY,'r');
        % set(gca,'XLim',[1 X],'YLIM',[1 Y],'YDir','reverse','DataAspectRatio',[1 1 1])
        % colorbar

        repDrainUpslopeArea = ithSubDirUpslopeArea(repDrainCoord);    % 대표 유역의 유역면적

        % 대표 유역의 하구 색인: 유역면적이 가장 큰 지점 색인
        % * 동서가 연결된 조건이라면, 가운데 모형영역을 선택함
        [repDrainMaxUpslopeArea,tmpRepDrainMaxUpslopeCoord] = max(repDrainUpslopeArea);

        repDrainMaxUpslopeCoord = repDrainCoord(tmpRepDrainMaxUpslopeCoord);

        % 위 색인과 대표 유역 경계의 색인이 일치하는 지점(하천 및 능선 시작점) 색인
        repDrainMaxUpslopeBoundaryCoord ...
            = find(repDrainBoundaryCoord == repDrainMaxUpslopeCoord);

        % 하천 및 능선 시작점의 좌표
        % * 주의: 대표 유역 경계 좌표의 처음과 끝이 공교롭게도 같은 지점일 경우,
        %   repDrainMaxUpslopeBoundaryCoord 원소는 2개가 됨. 따라서 오류를
        %   방지하기 위해 첫번째 원소만을 사용함
        repDrainMaxUpslopeCoordY = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord(1));
        repDrainMaxUpslopeCoordX = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord(1));

        
        % 만약 중앙에 있는 유역이 아니라면 면적이 가장 넓어도 다른 유역분지를
        % 찾음. 이는 동서가 연결된 경우에서 모의한 것도 있기 때문임
        if repDrainMaxUpslopeCoordX > nCols/2 - nCols/4 ...
            && repDrainMaxUpslopeCoordX < nCols/2 + nCols/4

            isProper = true;

        end
        
    end
    
    % 2) 하천종단곡선 경로 구하기:
    % * 원리: 유역 면적이 가장 큰 이웃 셀을 따라 경로를 저장함

    % 유역면적이 가장 넓은 (하구) 셀의 좌표
    pY = repDrainMaxUpslopeCoordY;
    pX = repDrainMaxUpslopeCoordX;

    % 하천종단곡선 경로 기록 변수 초기화
    ithRiverProfileYX = zeros(Y*X,2);           % 경로 좌표
    ithRivProfDistance = zeros(Y*X,1);          % 이웃 셀과의 거리
    ithRivProfPath = false(Y,X);

    % 하구 셀에서부터 유역면적이 가장 큰 이웃 셀의 좌표를 기록함
    ithSubDirRivProfNode = 1;                                 % 하구로부터의 종단곡선상 셀 색인
    ithRiverProfileYX(ithSubDirRivProfNode,:) = [pY,pX];      % 하구 셀의 좌표를 처음에 기록
    ithRivProfDistance(ithSubDirRivProfNode) = 0;             % 하구로부터의 거리 [m]
    isEnd = false;
    onlyRiverNodesNo = 0;

    % 하구에서부터 유역 최상류까지 좌표를 기록함
    while(isEnd == false)

        ithRivProfPath(pY,pX) = true;                   % 지나온 경로를 표시함

        % (1) 이웃 셀의 좌표 및 색인을 구함
        nbrY = pY + offsetY;                            % 이웃 셀 Y 좌표 배열
        nbrX = pX + offsetX;                            % 이웃 셀 X 좌표 배열

        % * 주의: 영역을 넘어가는 셀은 제외함
        outOfDomainCoord = find(nbrY > Y | nbrX > X | nbrY < 1 | nbrX < 1);
        nbrY(outOfDomainCoord) = [];
        nbrX(outOfDomainCoord) = [];
        
        nbrIdx = sub2ind([Y,X],nbrY,nbrX);              % 이웃 셀 색인

        % (2) 이웃 셀 중 유역면적이 가장 큰 셀을 찾음
        % * 원리: 유역면적이 가장 크면서, 이미 지나온 셀이 아닌 이웃 셀을 찾음
        % * 주의: 하지만 고도가 더 높아야 함
        
        nbrUpslopeArea = ithSubDirUpslopeArea(nbrIdx);  % 이웃 셀 유역면적 배열

        nbrProfilePath = ithRivProfPath(nbrIdx);        % 지나온 경로

        % 이웃 셀 좌표, 유역면적 및 지형단위 정보를 묶음
        nbrInfo = [nbrY,nbrX,nbrUpslopeArea,nbrProfilePath];

        % 지나온 경로상에 있는 셀이 아니면서 유역면적이 가장 넓은 순서로 정렬함
        sortedNbrInfo = sortrows(nbrInfo,[4,-3]);

        % 이웃 셀 중 유역면Ю 가장 넓은 셀의 좌표               
        newPY = sortedNbrInfo(1,1);
        newPX = sortedNbrInfo(1,2);
        
        
        % 유역면적이 가장 넓은 셀이더라도 현 좌표의 고도보다 커야함
        isHigher = false;
        
        nextNbr = 1;
        
        while (isHigher  == false)
            
            if ithSubDirElev(pY,pX) > ithSubDirElev(newPY,newPX)
           
                nextNbr = nextNbr + 1;
                
                newPY = sortedNbrInfo(nextNbr,1);
                newPX = sortedNbrInfo(nextNbr,2);
                
            else
                
                isHigher = true;
                
            end
            
        end        

        % (3) 대표 유역에 속한다면 좌표를 기록함        
        if representDrainage(newPY,newPX) == true ...
            
            % * 주의: 분수계까지 도달한 경우에도 유역면적이 넓은 이웃 셀을
            %   찾기위해 유역 내부를 탐색하는 경우가 있음 이를 방지하기 위해
            %   분수계에 도달한 경우는 탐색을 멈추게 함
            newPCoord = sub2ind([Y X],newPY,newPX);
            
            tmpInd = find(repDrainBoundaryCoord == newPCoord);
            [sizeRows, tmp] = size(tmpInd);
            
            if sizeRows > 0
                
                isEnd = true;
                
            end
            
            % * 주의: 종단곡선 경로 중 사면인 셀을 만나게 되면, 지금까지의 셀
            %   개수를 저장하여 하천종단곡선을 작성하는데 이용함
            ithSubDirTransportMode ...
                = transportMode(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
            
            if ithSubDirTransportMode(newPCoord) == BEDROCK_EXPOSED_HILLSLOPE ...
                || ithSubDirTransportMode(newPCoord) == SOIL_MANTLED_HILLSLOPE
                
                onlyRiverNodesNo = ithSubDirRivProfNode;          
                
            end
            
            ithSubDirRivProfNode = ithSubDirRivProfNode + 1;    % 종단곡선상 셀 색인 1 증가

            % 이웃 셀과의 거리를 구함
            if abs(pY-newPY) == 1 && abs(pX-newPX) == 1

                ithRivProfDistance(ithSubDirRivProfNode) ...
                    = ithRivProfDistance(ithSubDirRivProfNode-1) + dX * ROOT2;
            else

                ithRivProfDistance(ithSubDirRivProfNode) ...
                    = ithRivProfDistance(ithSubDirRivProfNode-1) + dX;

            end

            % 이웃 셀의 좌표를 종단곡선에 기록함
            pY = newPY;
            pX = newPX;

            ithRiverProfileYX(ithSubDirRivProfNode,:) = [pY,pX];

        else

            isEnd = true;

        end

    end

    % 하천 셀의 개수가 전체 종단곡선 셀 개수보다 크다면 조정함
    if onlyRiverNodesNo > ithSubDirRivProfNode || onlyRiverNodesNo == 0
        
        onlyRiverNodesNo = ithSubDirRivProfNode;        
        
    end
    
    % 3) 종단곡선 중 필요없는 값 제거
    % * 원리: Null 값이 나오는 것부터 제거함
    [tmp,ithRivProfEnd] = min(ithRiverProfileYX(:,2));      % Null값이 나오는 위치
    
    ithRiverProfileCoord = sub2ind([Y,X] ...                   % 선형색인으로 변환
        ,ithRiverProfileYX(1:ithRivProfEnd-1,1),ithRiverProfileYX(1:ithRivProfEnd-1,2));
    
    ithRivProfDistance = ithRivProfDistance(1:ithRivProfEnd-1,1);

    % 4) 하천종단곡선 보여주기
    
    % (1) 하천종단곡선 경로 분포
    
    figure(105)
    set(gcf,'Color',[1 1 1])
    
    maxUpslopeArea = max(log(ithSubDirUpslopeArea(:)));
    minUpslopeArea = min(log(ithSubDirUpslopeArea(:)));
    imshow(log(ithSubDirUpslopeArea),[minUpslopeArea maxUpslopeArea] ...
        ,'initialMagnification','fit')
    colormap(jet)
    colorbar
    
    hold on
    
    % 층 1: 종단곡선
    plot(ithRiverProfileYX(1:ithRivProfEnd-1,2) ... % X
        ,ithRiverProfileYX(1:ithRivProfEnd-1,1) ... % Y
        ,'k*')                                      %
    
    hold on
    
    % 층 2: 대표 유역 경계
    plot(repDrainBoundaryX,repDrainBoundaryY,'r');    
    
    % (2) 하천종단곡선
    figure(08)
    set(gcf,'Color',[1 1 1])
    
    ithSubDirBedrockElev = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
        
    plot(ithRivProfDistance(1:onlyRiverNodesNo) ...
        ,ithSubDirBedrockElev(ithRiverProfileCoord(1:onlyRiverNodesNo)) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',3);
        
    set(gca,'YLim',[0 1300] ...
        ,'XLim',[0 30000] ...
        ,'XDir','reverse' ...           % 영동쪽은 X축을 반대로!
        ,'Box','off' ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XMinorTick','on' ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])

    hT1 = title('River longitudinal profile [m]');

    set(hT1,'FontSize',11 ...
        ,'FontWeight','bold' ...
        ,'FontName','나눔고딕')
    
    % grid on
    
    hold on
    
    % 기반암 하상에 대한 표시
    ithSubDirTransportMode ...
        = transportMode(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);    
    ithSubDirBedrockChannel ...
        = ithSubDirTransportMode(ithRiverProfileCoord) == BEDROCK_CHANNEL;    
    ithSubDirBedrockChannel ...
        = ithSubDirBedrockChannel .* ithSubDirBedrockElev(ithRiverProfileCoord);
    ithSubDirBedrockChannel(ithSubDirBedrockChannel == 0) = NaN;
    
    plot(ithRivProfDistance(1:onlyRiverNodesNo),ithSubDirBedrockChannel(1:onlyRiverNodesNo),'k.')
    
    hold on
    
    % 6) 종단곡선 좌표를 전체 종단곡선에 기록함
    rivProfNodesNo(ithSubDir,1) = ithSubDirRivProfNode;
   
    accRivProfNodeNo = cumsum(rivProfNodesNo);
    
    if ithSubDir == 1
        
        riverProfileCoord(1:accRivProfNodeNo(ithSubDir,1)) = ithRiverProfileCoord;

        rivProfDistance(1:accRivProfNodeNo(ithSubDir,1)) = ithRivProfDistance;        
        
    else
        
        riverProfileCoord(accRivProfNodeNo(ithSubDir-1,1)+1 ...
            :accRivProfNodeNo(ithSubDir,1)) = ithRiverProfileCoord;

        rivProfDistance(accRivProfNodeNo(ithSubDir-1,1)+1 ...
            :accRivProfNodeNo(ithSubDir,1)) = ithRivProfDistance;

    end
    
    % 7) 대표유역 능선 좌표 구하기
    % * 원리: bwboundaries 함수를 이용해 구한 대표유역 경계는 임의의 지점에서
    %   시작하여 시계방향 순서로 좌표를 기록함. 따라서 대표유역 경계에서 하구와
    %   유역 최상위 지점의 위치를 확인하여, 하나는 시계방향으로 또 다른 하나는
    %   시계반대방향으로 하구에서 출발하는 분수계 종단곡선경로를 구함
    % * 주의: bwboundaries 함수를 이용해 구한 대표유역 경계는 임의의 지점에서
    %   시작하고 다시 그 지점에서 끝이 남. 따라서 시작되는 지점과 종료되는
    %   지점이 중복되는 것을 조심해야함
    
    % (1) 유역의 최상위 지점 좌표: 하천종단곡선 상에서 유역면적이 가장 작은 셀
    [repDrainHeighstY,repDrainHeighstX] ...
        = ind2sub([Y,X],ithRiverProfileCoord(end));

    % (2) 유역 최상위 지점 색인과 일치하는 대표유역경계 좌표의 색인
    repDrainHeighstBoundaryCoord ...
        = find(repDrainBoundaryCoord == ithRiverProfileCoord(end));

    % repDrainBoundaryYX = [repDrainBoundaryY repDrainBoundaryX];

    % * 주의: 하구지점 색인과 최상류 유역 지점 색인을 파악한 뒤에 이들 값에
    % 따라 분수계종단곡선 경로를 달리함
    if repDrainMaxUpslopeBoundaryCoord < repDrainHeighstBoundaryCoord

        % 하구지점 색인이 유역 최상류 지점 색인보다 작을 때
        
        % 반시계 방항 분수계 종단곡선 경로
        antiClockwiseHillslopeProfile ...
            = [repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryCoord(end-1:repDrainHeighstBoundaryCoord)];

        % 반시계 방향 분수계 종단곡선 경로상의 하구로부터의 거리를 구함

        antiClockwiseHillslopeProfileY ...                          % Y 좌표
            = [repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryY(end-1:repDrainHeighstBoundaryCoord)];
        antiClockwiseHillslopeProfileX ...                          % X 좌표
            = [repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryX(end-1:repDrainHeighstBoundaryCoord)];

        [profYSize,tmp] = size(antiClockwiseHillslopeProfileY);     % 종단곡선 노드 개수

        % 다음 분수계 노드와의 Y 좌표값 차이
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(antiClockwiseHillslopeProfileY(1:end-1) ...
            - antiClockwiseHillslopeProfileY(2:end));

        % 다음 분수계 노드와의 X 좌표값 차이
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(antiClockwiseHillslopeProfileX(1:end-1) ...
            - antiClockwiseHillslopeProfileX(2:end));    

        % 다음 이웃 셀과의 거리
        antiClockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        antiClockwiseHillslopeProfileDiffDistance(2:end) = dX;
        antiClockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % 하구로부터의 거리
        antiClockwiseHillslopeProfileDistance = cumsum(antiClockwiseHillslopeProfileDiffDistance);


        % 시계방향 분수계 종단곡선 경로
        clockwiseHillslopeProfile ...        
            = repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        % 시계방향 분수계 종단곡선 경로상의 하구로부터의 거리를 구함

        clockwiseHillslopeProfileY ...                              % Y 좌표
            = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        clockwiseHillslopeProfileX ...                              % X 좌표
            = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        [profYSize,tmp] = size(clockwiseHillslopeProfileY);       % 종단곡선 노드 개수

        % 다음 분수계 노드와의 Y 좌표값 차이
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(clockwiseHillslopeProfileY(1:end-1) ...
            - clockwiseHillslopeProfileY(2:end));

        % 다음 분수계 노드와의 X 좌표값 차이
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(clockwiseHillslopeProfileX(1:end-1) ...
            - clockwiseHillslopeProfileX(2:end));    

        % 다음 이웃 셀과의 거리
        clockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        clockwiseHillslopeProfileDiffDistance(2:end) = dX;
        clockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % 하구로부터의 거리
        clockwiseHillslopeProfileDistance ...
            = cumsum(clockwiseHillslopeProfileDiffDistance);

    else % repDrainMaxUpslopeBoundaryCoord >= repDrainHeighstBoundaryCoord

        % 하구 지점 색인이 유역 최상류 지점 색인보다 클 때
        
        % 반시계 방항 분수계 종단곡선 경로
        antiClockwiseHillslopeProfile ...
            = repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);

        % 반시계 방향 분수계 종단곡선 경로상의 하구로부터의 거리를 구함

        antiClockwiseHillslopeProfileY ...                          % Y 좌표
            = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);
        antiClockwiseHillslopeProfileX ...                          % X 좌표
            = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);

        [profYSize,tmp] = size(antiClockwiseHillslopeProfileY);     % 종단곡선 노드 개수

        % 다음 분수계 노드와의 Y 좌표값 차이
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(antiClockwiseHillslopeProfileY(1:end-1) ...
            - antiClockwiseHillslopeProfileY(2:end));

        % 다음 분수계 노드와의 X 좌표값 차이
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(antiClockwiseHillslopeProfileX(1:end-1) ...
            - antiClockwiseHillslopeProfileX(2:end));    

        % 다음 이웃 셀과의 거리
        antiClockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        antiClockwiseHillslopeProfileDiffDistance(2:end) = dX;
        antiClockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % 하구로부터의 거리
        antiClockwiseHillslopeProfileDistance = cumsum(antiClockwiseHillslopeProfileDiffDistance);


        % 시계방향 분수계 종단곡선 경로
        clockwiseHillslopeProfile ...        
            = [repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryCoord(1:repDrainHeighstBoundaryCoord)];

        % 시계방향 분수계 종단곡선 경로상의 하구로부터의 거리를 구함

        clockwiseHillslopeProfileY ...                              % Y 좌표
            = [repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryY(1:repDrainHeighstBoundaryCoord)];

        clockwiseHillslopeProfileX ...                              % X 좌표
            = [repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryX(1:repDrainHeighstBoundaryCoord)];

        [profYSize,tmp] = size(clockwiseHillslopeProfileY);       % 종단곡선 노드 개수

        % 다음 분수계 노드와의 Y 좌표값 차이
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(clockwiseHillslopeProfileY(1:end-1) ...
            - clockwiseHillslopeProfileY(2:end));

        % 다음 분수계 노드와의 X 좌표값 차이
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(clockwiseHillslopeProfileX(1:end-1) ...
            - clockwiseHillslopeProfileX(2:end));    

        % 다음 이웃 셀과의 거리
        clockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        clockwiseHillslopeProfileDiffDistance(2:end) = dX;
        clockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % 하구로부터의 거리
        clockwiseHillslopeProfileDistance ...
            = cumsum(clockwiseHillslopeProfileDiffDistance);

    end
    
    % 8) 분수계 종단곡선 그래프 보기        
    figure(9)
    set(gcf,'Color',[1 1 1])

    hold on

    hSPNo = ['hSP',num2str(ithSubDir)];
    
    plot(eval(hSPNo),ithRivProfDistance ...
        ,ithSubDirBedrockElev(ithRiverProfileCoord) ...   % 1. 하천종단곡선
        ,'k:','Linewidth',1.5)

    hold on

    % 하천 양쪽 분수계 종단곡선을 작성하기: 하지만 복잡해서 생략함
    %  plot(eval(hSPNo)clockwiseHillslopeProfileDistance,ithSubDirElev(clockwiseHillslopeProfile) ...
    %      ,antiClockwiseHillslopeProfileDistance,ithSubDirElev(antiClockwiseHillslopeProfile) ...
    %      ,'Color','Blue','LineWidth',1)

    % 한쪽 분수계 종단곡선만을 작성함
    plot(eval(hSPNo),clockwiseHillslopeProfileDistance ...
        ,ithSubDirElev(clockwiseHillslopeProfile) ...    % 2. 분수계 종단곡선
        ,'Color',[0 0 0],'LineWidth',1.5)

    set(eval(hSPNo),'XDir','reverse' ...        % 영동쪽은 X축을 반대로!
        ,'Box','off' ...
        ,'YLim',[0 1000],'XLim',[0 25000] ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...
        ,'XTick',0:5000:25000 ...
        ,'XTickLabel',{'0','5','10','15','20','25 Km'} ...
        ,'XMinorTick','on' ...
        ,'YTick',0:250:1000 ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])

    hold on


    % 분수계 종단곡선에 기반암 노출 사면 표시하기
    ithClockwiseBedrockExposedHill ...
        = ithSubDirTransportMode(clockwiseHillslopeProfile) == BEDROCK_EXPOSED_HILLSLOPE;

    ithClockwiseBedrockExposedHill ...
        = ithClockwiseBedrockExposedHill .* ithSubDirElev(clockwiseHillslopeProfile);

    ithClockwiseBedrockExposedHill(ithClockwiseBedrockExposedHill == 0) = NaN;

    plot(clockwiseHillslopeProfileDistance ...      % 3. 기반암 노출사면 표시
        ,ithClockwiseBedrockExposedHill,'k*');

    hold on

    % 제목 기재
    if ithSubDir == 1
    
        hT = title(eval(hSPNo),'Interfluve and River Longitudinal Profile');
        set(hT,'FontSize',11 ...
            ,'FontWeight','bold' ...
            ,'FontName','나눔고딕')
        
    end

    % 마지막 subplot 을 제외하고는 XTick 과 XTickLabel 제거함
    if ithSubDir ~= totalSubDirs

        set(eval(hSPNo),'XTick',[],'XTickLabel',[])

    end                       

    % 10) area-slope 그래프 그리기        
    ithFacetFlowSlope = facetFlowSlope(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);

    figure(10)
    set(gcf,'Color',[1 1 1])

    hSPNo = ['hSP',num2str(ithSubDir+3)];
    
    scatter(eval(hSPNo),ithSubDirUpslopeArea(representDrainage) ...
        ,ithFacetFlowSlope(representDrainage),'.');

    set(eval(hSPNo),'XScale','log','YScale','log' ...
        ,'Box','off' ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XMinorTick','on' ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])

%     hT = title(eval(hSPNo),'Area - Slope relationship');
% 
%     set(hT,'FontSize',11 ...
%         ,'FontWeight','bold' ...
%         ,'FontName','Helvetica')

 
    % 11) Hypsometric curve 그리기
    figHypsometry = figure(11);
    set(gcf,'Color',[1 1 1])
    
    hypsometricIntegral(ithSubDir,1) ...
        = hypsometry(ithSubDirElev(representDrainage),20,[1 1],'ro-',[2 2] ...
        ,figHypsometry,totalSubDirs,ithSubDir);
    
end
    
% 전체 종단곡선의 뒷부분을 잘라냄. 나중에 이를 이용할 일이 있으면 사용하지만
% 현재로서는 필요없음
% * 원리: Null 값이 나오는 것부터 제거함
% [tmp,rivProfEnd] = min(riverProfileCoord);              % Null값이 나오는 위치
% riverProfileCoord = riverProfileCoord(1:rivProfEnd-1);  % 종단곡선 경로 좌표 정리
% rivProfDistance = rivProfDistance(1:rivProfEnd-1,1);    % 경로 각 지점의 거리 정리

% 3. 소규모

% 1) 횡단상의 고도 변화
figure(12)
set(gcf,'Color',[1 1 1])

% 출력횟수 설정
theBiggestY = 1000;                      % Y 축 최대값 설정
endColor = 256;
cMap = colormap(jet(endColor));   % plot 색 그라디언트

% subplot 간격 조정
subplotM = 3;
subplotN = 1;

XMin = 0.1;
XMax = 0.95;
YMin = 0.1;     % * 주의: 0.1 보다 작을 경우 문제가 마지막 그래프가 작성되지 않음
YMax = 0.95;
XGap = 0.02;
YGap = 0.05;

XSize = (XMax - XMin) / subplotN;
YSize = (YMax - YMin) / subplotM;

XBox = XSize - XGap;
YBox = YSize - YGap;

% subplot 초기화

hSP1 = subplot(3,1,1);
set(hSP1,'Position',[XMin,YMax - YSize*1,XBox,YBox])
hold on

hSP2 = subplot(3,1,2);
set(hSP2,'Position',[XMin,YMax - YSize*2,XBox,YBox])
hold on

hSP3 = subplot(3,1,3);
hold on
set(hSP3,'Position',[XMin,YMax - YSize*3,XBox,YBox])

for ithSubDir = 1:totalSubDirs
    
    % 영동 유역 상류
 
    % 지표고도: 기반암 고도 + 퇴적층 두께
    plot(hSP1,axisXDistance ...
        ,bedrockElev(upperCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(upperCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt 용
        
    set(hSP1,'Box','off' ...
        ,'YLim',[0 theBiggestY] ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XTick',0:endXAxisDistance/3:endXAxisDistance ...
        ,'XTickLabel',[] ...
        ,'XMinorTick','on' ...
        ,'YTick',0:200:800 ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])
    
    title(hSP1,'Elevation on the (Upper/Middle/Lower) Cross Profile' ...
        ,'FontSize',11 ...
        ,'FontWeight','bold' ...
        ,'FontName','Helvetica')
    
    hold on
    
    % 영동 유역 중류

    % 지표고도: 기반암 고도 + 퇴적층 두께
    plot(hSP2,axisXDistance ...
        ,bedrockElev(middleCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(middleCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt 용
    
    set(hSP2,'Box','off' ...
        ,'YLim',[0 theBiggestY] ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XTick',0:endXAxisDistance/3:endXAxisDistance ...
        ,'XTickLabel',[] ...
        ,'XMinorTick','on' ...
        ,'YTick',0:200:800 ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])
    
    hold on 

    % 영동 유역 하류

    
    % 기반암 고도 + 퇴적층 두께
    plot(hSP3,axisXDistance ...
        ,bedrockElev(lowerCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(lowerCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt 용
    
    set(hSP3,'Box','off' ...
        ,'YLim',[0 theBiggestY] ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XTick',0:endXAxisDistance/3:endXAxisDistance ...
        ,'XTickLabel',{'0','5','10','15 Km'} ...
        ,'XMinorTick','on' ...
        ,'YTick',0:200:800 ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])
    
    hold on    

end