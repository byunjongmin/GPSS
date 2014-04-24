% =========================================================================
%> @section INTRO EstimateSubDT
%>
%> - 임시 세부 단위시간 동안 하천에 의한 고도 변화율을 이용해 하류 방향으로
%>   다음 셀과의 경사가 0이 되는데 걸리는 시간[trialTime]을 구하여 이를 세부
%>   단위시간으로 정의하는 함수
%>
%>  - 원리: 다음 셀과의 경사가 0이 된다는 의미는 하류 방향의 셀 고도와
%>    동일해졌다는 의미임. 따라서 단위시간이 길어서 상류와 하류의 기복이
%>    역전되는 문제를 해결하기 위한 알고리듬
%>  - 참고 : Tucker의 GOLEM에서 이 알고리듬을 도입하여 개선함
%>
%>  - History
%>   - 100227 GPSS2D08.m
%>    - FluvialProcess 0.6을 도입하였고, minTakenTime을 줄이는 방법은
%>      생략하였음
%>   - 100208 GPSS2d07.m
%>    - 세부 단위 시간만을 구하는 용도로 사용하기 위해 단순하게 만듦
%>   - 100124
%>    - 다음 셀과의 경사가 0가 되는 시간을 파악하는 함수로 만들면서 함수 이름도
%>      EstimateMinTakenTime으로 변경함
%>   - 100104
%>    - flooded region과 이의 유출구의 순 고도 변화량을 구하는 알고리듬을 새로
%>      설계함. 특히 유출구에서 비정상적으로 높은 퇴적물 운반량을 줄이는데
%>      주안점을 두었음
%>   - 091225
%>    - flooded region 내 sink 인 셀에서 FluvialProcess 함수 수행 후 유출구의
%>      고도보다 더 높아지는 현상이 발생하여, 이를 해결하기 위한 시도를 함
%>   - 091221
%>    - 퇴적물로 채워진 flooded region의 유출구 고도가 비정상적으로 높아지는
%>      문제를 해결하고, 퇴적물로 채워지지 않은 flooded region에서는 가장 낮은
%>      지점까지 물질 이동이 일어나도록 함
%>
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval subDT                    : 세부 단위시간 [s]
%> @retval sumSubDT                 : 누적 세부 단위시간 [s]
%> @retval nt                       : 세부 단위시간 추정을 위한 변수
%>
%> @param mRows                     : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                     : 모형 (외곽 경계 포함) 영역 열 개수
%> @param elev                      : 지표 고도 [m]
%> @param dSedimentThick            : 임시 세부 단위 시간 동안의 퇴적물 두께 변화율 [m/subDT]
%> @param dBedrockElev              : 임시 세부 단위 시간 동안의 기반암 고도 변화율 [m/subDT]
%> @param trialTime                 : 임시 세부 단위 시간 [s]
%> @param sumSubDT                  : 누적 세부 단위 시간 [s]
%> @param minSubDT                  : 최소한의 세부 단위 시간 [s]
%> @param basicManipulationRatio    : 반복문 내 임시 세부 단위시간 설정과 관련된 변수의 계수
%> @param nt                        : 반복문 내 임시 세부 단위시간 설정과 관련된 변수의 지수
%> @param bankfullTime              : 만수유량 [s]
%> @param consideringCellsNo        : 하천작용이 일어나는 셀들의 수
%> @param sortedYXElev              : 높은 고도 순으로 정렬한 Y,X 좌표값
%> @param SDSNbrY                   : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                   : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param floodedRegionCellsNo      : 개별 flooded region 셀 개수
%> @param e1LinearIndicies          : 무한 유향이 가리키는 다음 셀 색인
%> @param outputFluxRatioToE1       : 무한 유향에 의해 다음 셀로 분배되는 비율
%> @param e2LinearIndicies          : 무한 유향이 가리키는 다음 셀 색인
%> @param outputFluxRatioToE2       : 무한 유향에 의해 다음 셀로 분배되는 비율
% =========================================================================
function [subDT,sumSubDT,nt]= EstimateSubDT(mRows,nCols,elev,dSedimentThick,dBedrockElev,trialTime,sumSubDT,minSubDT,basicManipulationRatio,nt,bankfullTime,consideringCellsNo,sortedYXElev,SDSNbrY,SDSNbrX,floodedRegionCellsNo,e1LinearIndicies,outputFluxRatioToE1,e2LinearIndicies,outputFluxRatioToE2)
%
% function EstimateSubDT
%

