% =========================================================================
%> @section INTRO AccumulateUpstreamFlow
%>
%> - 상부 유역으로부터의 유량과 누적 셀 개수를 구하는 함수
%>
%>  - 주의: 유량의 경우 flooded region의 저수량을 제외한 유량과 제외하지 않은
%>    유량 2가지를 만들 수 있음
%>
%>  - 실제 개발 동기는 다음과 같음. 우선 flooded region의 저수량을 제외하지
%>    않은 유량을 이용할 경우, 유출구의 유량이 flooded region의 다른 셀들과는
%>    두드러지게 크고 이로 인해 유출구의 운반량만 아주 크게 나타나는 현상이
%>    발생함. 이것은 모델의 안정성에 심각한 문제를 야기했고 이를 개선하기 위해
%>    저수량을 제외한 유량을 구함
%>
%>  - 주의: 누적 셀 개수는 모형 내에서 필요하지 않으므로 주석 처리함
%>
%>  - 출력 변수 중 제외 대상: upstreamDischarge2, upstreamCellsNo
%>
%> - History
%>
%>  - 2009-12-31
%>   - flooded region에 해당하는 셀들의 유량과 셀 개수를 보다 현실화함
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @see IsBoundary()
%>
%> @retval upstreamDischarge1           : 연간 유량 [m^3/year]
%> @retval isOverflowing                : flooded region 저수량 초과 여부 태그
%>
%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param CELL_AREA                     : 셀 면적 [m^2]
%> @param sortedYXElev                  : 높은 고도 순으로 정렬한 Y,X 좌표값
%> @param consideringCellsNo            : 함수의 대상이 되는 셀들의 수
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param annualRunoff                  : 연간 지표 유출량 [m/year]
%> @param flood                         : SINK로 인해 물이 고이는 지역(flooded region)
%> @param floodedRegionCellsNo          : 개별 flooded region 셀 개수
%> @param floodedRegionStorageVolume    : 개렴 flooded region 저수량(부피)
%> @param floodedRegionIndex            : 개별 flooded region 색인
%> @param facetFlowDirection            : 무한 유향 알고리듬으로 구한 유향
%> @param e1LinearIndicies              : 무한 유향이 가리키는 다음 셀 색인
%> @param e2LinearIndicies              : 무한 유향이 가리키는 다음 셀 색인
%> @param outputFluxRatioToE1           : 무한 유향에 의해 다음 셀로 분배되는 비율
%> @param outputFluxRatioToE2           : 무한 유향에 의해 다음 셀로 분배되는 비율
%> @param SDSNbrY                       : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                       : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
% =========================================================================
function [upstreamDischarge1,isOverflowing] = AccumulateUpstreamFlow(mRows,nCols,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,sortedYXElev,consideringCellsNo,OUTER_BOUNDARY,annualRunoff,flood,floodedRegionCellsNo,floodedRegionStorageVolume,floodedRegionIndex,facetFlowDirection,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX)
%
% function AccumulateUpstreamFlow
%

% 변수 초기화
% 출력 변수 초기화
% 상부 유역으로부터의 유량[m^3] (flooded region의 저수량을 고려함)
% * 주의: 년간 지표 유출량으로 초기화
upstreamDischarge1 = ones(mRows,nCols) * annualRunoff * CELL_AREA;
upstreamDischarge1(OUTER_BOUNDARY) = 0;
% 상부 유역의 누적 셀 개수
% * 주의: 1로 초기화
upstreamCellsNo = ones(mRows,nCols);
upstreamCellsNo(OUTER_BOUNDARY) = 0;

%--------------------------------------------------------------------------
% mex 파일을 위한 색인
mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;

[upstreamDischarge1 ...              0 상부 유역으로부터의 유량 [m^3]
,inputDischarge ...                  1 상부 유역으로부터의 유량 [m^3]
,dischargeInputInFloodedRegion ...   2 flooded region으로의 유량
,isOverflowing] ...                  3 flooded region 저장량 초과 태그
= EstimateUpstreamFlow ...
(CELL_AREA ...                       0 셀 면적
,consideringCellsNo ...              1 상부 유역 유량과 셀 개수를 구하는 셀 수
,annualRunoff); ...                  2 연간 유출량
%--------------------------------- 입력 변수에서 생략한 부분
%,upstreamCellsNo2 ...                 4 상부 유역의 누적 셀 개수
%,inputCellsNo2 ...                    5 상부 유역의 누적 셀 개수
% -------------------------------- mexGetVariabelPtr 함수로 참조하는 변수들
% upstreamDischarge1 ...             3 상부 유역으로부터의 유출량 초기값
% upstreamCellsNo); ...              4 상부 유역의 누적 셀 개수 초기값
% mexSortedYXElev ...                5 고도순으로 정렬된 색인
% e1LinearIndicies ...               6 다음 셀 색인
% e2LinearIndicies ...               7 다음 셀 색인 
% outputFluxRatio1 ...               8 다음 셀로의 유출 비율
% outputFluxRatio2 ...               9 다음 셀로의 유출 비율
% mexSDSNbrLinearIndicies ...        10 다음 셀 색인
% flood ...                          11 flooded region
% floodedRegionCellsNo ...           12 flooded region 구성 셀 개수
% floodedRegionStorageVolume ...     13 flooded region 저장량 [m^3]

