% =========================================================================
%> @section INTRO FluvialProcess
%>
%> - 하천작용에 의한 퇴적층 두께 및 기반암 고도 변화율을 구하는 함수
%>
%> - History
%>  - 110819
%>   - 사면 셀에서 지표유출로 인한 물질이동을 반영함
%>  - 1007
%>   - 하도 내 하상 퇴적물을 명시적으로 포함
%>  - 100321
%>   - flooded region 의 순 퇴적물 두께 변화량 구하는 알고리듬을 간소화함
%>  - 100313
%>   - 기반암 하상 침식을 추가함
%>  - 100224
%>   - flooded region 및 이의 유출구의 순 고도 변화량을 구하는 알고리듬을
%>     전체적으로 수정함. 장기간의 지형 발달을 모의할 경우, 많은 시간이
%>     소요되지 않는 간단한 알고리듬을 도입함
%>  - 100209
%>   - EstimateMinTakenTime 함수와 별개로 하천에 의한 순 고도 변화량을 구하는
%>     함수로 특화 시킴
%>  - 100104
%>   - flooded region과 이의 유출구의 순 고도 변화량을 구하는 알고리듬을 새로
%>     설계함. 특히 유출구에서 비정상적으로 높은 퇴적물 운반량을 줄이는데
%>     주안점을 두었음
%>  - 091225
%>   - flooded region 내 sink 인 셀에서 FluvialProcess 함수 수행 후 유출구의
%>     고도보다 더 높아지는 현상이 발생하여, 이를 해결하기 위한 시도를 함
%>  - 091221
%>   - 퇴적물로 채워진 flooded region의 유출구 고도가 비정상적으로 높아지는
%>     문제를 해결하고, 퇴적물로 채워지지 않은 flooded region에서는 가장 낮은
%>     지점까지 물질 이동이 일어나도록 함
%>
%> @version 0.91
%> @callgraph
%> @callergraph
%> @see IsBoundary()
%>
%> @retval dSedimentThick               : 퇴적층 두께 변화율 [m/subDT]
%> @retval dBedrockElev                 : 기반암 고도 변화율 [m/subDT]
%> @retval dChanBedSed                  : 하도 내 하상 퇴적층 변화율 [m^3/subDT]

%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param CELL_AREA                     : 셀 면적 [m^2]
%> @param FLUVIALPROCESS_COND           : flooded region의 순 퇴적물 두께 변화율을 추정하는 방법
%> @param timeWeight                    : 만수유량 지속기간을 줄이기 위한 침식율 가중치
%> @param sortedYXElev                  : 높은 고도 순으로 정렬한 Y,X 좌표값
%> @param consideringCellsNo            : 함수의 대상이 되는 셀들의 수
%> @param channel                       : 하천 시작 임계치를 넘은 셀
%> @param chanBedSed                    : 하도 내 하상 퇴적층 부피 [m^3]
%> @param hillslope                     : 사면셀
%> @param sedimentThick                 : 퇴적층 두께
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param bankfullDischarge             : 만수유량 [m^3/s]
%> @param bankfullWidth                 : 만수유량시 하폭 [m]
%> @param flood                         : SINK로 인해 물이 고이는 지역(flooded region)
%> @param floodedRegionIndex            : 개별 flooded region 색인
%> @param floodedRegionCellsNo          : 개별 flooded region 셀 개수
%> @param floodedRegionLocalDepth       : flooded region 개별 셀의 깊이 [m]
%> @param floodedRegionTotalDepth       : flooded region 개별 셀 깊이의 총합 [m]
%> @param floodedRegionStorageVolume    : 개별 flooded region 부피 [m^3]
%> @param e1LinearIndicies              : 무한 유향이 가리키는 다음 셀 색인
%> @param e2LinearIndicies              : 무한 유향이 가리키는 다음 셀 색인
%> @param outputFluxRatioToE1           : 무한 유향에 의해 다음 셀로 분배되는 비율
%> @param outputFluxRatioToE2           : 무한 유향에 의해 다음 셀로 분배되는 비율
%> @param SDSNbrY                       : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                       : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param integratedSlope               : 수정된 facet flow 경사 [radian]
%> @param kfa                           : 
%> @param mfa                           : 하천에 의한 퇴적물 운반 수식에서 유량의 지수
%> @param nfa                           : 하천에 의한 퇴적물 운반 수식에서 경사의 지수
%> @param kfbre                         : 기반암 하상 연약도
%> @param fSRho                         : 운반되는 퇴적물의 평균 밀도
%> @param g                             : 중력가속도
%> @param nB                            : 기반암 하상 하도에서의 Manning 저항 계수
%> @param mfb                           : 기반암 하상 침식 수식에서 유량의 지수
%> @param nfb                           : 기반암 하상 침식 수식에서 경사의 지수
%> @param subDT                         : 세부 단위 시간 [s]
%> @param dX                            : 셀 크기 [s]
% =========================================================================
function [dSedimentThick,dBedrockElev,dChanBedSed] = FluvialProcess(mRows,nCols,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,FLUVIALPROCESS_COND,timeWeight,sortedYXElev,consideringCellsNo,channel,chanBedSed,hillslope,sedimentThick,OUTER_BOUNDARY,bankfullDischarge,bankfullWidth,flood,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth,floodedRegionTotalDepth,floodedRegionStorageVolume,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,subDT,dX)
%
% function FluvialProcess
%

