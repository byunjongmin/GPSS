% =========================================================================
%> @section INTRO AnalyseFinalResult
%>
%> ���� �ٸ� ������ ���ǽ��� ����� ���Ͽ� �м��ϴ� �Լ�.
%> AnalyseResult �Լ��� ��º��� majorOutputs�� �о����.
%>
%> �м� ����
%>  - 1. ���� ���ǰ�� ����
%>  - 2. ��ǥ ������ �����ϰ�, ���� ��õ���ܰ, �м��������, ���Ҹ�Ʈ���, 
%>    Area-Slope, Elevation-Slope �л굵�� �ۼ���
%>  - 3. �ұԸ� Ⱦ�ܻ��� �� ��ȭ
%>
%> @version 0.02
%> @see 
%> @retval
%>
%> @param OUTPUT_SUBDIR             : ���� ���ǰ���� ����� ���͸� (*����:��,���켱 ����. ��{'100831_1501';'100831_1507';'100831_1513'})
%> @param mRows                     : ���� ���� �� ����
%> @param nCols                     : ���� ���� �� ����
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
DATA_DIR = 'data';                  % ����� ������ �����ϴ� �ֻ��� ���͸�
OUTPUT_DIR = 'output';              % ��� ������ ������ ���͸�
[totalSubDirs,tmpNCols]= size(OUTPUT_SUBDIRs);

sedimentThick = zeros(mRows,nCols,totalSubDirs);
bedrockElev = zeros(mRows,nCols,totalSubDirs);
upslopeArea = zeros(mRows,nCols,totalSubDirs);
transportMode = zeros(mRows,nCols,totalSubDirs);
facetFlowSlope = zeros(mRows,nCols,totalSubDirs);

% OUTPUT_SUBDIRs ���͸� ����ŭ ���� ���ǰ���� �о���̰�, �̸� 3���� �迭�� ������
for ithSubDir = 1:totalSubDirs
    
    % A. ��� ���͸��� �ִ� ���� ���ǰ���� �ҷ���
    ithOutputSubdir = OUTPUT_SUBDIRs{ithSubDir,1};
    matFileName = strcat('s',ithOutputSubdir,'.mat');
    MAT_FILE_PATH = fullfile(DATA_DIR,OUTPUT_DIR,ithOutputSubdir,matFileName);
    load(MAT_FILE_PATH)

    % ����ǥ�� ����ȭ
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

    lastSedimentThick ...   % �ʱ� ���� ���
        = majorOutputs.sedimentThick(:,:,totalExtractTimesNo + 1);
    lastBedrockElev ...     % �ʱ� ������ �β� ���
        = majorOutputs.bedrockElev(:,:,totalExtractTimesNo + 1);
    lastUpslopeArea ...
        = majorOutputs.upslopeArea(:,:,totalExtractTimesNo);
    lastTransportMode ...
        = majorOutputs.transportMode(:,:,totalExtractTimesNo);
    lastFacetFlowSlope ...
        = majorOutputs.facetFlowSlope(:,:,totalExtractTimesNo);

    % �޸� û��
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

% ��� �� ���� ����
ROOT2 = 1.41421356237310;           % sqrt(2)

% ���ȯ�� �з� ���
% ALLUVIAL_CHANNEL = 1;               % ���� �ϵ�
BEDROCK_CHANNEL = 2;                % ��ݾ� �ϻ� �ϵ�
BEDROCK_EXPOSED_HILLSLOPE = 3;      % ��ݾ��� ����� ���
SOIL_MANTLED_HILLSLOPE = 4;         % ���������� ���� ���

% �̿� ���� ��ǥ�� ���ϱ� ���� offset. ��õ���ܰ ��ǥ�� ���ϱ� ���� �ʿ���
% * ����: ���ʿ� �ִ� �̿� ������ �ݽð� ������
offsetY = [0; -1; -1; -1; 0; 1; 1; 1];
offsetX = [1; 1; 0; -1; -1; -1; 0; 1];

endXAxisDistance = X * dX;          % �׷��� X �� �� �Ÿ�
endYAxisDistance = Y * dX;          % �׷��� Y �� �� �Ÿ�

axisXDistance = 0.5*dX:dX:endXAxisDistance-0.5*dX;  % X �� �Ÿ� ��ǥ

