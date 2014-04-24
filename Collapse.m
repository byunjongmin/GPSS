% =========================================================================
%> @section INTRO Collapse
%>
%> - 불안정한 셀에서 활동을 발생시켜 사면 물질을 사면 하부로 연쇄적으로
%>   이동시키는 함수.
%>  - 주의: FluvialProcess 함수에서는 흐름분배를 위해 무한 유향 알고리듬을
%>    용하였지만, 이 함수에서는 최대하부경사 유향 알고리듬을 이용함. 이는 무한
%>    유향 알고리듬을 이용할 경우 오랜 연산 시간이 필요하기 때문임.
%>  - 참고: Tucker(1994)의 GOLEM에 있는 알고리듬을 수정함.
%>
%> - History
%>  - 2010-09-28
%>   - RapidMassMovement 함수의 실행 속도를 향상하기 위해 CollapseMex.c를 도입함.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%> @see ProcessSink(), IsBoundary(), CalcSDSFlow()
%>
%> @retval dBedrockElev                 : 기반암 고도 변화율 [m/dT]
%> @retval dSedimentThick               : 퇴적층 두께 변화율 [m/dT]
%> @retval SDSNbrY                      : 활동 발생 후 갱신된 다음 셀 Y 좌표값
%> @retval SDSNbrX                      : 활동 발생 후 갱신된 다음 셀 X 좌표값
%> @retval flood                        : 활동 발생 후 갱신된 flooded region
%>
%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y                             : 외곽 경계를 제외한 Y축 크기
%> @param X                             : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                         : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                         : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                         : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                         : 모형 영역 X 마지막 좌표값(=X+1)
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param CELL_AREA                     : 셀 면적 [m^2]
%> @param DISTANCE_RATIO_TO_NBR         : 셀 크기를 기준으로 이웃 셀간 거리비 [m]
%> @param ROOT2                         : sqrt(2)
%> @param QUARTER_PI                	: pi * 0.25
%> @param oversteepSlopes               : 불안정한 셀
%> @param oversteepSlopesIndicies       : (고도순으로 정렬된) 불안정한 셀 색인
%> @param oversteepSlopesNo             : 불안정한 셀 개수
%> @param rapidMassMovementType         : 활동 유형
%> @param soilCriticalSlopeForFailure   : 천부활동 발생 임계 사면각 [radian]
%> @param rockCriticalSlopeForFailure   : 기반암활동 발생 임계 사면각 [radian]
%> @param bedrockElev                   : 지표 고도 [m]
%> @param sedimentThick                 : 퇴적층 두께 [m]
%> @param elev                          : 지표 고도 [m]
%> @param SDSNbrY                       : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                       : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param flood                         : SINK로 인해 물이 고이는 지역(flooded region)
%> @param dX                            : 셀 크기
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param IS_LEFT_RIGHT_CONNECTED       : 좌우 외곽 경계 연결을 결정
%> @param ithNbrYOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
%> @param ithNbrXOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
%> @param sE0LinearIndicies             : 외곽 경계를 제외한 중앙 셀
%> @param s3IthNbrLinearIndicies        : 8 방향 이웃 셀을 가리키는 3차원 색인 배열
% =========================================================================
function [dBedrockElev,dSedimentThick,SDSNbrY,SDSNbrX,flood] = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI,oversteepSlopes,oversteepSlopesIndicies,oversteepSlopesNo,rapidMassMovementType,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure,bedrockElev,sedimentThick,elev,SDSNbrY,SDSNbrX,flood,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function Collapse
%

% 상수
SOIL = 1;           % 천부활동
% ROCK = 2;         % 기반암활동

FLOODED = 2;                            % flooded region 태그

% 변수 초기화
minDElevByCollapse = - 0.001;           % 무한 반복을 방지하기 위한 변수. 주의: 음수
facetFlowSlope = nan(mRows,nCols);      % (무한 유향 알고리듬을 이용한) 사면 경사
dBedrockElev = zeros(mRows,nCols);      % 기반암 고도 변화율
dSedimentThick = zeros(mRows,nCols);    % 퇴적층 두께 변화율

