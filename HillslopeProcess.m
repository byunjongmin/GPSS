% =========================================================================
%> @section INTRO HillslopeProcess
%>
%> - 사면작용에 의한 퇴적물 두께 변화율[m/dT]을 구하는 함수
%>  - 변화율(편미분 방정식의 해)은 finite volume 접근법을 이용함 (Tucker et al., 2001).
%>
%> @version 0.8
%> @callgraph
%> @callergraph
%>
%> @retval dSedimentThick           : 사면작용으로 인한 퇴적층 두께 변화율 [m/dT]
%>
%> @param mRows                     : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                     : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y                         : 외곽 경계를 제외한 Y축 크기
%> @param X                         : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                     : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                     : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                     : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                     : 모형 영역 X 마지막 좌표값(=X+1)
%> @param dX                        : 셀 크기 [m]
%> @param dT                        : 만수유량 재현기간 [year]
%> @param CELL_AREA                 : 셀 면적 [m^2]
%> @param sortedYXElev              : 높은 고도 순으로 정렬한 Y,X 좌표값
%> @param consideringCellsNo        : 함수의 대상이 되는 셀들의 수
%> @param s3IthNbrLinearIndicies    : 8 방향 이웃 셀을 가리키는 3차원 색인 배열
%> @param sedimentThick             : 퇴적층 두께 [m]
%> @param DIFFUSION_MODEL           : 확산모델 유형 (1: linear, 2: non-linear Roering et al.(1999))
%> @param kmd                       : 사면작용의 확산 계수 [m2/m year]
%> @param soilCriticalSlopeForFailure : critical hillslope gradient [m/m]
%> @param flood                     : SINK로 인해 물이 고이는 지역(flooded region)
%> @param floodedRegionCellsNo      : 개별 flooded region 셀 개수
%> @param floodedRegionIndex        : 개별 flooded region 색인
%> @param SDSNbrY                   : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                   : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param slopeAllNbr               : 8 이웃 셀과의 경사 [radian]
% =========================================================================
function dSedimentThick = HillslopeProcess(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
    ,dX,dT,CELL_AREA,sortedYXElev,consideringCellsNo,s3IthNbrLinearIndicies ...
    ,sedimentThick,DIFFUSION_MODEL,kmd,soilCriticalSlopeForFailure ...
    ,flood,floodedRegionCellsNo,floodedRegionIndex,SDSNbrY,SDSNbrX,slopeAllNbr)
% 
% function HillslopePrcess
%

%--------------------------------------------------------------------------
% 1. 셀 외부로의 사면작용 (하천을 포함하지 않는 셀 대상)

% 1) 사면작용에 의한 개별 이웃 셀로의 퇴적물 운반능력
% * 주의 : 개별 이웃 셀로의 최대 퇴적물 운반능력 추정은 개별 요소 연산에 의한
%   것이 아니라, 행렬 연산으로 구함

% 상수 정의
LINEAR = 1;

% 변수 초기화
% 개별 이웃 셀로의 퇴적물 운반능력 [m^3/m^2 dT]
transportCapacityToNbrs = zeros(mRows,nCols,8);
% 모든 이웃 셀로의 퇴적물 운반능력 [m^3/m^2 dT]
sumTransportCapacityToNbrs = zeros(mRows,nCols);