%--------------------------------------------------------------------------
% 1. ���� ���ǰ�� �� ���

figure(01)
set(gcf,'Color',[1 1 1])

% ���� ���ǰ���� ���������� �����ֱ� ���� ������ �������� �迭��
spacing = 1;                % ����

mergedElev ...              % ������ ����� ���ӵ� �� �ڷ� ���� �ʱ�ȭ
    = NaN(Y,X*totalSubDirs + (totalSubDirs - 1) * spacing);

% ������ �������� �迭�ϱ� ���� ���� �ʱ�ȭ
xIni = 1;                   % DEM ���� X ��ǥ
xEnd = X;                   % DEM �� X ��ǥ

for ithSubDir = 1:totalSubDirs
    
    % ��� �ñ⸦ ������ ���
    mergedElev(:,xIni:xEnd) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    xIni = X*ithSubDir + ithSubDir + spacing;               % ���� DEM ���� X ��ǥ
    
    xEnd = xIni + X - spacing;                      % ���� DEM �� X ��ǥ
    
end

% surfl �Լ��� ����� ���� ����
endXAxisDistanceForMergedElev ...
    = (X*totalSubDirs + (totalSubDirs - 1) * spacing) * dX;

[meshgridXForMergedElev,meshgridYForMergedElev] ...
    = meshgrid(0.5*dX:dX:endXAxisDistanceForMergedElev-0.5*dX ...
    ,0.5*dX:dX:endYAxisDistance-0.5*dX);

% surfl �׷���
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

colormap(demcmap(mergedElev))               % PPT ��
% colormap(flipud(gray))                    % ���ǿ�

%--------------------------------------------------------------------------
% 2. ��ǥ ������ �����ϰ�, ���� ��õ���ܰ, ���Ҹ�Ʈ���, Area-Slope
%    Elevation-Slope �л굵�� �ۼ���

% ���� ����
endColor = 256;
cMap = colormap(jet(endColor));           % plot �� �׶���Ʈ
hypsometricIntegral = zeros(totalSubDirs,1);    % ���Ҹ�Ʈ�� ���а�


figure(9);
set(gcf,'Color',[1 1 1])

% subplot �ʱ�ȭ
subplotM = totalSubDirs;
subplotN = 1;

