% =========================================================================
%> @section INTRO ProcessSink
%>
%> - ������ ���ǵ��� ���� ��(SINK)�� ���ⱸ�� ã�� ���� ��ǥ�� SDSNbrY,
%>   SDSNbrX�� ����ϴ� �Լ�
%>
%>  - �ֿ� �˰���
%>   - SINK�� �̿� �� �� ���� ������� ���� ���� �밳 SINK�� ���ⱸ�� ������,
%>    �� ���� ������ �ٽ� ó���� SINK ���� ����Ű�� ��찡 ����. �� ��쿡
%>    �� ���� SINK�� �������� ���ⱸ��� ���� ����. ���� �� �Լ�������
%>    ���ⱸ�� ã�� �������� ���ⱸ�� �����Ǿ��� ���� flooded region
%>    (�Ǵ� lake)���� �����ϰ�, �� �ֺ��� ���� ���� ���� ���� �ٽ� ã��.\n
%>    ���� ���� ���� ���� ������ flooded region�� �ش��ϴ� ���� ����Ű��
%>    �ʴ´ٸ�, �� ���� �������� ���ⱸ�� ��. ������ �׷��� �ʴٸ� �� ����
%>    flooded region ��Ͽ� ���Եǰ� ���� ������ ���ⱸ�� ã�� ������ �ݺ���.
%>
%>  - History
%>   - 091221
%>    - ���Լ��� �ִ� ProcessSink �Լ��� ���� ������ �Լ� ���ο� ���Խ�Ŵ
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see IsBoundary(), FindSDSDryNbr()
%>
%> @retval flood                        : flooded region
%> @retval SDSNbrY                      : ������ ���� ���� Y ��ǥ��
%> @retval SDSNbrX                      : ������ ���� ���� X ��ǥ��
%> @retval SDSFlowDirection             : ������ ����
%> @retval steepestDescentSlope         : ������ ���
%> @retval integratedSlope              : ������ facet flow ���
%> @retval floodedRegionIndex           : flooded region ����
%> @retval floodedRegionCellsNo         : flooded region ���� �� ��
%> @retval floodedRegionLocalDepth      : flooded region ���� ���ⱸ �� ���� [m]
%> @retval floodedRegionTotalDepth      : flooded region local depth �� �� [m]
%> @retval floodedRegionStorageVolume   : flooded region ������ [m^3]
%>
%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param X_INI                         : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                         : ���� ���� X ������ ��ǥ��(=X+1)
%> @param Y_TOP_BND                     : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND                  : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                    : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND                   : ���� �ܰ� �� ��� X ��ǥ��
%> @param QUARTER_PI                	: pi * 0.25
%> @param CELL_AREA                     : �� ���� [m^2]
%> @param elev                          : ��ǥ �� [m]
%> @param ithNbrYOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
%> @param ithNbrXOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param IS_LEFT_RIGHT_CONNECTED       : �¿� �ܰ� ��� ������ ����
%> @param slopeAllNbr                   : 8���� �̿� ������ ���
%> @param steepestDescentSlope          : �ִ��Ϻΰ��
%> @param facetFlowSlope                : facet flow ���
%> @param SDSNbrY                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param SDSFlowDirection              : �ִ��Ϻΰ�� ����
% =========================================================================
function [flood,SDSNbrY,SDSNbrX,SDSFlowDirection,steepestDescentSlope,integratedSlope,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth,floodedRegionTotalDepth,floodedRegionStorageVolume,allSinkCellsNo] = ProcessSink(mRows,nCols,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA,elev,ithNbrYOffset,ithNbrXOffset,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,slopeAllNbr,steepestDescentSlope,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection)
%
% function ProcessSink
%

% ��� ����
% flood ���� ����
UNFLOODED = 0;
CURRENT_FLOODED = 1;
OLD_FLOODED = 2;
SINK = 3; 

LISTMAX = mRows * nCols; % model domain cells number
VERY_HIGH = inf;