% 각각의 이웃 셀에 대한 퇴적물 운반능력과 이의 총 합
for ithNbr = 1:8
    
    % 1. (행렬연산을 쉽게하기 위해) i번째 이웃 셀과의 최대 하부 경사를
    %    2차원 행렬로 저장한다.
    sIthNbrSDSSlope = slopeAllNbr(Y_INI:Y_MAX,X_INI:X_MAX,ithNbr);
    
    % 2. i번째 이웃 셀과의 최대하부경사가 양인 셀
    satisfyingCells = (sIthNbrSDSSlope > 0);
    
    % 3. i번째 이웃 셀로의 퇴적물 운반 능력
    % 1) 변수 초기화
    sTransportCapacityToIthNbr = zeros(Y,X);
    
    % 2) 퇴적물 운반 능력

    if DIFFUSION_MODEL == LINEAR

        % * 선형 모델의 경우
        sTransportCapacityToIthNbr(satisfyingCells) ...
            = dX * ( kmd * sIthNbrSDSSlope(satisfyingCells) ) ...
            .* dT ...                               % 단위변환 [m^3/dT]
            ./ CELL_AREA;                           % 단위변환 [m/dT]

    else
    
        % * 비선형 모델은 Roering et al. (1999) 수식 8 참고
        
        % 주의 : dZ/Sc 가 1보다 크지 않도록 하기 위한 처리 추가. 1보다 클
        % 경우, qs가 음수가 되며 이로 인해 고도가 상승하는 문제가 발생함.
        ratSlpCritSlp = zeros(Y,X);
        ratSlpCritSlp(satisfyingCells) ...
            = sIthNbrSDSSlope(satisfyingCells) ./ soilCriticalSlopeForFailure;
        over099Idx = ratSlpCritSlp >= 0.99; % set threshold 0.99
        ratSlpCritSlp(over099Idx) = 0.99;

        sTransportCapacityToIthNbr(satisfyingCells) ...
            = dX .* ( kmd .* ( sIthNbrSDSSlope(satisfyingCells) ...
            ./ ( 1 - ratSlpCritSlp(satisfyingCells) .^ 2) ) ) ...
            .* dT ...                             % 단위변환 [m^3/dT]
            ./ CELL_AREA;                         % 단위변환 [m/dT]

    end
    
    transportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX,ithNbr) ...
        = sTransportCapacityToIthNbr;
    
    % 4. 모든 이웃 셀로의 퇴적물 운반 능력
    sumTransportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sumTransportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + sTransportCapacityToIthNbr;
    
end

% 2) (높은 고도 순으로) 사면작용에 의한 퇴적물 두께 변화율

% 8방향 이웃 셀 색인 (3차원 변수)
% * 주의: CalcInfinitiveFlow 및 CalcSDSFlow 함수와 달리 이웃 셀 색인의 행과
%   열은 각각 mRows와 nCols임. n은 3차원을 나타내는 3을 붙이기 위해 그냥'null'
%   붙인 것임
n3IthNbrLinearIndicies = nan(mRows,nCols,8);
n3IthNbrLinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX,:) = s3IthNbrLinearIndicies;

%--------------------------------------------------------------------------
% HillslopeProcessMex 함수 부분

% 선형 색인 준비
% mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
% mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;
% 
% [inputFluxMex ...                   0 상부 유역으로부터의 유입율 [m/dT]
% ,outputFluxMex...                   1 이웃 셀로의 총 유출율 [m/dT]
% ,inputFloodedRegionMex ...          2 flooded region으로의 유입율 [m/dT]
%     ] = HillslopeProcessMex(mRows,nCols,consideringCellsNo);
% HillslopeProcessMex 함수가 mexGetVariablePtr 함수로 참조하는 변수
%
% mexSortedIndicies ...            0 . 고도순으로 정렬된 색인
% mexSDSNbrIndicies ...            1 . 다음 셀 색인
% n3IthNbrLinearIndicies ...       2 . 3차원 8방향 이웃 셀 색인
% flood ...                        3 . flooded region
% sedimentThick ...                4 . 퇴적물 두께
% transportCapacityToNbrs ...      5 . 각 이웃 셀로의 사면작용 운반능력
% sumTransportCapacityToNbrs ...   6 . 총 사면작용 운반능력
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% HillslopeProcessMex 이전 함수
%--------------------------------------------------------------------------
% (높은 고도 순으로) 운반능력에 따라 사면물질을 각 이웃 셀에 분배함
% * 주의: 다음의 이유로 flooded region의 유출구인지를 확인하지 않음 1) 단위
%   시간이 1년인 경우에 flooded region으로의 유입율이 저장량을 넘는 일이 거의
%   없음 2) 사면 물질에 의한 이동이므로 flooded region의 유입량이 저장량을
%   초과하더라도 초과량이 유출구를 통해 이동되지 않는다고 가정함 3) 유출구
%   여부에 따라 이웃 셀에 분배하는 방식이 달라지지는 않음

FLOODED = 2;  % flooded region 태그
inputFlux = zeros(mRows,nCols);          % 상부 유역으로부터의 유입량 [m^3/subDT]
inputFloodedRegion = zeros(mRows,nCols); % flooded region으로의 유입량[m^3/subDT]
outputFlux = zeros(mRows,nCols);         % 유향을 따라 다음 셀로의 유출량 [m^3/subDT]