XMin = 0.1;
XMax = 0.95;
YMin = 0.1;     % * ����: 0.1 ���� ���� ��� ������ ������ �׷����� �ۼ����� ����
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
YMin = 0.1;     % * ����: 0.1 ���� ���� ��� ������ ������ �׷����� �ۼ����� ����
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
        
    % 1) ���� ���� ���� ������ ã�Ƽ� �̸� ��ǥ �������� ������
    isProper = false;    
    iterationNo = 0;
    GOTTEN_ZERO = 0;
    
    % (1) watershed �Լ��� �̿��Ͽ� ������ ������
    
    ithSubDirElev = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    watersheds = watershed(ithSubDirElev);                   % ���� ����

    % ���������� �� ����
    figure(101)
    rgb = label2rgb(watersheds,'jet','w','shuffle');
    imshow(rgb,'initialMagnification','fit')

    watershedTable = tabulate(watersheds(:));

    sortedWatershedTable = sortrows(watershedTable,-2);
    
    % i ��° ��������
    ithSubDirUpslopeArea = upslopeArea(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
    
    % (2) ������ ��ǥ ������ ������ ������ �ݺ���
    % * ����: �¿�� ����� ����� ���������� �� ���� ���ļ� while�� �����
    %   ���� �� ����
    while isProper == false
        
        iterationNo = iterationNo + 1;

        modeWatershedNo = sortedWatershedTable(iterationNo + GOTTEN_ZERO,1);

        % * ����: �ʱ� ������ watershed �Լ��� ���еǴ� ������ ����.
        % * ����: ������ table���� 0�� �ִ� ���� ��������!
        if modeWatershedNo == 0

            GOTTEN_ZERO = 1;
            modeWatershedNo = sortedWatershedTable(iterationNo + GOTTEN_ZERO,1);

        end

        representDrainage = watersheds == modeWatershedNo;      % ��ǥ ����(��)

        repDrainCoord = find(watersheds == modeWatershedNo);    % ��ǥ ���� ����    

        % A. bwboundaries �Լ��� �̿��Ͽ� ��ǥ ���� ��� ��ǥ �� ������ ����
        % * ����: �̿� �� ���� ������ 4���� �ϴ� ���� ���� ���� �� ����. ���� ��ǥ
        %   ������ �׵θ��� �ش���. �� ���� �ܺΰ� �ƴ�.

        % repDrainBoundary = bwboundaries(representDrainage,4);   % ��ǥ ���� ��� ��ǥ ����
        % * ����: ������ Ȯ�� ��Ű�� ������ ���� ������ ��踦 �����ϰ� ��
        % repDrainBoundary = bwboundaries(imdilate(representDrainage,ones(3,3)));
        repDrainBoundary = bwboundaries(imdilate(representDrainage,[0 1 0; 1 1 1; 0 1 0]));

        repDrainBoundary1 = repDrainBoundary{1};
        repDrainBoundaryY = repDrainBoundary1(:,1);             % ��ǥ ���� ��� Y ��ǥ
        repDrainBoundaryX = repDrainBoundary1(:,2);             % ��ǥ ���� ��� X ��ǥ

        repDrainBoundaryCoord ...                               % ��ǥ ���� ��� ���� ��ǥ
            = sub2ind([Y X],repDrainBoundaryY,repDrainBoundaryX);

        % ���� ��� ����
        % figure(102)
        % plot(repDrainBoundaryX,repDrainBoundaryY,'r');
        % set(gca,'XLim',[1 X],'YLIM',[1 Y],'YDir','reverse','DataAspectRatio',[1 1 1])
        % colorbar

        repDrainUpslopeArea = ithSubDirUpslopeArea(repDrainCoord);    % ��ǥ ������ ��������

        % ��ǥ ������ �ϱ� ����: ���������� ���� ū ���� ����
        % * ������ ����� �����̶��, ��� ���������� ������
        [repDrainMaxUpslopeArea,tmpRepDrainMaxUpslopeCoord] = max(repDrainUpslopeArea);

        repDrainMaxUpslopeCoord = repDrainCoord(tmpRepDrainMaxUpslopeCoord);

        % �� ���ΰ� ��ǥ ���� ����� ������ ��ġ�ϴ� ����(��õ �� �ɼ� ������) ����
        repDrainMaxUpslopeBoundaryCoord ...
            = find(repDrainBoundaryCoord == repDrainMaxUpslopeCoord);

        % ��õ �� �ɼ� �������� ��ǥ
        % * ����: ��ǥ ���� ��� ��ǥ�� ó���� ���� �����ӰԵ� ���� ������ ���,
        %   repDrainMaxUpslopeBoundaryCoord ���Ҵ� 2���� ��. ���� ������
        %   �����ϱ� ���� ù��° ���Ҹ��� �����
        repDrainMaxUpslopeCoordY = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord(1));
        repDrainMaxUpslopeCoordX = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord(1));

        
        % ���� �߾ӿ� �ִ� ������ �ƴ϶�� ������ ���� �о �ٸ� ����������
        % ã��. �̴� ������ ����� ��쿡�� ������ �͵� �ֱ� ������
        if repDrainMaxUpslopeCoordX > nCols/2 - nCols/4 ...
            && repDrainMaxUpslopeCoordX < nCols/2 + nCols/4

            isProper = true;

        end
        
    end
    
    % 2) ��õ���ܰ ��� ���ϱ�:
    % * ����: ���� ������ ���� ū �̿� ���� ���� ��θ� ������

    % ���������� ���� ���� (�ϱ�) ���� ��ǥ
    pY = repDrainMaxUpslopeCoordY;
    pX = repDrainMaxUpslopeCoordX;

    % ��õ���ܰ ��� ��� ���� �ʱ�ȭ
    ithRiverProfileYX = zeros(Y*X,2);           % ��� ��ǥ
    ithRivProfDistance = zeros(Y*X,1);          % �̿� ������ �Ÿ�
    ithRivProfPath = false(Y,X);

    % �ϱ� ���������� ���������� ���� ū �̿� ���� ��ǥ�� �����
    ithSubDirRivProfNode = 1;                                 % �ϱ��κ����� ���ܰ�� �� ����
    ithRiverProfileYX(ithSubDirRivProfNode,:) = [pY,pX];      % �ϱ� ���� ��ǥ�� ó���� ���
    ithRivProfDistance(ithSubDirRivProfNode) = 0;             % �ϱ��κ����� �Ÿ� [m]
    isEnd = false;
    onlyRiverNodesNo = 0;

    % �ϱ��������� ���� �ֻ������ ��ǥ�� �����
    while(isEnd == false)

        ithRivProfPath(pY,pX) = true;                   % ������ ��θ� ǥ����

        % (1) �̿� ���� ��ǥ �� ������ ����
        nbrY = pY + offsetY;                            % �̿� �� Y ��ǥ �迭
        nbrX = pX + offsetX;                            % �̿� �� X ��ǥ �迭

        % * ����: ������ �Ѿ�� ���� ������
        outOfDomainCoord = find(nbrY > Y | nbrX > X | nbrY < 1 | nbrX < 1);
        nbrY(outOfDomainCoord) = [];
        nbrX(outOfDomainCoord) = [];
        
        nbrIdx = sub2ind([Y,X],nbrY,nbrX);              % �̿� �� ����

        % (2) �̿� �� �� ���������� ���� ū ���� ã��
        % * ����: ���������� ���� ũ�鼭, �̹� ������ ���� �ƴ� �̿� ���� ã��
        % * ����: ������ ���� �� ���ƾ� ��
        
        nbrUpslopeArea = ithSubDirUpslopeArea(nbrIdx);  % �̿� �� �������� �迭

        nbrProfilePath = ithRivProfPath(nbrIdx);        % ������ ���

        % �̿� �� ��ǥ, �������� �� �������� ������ ����
        nbrInfo = [nbrY,nbrX,nbrUpslopeArea,nbrProfilePath];

        % ������ ��λ� �ִ� ���� �ƴϸ鼭 ���������� ���� ���� ������ ������
        sortedNbrInfo = sortrows(nbrInfo,[4,-3]);

        % �̿� �� �� ������� ���� ���� ���� ��ǥ               
        newPY = sortedNbrInfo(1,1);
        newPX = sortedNbrInfo(1,2);
        
        
        % ���������� ���� ���� ���̴��� �� ��ǥ�� ������ Ŀ����
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

        % (3) ��ǥ ������ ���Ѵٸ� ��ǥ�� �����        
        if representDrainage(newPY,newPX) == true ...
            
            % * ����: �м������ ������ ��쿡�� ���������� ���� �̿� ����
            %   ã������ ���� ���θ� Ž���ϴ� ��찡 ���� �̸� �����ϱ� ����
            %   �м��迡 ������ ���� Ž���� ���߰� ��
            newPCoord = sub2ind([Y X],newPY,newPX);
            
            tmpInd = find(repDrainBoundaryCoord == newPCoord);
            [sizeRows, tmp] = size(tmpInd);
            
            if sizeRows > 0
                
                isEnd = true;
                
            end
            
            % * ����: ���ܰ ��� �� ����� ���� ������ �Ǹ�, ���ݱ����� ��
            %   ������ �����Ͽ� ��õ���ܰ�� �ۼ��ϴµ� �̿���
            ithSubDirTransportMode ...
                = transportMode(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
            
            if ithSubDirTransportMode(newPCoord) == BEDROCK_EXPOSED_HILLSLOPE ...
                || ithSubDirTransportMode(newPCoord) == SOIL_MANTLED_HILLSLOPE
                
                onlyRiverNodesNo = ithSubDirRivProfNode;          
                
            end
            
            ithSubDirRivProfNode = ithSubDirRivProfNode + 1;    % ���ܰ�� �� ���� 1 ����

            % �̿� ������ �Ÿ��� ����
            if abs(pY-newPY) == 1 && abs(pX-newPX) == 1

                ithRivProfDistance(ithSubDirRivProfNode) ...
                    = ithRivProfDistance(ithSubDirRivProfNode-1) + dX * ROOT2;
            else

                ithRivProfDistance(ithSubDirRivProfNode) ...
                    = ithRivProfDistance(ithSubDirRivProfNode-1) + dX;

            end

            % �̿� ���� ��ǥ�� ���ܰ�� �����
            pY = newPY;
            pX = newPX;

            ithRiverProfileYX(ithSubDirRivProfNode,:) = [pY,pX];

        else

            isEnd = true;

        end

    end

    % ��õ ���� ������ ��ü ���ܰ �� �������� ũ�ٸ� ������
    if onlyRiverNodesNo > ithSubDirRivProfNode || onlyRiverNodesNo == 0
        
        onlyRiverNodesNo = ithSubDirRivProfNode;        
        
    end
    
    % 3) ���ܰ �� �ʿ���� �� ����
    % * ����: Null ���� ������ �ͺ��� ������
    [tmp,ithRivProfEnd] = min(ithRiverProfileYX(:,2));      % Null���� ������ ��ġ
    
    ithRiverProfileCoord = sub2ind([Y,X] ...                   % ������������ ��ȯ
        ,ithRiverProfileYX(1:ithRivProfEnd-1,1),ithRiverProfileYX(1:ithRivProfEnd-1,2));
    
    ithRivProfDistance = ithRivProfDistance(1:ithRivProfEnd-1,1);

    % 4) ��õ���ܰ �����ֱ�
    
    % (1) ��õ���ܰ ��� ����
    
    figure(105)
    set(gcf,'Color',[1 1 1])
    
    maxUpslopeArea = max(log(ithSubDirUpslopeArea(:)));
    minUpslopeArea = min(log(ithSubDirUpslopeArea(:)));
    imshow(log(ithSubDirUpslopeArea),[minUpslopeArea maxUpslopeArea] ...
        ,'initialMagnification','fit')
    colormap(jet)
    colorbar
    
    hold on
    
    % �� 1: ���ܰ
    plot(ithRiverProfileYX(1:ithRivProfEnd-1,2) ... % X
        ,ithRiverProfileYX(1:ithRivProfEnd-1,1) ... % Y
        ,'k*')                                      %
    
    hold on
    
    % �� 2: ��ǥ ���� ���
    plot(repDrainBoundaryX,repDrainBoundaryY,'r');    
    
    % (2) ��õ���ܰ
    figure(08)
    set(gcf,'Color',[1 1 1])
    
    ithSubDirBedrockElev = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
        
    plot(ithRivProfDistance(1:onlyRiverNodesNo) ...
        ,ithSubDirBedrockElev(ithRiverProfileCoord(1:onlyRiverNodesNo)) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',3);
        
    set(gca,'YLim',[0 1300] ...
        ,'XLim',[0 30000] ...
        ,'XDir','reverse' ...           % �������� X���� �ݴ��!
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
        ,'FontName','�������')
    
    % grid on
    
    hold on
    
    % ��ݾ� �ϻ� ���� ǥ��
    ithSubDirTransportMode ...
        = transportMode(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);    
    ithSubDirBedrockChannel ...
        = ithSubDirTransportMode(ithRiverProfileCoord) == BEDROCK_CHANNEL;    
    ithSubDirBedrockChannel ...
        = ithSubDirBedrockChannel .* ithSubDirBedrockElev(ithRiverProfileCoord);
    ithSubDirBedrockChannel(ithSubDirBedrockChannel == 0) = NaN;
    
    plot(ithRivProfDistance(1:onlyRiverNodesNo),ithSubDirBedrockChannel(1:onlyRiverNodesNo),'k.')
    
    hold on
    
    % 6) ���ܰ ��ǥ�� ��ü ���ܰ�� �����
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
    
    % 7) ��ǥ���� �ɼ� ��ǥ ���ϱ�
    % * ����: bwboundaries �Լ��� �̿��� ���� ��ǥ���� ���� ������ ��������
    %   �����Ͽ� �ð���� ������ ��ǥ�� �����. ���� ��ǥ���� ��迡�� �ϱ���
    %   ���� �ֻ��� ������ ��ġ�� Ȯ���Ͽ�, �ϳ��� �ð�������� �� �ٸ� �ϳ���
    %   �ð�ݴ�������� �ϱ����� ����ϴ� �м��� ���ܰ��θ� ����
    % * ����: bwboundaries �Լ��� �̿��� ���� ��ǥ���� ���� ������ ��������
    %   �����ϰ� �ٽ� �� �������� ���� ��. ���� ���۵Ǵ� ������ ����Ǵ�
    %   ������ �ߺ��Ǵ� ���� �����ؾ���
    
    % (1) ������ �ֻ��� ���� ��ǥ: ��õ���ܰ �󿡼� ���������� ���� ���� ��
    [repDrainHeighstY,repDrainHeighstX] ...
        = ind2sub([Y,X],ithRiverProfileCoord(end));

    % (2) ���� �ֻ��� ���� ���ΰ� ��ġ�ϴ� ��ǥ������� ��ǥ�� ����
    repDrainHeighstBoundaryCoord ...
        = find(repDrainBoundaryCoord == ithRiverProfileCoord(end));

    % repDrainBoundaryYX = [repDrainBoundaryY repDrainBoundaryX];

    % * ����: �ϱ����� ���ΰ� �ֻ�� ���� ���� ������ �ľ��� �ڿ� �̵� ����
    % ���� �м������ܰ ��θ� �޸���
    if repDrainMaxUpslopeBoundaryCoord < repDrainHeighstBoundaryCoord

        % �ϱ����� ������ ���� �ֻ�� ���� ���κ��� ���� ��
        
        % �ݽð� ���� �м��� ���ܰ ���
        antiClockwiseHillslopeProfile ...
            = [repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryCoord(end-1:repDrainHeighstBoundaryCoord)];

        % �ݽð� ���� �м��� ���ܰ ��λ��� �ϱ��κ����� �Ÿ��� ����

        antiClockwiseHillslopeProfileY ...                          % Y ��ǥ
            = [repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryY(end-1:repDrainHeighstBoundaryCoord)];
        antiClockwiseHillslopeProfileX ...                          % X ��ǥ
            = [repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:-1:1) ...
            ;repDrainBoundaryX(end-1:repDrainHeighstBoundaryCoord)];

        [profYSize,tmp] = size(antiClockwiseHillslopeProfileY);     % ���ܰ ��� ����

        % ���� �м��� ������ Y ��ǥ�� ����
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(antiClockwiseHillslopeProfileY(1:end-1) ...
            - antiClockwiseHillslopeProfileY(2:end));

        % ���� �м��� ������ X ��ǥ�� ����
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(antiClockwiseHillslopeProfileX(1:end-1) ...
            - antiClockwiseHillslopeProfileX(2:end));    

        % ���� �̿� ������ �Ÿ�
        antiClockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        antiClockwiseHillslopeProfileDiffDistance(2:end) = dX;
        antiClockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % �ϱ��κ����� �Ÿ�
        antiClockwiseHillslopeProfileDistance = cumsum(antiClockwiseHillslopeProfileDiffDistance);


        % �ð���� �м��� ���ܰ ���
        clockwiseHillslopeProfile ...        
            = repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        % �ð���� �м��� ���ܰ ��λ��� �ϱ��κ����� �Ÿ��� ����

        clockwiseHillslopeProfileY ...                              % Y ��ǥ
            = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        clockwiseHillslopeProfileX ...                              % X ��ǥ
            = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:repDrainHeighstBoundaryCoord);

        [profYSize,tmp] = size(clockwiseHillslopeProfileY);       % ���ܰ ��� ����

        % ���� �м��� ������ Y ��ǥ�� ����
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(clockwiseHillslopeProfileY(1:end-1) ...
            - clockwiseHillslopeProfileY(2:end));

        % ���� �м��� ������ X ��ǥ�� ����
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(clockwiseHillslopeProfileX(1:end-1) ...
            - clockwiseHillslopeProfileX(2:end));    

        % ���� �̿� ������ �Ÿ�
        clockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        clockwiseHillslopeProfileDiffDistance(2:end) = dX;
        clockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % �ϱ��κ����� �Ÿ�
        clockwiseHillslopeProfileDistance ...
            = cumsum(clockwiseHillslopeProfileDiffDistance);

    else % repDrainMaxUpslopeBoundaryCoord >= repDrainHeighstBoundaryCoord

        % �ϱ� ���� ������ ���� �ֻ�� ���� ���κ��� Ŭ ��
        
        % �ݽð� ���� �м��� ���ܰ ���
        antiClockwiseHillslopeProfile ...
            = repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);

        % �ݽð� ���� �м��� ���ܰ ��λ��� �ϱ��κ����� �Ÿ��� ����

        antiClockwiseHillslopeProfileY ...                          % Y ��ǥ
            = repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);
        antiClockwiseHillslopeProfileX ...                          % X ��ǥ
            = repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:-1:repDrainHeighstBoundaryCoord);

        [profYSize,tmp] = size(antiClockwiseHillslopeProfileY);     % ���ܰ ��� ����

        % ���� �м��� ������ Y ��ǥ�� ����
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(antiClockwiseHillslopeProfileY(1:end-1) ...
            - antiClockwiseHillslopeProfileY(2:end));

        % ���� �м��� ������ X ��ǥ�� ����
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(antiClockwiseHillslopeProfileX(1:end-1) ...
            - antiClockwiseHillslopeProfileX(2:end));    

        % ���� �̿� ������ �Ÿ�
        antiClockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        antiClockwiseHillslopeProfileDiffDistance(2:end) = dX;
        antiClockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % �ϱ��κ����� �Ÿ�
        antiClockwiseHillslopeProfileDistance = cumsum(antiClockwiseHillslopeProfileDiffDistance);


        % �ð���� �м��� ���ܰ ���
        clockwiseHillslopeProfile ...        
            = [repDrainBoundaryCoord(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryCoord(1:repDrainHeighstBoundaryCoord)];

        % �ð���� �м��� ���ܰ ��λ��� �ϱ��κ����� �Ÿ��� ����

        clockwiseHillslopeProfileY ...                              % Y ��ǥ
            = [repDrainBoundaryY(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryY(1:repDrainHeighstBoundaryCoord)];

        clockwiseHillslopeProfileX ...                              % X ��ǥ
            = [repDrainBoundaryX(repDrainMaxUpslopeBoundaryCoord:end-1) ...
            ;repDrainBoundaryX(1:repDrainHeighstBoundaryCoord)];

        [profYSize,tmp] = size(clockwiseHillslopeProfileY);       % ���ܰ ��� ����

        % ���� �м��� ������ Y ��ǥ�� ����
        dHillProfY = zeros(profYSize,1);

        dHillProfY(2:end) = abs(clockwiseHillslopeProfileY(1:end-1) ...
            - clockwiseHillslopeProfileY(2:end));

        % ���� �м��� ������ X ��ǥ�� ����
        dHillProfX = zeros(profYSize,1);

        dHillProfX(2:end) = abs(clockwiseHillslopeProfileX(1:end-1) ...
            - clockwiseHillslopeProfileX(2:end));    

        % ���� �̿� ������ �Ÿ�
        clockwiseHillslopeProfileDiffDistance = zeros(profYSize,1);
        clockwiseHillslopeProfileDiffDistance(2:end) = dX;
        clockwiseHillslopeProfileDiffDistance(dHillProfY == 1 & dHillProfX == 1) = dX * ROOT2;

        % �ϱ��κ����� �Ÿ�
        clockwiseHillslopeProfileDistance ...
            = cumsum(clockwiseHillslopeProfileDiffDistance);

    end
    
    % 8) �м��� ���ܰ �׷��� ����        
    figure(9)
    set(gcf,'Color',[1 1 1])

    hold on

    hSPNo = ['hSP',num2str(ithSubDir)];
    
    plot(eval(hSPNo),ithRivProfDistance ...
        ,ithSubDirBedrockElev(ithRiverProfileCoord) ...   % 1. ��õ���ܰ
        ,'k:','Linewidth',1.5)

    hold on

    % ��õ ���� �м��� ���ܰ�� �ۼ��ϱ�: ������ �����ؼ� ������
    %  plot(eval(hSPNo)clockwiseHillslopeProfileDistance,ithSubDirElev(clockwiseHillslopeProfile) ...
    %      ,antiClockwiseHillslopeProfileDistance,ithSubDirElev(antiClockwiseHillslopeProfile) ...
    %      ,'Color','Blue','LineWidth',1)

    % ���� �м��� ���ܰ���� �ۼ���
    plot(eval(hSPNo),clockwiseHillslopeProfileDistance ...
        ,ithSubDirElev(clockwiseHillslopeProfile) ...    % 2. �м��� ���ܰ
        ,'Color',[0 0 0],'LineWidth',1.5)

    set(eval(hSPNo),'XDir','reverse' ...        % �������� X���� �ݴ��!
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


    % �м��� ���ܰ�� ��ݾ� ���� ��� ǥ���ϱ�
    ithClockwiseBedrockExposedHill ...
        = ithSubDirTransportMode(clockwiseHillslopeProfile) == BEDROCK_EXPOSED_HILLSLOPE;

    ithClockwiseBedrockExposedHill ...
        = ithClockwiseBedrockExposedHill .* ithSubDirElev(clockwiseHillslopeProfile);

    ithClockwiseBedrockExposedHill(ithClockwiseBedrockExposedHill == 0) = NaN;

    plot(clockwiseHillslopeProfileDistance ...      % 3. ��ݾ� ������ ǥ��
        ,ithClockwiseBedrockExposedHill,'k*');

    hold on

    % ���� ����
    if ithSubDir == 1
    
        hT = title(eval(hSPNo),'Interfluve and River Longitudinal Profile');
        set(hT,'FontSize',11 ...
            ,'FontWeight','bold' ...
            ,'FontName','�������')
        
    end

    % ������ subplot �� �����ϰ�� XTick �� XTickLabel ������
    if ithSubDir ~= totalSubDirs

        set(eval(hSPNo),'XTick',[],'XTickLabel',[])

    end                       

    % 10) area-slope �׷��� �׸���        
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

 
    % 11) Hypsometric curve �׸���
    figHypsometry = figure(11);
    set(gcf,'Color',[1 1 1])
    
    hypsometricIntegral(ithSubDir,1) ...
        = hypsometry(ithSubDirElev(representDrainage),20,[1 1],'ro-',[2 2] ...
        ,figHypsometry,totalSubDirs,ithSubDir);
    
