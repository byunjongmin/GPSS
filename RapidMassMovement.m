% =========================================================================
%> @section INTRO RapidMassMovement
%>
%> - 불안정한 사면을 파악하고, 이들에 활동을 발생시키는 함수
%>  - 주의: 활동에 의한 물질이동은 보다 물리기반 법칙에 근거해야 함.
%>  - 원리:
%>   - 1. 활동을 천부활동(shallow landslide)와 기반암활동(bedrock landslide)로
%>     구분함. 천부활동에는 암설류(debris flow), 암설애벌런치(debris avalanch),
%>     암설활동(debris landslide) 등과 같이 토양층이 이동되는 것을 포함함
%>   - 2. 불안정한 셀에서 안정 사면각을 이룰 정도만큼의 사면물질이 다음 셀로
%>     이동하며, 이후 사면물질은 사면 하부로 연쇄적으로 이동하며, 다음 셀로 더
%>     이상의 물질이동이 일어나지 않는 안정사면에서 연쇄 이동을 종료함.
%>  - 주의: 단순함을 위해 무한 유향이 아닌 D8 알고리듬을 이용한다.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see Collapse(), CalcSDSFlow(), CheckOversteepSlopes()
%>
%> @retval dBedrockElev                 : 활동에 의한 기반암 고도 변화율 [m/dT]
%> @retval dSedimentThick               : 활동에 의한 퇴적층 두께 변화율 [m/dT]
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
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param dT                            : 만수유량 재현기간 [year]
%> @param ROOT2                         : sqrt(2)
%> @param QUARTER_PI                    : pi * 0.25
%> @param CELL_AREA                     : 셀 면적 [m^2]
%> @param DISTANCE_RATIO_TO_NBR         : 셀 크기를 기준으로 이웃 셀간 거리비 [m]
%> @param soilCriticalSlopeForFailure   : 천부활동이 발생하는 임계 사면각 [radian]
%> @param rockCriticalSlopeForFailure   : 기반암활동이 발생하는 임계 사면각 [radian]
%> @param bedrockElev                   : 기반암 고도 [m]
%> @param sedimentThick                 : 퇴적층 두께 [m]
%> @param dTAfterLastShallowLandslide   : 마지막 천부활동 이후 경과 시간 [year]
%> @param dTAfterLastBedrockLandslide   : 마지막 기반암활동 이후 경과 시간 [year]
%> @param dX                            : 셀 크기 [m]
%> @param OUTER_BOUNDARY                : 모형 영역 외곽 경계 마스크
%> @param IS_LEFT_RIGHT_CONNECTED       : 좌우 외곽 경계 연결을 결정
%> @param ithNbrYOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
%> @param ithNbrXOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
%> @param sE0LinearIndicies             : 외곽 경계를 제외한 중앙 셀
%> @param s3IthNbrLinearIndicies        : 8 방향 이웃 셀을 가리키는 3차원 색인 배열
% =========================================================================
function [dBedrockElev,dSedimentThick,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide] = RapidMassMovement(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,dT,ROOT2,QUARTER_PI,CELL_AREA,DISTANCE_RATIO_TO_NBR,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure,bedrockElev,sedimentThick,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function RapidMassMovement
%

% 상수 및 변수 초기화
SOIL = 1; % 천부활동
ROCK = 2; % 암석붕괴

% RapidMassMovement 가 발생하지 않도록 하려면 0을 대입할 것
oversteepSlopesNo = 0;

dBedrockElev = zeros(mRows,nCols);
dSedimentThick = zeros(mRows,nCols);
facetFlowSlope = nan(mRows,nCols);

while (oversteepSlopesNo > 0)
    
    % 지표 고도를 갱신함
    elev = bedrockElev + sedimentThick;
    
    % 유향을 갱신함
    [steepestDescentSlope ...       % 경사
    ,slopeAllNbr ...                % 8 이웃 셀과의 경사
    ,SDSFlowDirection ...           % 유향
    ,SDSNbrY ...                    % 다음 셀의 Y 좌표값
    ,SDSNbrX] ...                   % 다음 셀의 X 좌표값
        = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
        ,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);
        
    % 유향이 정의되지 않은 셀에 유향을 부여함
    [flood ...                          % flooded region
    ,SDSNbrY ...                        % 수정된 다음 셀의 Y 좌표값
    ,SDSNbrX ...                        % 수정된 다음 셀의 X 좌표값
    ,SDSFlowDirection ...               % 수정된 유향
    ,steepestDescentSlope ...           % 수정된 경사
    ,integratedSlope ...                % 수정된 무한 유향 경사
    ,floodedRegionIndex ...             % flooded region 색인
    ,floodedRegionCellsNo ...           % flooded region 구성 셀 수
    ,floodedRegionLocalDepth ...        % flooded region 고도와 유출구 고도와의 차이
    ,floodedRegionTotalDepth ...        % 총 local depth
    ,floodedRegionStorageVolume] ...    % flooded region 총 저장량
        = ProcessSink(mRows,nCols,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
        ,elev,ithNbrYOffset,ithNbrXOffset ...
        ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,slopeAllNbr,steepestDescentSlope ...
        ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection); 

	% 1. 천부활동
    
    % 1) 천부활동이 발생할 것으로 예상되는 불안정한 사면을 파악함
	[oversteepSlopes ...                % 불안정한 사면
    ,oversteepSlopesIndicies ...        % 불안정한 셀 색인
    ,dTAfterLastShallowLandslide ...    % 마지막 천부활동 이후 경과 시간
    ,dTAfterLastBedrockLandslide] ...   % 마지막 기반암활동 이후 경과 시간
        = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dT,ROOT2 ...
        ,SOIL,soilCriticalSlopeForFailure ...
        ,bedrockElev,sedimentThick,elev ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...        
        ,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood);	
	
    
    % 2) 천부활동으로 인한 고도 변화율을 구함
	oversteepSlopesNo = size(oversteepSlopesIndicies,1);
	
	if oversteepSlopesNo > 0
	
		[dBedrockElevByDebrisFlow ...       % 기반암 고도 변화율
        ,dSedimentThickByDebrisFlow ...     % 퇴적층 두께 변화율
        ,SDSNbrY ...                    % 천부활동후 수정된 다음 셀의 Y 좌표값
        ,SDSNbrX ...                    % 천부활동후 수정된 다음 셀의 X 좌표값
        ,flood] ...                     % 천부활동후 수정된 flooded region
            = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI ...
            ,oversteepSlopes ...
            ,oversteepSlopesIndicies,oversteepSlopesNo ...
            ,SOIL ...
            ,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
            ,bedrockElev,sedimentThick,elev ...
            ,SDSNbrY,SDSNbrX,flood ...
            ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);
		
		% 3) 퇴적층 두께를 갱신하고, 누적 변화율을 구함
		dSedimentThick = dSedimentThick + dSedimentThickByDebrisFlow;
		sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
		    = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
		    + dSedimentThickByDebrisFlow(Y_INI:Y_MAX,X_INI:X_MAX);
		elev = bedrockElev + sedimentThick;

	end
	
    % 2. 기반암활동
    
	% 1) 기반암활동이 발생할 것으로 예상되는 불안정한 사면을 파악함
	[oversteepSlopes ...                % 불안정한 사면
    ,oversteepSlopesIndicies ...        % 불안정한 셀 색인
    ,dTAfterLastShallowLandslide ...    % 마지막 천부활동 이후 경과 시간
    ,dTAfterLastBedrockLandslide] ...   % 마지막 기반암활동 이후 경과 시간
        = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dT,ROOT2 ...
        ,ROCK,rockCriticalSlopeForFailure ...
        ,bedrockElev,sedimentThick,elev ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...   
        ,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood);
	
	% 2) 기반암활동으로 인한 고도 변화율을 구함
	oversteepSlopesNo = size(oversteepSlopesIndicies,1);
	
	if oversteepSlopesNo > 0
	
		[dBedrockElevByRockFailure ...      % 기반암 고도 변화율
        ,dSedimentThickByRockFailure ...    % 퇴적층 두께 변화율
        ,SDSNbrY ...                    % 기반암활동후 수정된 다음 셀의 Y 좌표값
        ,SDSNbrX ...                    % 기반암활동후 수정된 다음 셀의 X 좌표값
        ,flood] ...                     % 기반암활동후 수정된 flooded region
            = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI ...
            ,oversteepSlopes ...
            ,oversteepSlopesIndicies,oversteepSlopesNo ...
            ,ROCK ...
            ,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
            ,bedrockElev,sedimentThick,elev ...
            ,SDSNbrY,SDSNbrX,flood ...
            ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);
		
		% 3) 퇴적층 두께와 기반암 고도를 갱신하고, 누적 변화율을 구함
		dSedimentThick = dSedimentThick + dSedimentThickByRockFailure;
		dBedrockElev = dBedrockElev + dBedrockElevByRockFailure;
		sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
		    = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
		    + dSedimentThickByRockFailure(Y_INI:Y_MAX,X_INI:X_MAX);
		bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX)...
		    = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX)...
		    + dBedrockElevByRockFailure(Y_INI:Y_MAX,X_INI:X_MAX);  

	end
    
end

end % RapidMassMovement end