% 상수 초기화
% FLUVIALPROCESS_COND 태그
SIMPLE = 1;
% DETAIL = 2;

% 변수 초기화

transportCapacityForShallow ...     % 지표유출로 인한 물질이동
    = ( bankfullWidth ...
    .* ( kfa .* ( bankfullDischarge ./ bankfullWidth ) .^ mfa ...
    .* integratedSlope .^ nfa ) ) .* subDT ...
    .* timeWeight;                  % 만제유량 지속기간 축소를 위한 가중치
% 보완점: 현재로는 하천에 의한 퇴적물 운반능력과 동일하게 설정함. 추후 매개변수
% 보정이 필요함

transportCapacity ...               % 퇴적물 운반 능력[m^3/subDT]
    = ( bankfullWidth ...
    .* ( kfa .* ( bankfullDischarge ./ bankfullWidth ) .^ mfa ...
    .* integratedSlope .^ nfa ) ) .* subDT ...
    .* timeWeight;                  % 만제유량 지속기간 축소를 위한 가중치

% 기반암 하상 침식율[m^3/subDT]
% * 가정: 셀 전체가 아닌 하도를 따라 침식되는 부피를 구함 (Tucker et al.,1994)
bedrockIncision ...
    = ( dX .* bankfullWidth ...
    .* (kfbre * fSRho * g * nB^mfb ...
    .* (bankfullDischarge ./ bankfullWidth).^ mfb ...
    .* integratedSlope .^ nfb ) ) .* subDT ...
    .* timeWeight;                  % 만제유량 지속기간 축소를 위한 가중치

%--------------------------------------------------------------------------
% EstimateDElevByFluvial.c 부분

% flooded region을 제외한 셀들의 퇴적층 두께 및 기반암 고도 변화율 추정

% 선형 색인 준비
mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;

[dSedimentThick ...      % 퇴적층 두께 변화율 [m^3/m^2 subDT]
,dBedrockElev ...        % 기반암 고도 변화율 [m^3/m^2 subDT]
,dChanBedSed ...         % 하도 내 하상 퇴적물 변화율 [m^3/subDT]
,inputFlux ...           % 상부 유역으로 부터의 유입율 [m^3/subDT]
,outputFlux...           % 하류로의 유출율 [m^3/subDT]
,inputFloodedRegion ...  % flooded region으로의 유입율 [m^3/subDT]
,isFilled] ...           % 상부 유입으로 인한 flooded region의 매적 유무
= EstimateDElevByFluvialProcess ...
(dX ...                              % 0 . 셀 크기
,mRows ...                           % 1 . 행 개수
,nCols ...                           % 2 . 열 개수
,consideringCellsNo);                % 3 . 하천작용이 발생하는 셀 수
% ------------------------------------% 이하는 mexGetVariablePtr로 부름
% mexSortedIndicies ...              % 4 . 고도순으로 정렬된 색인
% e1LinearIndicies ...               % 5 . 다음 셀 색인
% e2LinearIndicies ...               % 6 . 다음 셀 색인
% outputFluxRatioToE1 ...            % 7 . 다음 셀로의 유출 비율
% outputFluxRatioToE2 ...            % 8 . 다음 셀로의 유출 비율
% mexSDSNbrIndicies ...              % 9 . 다음 셀 색인
% flood ...                          % 10 . flooded region
% floodedRegionCellsNo ...           % 11 . flooded region 구성 셀 수
% floodedRegionStorageVolume ...     % 12 . flooded region 저장량
% bankfullWidth ...                  % 13 . 만제유량시 하폭
% transportCapacity ...              % 14 . 최대 퇴적물 운반능력
% bedrockIncision ...                % 15 . 기반암 하상 침식율
% chanBedSed ...                     % 16 . 하도내 하상 퇴적층 부피
% sedimentThick ...                  % 17 . 퇴적층 두께
% hillslope ...                      % 18 . 사면셀
% transportCapacityForShallow ...    % 19 . 지표유출로 인한 물질이동
%--------------------------------------------------------------------------