end
    
% ��ü ���ܰ�� �޺κ��� �߶�. ���߿� �̸� �̿��� ���� ������ ���������
% ����μ��� �ʿ����
% * ����: Null ���� ������ �ͺ��� ������
% [tmp,rivProfEnd] = min(riverProfileCoord);              % Null���� ������ ��ġ
% riverProfileCoord = riverProfileCoord(1:rivProfEnd-1);  % ���ܰ ��� ��ǥ ����
% rivProfDistance = rivProfDistance(1:rivProfEnd-1,1);    % ��� �� ������ �Ÿ� ����

% 3. �ұԸ�

% 1) Ⱦ�ܻ��� �� ��ȭ
figure(12)
set(gcf,'Color',[1 1 1])

% ���Ƚ�� ����
theBiggestY = 1000;                      % Y �� �ִ밪 ����
endColor = 256;
cMap = colormap(jet(endColor));   % plot �� �׶���Ʈ

% subplot ���� ����
subplotM = 3;
subplotN = 1;

XMin = 0.1;
XMax = 0.95;
YMin = 0.1;     % * ����: 0.1 ���� ���� ��� ������ ������ �׷����� �ۼ����� ����
YMax = 0.95;
XGap = 0.02;
YGap = 0.05;

XSize = (XMax - XMin) / subplotN;
YSize = (YMax - YMin) / subplotM;

XBox = XSize - XGap;
YBox = YSize - YGap;

% subplot �ʱ�ȭ

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
    
    % ���� ���� ���
 
    % ��ǥ��: ��ݾ� �� + ������ �β�
    plot(hSP1,axisXDistance ...
        ,bedrockElev(upperCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(upperCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt ��
        
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
    
    % ���� ���� �߷�

    % ��ǥ��: ��ݾ� �� + ������ �β�
    plot(hSP2,axisXDistance ...
        ,bedrockElev(middleCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(middleCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt ��
    
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

    % ���� ���� �Ϸ�

    
    % ��ݾ� �� + ������ �β�
    plot(hSP3,axisXDistance ...
        ,bedrockElev(lowerCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        + sedimentThick(lowerCrossProfileY,X_INI:X_MAX,ithSubDir) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',1.5) % ppt ��
    
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