% ��� ���� �ʱ�ȭ
flood = zeros(mRows,nCols); % flood ���¸� ��Ÿ���� ����
currentFloodedRegionIndex = 0; % �� flooded region ����
floodedRegionIndex = zeros(mRows, nCols); % flooded region ���� ����
floodedRegionCellsNo = zeros(mRows, nCols); % flooded region ���� �� ����
% flooded region ����. �ش� ���ⱸ�� ���� [m]
floodedRegionLocalDepth = zeros(mRows, nCols);
floodedRegionTotalDepth = zeros(mRows, nCols); % Local Depth �� �� [m]
currentFloodedRegionCellsYXList ... % ó���� flooded region �� ��ǥ ��� ����
    = struct('Y',zeros(LISTMAX,1),'X',zeros(LISTMAX,1));
% facet flow slope�� ������� �Ͽ� ProcessSink �Լ����� ������ ���� ������ ���
integratedSlope = facetFlowSlope;

% 1. ������ ���ǵ��� ���� ���鸸�� flood ������ ����Ѵ�.

% 1) ������ ���ǵ��� ���� ����(�� ���� ���� ���� �������)��
%    noFlowDirection���� ����Ѵ�.
% * ���� : SDSFlowDirection���� �� ���� ��� �κе� NaN�̱� ������ �ٸ�
%   ������ ���� �ʿ䰡 ����.
noFlowDirection = isnan(SDSFlowDirection) & ~OUTER_BOUNDARY;

% 2) noFlowDirection�� �ش��ϴ� ������ flood ������ SINK(3)�� ����Ѵ�.
flood(noFlowDirection) = SINK;

% 2. SINK�� ������ ��ǥ�� ������� �����.
[sinkCellsY,sinkCellsX] = find(flood == SINK);

% 1) SINK�� ������ �� ������ �ľ��Ѵ�.
allSinkCellsNo = size(sinkCellsY,1);