for ithCell=1:consideringCellsNo

    % (1) i번째 셀의 좌표 정보
    ithCellY = sortedYXElev(ithCell,1);
    ithCellX = sortedYXElev(ithCell,2);
 
    % (2) i번째 셀의 퇴적물 두께를 고려한 이웃 셀로의 실제 이동 비율과 양
        
    % A. 실제 이동되는 비율 초기화
    % 참고: 상부 사면에서의 유입량을 고려하지 않음
    scale = 1;
    
    % B. 사면작용에 의한 총 퇴적물 운반능력이 현 퇴적물 두께보다 큰 지를 확인함
    if sumTransportCapacityToNbrs(ithCellY,ithCellX) > sedimentThick(ithCellY,ithCellX)

        % A) 크다면, 퇴적층 두께로 수정함
        outputFlux(ithCellY,ithCellX) = sedimentThick(ithCellY,ithCellX);
        % 전달 비율도 조정함
        scale = sedimentThick(ithCellY,ithCellX) ./ sumTransportCapacityToNbrs(ithCellY,ithCellX);        

    else

        % B) 작다면, 운반능력 그대로 둠
        outputFlux(ithCellY,ithCellX) = sumTransportCapacityToNbrs(ithCellY,ithCellX);

    end

    % (3) 각 이웃 셀의 유입율에 유출율을 더함
    for ithNbr = 1:8

        % A. i번째 이웃 셀로의 유출량이 있는지를 확인함
        if transportCapacityToNbrs(ithCellY,ithCellX,ithNbr) > 0

            % A) i번째 이웃 셀로의 유출이 있는 경우
            
            % (A) i번째 이웃 셀이 flooded region 인지를 확인함
            if flood(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr)) == FLOODED

                % a. flooded region인 경우, inputFloodedRegion의 유입율에
                %    유출율을 더함
                
                % a) flooded region 유출구 좌표
                outletY ...
                    = SDSNbrY(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr));
                outletX ...
                    = SDSNbrX(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr));

                % b) inputFloodedRegion 유입율에 유출율을 더함
                inputFloodedRegion(outletY,outletX) ...
                    = inputFloodedRegion(outletY,outletX) ...
                    + scale * transportCapacityToNbrs(ithCellY,ithCellX,ithNbr);

            else

                % b. flooded region이 아닌 경우, i번째 이웃 셀의 유입율에
                %    유출율을 더함
                inputFlux(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr)) ...
                    = inputFlux(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr)) ...
                    + scale * transportCapacityToNbrs(ithCellY,ithCellX,ithNbr);

            end % if flood(n3IthNbrLinearIndicies(ithCellY,ithCellX,ithNbr)) == FLOODED

        end % if transportCapacityToNbrs(ithCellY,ithCellX,ithNbr) > 0
        
    end % for ithNbr = 1:8

end % ithCell=1:consideringCellsNo

% Debug for Mex file
% diffInputFlux = abs(sum(sum(inputFluxMex-inputFlux)));
% diffOutputFlux = abs(sum(sum(outputFluxMex-outputFlux)));
% diffInputFloodedRegion = abs(sum(sum(inputFloodedRegionMex-inputFloodedRegion)));
% 
% if diffInputFlux +  diffOutputFlux + diffInputFloodedRegion > 0.1
%     warning('Warning: HillslopeMex brings big difference!\n')
% end

%--------------------------------------------------------------------------

% 3) flooded region의 퇴적층 두께 변화율
% 앞서 flooded region을 제외한 셀들을 대상으로 사면물질을 이웃 셀에 분배함.
% 여기서는 flooded region으로 유입한 사면물질로 인한 flooded region의 퇴적층
% 두께 변화율을 구함

% (1) flooded region들의 유출구 좌표와 개수
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% (2) 개별 flooded region 구성 셀들의 퇴적층 두께 변화율
for ithFloodedRegion = 1:floodedRegionsNo
    
    % A. 현재 처리할 flooded region의 유출구 좌표
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % B. 현재 처리할 flooded region의 색인 번호
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % C. 현재 처리할 flooded region을 정의
    currentFloodedRegion ...
        = (floodedRegionIndex == floodedRegionIndexNo);
    
    % D. 퇴적물 유입으로 인해 상승하는 평균 퇴적츠 두께
    inputFlux(currentFloodedRegion) ...
        = inputFlux(currentFloodedRegion) ...
        + ( inputFloodedRegion(outletY,outletX) ...
        / floodedRegionCellsNo(outletY,outletX) );
    
end

% 4) (셀 외부) 사면작용으로 인한 퇴적층 두께 변화율 [m/dT]
% * 주의: 여기서의 사면작용은 토양 포행에 한정되므로, 기반암 고도 변화는 없음
% * 주의: inputFlux 외곽 경계에는 사면작용으로 인핸 모델영역에서 유출되는 양이
%   반영되어 있음.
dSedimentThick = inputFlux - outputFlux;

end % HillslopeProcess end