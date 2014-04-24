% =========================================================================
%> @section INTRO CheckOversteepSlopes
%>
%> - 활동 유형(천부활동(shallow landsliding)과 기반암활동(bedrock
%>    landsliding))에 따라 불안정한 사면을 파악하는 함수.
%>
%> - History
%>  - 2010-12-21
%>   -RapidMassMovement 함수에 활동 발생확률 개념을 도입함.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%> @see RapidMassMovement()
%>
%> @retval oversteepSlopes              : 불안정한 셀
%> @retval oversteepSlopesIndicies      : (고도순으로 정렬된) 불안정한 셀 색인
%> @retval dTAfterLastShallowLandslide  : 갱신된 마지막 천부활동 이후 경과 시간 [year]
%> @retval dTAfterLastBedrockLandslide  : 갱신된 마지막 기반암활동 이후 경과 시간 [year]
%>
%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y                             : 외곽 경계를 제외한 Y축 크기
%> @param X                             : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                         : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                         : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                         : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                         : 모형 영역 X 마지막 좌표값(=X+1)
%> @param dT                            : 만수유량 재현기간 [year]
%> @param ROOT2                         : sqrt(2)
%> @param rapidMassMovementType         : 활동 유형
%> @param criticalSlopeForFailure       : 활동 발생 임계 사면각 [radian]
%> @param bedrockElev                   : 기반암 고도 [m]
%> @param sedimentThick                 : 퇴적층 두께 [m]
%> @param elev                          : 지표 고도 [m]
%> @param dTAfterLastShallowLandslide   : 마지막 천부활동 이후 경과 시간 [year]
%> @param dTAfterLastBedrockLandslide   : 마지막 기반암활동 이후 경과 시간 [year]
%> @param dX                            : 셀 크기 [m]
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param SDSNbrY                       : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                       : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param flood                         : SINK로 인해 물이 고이는 지역(flooded region)
% =========================================================================
function [oversteepSlopes,oversteepSlopesIndicies,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide] = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,dT,ROOT2,rapidMassMovementType,criticalSlopeForFailure,bedrockElev,sedimentThick,elev,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood)
%
% function CheckOversteepSlopes
%

% 상수 초기화
FLOODED = 2; % flooded region 태그
% 활동 유형
SOIL = 1;   % 천부활동
% ROCK = 2; % 기반암활동

% 변수 정의
% * 주의: 다시 한번 고려할 필요가 있음. 실제로 시뮬레이션을 해서 어느 정도의
% 활동 발생 빈도를 보이는지 파악할 필요가 있음.
minSedimentThickForInitiation = 0.1;    % [m] 천부활동이 발생할 수 있는 최소한의 퇴적층 두께
shallowLandslideCharTime = 100;         % [year] 천부활동이 다시 발생하는 재현기간
bedrockLandslideCharTime = 100;         % [year] 기반암활동이 다시 발생하는 재현기간

% 1. 활동 유형에 따라 발생 기본 조건을 만족하는 셀의 색인을 파악하고 (발생확률
% 및 이동율을 추정하기 위한) 유효 고도를 정의함
if rapidMassMovementType == SOIL

	% 천부활동이 시작되는 곳은 퇴적층 두께가 일정값 이상이어야함
    % * 이는 활동 빈도가 유역면적에 비례한다는 사실을 대체함. 하지만 이는 아직
    %   확실한 근거가 없음. 이를 찾는 즉시 삽입할 것. 그래도 일단 0.5로 대입함
	preliminaryCellsIndicies ...
        = find(sedimentThick > minSedimentThickForInitiation ...
        & flood ~= FLOODED & ~ OUTER_BOUNDARY);
	
	% 지표 고도가 유효 고도임
	effectiveElev = elev;
	
else

	% 기반암활동은 퇴적층 두께와 관련없음
	preliminaryCellsIndicies = find(flood ~= FLOODED & ~ OUTER_BOUNDARY);
	
	% 기반암 고도가 유효 고도임
	effectiveElev = bedrockElev;
	
end

% 2. 활동 발생 확률 구하기
% * 원리: 활동 발생 임계 고도 차이와 마지막 활동 발생 이후 경과 시간을 이용함

% 1) 기본 조건 만족 셀의 다음 셀 색인을 구함
preliminaryCellsNbrsY = SDSNbrY(preliminaryCellsIndicies);
preliminaryCellsNbrsX = SDSNbrX(preliminaryCellsIndicies);
preliminaryCellsNbrsIndicies ...
    = (preliminaryCellsNbrsX - 1)*mRows + preliminaryCellsNbrsY;

% 2) 다음 셀 방향에 따른 안정사면각을 이루는 고도 차이(이하 critical height)를 정의함