% (flooded region 고도 변화율을 구하기 위한) 차원 변화 [m^3 -> m]
inputFlux = inputFlux ./ CELL_AREA;
outputFlux = outputFlux ./ CELL_AREA;
inputFloodedRegion ...
    = inputFloodedRegion ./ (floodedRegionCellsNo * CELL_AREA);

% 하천을 포함하지 않은 셀로의 유입율을 퇴적물 두께 변화율에 반영함
dSedimentThick(~channel) = dSedimentThick(~channel) + inputFlux(~channel);

%--------------------------------------------------------------------------
% 앞서 flooded region을 제외한 셀들에서 퇴적물 두께 및 기반암 고도 변화율을
% 구함. 여기서는 flooded region 셀들의 퇴적물 두께 변화율을 구하고, flooded
% region 유출구의 퇴적물 두께 변화율을 재계산함.

% 상수
X_INI = 1;
X_MAX = nCols - 1;
Y_INI = 2;
Y_MAX = mRows - 1;

% 변수 초기화
% flooded region 유출구의 고도 변화율[m/subDT]이 양의 값을 가질 때, 이를
% flooded region 셀 개수로 나눈 값
sedimentDepthToBeAdded = zeros(mRows,nCols);
% flooded region의 고도가 상승할 경우, flooded region에 비해 유출구의 고도가
% 상대적으로 상승하는 비율(일반적으로 < 1)
outletWeightToBeAdded = 0.5;
% flooded region의 고도가 동일하게 설정되는 것을 방지하기 위한 난수 정의
verySmallRandomValues = rand(mRows,nCols) * 0.001;

% 1. 퇴적물 두께와 기반암 고도 변화율을 합하여 고도 변화율을 구함
% * flooded region의 퇴적물 두께 변화율에 결정적 영향을 주는 것은 유출구의
%   고도 변화율임
dElev = zeros(mRows,nCols);
dElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = dSedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
    + dBedrockElev(Y_INI:Y_MAX,X_INI:X_MAX);

