% =========================================================================
%> @section INTRO ProcessSink
%>
%> - 유향이 정의되지 않은 셀(SINK)의 유출구를 찾아 이의 좌표를 SDSNbrY,
%>   SDSNbrX에 기록하는 함수
%>
%>  - 주요 알고리듬
%>   - SINK의 이웃 셀 중 가장 비고차가 작은 셀이 대개 SINK의 유출구가 되지만,
%>    이 셀의 유향이 다시 처음의 SINK 셀을 가리키는 경우가 있음. 이 경우에
%>    이 셀은 SINK의 실질적인 유출구라고 보기 힘듦. 따라서 본 함수에서는
%>    유출구를 찾는 과정에서 유출구로 추정되었던 셀을 flooded region
%>    (또는 lake)으로 정의하고, 이 주변을 따라 가장 낮은 셀을 다시 찾음.\n
%>    만약 가장 낮은 셀의 유향이 flooded region에 해당하는 셀을 가리키지
%>    않는다면, 이 셀은 실질적인 유출구가 됨. 하지만 그렇지 않다면 이 셀은
%>    flooded region 목록에 포함되고 위의 과정은 유출구를 찾을 때까지 반복됨.
%>
%>  - History
%>   - 091221
%>    - 주함수에 있던 ProcessSink 함수의 예비 절차를 함수 내부에 포함시킴
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see IsBoundary(), FindSDSDryNbr()
%>
%> @retval flood                        : flooded region
%> @retval SDSNbrY                      : 수정된 다음 셀의 Y 좌표값
%> @retval SDSNbrX                      : 수정된 다음 셀의 X 좌표값
%> @retval SDSFlowDirection             : 수정된 유향
%> @retval steepestDescentSlope         : 수정된 경사
%> @retval integratedSlope              : 수정된 facet flow 경사
%> @retval floodedRegionIndex           : flooded region 색인
%> @retval floodedRegionCellsNo         : flooded region 구성 셀 수
%> @retval floodedRegionLocalDepth      : flooded region 고도와 유출구 고도 차이
%> @retval floodedRegionTotalDepth      : flooded region local depth 총 합
%> @retval floodedRegionStorageVolume   : flooded region 저수량
%>
%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param X_INI                         : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                         : 모형 영역 X 마지막 좌표값(=X+1)
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param QUARTER_PI                	: pi * 0.25
%> @param CELL_AREA                     : 셀 면적 [m^2]
%> @param elev                          : 지표 고도 [m]
%> @param ithNbrYOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
%> @param ithNbrXOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param IS_LEFT_RIGHT_CONNECTED       : 좌우 외곽 경계 연결을 결정
%> @param slopeAllNbr                   : 8방향 이웃 셀과의 경사
%> @param steepestDescentSlope          : 최대하부경사
%> @param facetFlowSlope                : facet flow 경사
%> @param SDSNbrY                       : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                       : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param SDSFlowDirection              : 최대하부경사 유향
% =========================================================================
function [flood,SDSNbrY,SDSNbrX,SDSFlowDirection,steepestDescentSlope,integratedSlope,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth,floodedRegionTotalDepth,floodedRegionStorageVolume] = ProcessSink(mRows,nCols,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA,elev,ithNbrYOffset,ithNbrXOffset,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,slopeAllNbr,steepestDescentSlope,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection)
%
% function ProcessSink
%

% 상수 정의
% flood 상태 정의
UNFLOODED = 0;
CURRENT_FLOODED = 1;
OLD_FLOODED = 2;
SINK = 3; 

LISTMAX = mRows * nCols; % model domain cells number
VERY_HIGH = inf;

% 출력 변수 초기화
flood = zeros(mRows,nCols); % flood 상태를 나타내는 변수
currentFloodedRegionIndex = 0; % 현 flooded region 색인
floodedRegionIndex = zeros(mRows, nCols); % flooded region 색인 분포
floodedRegionCellsNo = zeros(mRows, nCols); % flooded region 구성 셀 개수
% flooded region 깊이. 해당 유출구의 고도차 [m]
floodedRegionLocalDepth = zeros(mRows, nCols);
floodedRegionTotalDepth = zeros(mRows, nCols); % Local Depth 총 합 [m]
currentFloodedRegionCellsYXList ... % 처리할 flooded region 셀 좌표 기록 변수
    = struct('Y',zeros(LISTMAX,1),'X',zeros(LISTMAX,1));