% (1) 이웃 셀 방향에 따른 critical height
criticalHeightForOrtho = criticalSlopeForFailure * dX;
criticalHeightForDiag = criticalSlopeForFailure * dX * ROOT2;

% (2) 다음 셀 방향에 따른 critical height
% - (일단 대각선 방향 critical height로) 초기화
criticalHeight = zeros(mRows,nCols);
criticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = ones(Y,X) * criticalHeightForDiag;

% - 다음 셀이 직각 방향인 셀의 critical height
nbrIndicies = (SDSNbrX - 1) * mRows + SDSNbrY;      % 다음 셀 색인
indicies = reshape(1:mRows*nCols,[mRows,nCols]);    % 중앙 셀 색인
dIndicies = indicies - nbrIndicies;            % 중앙 셀과 다음 셀 색인 차
orthogonalDownstream = false(mRows,nCols);
orthogonalDownstream(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = (mod(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX),mRows) == 0) ...
    | (abs(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX)) == 1);
criticalHeight(orthogonalDownstream) = criticalHeightForOrtho;

% 3) (조건을 만족하는 셀을 대상으로) 다음 셀과의 고도차를 구함
% * 주의: 유효고도를 기준으로 함
downslopeDElev = zeros(mRows,nCols);
downslopeDElev(preliminaryCellsIndicies) ...
    = effectiveElev(preliminaryCellsIndicies) ...
    - elev(preliminaryCellsNbrsIndicies);

% 4) 활동 유형에 따라 활동 발생 확률을 구하고, 활동 발생 셀의 색인을 파악함

landslideProbability = zeros(mRows,nCols);  % 활동 발생 확률 초기화

if rapidMassMovementType == SOIL
    
    % 천부활동 발생 확률
    landslideProbability(preliminaryCellsIndicies) ...
        = (downslopeDElev(preliminaryCellsIndicies) ...
        ./ criticalHeight(preliminaryCellsIndicies) - 1) ...
        + dTAfterLastShallowLandslide(preliminaryCellsIndicies) ...
        / shallowLandslideCharTime;
    % * 주의: 만약 임계 고도차보다 적을 경우 발생확률은 0임
    % * 전제: 임계 고도차보다 클 때 활동이 발생함
    landslideProbability(downslopeDElev - criticalHeight < 0) = 0;

    % 천부활동 발생 셀 색인
    oversteepSlopesIndicies = find(landslideProbability >= 1);
    
    % for debug
    [tmp1,tmp2] = size(oversteepSlopesIndicies);
    if tmp1 > 0
       
        3;
    
    end
    
    % 마지막 천부활동 발생 이후 경과 시간
    dTAfterLastShallowLandslide(landslideProbability > 0) ...
        = dTAfterLastShallowLandslide(landslideProbability > 0) + dT;
    
    dTAfterLastShallowLandslide(oversteepSlopesIndicies) = 0;
    
else

    % 기반암활동 발생 확률
    landslideProbability(preliminaryCellsIndicies) ...
        = (downslopeDElev(preliminaryCellsIndicies) ...
        ./ criticalHeight(preliminaryCellsIndicies) - 1) ...
        + dTAfterLastBedrockLandslide(preliminaryCellsIndicies) ...
        / bedrockLandslideCharTime;
    % * 주의: 만약 임계 고도차보다 적을 경우 발생확률은 0임
    % * 전제: 임계 고도차보다 클 때 활동이 발생함
    landslideProbability(downslopeDElev - criticalHeight < 0) = 0;
    
    % 기반암활동 발생 셀 색인
    oversteepSlopesIndicies = find(landslideProbability >= 1);
    
    % for debug
    [tmp1,tmp2] = size(oversteepSlopesIndicies);
    if tmp1 > 0
       
        3;
        
    end
    
    % 마지막 기반암활동 발생 이후 경과 시간
    % * 주의: 천부활동의 경과 시간도 0으로 설정함
    dTAfterLastBedrockLandslide(landslideProbability > 0) ...
        = dTAfterLastBedrockLandslide(landslideProbability > 0) + dT;
    
    dTAfterLastBedrockLandslide(oversteepSlopesIndicies) = 0;
    dTAfterLastShallowLandslide(oversteepSlopesIndicies) = 0; % 주의
    
    
end

% 3. 활동 발생 셀의 공간적 분포
oversteepSlopes = false(mRows,nCols);
oversteepSlopes(oversteepSlopesIndicies) = true;

% 4. 활동 발생 셀 색인을 고도 순으로 배열함
oversteepSlopesElev = elev(oversteepSlopesIndicies);
sortedOversteepSlopes = [oversteepSlopesIndicies oversteepSlopesElev];
sortedOversteepSlopes = sortrows(sortedOversteepSlopes,-2);
oversteepSlopesIndicies = sortedOversteepSlopes(:,1);

end % CheckOversteepSlopes end