% 2. flooded region 유출구의 좌표와 셀 개수
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% 3. 개별 flooded region과 유출구의 퇴적물 두께 변화율을 구함
for ithFloodedRegion = 1:floodedRegionsNo
    
    % 1) 현재 처리할 flooded region의 유출구 좌표
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % 2) 현재 처리할 flooded region의 색인 번호
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % 3) 현재 처리할 flooded region을 정의
    currentFloodedRegion = ...
        (floodedRegionIndex == floodedRegionIndexNo);
    
    % 3) 유출구가 외곽 경계에 위치하는지 확인함
    if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)

        % (1) 유출구가 외곽 경계에 위치한다면, 1) 유입 퇴적물의 저장량 초과 여부,
        %     2) 유출구의 퇴적물 유입율과 유출율, 3) 유출구의 퇴적물 두께
        %     변화율을 앞에서 구하지 않았으므로 여기서 이를 구함
        % * 주의: 실제 의미있는 것은 1)과 2)의 유입율임. 이는 외곽 경계의
        %   퇴적물 두께 및 고도 변화율은 의미가 없기 때문임

        % a. flooded region으로의 유입율[m/subDT]이 저장량[m^3/m^2]을
        %    초과했는지 확인함
        if inputFloodedRegion(outletY,outletX) > ...
            floodedRegionTotalDepth(outletY,outletX)

            % a) 유입율이 저장량을 초과한다면,
            % (a) 유출구의 유입율에 flooded region 초과 평균 유입율을 더함
            inputFlux(outletY,outletX) ...
                = inputFlux(outletY,outletX) ...
                + (inputFloodedRegion(outletY,outletX) ...      % [m/subDT]
                - floodedRegionTotalDepth(outletY,outletX)) ... % [m/subDT]
                / floodedRegionCellsNo(outletY,outletX);

            % * 유입 퇴적물이 저장율을 초과했다고 표시함
            isFilled(outletY,outletX) = true;

        % else

            % b) 유입율이 저장량을 초과하지 않는다면, 유출구의 유입율에 0을 입력            

        end

        % b. (외곽 경계에 위치한) 유출구의 퇴적물 유출율
        % * 유출구가 영역 경계에 위치하기 때문에, 하천작용에 의한 퇴적물 운반
        %   수식을 사용할 수 없음. 외곽 경계로 유입된 물질은 즉시 제거되기
        %   때문에 외곽 경계에서의 유출율은 곧 유입율임
        % * 주의: 하지만 outputFlux는 이후 사용하지 않으므로 주석 처리
        % outputFlux(outletY,outletX) = inputFlux(outletY,outletX);

        % c. 유출구의 퇴적물 두께 변화율 [m/subDT]
        % * 주의: 0으로 무의미하므로 주석 처리
        % dSedimentThick(outletY,outletX) ...
        %     = inputFlux(outletY,outletX) - outputFlux(outletY,outletX);
        %     => 0
        
        % d. 유출구의 고도 변화율[m/subDT]을 갱신
        % * 주의: 0으로 무의미하므로 주석 처리
        % dElev(outletY,outletX) = dSedimentThick(outletY,outletX);
        %     => 0

    end % if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    
    
    % 6) flooded region으로 유입한 퇴적물이 저장량을 초과했는지 확인함
    if isFilled(outletY,outletX) == true

        % (1) 유입한 퇴적물이 저장량을 초과했다면, flooded region 유출구의
        %     고도가 상승했는지 확인함         
        if dElev(outletY,outletX) > 0

            % A. 유출구의 고도가 상승했다면(조건 1,6) 유출구의 유출율이 유입된
            %    퇴적물보다 적다는 의미. 따라서 flooded region의 고도는 유출구
            %    고도 이상으로 상승함.

            % A) flooded region이 유출구 고도 이상으로 상승하는 높이 [m/subDT]
            sedimentDepthToBeAdded(outletY,outletX) ...
                = dElev(outletY,outletX) ...
                / ( floodedRegionCellsNo(outletY,outletX) ...
                + outletWeightToBeAdded );

            % B) flooded region의 퇴적물 두께 변화율을 상승하는 높이로 증가시킴
            dSedimentThick(currentFloodedRegion) ...
                = floodedRegionLocalDepth(currentFloodedRegion) ...
                + sedimentDepthToBeAdded(outletY,outletX) ...
                + verySmallRandomValues(currentFloodedRegion);

            % C) 유출구의 퇴적물 두께 변화율 조정
            dSedimentThick(outletY,outletX) ...
                = sedimentDepthToBeAdded(outletY,outletX) ...
                * outletWeightToBeAdded;

        else % dElev(outletY,outletX) <= 0

            % B. 유출구의 고도가 감소하거나(조건 2,7) 같다면(조건 11,13)
            %    flooded region 고도는 예전 유출구의 고도만큼 상승함
            % * 유출구의 퇴적물 두께 변화율은 재계산하지 않음

            % A) flooded region의 순 퇴적물 두께 변화율을 예전 유출구 고도만큼
            %    상승시킴
            dSedimentThick(currentFloodedRegion) ...
                = floodedRegionLocalDepth(currentFloodedRegion) ...
                + verySmallRandomValues(currentFloodedRegion);

        end % dElev(outletY,outletX) > 0

    else % isFilled(outletY,outletX) == false

        % (2) 유입한 퇴적물이 저장량보다 작은 경우
        % * 주의: flooded region으로 유입한 퇴적물이 가장 깊은 곳부터 퇴적되는
        %   알고리듬은 flooded region이 넓게 나타나는 지형(특히 rand 함수를
        %   함수를 이용하여 만든 초기 지형)에서는 상당히 많은 시간이 소요되기
        %   때문에, 장기간의 지형 발달을 모의할 때는 간단한 알고리듬을 이용함

        % A. 간단한 알고리듬을 이용할 것인지를 확인함
        if FLUVIALPROCESS_COND == SIMPLE

            % A) 간단한 알고리듬을 이용한다면,
            % (A) flooded region으로의 퇴적물 유입으로 상승하는 평균
            %     높이[m^3/m^2]를 구함
            increasingHeightByInput = inputFloodedRegion(outletY,outletX);
            % * 주의: floodedRegionCellsNo(outletY,outletX) 나눌 필요 없음

            % (B) flooded region의 퇴적물 두께 변화율을 평균 높이만큼 증가시킴
            dSedimentThick(currentFloodedRegion) ...
              = increasingHeightByInput ...
              + verySmallRandomValues(currentFloodedRegion);            

        else % FLUVIALPROCESS_COND == DETAIL

            % B) 자세한 알고리듬을 이용한다면,
            % (A) 유입한 퇴적물은 flooded region의 가장 낮은 지점을 채우면서
            %     상승하며, 이로 인해 유입율이 다할 때까지 flooded region의
            %     최대 깊이는 점점 작아짐

            % a. 현재 처리할 flooded region의 local depth를 추출함
            currentLocalDepth = floodedRegionLocalDepth(currentFloodedRegion);

            % b. flooded region으로의 퇴적물 유입으로 상승하는 높이[m^3/m^2]
            increasingHeightByInput = inputFloodedRegion(outletY,outletX);
            % * 주의: floodedRegionCellsNo(outletY,outletX) 나눌 필요 없음

            % c. 현재 처리할 flooded region이 2개 이상의 셀로 구성되었는지 확인
            if floodedRegionCellsNo(outletY,outletX) > 1

                % a) 현재 처리할 flooded region이 2개 이상의 셀로 구성되어
                %    있다면, 유입한 퇴적물은 가장 깊은 바닥을 먼저 채움

                % (a) local depth를 내림차순으로 정렬함
                sortedCurrentLocalDepth = sort(currentLocalDepth,'descend');

                % (b) 유입한 퇴적물이 flooded region의 가장 깊은 바닥을 채우고
                %     남는 양[m^3/m^2]을 퇴적물 유입으로 상승하는 높이로 정의
                remainedInput = increasingHeightByInput;

                % (c) 유입 퇴적물의 양이 다할 때까지 flooded region의 바닥을 채움
                isDone = false;

                while (isDone == false)

                    % 1. 현재 가장 깊은 셀(local depth가 가장 큰 셀)의 깊이를 파악함
                    maxLocalDepth = max(sortedCurrentLocalDepth(:));

                    % 2. 현재 가장 깊은 셀(들)이 몇 개인지를 파악함
                    maxLocalDepthCellsNo ...
                      = find(sortedCurrentLocalDepth == maxLocalDepth);
                    maxLocalDepthCellsNo = size(maxLocalDepthCellsNo,1);

                    % 3. 현재 가장 깊은 셀(들)의 수가 flooded region의 셀
                    %    수와 동일한지를 확인함
                    if maxLocalDepthCellsNo ...
                            ~= floodedRegionCellsNo(outletY,outletX)

                        % 1) 동일하지 않다면, 현재 flooded region의 깊이가
                        %    서로 다르다는 의미. 따라서 flooded region의
                        %    가장 깊은 바닥부터 채움

                        % (1) 다음으로 깊은 셀의 깊이를 파악
                        secondMaxLocalDepth = sortedCurrentLocalDepth ...
                            (maxLocalDepthCellsNo+1,1);

                        % (2) 현재 가장 깊은 셀과 다음으로 깊은 셀과의 차이
                        depthDifference ...
                            = maxLocalDepth - secondMaxLocalDepth;

                        % (3) 가장 깊은 셀(들)에 퇴적될 양[m^3/m^2]
                        depthToBeDeposited ...
                            = depthDifference * maxLocalDepthCellsNo;

                        % (4) 남아있는 유입 퇴적물의 양을 현재 퇴적될 양과 비교
                        if remainedInput > depthToBeDeposited

                            % A. 남아있는 유입 퇴적물의 양이 퇴적될 양보다
                            %    크다면, 남아있는 유입 퇴적물로 현재 가장
                            %    깊은 셀(들)을 채우고 가장 깊은 셀(들)의
                            %    깊이를 다음으로 깊은 셀의 깊이로 변경함
                            sortedCurrentLocalDepth ...
                                (1:maxLocalDepthCellsNo,1) ...
                                    = secondMaxLocalDepth;

                            remainedInput ...
                                = remainedInput - depthToBeDeposited;

                        else % remainedInput <= depthToBeDeposited

                            % B. 남아있는 유입 퇴적물의 양이 퇴적될 양보다
                            %    작다면, 마지막으로 남아있는 유입 퇴적물이
                            %    가장 깊은 셀(들)을 채우면서 상승할 높이를
                            %    구함

                            % A) 남아있는 유입 퇴적물의 양을 가장 깊은
                            %    셀(들)의 수만큼 나눔
                            finalDepthToBeDeposited ...
                                = remainedInput / maxLocalDepthCellsNo;

                            % B) 최종 flooded region의 최대 깊이를 구함
                            maxDepth ...
                            = maxLocalDepth - finalDepthToBeDeposited;

                            % C) 가장 깊은 셀의 깊이를 수정
                            sortedCurrentLocalDepth ...
                                (1:maxLocalDepthCellsNo,1) = maxDepth;

                            % D) 최대 깊이를 구했으므로 반복을 마침
                            isDone = true;

                        end % remainedInput > depthToBeDeposited

                    else  % maxLocalDepthCellsNo ...
                          %   ~= floodedRegionCellsNo(outletY,outletX)

                        % 2) 동일하다면, flooded region 전체 깊이가
                        %    동일하다는 의미. 따라서 남아있는 유입 퇴적물의
                        %    양을 flooded region 셀 수로 나누고 이를 최대
                        %    깊이에서 뺌

                        % (1) 남아있는 유입 퇴적물의 양을 가장 깊은 셀(들)의
                        %     수만큼 나눔
                        finalDepthToBeDeposited ...
                            = remainedInput / maxLocalDepthCellsNo;

                        % (2) 최종 flooded region의 최대 깊이를 구함
                        maxDepth ...
                            = maxLocalDepth - finalDepthToBeDeposited;

                        % (3) 최대 깊이를 구했으므로 반복을 멈춤
                        isDone = true;                            

                    end % if maxLocalDepthCellsNo ...

                end % while (isDone == false)

            else % floodedRegionCellsNo(outletY,outletX) <= 1

                % b) 현재 처리할 flooded region이 하나의 셀이라면, 유입한
                %    퇴적물 양 자체가 flooded region의 증가하는 높이가 됨

                % (a) flooded region의 최대 깊이는 local depth - flooded
                %     region으로의 퇴적물 유입으로 증가하는 높이)임
                % * 주의: flooded region 셀이 하나일 경우, 이의 local depth는
                %   total depth와 동일함
                maxDepth ...
                    = ( floodedRegionTotalDepth(outletY,outletX) ...
                        - increasingHeightByInput );

            end % floodedRegionCellsNo(outletY,outletX) > 1

            % * 유출구의 고도 증가 여부를 확인할 필요없이 flooded region 최대
            %   깊이까지 순 퇴적물 두께 변화량을 증가하면 됨
            % * 조건(4,5,9,10/3,8/12,13)
            
            satisfyingCells = ...
                currentFloodedRegion & (floodedRegionLocalDepth > maxDepth);

            dSedimentThick(satisfyingCells) ...
                = floodedRegionLocalDepth(satisfyingCells) - maxDepth ...
                + verySmallRandomValues(satisfyingCells);

        end % if FLUVIALPROCESS_COND 

    end % isFilled(outletY,outletX) == true
        
end % for ithFloodedRegion = 1:floodedRegionsNo

%--------------------------------------------------------------------------
% 외곽 경계로의 유입율을 퇴적물 두께 변화율에 반영함 [m/subDT]
% * 주의: inputFlux의 외곽 경계값을 이용하여 모델 영역의 평균 침식율을 구할
%   경우 영역 셀 개수로 나누어야 함

dSedimentThick(OUTER_BOUNDARY) = inputFlux(OUTER_BOUNDARY);

end % FluvialProcess end