% facet flow slope을 기반으로 하여 ProcessSink 함수에서 수정된 값을 포함한 경사
integratedSlope = facetFlowSlope;

% 1. 유향이 정의되지 않은 셀들만을 flood 변수에 기록한다.

% 1) 유향이 정의되지 않은 셀들(모델 영역 내부 만을 대상으로)을
%    noFlowDirection으로 기록한다.
% * 주의 : SDSFlowDirection에서 모델 영역 경계 부분도 NaN이기 때문에 다른
%   조건을 더할 필요가 없다.
noFlowDirection = isnan(SDSFlowDirection) & ~OUTER_BOUNDARY;

% 2) noFlowDirection에 해당하는 셀들의 flood 변수에 SINK(3)를 기록한다.
flood(noFlowDirection) = SINK;

% 2. SINK인 셀들의 좌표를 목록으로 만든다.
[sinkCellsY,sinkCellsX] = find(flood == SINK);

% 1) SINK인 셀들의 총 개수를 파악한다.
allSinkCellsNo = size(sinkCellsY,1);

% 3. 각각의 SINK에 대해 SINK와 이를 포함하는 flooded regeion의 유출구를 찾고
%    유출구의 좌표를 flooded region 구성 셀들의 SDSNbrY,SDSNbrX에 기록한다.
%    이를 모든 SINK에 대해 반복한다.
for ithSink=1:allSinkCellsNo

    % 1) SINK 목록 중 하나를 택한다.
    
    % (1) for문 변수 초기화
    % flooded region의 유출구를 찾았는지 표시하는 상태 변수 초기화
    OUTLET_FOUNDED = false;
    % 현재 처리할 flooded region 구성 셀들의 총 개수
    currentFloodedRegionAllCellsNo = 1;
    % 이번에 처리할 flooded region의 색인 번호를 하나 증가시킴
    currentFloodedRegionIndex = currentFloodedRegionIndex + 1;
    
    % (2) 이번에 처리할 SINK의 좌표(Y,X)를 불러옴
    currentSinkCellY = sinkCellsY(ithSink,1); % SINK y 좌표
    currentSinkCellX = sinkCellsX(ithSink,1); % SINK x 좌표

    % (3) SINK 셀을 CURRENT_FLOODED 상태로 표기
    flood(currentSinkCellY,currentSinkCellX) = CURRENT_FLOODED;

    % (4) SINK 좌표를 currentFloodedRegionCellsYXList(1)에 기록함
    currentFloodedRegionCellsYXList.Y(1) = currentSinkCellY;
    currentFloodedRegionCellsYXList.X(1) = currentSinkCellX;    

    % 2) (이번에 처리할 SINK로부터 시작된) flooded region의 유출구를 찾는다.
    while (OUTLET_FOUNDED == false)

        % (1) while문 변수 초기화
        % 비고차가 가장 작은 이웃 셀을 찾기 위한 기준 고도 변수 초기화
        lowerElev = VERY_HIGH;
        % flooded region의 개별 셀을 지정하는 변수값을 1로 초기화
        % 즉, flooded region의 첫 번째 셀에서부터 다시 시작한다.        
        processingCellIndex = 1;
        
        % (2) flooded region의 주변을 따라 가장 비고차가 작은 셀을 찾아라.
        % 반복문 내에서 flooded region의 셀 수가 증가할 수 있기 때문에
        % while 반복문을 사용함
        while (processingCellIndex <= currentFloodedRegionAllCellsNo)
            
            % A. flooded region의 n번째 셀의 주변 이웃 셀에 대해 다음의 조건을
            %    만족하는지 파악한다. flooded region의 주변을 따라 가장
            %    비고차가 작은 셀을 찾는 과정이다.
            for tmpNbrX ...
                = currentFloodedRegionCellsYXList.X(processingCellIndex) - 1 ...
                :currentFloodedRegionCellsYXList.X(processingCellIndex) + 1
                for nbrY ...
                    = currentFloodedRegionCellsYXList.Y(processingCellIndex) - 1 ...
                    :currentFloodedRegionCellsYXList.Y(processingCellIndex) + 1                
                
                    % A) 좌우가 연결되었는지 확인하고, 이에 따라 이웃 셀 좌표를
                    %    다시 정의한다.
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
                    
                    % A) 이웃 셀이 현재 처리 중인 flooded region에 해당한다면
                    %    다음 이웃 셀로 넘어간다.
                    %    if flood(nbrY, nbrX) == CURRENT_FLOODED
                    %    * 3x3 창의 중앙 셀은 CURRENT_FLOODED 상태임
                    
                    % B) 이웃 셀이 현재 처리 중인 flooded region이 아니라면,
                    %    즉 유향이 정의되어 있거나 SINK인 경우에는
                    %    flooded region 주변을 따라 비고차가 가장 작은
                    %    셀인지를 알아본다.
                    if (flood(nbrY,nbrX) == UNFLOODED) || ...
                            (flood(nbrY,nbrX) == SINK)
                        
                        % 만약 가장 낮은 고도인 경우라면
                        % 이의 고도와 좌표를 저장해둔다.
                        if ( elev(nbrY,nbrX) < lowerElev )

                            lowerCellY = nbrY;
                            lowerCellX = nbrX;
                            lowerElev = elev(nbrY,nbrX);    

                        end
                        
                    % C) 이웃 셀이 유출구를 찾은 flooded region이라면 현재
                    %    현재 처리 중인 flooded region이 과거
                    %    flooded region과 연결되어 있다는 의미이다. 따라서 두
                    %    flooded region을 합하여 유출구를 찾는 작업을
                    %    시도해야 하며, 이를 위해 과거 처리한
                    %    flooded region에 해당하는 이웃 셀을 현재 처리 중인
                    %    flooded region의 목록에 포함시킨다.
                    
                    elseif ( flood(nbrY,nbrX) == OLD_FLOODED )

                        flood(nbrY,nbrX) = CURRENT_FLOODED;
                            
                        currentFloodedRegionAllCellsNo ...
                            = currentFloodedRegionAllCellsNo + 1;

                        currentFloodedRegionCellsYXList.Y(currentFloodedRegionAllCellsNo) = nbrY;
                        currentFloodedRegionCellsYXList.X(currentFloodedRegionAllCellsNo) = nbrX;
                        
                        % 과거 처리한 flooded region의 유출구에 기록된
                        % 정보들을 제거한다. 이는 과거 flooded region의
                        % 유출구가 현재 처리 중인 flooded region의 유출구가
                        % 아닐 수 있기 때문이다.
                        
                        % 과거 flooded region의 유출구 좌표 파악
                        outletY = SDSNbrY(nbrY,nbrX);
                        outletX = SDSNbrX(nbrY,nbrX);
                        
                        % 유출구에 기록된 정보를 제거함
                        if floodedRegionCellsNo(outletY,outletX) > 0

                            floodedRegionIndex(outletY,outletX) = 0; 
                            floodedRegionCellsNo(outletY,outletX) = 0;
                            floodedRegionTotalDepth(outletY,outletX) = 0;

                        end
                    end
                end % for (nbrX=
            end % for (nbrY=
            
            % B. flooded region의 processingCellIndex+1 번째 셀로 넘어간다. 
            processingCellIndex = processingCellIndex + 1; 

        end % while (processingCellIndex<

        % (3) while 반복문을 통해, flooded region 주변을 따라 가장 낮은 셀을
        %     찾았다. 이제 이 셀이 실질적인 유출구인지를 판단한다.
        
        % A. 만약 가장 낮은 셀이 모델 영역 경계에 해당한다면, 이를
        %    flooded region의 실질적인 유출구로 가정하고 유출구를 찾는 반복
        %    과정을 여기서 마친다.
        if IsBoundary(lowerCellY,lowerCellX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
            
            OUTLET_FOUNDED = true;

        % B. 만약 가장 낮은 셀이 모델 영역 경계에 해당하지 않는다면, 가장 낮은
        %    셀의 주변 이웃 셀을 탐색하여 유출구의 조건을 만족하는지 알아본다.
        else
            
            % A) 가장 낮은 셀의 이웃 셀 중 현재 처리 중인 flooded region에
            %    해당하지 않으면서, 하부 경사가 가장 큰 셀을 찾는다.
            %    이 이웃 셀이 존재한다면,
            %    - 이와의 경사를 가장 낮은 셀에서의 경사로 정의하고,
            %    - 이 이웃 셀의 좌표를 가장 낮은 셀의 SDSNbrY와 SDSNbrX에
            %      기록하고,
            %    - 가장 낮은 셀의 최대 하부 경사 유향(SDSFlowDirection)도
            %      이 이웃 셀을 가리키도록 정의한다.
            %    - 실질적인 유출구를 찾았다는 결과를 반환한다.
            %    존재하지 않는다면 유출구를 찾지 못했다는 결과를 반환한다.
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
           
            % B-1) 만약 가장 낮은 셀이 실질적인 유출구라면, 반복을 멈추어라
            if isTrue == true

                OUTLET_FOUNDED = true;

            % B-2) 만약 가장 낮은 셀이 유출구가 아니라면, 이를
            %     flooded region에 포함시키고 반복을 계속한다.
            else
                
                % 가장 낮은 셀의 flood 변수에 FLOODED로 기록한다.
                flood(lowerCellY,lowerCellX) = CURRENT_FLOODED;
                
                % flooded region의 셀 수를 하나 증가시킨다.
                currentFloodedRegionAllCellsNo ...
                    = currentFloodedRegionAllCellsNo + 1;
                
                % 가장 낮은 셀의 좌표도 기록한다.
                currentFloodedRegionCellsYXList.Y(currentFloodedRegionAllCellsNo) ...
                    = lowerCellY;
                currentFloodedRegionCellsYXList.X(currentFloodedRegionAllCellsNo) ...
                    = lowerCellX;
                
                OUTLET_FOUNDED = false;
                
            end % if isTrue == true
        end % if IsBoundary(lowerCellY,lowerCellX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    end % while (OUTLET_FOUNDED)

    % 3) while 반복문을 통해 flooded region의 유출구를 찾았다. 따라서
    %    flooded region을 유출구와 연결시키고, flooded region 관련 속성을
    %    기록해야 한다.

    % (1) flooded region 셀들의 색인화
    floodedCellY ...
        = currentFloodedRegionCellsYXList.Y(1:currentFloodedRegionAllCellsNo);
    floodedCellX ...
        = currentFloodedRegionCellsYXList.X(1:currentFloodedRegionAllCellsNo);
    floodedCellIndex = sub2ind([mRows,nCols],floodedCellY,floodedCellX);
    
    % (2) flooded region에 속하는 모든 셀들의 SDSNbrY,SDSNbrX에 유출구의
    %     좌표를 기록한다.
    SDSNbrY(floodedCellIndex) = lowerCellY;
    SDSNbrX(floodedCellIndex) = lowerCellX;
    
    % (3) 현재 flooded region의 flood 변수에는 OLD_FLOODED라고 기록하여,
    %     다음에 처리할 flooded region과 구분되도록 한다
    flood(floodedCellIndex) = OLD_FLOODED;
    
    % (4) flooded region의 각종 속성값들을 기록한다.
    % A. flooded region 색인 번호
    floodedRegionIndex(floodedCellIndex) = currentFloodedRegionIndex;
    
    % B. 유출구와의 고도차
    floodedRegionLocalDepth(floodedCellIndex) ...
        = elev(lowerCellY,lowerCellX) - elev(floodedCellIndex);
    
    % 4) 현재 처리 중인 flooded region의 유출구에 flooded region의 속성값들을
    %    기록한다.

    % (1) 유출구에 flooded region 색인 번호를 음수로 기록한다.
    floodedRegionIndex(lowerCellY,lowerCellX) = - currentFloodedRegionIndex;
    
    % (2) 유출구에 flooded region의 총 셀 수를 기록한다.
    floodedRegionCellsNo(lowerCellY,lowerCellX) = currentFloodedRegionAllCellsNo;
    
    % (3) 유출구에 flooded region의 총 floodedRegionLocalDepth 합을 기록한다.
    floodedRegionTotalDepth(lowerCellY,lowerCellX) ...
        = sum(floodedRegionLocalDepth(floodedCellIndex));
    
end % for (ithSink=0 */

% flooded region의 저장량[m^3]
floodedRegionStorageVolume = floodedRegionTotalDepth * CELL_AREA;

end % ProcessSink end