% 1. 활동 유형에 따라 (이동율을 추정하기 위한) 유효 고도와 활동이 발생하게 되는
% 임계 고도차를 정의함

% * 주의: 천부활동과 기반암활동이 발생하는 임계 고도차이는 서로 다름
% * 원리: 기반암 고도에 퇴적층 두께를 더한 지표 고도와 다음 셀의 지표 고도를
%   이용하여 구한 경사는 천부활동 발생을 설명할 수 있지만, 기반암활동 원인을
%   설명하지 못함. 기반암활동의 경우는 기반암 고도와 다음 셀의 지표고도와의
%   차이가 보다 설득력 있음.

% 1) 중앙 셀과 다음 셀 색인과의 차이
indicies = reshape(1:mRows*nCols,[mRows,nCols]);    % 중앙 셀 색인
nbrIndicies = (SDSNbrX - 1) * mRows + SDSNbrY;      % 다음 셀 색인
dIndicies = indicies - nbrIndicies;                 % 중앙 셀 색인과 다음 셀 색인 차이

% 2) 다음 셀이 직각 방향인 셀
orthogonalDownstream = false(mRows,nCols);          % 다음 셀이 직각 방향인 셀
orthogonalDownstream(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = (mod(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX),mRows) == 0) ...
    | (abs(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX)) == 1);

% 3) 다음 셀 방향에 따른 천부활동이 발생하는 임계 고도차
% * 주의: 기반암활동인 경우에도 하류에서는 천부활동처럼 퇴적층만 이동하므로
%   soilCriticalHeight가 필요함. 따라서 조건문 밖에 둠.
soilCriticalHeightForOrtho = soilCriticalSlopeForFailure * dX;
soilCriticalHeightForDiag = soilCriticalSlopeForFailure * dX * ROOT2;
soilCriticalHeight = zeros(mRows,nCols);
soilCriticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = ones(Y,X) * soilCriticalHeightForDiag;
soilCriticalHeight(orthogonalDownstream) = soilCriticalHeightForOrtho;

% 4) 활동이 발생하는 임계 고도차 정의
if rapidMassMovementType == SOIL
    
    % 천부활동일 경우    
    effectiveElev = bedrockElev + sedimentThick;    % 천부활동의 유효 고도
    criticalHeight = soilCriticalHeight;            % 천부활동의 임계 고도차
    
else % rapidMassMovementType == ROCK
    
    % 기반암활동일 경우
    % 다음 셀 방향에 따른 임계 고도차
    rockCriticalHeightForOrtho = rockCriticalSlopeForFailure * dX;
    rockCriticalHeightForDiag = rockCriticalSlopeForFailure * dX * ROOT2;
    rockCriticalHeight = zeros(mRows,nCols);
    rockCriticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = ones(Y,X) * rockCriticalHeightForDiag;
    rockCriticalHeight(orthogonalDownstream) = rockCriticalHeightForOrtho;
        
	effectiveElev = bedrockElev;                    % 기반암활동의 유효 고도
    criticalHeight = rockCriticalHeight;            % 기반암활동의 임계 고도차
    
end

% 2. 불안정한 개별 셀들에서 활동이 발생하고 이로 인한 고도 변화가 발생함

[oversteepSlopesY,oversteepSlopesX] ...             % 불안정 셀 좌표 목록
    = ind2sub([mRows nCols],oversteepSlopesIndicies);

