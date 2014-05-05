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
function AnalyseFinalResultGeneral(OUTPUT_SUBDIRs,mRows,nCols)
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
    
    % if a broken simulation
    totalExtractTimesNo = 23;

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
        ,'majorOutputs.facetFlowSlope');

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

%--------------------------------------------------------------------------
% 1. ���� ���ǰ�� �� ���

figure(31)
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
    ,'Xlim',[0 endXAxisDistanceForMergedElev],'XDir','Reverse')

set(gca,'XTick',[],'XTickLabel',[])

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
    % figure(32)
    % rgb = label2rgb(watersheds,'jet','w','shuffle');
    % imshow(rgb,'initialMagnification','fit')

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
        figure(33)
        plot(repDrainBoundaryX,repDrainBoundaryY,'r');
        set(gca,'XLim',[1 X],'YLIM',[1 Y],'YDir','reverse','DataAspectRatio',[1 1 1])
        colorbar

        repDrainUpslopeArea = ithSubDirUpslopeArea(repDrainCoord);    % ��ǥ ������ ��������

        % boundary flow out condition �� ����ؼ� ��迡 �ش��ϴ� ���� �����ϵ��� �� ��.
        % �����ؾ���.
%         tmpBndIdx = false(Y,X);
%         tmpBndIdx(1,:) = true;
%         tmpBndIdx(end,:) = true;
%         tmpBndIdx(:,1) = true;
%         tmpBndIdx(:,end) = true;
%         find(tmpBndIdx == true);
        
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
    
    % ����� ���ǽÿ� ���⿡ �����ϰ� pY, pX�� �޸��� ��
    figure(34)
    imagesc(ithSubDirUpslopeArea)
    % pY = 99; % for custom setting
    % pX = 49; % for custom setting

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
        outOfDomainCoord = find(nbrY > Y | nbrX > X | nbrY < 1 | nbrX < 1 ...
                                | nbrY >= Y);
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

        % �̿� �� �� ���������� ���� ���� ���� ��ǥ               
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

        if ithSubDirElev(pY,pX) > ithSubDirElev(newPY,newPX)
            isEnd = true;            
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
    
    figure(35)
    set(gcf,'Color',[1 1 1])
    
    maxUpslopeArea = max(log(ithSubDirUpslopeArea(:)));
    minUpslopeArea = min(log(ithSubDirUpslopeArea(:)));
    imshow(log(ithSubDirUpslopeArea),[minUpslopeArea maxUpslopeArea] ...
        ,'initialMagnification','fit')
    colormap(jet)
    colorbar
    
    hold on
    
    % layer 1: ���ܰ
    plot(ithRiverProfileYX(1:ithRivProfEnd-1,2) ... % X
        ,ithRiverProfileYX(1:ithRivProfEnd-1,1) ... % Y
        ,'k*')                                      %
    
    hold on
    
    % layer 2: ��ǥ ���� ���
    plot(repDrainBoundaryX,repDrainBoundaryY,'r');    
    
    % (2) ��õ���ܰ
    figure(36)
    set(gcf,'Color',[1 1 1])
    
    ithSubDirBedrockElev = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);
        
    plot(ithRivProfDistance(1:onlyRiverNodesNo) ...
        ,ithSubDirBedrockElev(ithRiverProfileCoord(1:onlyRiverNodesNo)) ...
        ,'Color',cMap(round(endColor*(ithSubDir/totalSubDirs)),:),'LineWidth',3);
    
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
        
    set(gca ...
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
               

    % 10) area-slope �׷��� �׸���        
    ithFacetFlowSlope = facetFlowSlope(Y_INI:Y_MAX,X_INI:X_MAX,ithSubDir);

    figure(37)
    
    scatter(ithSubDirUpslopeArea(representDrainage) ...
        ,ithFacetFlowSlope(representDrainage),'.');

    set(gca,'XScale','log','YScale','log' ...
        ,'Box','off' ...
        ,'TickDir','out' ...
        ,'TickLength',[0.02 0.02] ...    
        ,'XMinorTick','on' ...
        ,'YMinorTick','on' ...
        ,'XColor',[0.3 0.3 0.3] ...
        ,'YColor',[0.3 0.3 0.3])

    hT = title('Area - Slope relationship');

    set(hT,'FontSize',11 ...
        ,'FontWeight','bold' ...
        ,'FontName','Helvetica')

 
    % 11) Hypsometric curve �׸���
    figHypsometry = figure(38);
    set(gcf,'Color',[1 1 1])
    
    hypsometricIntegral(ithSubDir,1) ...
        = hypsometry(ithSubDirElev(representDrainage),20,[1 1],'ro-',[2 2] ...
        ,figHypsometry,totalSubDirs,ithSubDir);
    
end