% 3. ������ SINK�� ���� SINK�� �̸� �����ϴ� flooded regeion�� ���ⱸ�� ã��
%    ���ⱸ�� ��ǥ�� flooded region ���� ������ SDSNbrY,SDSNbrX�� ����Ѵ�.
%    �̸� ��� SINK�� ���� �ݺ��Ѵ�.
for ithSink=1:allSinkCellsNo

    % 1) SINK ��� �� �ϳ��� ���Ѵ�.
    
    % (1) for�� ���� �ʱ�ȭ
    % flooded region�� ���ⱸ�� ã�Ҵ��� ǥ���ϴ� ���� ���� �ʱ�ȭ
    OUTLET_FOUNDED = false;
    % ���� ó���� flooded region ���� ������ �� ����
    currentFloodedRegionAllCellsNo = 1;
    % �̹��� ó���� flooded region�� ���� ��ȣ�� �ϳ� ������Ŵ
    currentFloodedRegionIndex = currentFloodedRegionIndex + 1;
    
    % (2) �̹��� ó���� SINK�� ��ǥ(Y,X)�� �ҷ���
    currentSinkCellY = sinkCellsY(ithSink,1); % SINK y ��ǥ
    currentSinkCellX = sinkCellsX(ithSink,1); % SINK x ��ǥ

    % (3) SINK ���� CURRENT_FLOODED ���·� ǥ��
    flood(currentSinkCellY,currentSinkCellX) = CURRENT_FLOODED;

    % (4) SINK ��ǥ�� currentFloodedRegionCellsYXList(1)�� �����
    currentFloodedRegionCellsYXList.Y(1) = currentSinkCellY;
    currentFloodedRegionCellsYXList.X(1) = currentSinkCellX;    

    % 2) (�̹��� ó���� SINK�κ��� ���۵�) flooded region�� ���ⱸ�� ã�´�.
    while (OUTLET_FOUNDED == false)

        % (1) while�� ���� �ʱ�ȭ
        % ������� ���� ���� �̿� ���� ã�� ���� ���� �� ���� �ʱ�ȭ
        lowerElev = VERY_HIGH;
        % flooded region�� ���� ���� �����ϴ� �������� 1�� �ʱ�ȭ
        % ��, flooded region�� ù ��° ���������� �ٽ� �����Ѵ�.        
        processingCellIndex = 1;
        
        % (2) flooded region�� �ֺ��� ���� ���� ������� ���� ���� ã�ƶ�.
        % �ݺ��� ������ flooded region�� �� ���� ������ �� �ֱ� ������
        % while �ݺ����� �����
        while (processingCellIndex <= currentFloodedRegionAllCellsNo)
            
            % A. flooded region�� n��° ���� �ֺ� �̿� ���� ���� ������ ������
            %    �����ϴ��� �ľ��Ѵ�. flooded region�� �ֺ��� ���� ����
            %    ������� ���� ���� ã�� �����̴�.
            for tmpNbrX ...
                = currentFloodedRegionCellsYXList.X(processingCellIndex) - 1 ...
                :currentFloodedRegionCellsYXList.X(processingCellIndex) + 1
                for nbrY ...
                    = currentFloodedRegionCellsYXList.Y(processingCellIndex) - 1 ...
                    :currentFloodedRegionCellsYXList.Y(processingCellIndex) + 1                
                
                    % A) �¿찡 ����Ǿ����� Ȯ���ϰ�, �̿� ���� �̿� �� ��ǥ��
                    %    �ٽ� �����Ѵ�.
                    if IS_LEFT_RIGHT_CONNECTED == true
                        
                        if tmpNbrX == X_LEFT_BND                            
                            nbrX = X_MAX;                            
                        elseif tmpNbrX == X_RIGHT_BND                            
                            nbrX = X_INI;                            
                        else
                            nbrX = tmpNbrX;
                        end
                        
                    else
                        
                        nbrX = tmpNbrX;
                        
                    end
                    
                    % A) �̿� ���� ���� ó�� ���� flooded region�� �ش��Ѵٸ�
                    %    ���� �̿� ���� �Ѿ��.
                    %    if flood(nbrY, nbrX) == CURRENT_FLOODED
                    %    * 3x3 â�� �߾� ���� CURRENT_FLOODED ������
                    
                    % B) �̿� ���� ���� ó�� ���� flooded region�� �ƴ϶��,
                    %    �� ������ ���ǵǾ� �ְų� SINK�� ��쿡��
                    %    flooded region �ֺ��� ���� ������� ���� ����
                    %    �������� �˾ƺ���.
                    if (flood(nbrY,nbrX) == UNFLOODED) || ...
                            (flood(nbrY,nbrX) == SINK)
                        
                        % ���� ���� ���� ���� �����
                        % ���� ���� ��ǥ�� �����صд�.
                        if ( elev(nbrY,nbrX) < lowerElev )

                            lowerCellY = nbrY;
                            lowerCellX = nbrX;
                            lowerElev = elev(nbrY,nbrX);    

                        end
                        
                    % C) �̿� ���� ���ⱸ�� ã�� flooded region�̶�� ����
                    %    ���� ó�� ���� flooded region�� ����
                    %    flooded region�� ����Ǿ� �ִٴ� �ǹ��̴�. ���� ��
                    %    flooded region�� ���Ͽ� ���ⱸ�� ã�� �۾���
                    %    �õ��ؾ� �ϸ�, �̸� ���� ���� ó����
                    %    flooded region�� �ش��ϴ� �̿� ���� ���� ó�� ����
                    %    flooded region�� ��Ͽ� ���Խ�Ų��.
                    
                    elseif ( flood(nbrY,nbrX) == OLD_FLOODED )

                        flood(nbrY,nbrX) = CURRENT_FLOODED;
                            
                        currentFloodedRegionAllCellsNo ...
                            = currentFloodedRegionAllCellsNo + 1;

                        currentFloodedRegionCellsYXList.Y(currentFloodedRegionAllCellsNo) = nbrY;
                        currentFloodedRegionCellsYXList.X(currentFloodedRegionAllCellsNo) = nbrX;
                        
                        % ���� ó���� flooded region�� ���ⱸ�� ��ϵ�
                        % �������� �����Ѵ�. �̴� ���� flooded region��
                        % ���ⱸ�� ���� ó�� ���� flooded region�� ���ⱸ��
                        % �ƴ� �� �ֱ� �����̴�.
                        
                        % ���� flooded region�� ���ⱸ ��ǥ �ľ�
                        outletY = SDSNbrY(nbrY,nbrX);
                        outletX = SDSNbrX(nbrY,nbrX);
                        
                        % ���ⱸ�� ��ϵ� ������ ������
                        if floodedRegionCellsNo(outletY,outletX) > 0

                            floodedRegionIndex(outletY,outletX) = 0; 
                            floodedRegionCellsNo(outletY,outletX) = 0;
                            floodedRegionTotalDepth(outletY,outletX) = 0;

                        end
                    end
                end % for (nbrX=
            end % for (nbrY=
            
            % B. flooded region�� processingCellIndex+1 ��° ���� �Ѿ��. 
            processingCellIndex = processingCellIndex + 1; 

        end % while (processingCellIndex<

        % (3) while �ݺ����� ����, flooded region �ֺ��� ���� ���� ���� ����
        %     ã�Ҵ�. ���� �� ���� �������� ���ⱸ������ �Ǵ��Ѵ�.
        
        % A. ���� ���� ���� ���� �� ���� ��迡 �ش��Ѵٸ�, �̸�
        %    flooded region�� �������� ���ⱸ�� �����ϰ� ���ⱸ�� ã�� �ݺ�
        %    ������ ���⼭ ��ģ��.
        if IsBoundary(lowerCellY,lowerCellX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
            
            OUTLET_FOUNDED = true;

        % B. ���� ���� ���� ���� �� ���� ��迡 �ش����� �ʴ´ٸ�, ���� ����
        %    ���� �ֺ� �̿� ���� Ž���Ͽ� ���ⱸ�� ������ �����ϴ��� �˾ƺ���.
        else
            
            % A) ���� ���� ���� �̿� �� �� ���� ó�� ���� flooded region��
            %    �ش����� �����鼭, �Ϻ� ��簡 ���� ū ���� ã�´�.
            %    �� �̿� ���� �����Ѵٸ�,
            %    - �̿��� ��縦 ���� ���� �������� ���� �����ϰ�,
            %    - �� �̿� ���� ��ǥ�� ���� ���� ���� SDSNbrY�� SDSNbrX��
            %      ����ϰ�,
            %    - ���� ���� ���� �ִ� �Ϻ� ��� ����(SDSFlowDirection)��
            %      �� �̿� ���� ����Ű���� �����Ѵ�.
            %    - �������� ���ⱸ�� ã�Ҵٴ� ����� ��ȯ�Ѵ�.
            %    �������� �ʴ´ٸ� ���ⱸ�� ã�� ���ߴٴ� ����� ��ȯ�Ѵ�.
            [SDSNbrY ...
            ,SDSNbrX ...
            ,SDSFlowDirection ...
            ,steepestDescentSlope ...
            ,integratedSlope ...
            ,isTrue] ...
                = FindSDSDryNbr(X_INI,X_MAX,X_LEFT_BND,X_RIGHT_BND ...
                ,QUARTER_PI,lowerCellY,lowerCellX ...
                ,elev,slopeAllNbr,SDSNbrY,SDSNbrX,SDSFlowDirection ...
                ,flood,steepestDescentSlope,integratedSlope ...
                ,ithNbrYOffset,ithNbrXOffset,IS_LEFT_RIGHT_CONNECTED);
           
            % B-1) ���� ���� ���� ���� �������� ���ⱸ���, �ݺ��� ���߾��
            if isTrue == true

                OUTLET_FOUNDED = true;

            % B-2) ���� ���� ���� ���� ���ⱸ�� �ƴ϶��, �̸�
            %     flooded region�� ���Խ�Ű�� �ݺ��� ����Ѵ�.
            else
                
                % ���� ���� ���� flood ������ FLOODED�� ����Ѵ�.
                flood(lowerCellY,lowerCellX) = CURRENT_FLOODED;
                
                % flooded region�� �� ���� �ϳ� ������Ų��.
                currentFloodedRegionAllCellsNo ...
                    = currentFloodedRegionAllCellsNo + 1;
                
                % ���� ���� ���� ��ǥ�� ����Ѵ�.
                currentFloodedRegionCellsYXList.Y(currentFloodedRegionAllCellsNo) ...
                    = lowerCellY;
                currentFloodedRegionCellsYXList.X(currentFloodedRegionAllCellsNo) ...
                    = lowerCellX;
                
                OUTLET_FOUNDED = false;
                
            end % if isTrue == true
        end % if IsBoundary(lowerCellY,lowerCellX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    end % while (OUTLET_FOUNDED)

    % 3) while �ݺ����� ���� flooded region�� ���ⱸ�� ã�Ҵ�. ����
    %    flooded region�� ���ⱸ�� �����Ű��, flooded region ���� �Ӽ���
    %    ����ؾ� �Ѵ�.

    % (1) flooded region ������ ����ȭ
    floodedCellY ...
        = currentFloodedRegionCellsYXList.Y(1:currentFloodedRegionAllCellsNo);
    floodedCellX ...
        = currentFloodedRegionCellsYXList.X(1:currentFloodedRegionAllCellsNo);
    floodedCellIndex = sub2ind([mRows,nCols],floodedCellY,floodedCellX);
    
    % (2) flooded region�� ���ϴ� ��� ������ SDSNbrY,SDSNbrX�� ���ⱸ��
    %     ��ǥ�� ����Ѵ�.
    SDSNbrY(floodedCellIndex) = lowerCellY;
    SDSNbrX(floodedCellIndex) = lowerCellX;
    
    % (3) ���� flooded region�� flood �������� OLD_FLOODED��� ����Ͽ�,
    %     ������ ó���� flooded region�� ���еǵ��� �Ѵ�
    flood(floodedCellIndex) = OLD_FLOODED;
    
    % (4) flooded region�� ���� �Ӽ������� ����Ѵ�.
    % A. flooded region ���� ��ȣ
    floodedRegionIndex(floodedCellIndex) = currentFloodedRegionIndex;
    
    % B. ���ⱸ���� ����
    floodedRegionLocalDepth(floodedCellIndex) ...
        = elev(lowerCellY,lowerCellX) - elev(floodedCellIndex);
    
    % 4) ���� ó�� ���� flooded region�� ���ⱸ�� flooded region�� �Ӽ�������
    %    ����Ѵ�.

    % (1) ���ⱸ�� flooded region ���� ��ȣ�� ������ ����Ѵ�.
    floodedRegionIndex(lowerCellY,lowerCellX) = - currentFloodedRegionIndex;
    
    % (2) ���ⱸ�� flooded region�� �� �� ���� ����Ѵ�.
    floodedRegionCellsNo(lowerCellY,lowerCellX) = currentFloodedRegionAllCellsNo;
    
    % (3) ���ⱸ�� flooded region�� �� floodedRegionLocalDepth ���� ����Ѵ�.
    floodedRegionTotalDepth(lowerCellY,lowerCellX) ...
        = sum(floodedRegionLocalDepth(floodedCellIndex));
    
end % for (ithSink=0 */

% flooded region�� ���差[m^3]
floodedRegionStorageVolume = floodedRegionTotalDepth * CELL_AREA;

end % ProcessSink end