% 1. 반복문 내 변수 초기화
takenTime = inf(mRows,nCols);   % 최종 소요 시간

% 2. 임시 세부 단위시간 동안의 고도 변화율 갱신
dElev = dSedimentThick + dBedrockElev;

%--------------------------------------------------------------------------
% 선형 색인 준비
mexSortedIndicies ...       % sortedYXElev를 위한 선형 색인
    = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies ...       % SDSNbrY,SDSNbrX를 위한 선형 핵인
    = (SDSNbrX-1)*mRows + SDSNbrY;

takenTime ...                    0 하류방향 셀과의 경사가 0이 되는 시간 [s]
    = EstimateSubDTMex ...
 	(mRows ...                   0 . 행 개수
 	,nCols ...                   1 . 열 개수
 	,consideringCellsNo); ...    2 . 하천작용이 발생하는 셀 수
%----------------------------- mexGetVariablePtr 함수로 참조하는 변수
% mexSortedIndicies ...        3 . 고도순으로 정렬된 색인
% e1LinearIndicies ...         4 . 다음 셀 색인
% e2LinearIndicies ...         5 . 다음 셀 색인
% outputFluxRatioToE1 ...      6 . 다음 셀로의 유출 비율
% outputFluxRatioToE2 ...      7 . 다음 셀로의 유출 비율
% mexSDSNbrIndicies ...        8 . 다음 셀 색인
% floodedRegionCellsNo ...     9 . flooded region 구성 셀 수
% dElev ...                    10 . 고도 변화율 [m/trialTime]
% elev ...                     11 . 고도 [m]
%----------------------------- mexGetVariable 함수로 복사해오는 변수
% takenTime ...                0 . inf로 초기화된 출력 변수


%--------------------------------------------------------------------------

% 4. 다음 셀과 경사가 0이 되는데 걸리는 시간[trialTime]이 최소인 시간과 지점
% * 주의: 만약 같은 곳이 2곳 이상이라면, 경사가 큰 곳을 택함. 하지만 이것까지
%         고려하지는 않음.
[minTakenTimeToBeFlat,minLocation] = min(takenTime(:));

%--------------------------------------------------------------------------
% minTakenTime을 보다 늘리는 방법 : GPSS2D07.m 참고
%-------------------------------------------------------------------------

% 5. 세부 단위시간[s]
subDT = (minTakenTimeToBeFlat * trialTime) ... % 단위 변화: [trialTime] -> [s]
    * 0.95;                                         % * 주의: 최소시간보다 작게함

% 6. 다음 임시 세부 단위시간을 구함
% * 원리: 모델 구동 결과, 구동 초기에는 최소 시간이 짧지만 후반부로 갈수록 점점
%         길어짐. 따라서 최소 시간이 길어지면 임시 세부 단위시간도 증가시켜서
%         전체적인 모델 구동 시간을 줄임. 하지만 엄밀한 테스트는 시행하지 않았음

% 1) 최소 시간과 임시 세부 단위시간을 비교
if minTakenTimeToBeFlat > trialTime

    % (1) 최소 시간이 임시 세부 단위시간보다 크다면,
    %     다음 임시 세부 단위시간을 늘리기 위해, 지수를 3 감소시킴
    nt = nt - 3;
    
    % * 주의: 세부 단위시간을 임시 세부 단위시간으로 정의함
    subDT = trialTime;

elseif minTakenTimeToBeFlat < trialTime * basicManipulationRatio

    % (2) 만약 최소 시간이 임시 세부 단위시간의 절반보다 작다면,
    %     다음 임시 세부 단위시간을 줄이기 위해 지수를 1 증가시킴
    nt = nt + 1;

end

% 7. 만약 세부 단위시간이 퇴적물 운반량 수식의 최소 단위보다 작다면,
%    최소 단위를 대입함
if subDT < minSubDT

    subDT = minSubDT;

end

% 8. 만약 세부 단위시간의 누적 합이 만제유량 지속 기간을 초과하면
%    초과하지 않은 양만큼을 세부 단위시간으로 정의함
sumSubDT = sumSubDT + subDT;

if sumSubDT > bankfullTime

    exceededTime = sumSubDT - bankfullTime;

    subDT = subDT - exceededTime;

end

end % EstimateSubDT end