%--------------------------------------------------------------------------
% 앞서 flooded region을 제외한 셀들의 유량과 셀 개수를 구했다. 여기서는
% flooded region에 해당하는 셀들의 유량과 셀 개수를 설정한다.

% 1. flooded region들의 유출구 좌표와 개수를 구한다.
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% 2. 개별 flooded region 구성 셀들의 유량과 셀 개수를 구한다.
for ithFloodedRegion = 1:floodedRegionsNo
    
    % 1) 현재 처리할 flooded region의 유출구 좌표를 확인한다.
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % 2) 현재 처리할 flooded region의 색인 번호를 파악한다.
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % 3) 반복문 변수를 정의한다.
    currentFloodedRegion ...
        = (floodedRegionIndex == floodedRegionIndexNo);
    
    % 4) 유출구가 모델 영역 경계에 위치하는지 확인한다.
    if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)

        % (1) 유출구가 모델 영역 경계에 위치한다면, 1) flooded
        %    region 저수량 초과 여부, 2) 유출구의 유입량과 유출량을 구하지
        %    않았다. 여기서는 이들을 구한다.

        % A. flooded region의 유입량에 지표 유출량 합계를 더한다.
        dischargeInputInFloodedRegion(outletY,outletX) ...
            = dischargeInputInFloodedRegion(outletY,outletX)...
            + floodedRegionCellsNo(outletY,outletX) ...
            * annualRunoff * CELL_AREA;

        % B. flooded region의 저수량과 유입량을 비교한다.
        if dischargeInputInFloodedRegion(outletY,outletX) ...
                > floodedRegionStorageVolume(outletY,outletX)

            % A) 유입량이 flooded region의 저수량을 초과한다면,
            %    유출구의 유입량에 flooded region의 초과 유입량을
            %    더한다.
            inputDischarge(outletY,outletX) ...
                = inputDischarge(outletY,outletX) ...
                + ( dischargeInputInFloodedRegion(outletY,outletX) ...
                - floodedRegionStorageVolume(outletY,outletX) );

            % B) 유입량이 초과했음을 표시한다.
            isOverflowing(outletY,outletX) = true;

        end

        % C. 유출구의 유량에 상부 유역으로부터 유입하는 유량을 더한다.
        % * 주의 : flooded region의 초과 유입량을 포함한 것이다.
        % * 영역 경계에 있는 셀이기 때문에, 여기서 계산되어도 문제가 없다.
        upstreamDischarge1(outletY,outletX) ...
            = upstreamDischarge1(outletY,outletX) ...
            + inputDischarge(outletY,outletX);

        % D. 유출구의 누적 셀 개수에 상부 유역으로부터 유입하는 셀의
        %    갯수를 더한다.
        % * 주의 : flooded region의 셀 개수를 포함한 것이다.
%         upstreamCellsNo(outletY,outletX) ...
%             = upstreamCellsNo(outletY,outletX) ...
%             + inputUpstreamCellsNo(outletY,outletX) ...
%             + floodedRegionCellsNo(outletY,outletX);

    end % IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    
    % 5) 현재 처리할 flooded region의 유량을 구한다.
    % (1) flooded region으로의 유입량이 저수량을 초과했는지 확인한다.
    if isOverflowing(outletY,outletX) == true
        
        % A. 만약 초과했다면, 유출구보다 조금 작은 유량을 대입한다.
        upstreamDischarge1(currentFloodedRegion) ...
            = upstreamDischarge1(outletY,outletX) - annualRunoff * CELL_AREA;
    
    else
        
        % B. 초과하지 않는다면, flooded region으로의 유입량과 이의 지표 유출량
        %    합을 대입한다.
        upstreamDischarge1(currentFloodedRegion) ...
            = dischargeInputInFloodedRegion(outletY,outletX);
        
    end

    % 6) 현재 처리할 flooded region의 셀 개수를 구한다. 유출구의 셀 개수보다
    %    조금 작은 값을 대입한다.
%     upstreamCellsNo(currentFloodedRegion) ...
%             = upstreamCellsNo(outletY,outletX) - 1;
        
end % ithFloodedRegion = 1:

% upstreamCellsNo을 이용하여 저수량을 고려하지 않은 상부 유역으로부터의 유량을
% 구함
% upstreamDischarge2 = upstreamCellsNo .* annualRunoff .* CELL_AREA;

end % AccumulateUpstreamFlow end