for ithCell = 1:oversteepSlopesNo

    % 1) 반복문 변수 초기화
    isBoundary = false;     % 물질이 영역 경계에 도착했는지 표시하는 변수
    dBedrockElevByIthCell = zeros(mRows,nCols); % i번째 불안정 셀로 인한 변화율
    dSedimentThickByIthCell = zeros(mRows,nCols);
    
	% 2) 현재 처리할 불안정 셀 좌표
	y = oversteepSlopesY(ithCell);
	x = oversteepSlopesX(ithCell);

	% 3) 다음 셀 색인을 구함
	nextY = SDSNbrY(y,x);
	nextX = SDSNbrX(y,x);
	
	% 4) 활동으로 인한 현 셀에서의 침식율 추정
    % * 원리: 임계 고도차를 초과하는 물질이 다음 셀로 이동함
	dElev1 = ...
        - ((effectiveElev(y,x) - elev(nextY,nextX)) - criticalHeight(y,x));
    
    % * 주의: 침식율이 음인지를 확인하고, 아닌 경우라면 현 셀에서의 이동을 종료함
    if dElev1 < 0
        
        % (1) 조건에 따라 침식율 조정
		% * 원리: 다음 셀의 고도는 현 셀에서의 사면물질 이동으로 인해 상승함.
        %   따라서 현 셀의 안정 고도차보다 더 작은 양이 이동되어야 함
        % * 주의: 다음 셀이 외곽 경계라면 줄이지 않으며, 연쇄 이동을 종료함.
        % * 주의: 다음 셀이 불안정한 셀일 경우에는 다음 셀에서의 물질 이동이
        %   많을 것으로 예상되므로 줄이지 않음
        
        % 추정한 침식율을 줄임
		dElev1 = dElev1 * 0.5;

        if IsBoundary(nextY,nextX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND) == true
			
			dElev1 = dElev1 * 2;
            
            % * 주의: 천부활동일 경우, 이동율은 퇴적층 두께에 제한됨
            if rapidMassMovementType == SOIL && - dElev1 > sedimentThick(y,x)

                dElev1 = - sedimentThick(y,x);
                
            end
            
            dSedimentThickByIthCell(nextY,nextX) ...
                = dSedimentThickByIthCell(nextY,nextX) - dElev1;
            
			isBoundary = true;
			
		elseif oversteepSlopes(nextY,nextX) == true
			
			dElev1 = dElev1 * 2;
			
        end % IsBoundary(nextY,nextX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND) == true

        % * 침식율이 최소 침식율보다 작으면 최소 침식율로 대체함
        % * 주의: 침식율의 왜곡이 발생하지만, 이를 통해 빠르게 안정 고도차 범위
        %   내로 도달하여 무한 반복을 방지함        
        if - dElev1 < - minDElevByCollapse
            
            dElev1 = minDElevByCollapse;
            
        end
        
        % (2) 퇴적층 두께 및 기반암 고도를 갱신함
        if rapidMassMovementType == SOIL
            
            % * 주의: 천부활동일 경우, 이동율은 퇴적층 두께에 제한됨
            if - dElev1 > sedimentThick(y,x)
                dElev1 = - sedimentThick(y,x);                
            end
            
            dSedimentThickByIthCell(y,x) ...
                = dSedimentThickByIthCell(y,x) + dElev1;

        else % rapidMassMovementType == ROCK

            dBedrockElevByIthCell(y,x) ...
                = dBedrockElevByIthCell(y,x) + dElev1;
            
            % * 주의: 기반암 상부의 퇴적층까지도 침식율에 포함함
            dSedimentThickByIthCell(y,x) ...
                = dSedimentThickByIthCell(y,x) - sedimentThick(y,x);
            dElev1 = dElev1 + dSedimentThickByIthCell(y,x);

        end

        isStable = false;
        
    else % dElev1 >= 0       
        
        isStable = true;        
        
    end % dElev1 < 0
	
    % 5) 안정 사면을 이룰 때까지 다음 셀로 연쇄적인 물질 이동이 발생함
    dSedimentThickByIthCell ... % i번째 불안정 셀로 인한 퇴적물 두께 변화율 [m/dT]
        = CollapseMex(mRows,nCols,isStable,isBoundary,nextY,nextX ...
        ,rapidMassMovementType,dElev1);
    %
    % * CollapseMex.c
    %
    % 높은 고도 순으로 활동에 의해 불안정한 셀에서 다음 셀로의 연속적인
    % 기반암 고도 및 퇴적층 두께 변화율을 구하는 함수 
    % * 참고: Collapse 함수의 while 반복문만을 MEX 파일로 변경함
    % 
    % dSedimentThickByIthCell ...      0 . i번째 불안정 셀로 인한 퇴적물 두께 변화율 [m/dT]
    % = CollapseMex ...
    % (mRows ...                       0 . 행 개수
    % ,nCols ...                       1 . 열 개수
    % ,isStable ...                    2 . 다음 셀로의 물질이동이 않는 안정화 여부
    % ,isBoundary ...                  3 . 연쇄적 이동의 외곽 경계 도달 여부
    % ,nextY ...                       4 . 다음 셀의 Y 좌표
    % ,nextX ...                       5 . 다음 셀의 X 좌표
    % ,rapidMassMovementType ...       6 . 활동 유형
    % ,dElev1)                         7 . i번째 셀의 침식율 [m/dT]
    %
    %----------------------------- mexGetVariablePtr 함수로 참조하는 변수
    %
    % dSedimentThickByIthCell          8 . i번째 불안정 셀로 인한 퇴적물 두께 변화율 [m/dT]
    % SDSNbrY ...                      9 . 다음 셀 Y 좌표
    % SDSNbrX ...                      10. 다음 셀 X 좌표
    % elev ...                         11. 갱신된 지표 고도 [m]
    % soilCriticalHeight ...           12. 천부활동 발생의 임계 고도차 [m]
    % sedimentThick ...                13. 퇴적층 두께
    % oversteepSlopes ...              14. 불안정한 셀
    % flood ...                        15. flooded region

    % 누적 기반암 고도 및 퇴적층 두께 변화율을 구함
    dBedrockElev = dBedrockElev + dBedrockElevByIthCell;
    dSedimentThick = dSedimentThick + dSedimentThickByIthCell;
    
    % 기반암 고도 및 퇴적층 두께 그리고 고도를 갱신함
    bedrockElev = bedrockElev + dBedrockElevByIthCell;
    sedimentThick = sedimentThick + dSedimentThickByIthCell;
    elev = bedrockElev + sedimentThick;
    
    % 불안정한 사면에서 발원한 사면물질은 사면 하부로 이동하므로, 사면 하부의
    % 고도가 변화면서 유향이 달라짐. 따라서 유향을 새로 구함
    [steepestDescentSlope ...   % 수정된 경사
    ,slopeAllNbr ...            % 수정된 8개 이웃 셀과의 경사
    ,SDSFlowDirection ...       % 수정된 유향
    ,SDSNbrY ...                % 수정된 다음 셀의 Y 좌표값
    ,SDSNbrX] ...               % 수정된 다음 셀의 X 좌표값
        = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
        ,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);
        
    % 유향이 정의되지 않은 셀에 유향을 부여한다.
    [flood ...                      % 수정된 flooded region
    ,SDSNbrY ...                    % 수정된 다음 셀의 Y 좌표값
    ,SDSNbrX ...                    % 수정된 다음 셀의 X 좌표값
    ,SDSFlowDirection ...           % 수정된 유향
    ,steepestDescentSlope ...       % 수정된 경사
    ,integratedSlope ...            % 수정된 facet flow 경사
    ,floodedRegionIndex ...         % 수정된 flooded region 색인
    ,floodedRegionCellsNo ...       % 수정된 flooded region 구성 셀 수
    ,floodedRegionLocalDepth ...    % 수정된 flooded region 고도와 유출구 고도 차이
    ,floodedRegionTotalDepth ...    % 수정된 local depth 총 합
    ,floodedRegionStorageVolume] ...% 수정된 flooded region 저수량
        = ProcessSink(mRows,nCols,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
        ,elev,ithNbrYOffset,ithNbrXOffset ...
        ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,slopeAllNbr,steepestDescentSlope ...
        ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);    
    
end % for ithCell

end % Collapse end