% =========================================================================
%> @section INTRO AdjustBoundary
%>
%> - 경계조건에 따라 외곽 경계의 기반암 고도와 퇴적물 두께를 정의하는 함수
%>
%>  - 주의: 영역 경계에서는 구체적인 지형형성작용이 발생하지 않음. 하지만 영역
%>    경계 셀들의 경사 및 유향을 결정하는데 꼭 필요한 것이 외곽 경계의 고도이며
%>    여기서는 이를 결정함. 이 함수는 경계조건에 따라 고도(= 기반암 고도 +
%>    퇴적물 두께)를 정의하는데, 퇴적층 두께는 항상 0으로 설정하고 기반암 고도는
%>    경계조건에 따라 달리 설정함
%>
%>  - 원리: 외곽 경계조건은 1) 외곽 경계와 모형 영역 연접 셀의 지반융기율이
%>    같거나 유사할 때와 2) 다를 경우(예: 외곽 경계에 구조선이 위치하는 경우)로
%>    크게 구분하여 생각해 볼 수 있음.\n
%>    1)의 경우는 (1) 상대적인 해수면의 하강으로 인해 하구로부터의 침식 wave가
%>    외곽 경계에 도달하고 이것이 통과하면서 침식 기준면이 하강하는 경우,
%>    (2) 모형 영역과 외곽이 동적 평형을 이루어 침식 기준면이 유지되는 경우,
%>    (3) 상대적인 해수면의 상승으로 인해 하구로 부터 퇴적이 진전되어 침식
%>    기준면이 상승하는 경우로 각각 나눌 수 있음.\n
%>    (2)의 경우는 초기 지형에서 정상 상태로의 발달을 모의할 때 적절한 경계
%>    조건이라 보기 어려움.\n
%>    (3)의 경우는 해안선이 모델 외곽에 존재할 때는 침식 기준면이 유지되나, 영역
%>    내부로까지 전진할 경우 침식 기준면이 상승하게 되는데 현재로서는 모의할 수 없음.\n
%>    2)의 경우는 모형 영역이 지반융기로 인해 고도가 상승하지만 경계 고도는
%>    고정되어 침식 기준면이 하강하는 경우가 대표적인 예임.
%>
%>  - 주의: 모형에서는 1)의 (1)을 (2)와 동일하게 모의함. 결국 외곽 경계 고도가
%>    연접 셀 고도에 비해 상대적으로 낮아지기 때문임. 하지만 이 경우에 모의 기간
%>    동안 지반융기율의 시간적 분포는 외곽 경계로 침식 wave가 도달한 시점부터
%>    시작되며 이로 인해 낮아지는 고도 변화율에 해당함. 그리고 모의 기간 동안의
%>    총 지반융기량은 침식 wave가 외곽 경계를 통과하면서 낮아진 고도를 가리킴.
%>
%>  - 주요 조건:
%>   - BOUNDARY_OUTFLOW_COND: 유출구 또는 영역으로부터의 유출이 발생하는 외곽 경계조건
%>    - 0: ONE_OUTLET, 하나의 유출구
%>    - 1: BOTTOM_BOUNDARY, 아래 경계면에서 유출이 발생함
%>    - 2: TOP_BOTTOM_BOUNDARY, 위와 아래 경계면에서 유출이 발생함
%>    - 4: ALL_BOUNDARY, 모든 면에서 유출이 발생함
%>   - BOUNDARY_ELEV_COND: 외곽 경계 고도 조건
%>    - 0: CONSTANT_ELEV, 1)의 (1) 또는 2)
%>    - 1: YEONGSEO_ELEV, 경동성 요곡 지반융기 운동 모의에서의 영서쪽 외곽 경계
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev              : 경계 조건이 반영된 기반암 고도 [m]
%> @retval sedimentThick            : 경계 조건이 반영된 퇴적층 두께 [m]
%>
%> @param Y_INI                     : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                     : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                     : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                     : 모형 영역 X 마지막 좌표값(=X+1)
%> @param Y_TOP_BND                 : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND              : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND               : 모형 외곽 우 경계 X 좌표값
%> @param bedrockElev               : 기반암 고도 [m]
%> @param sedimentThick             : 퇴적층 두께 [m]
%> @param OUTER_BOUNDARY            : 모형 영역 외곽 경계 마스크
%> @param BOUNDARY_OUTFLOW_COND     : 유출구 또는 영역으로부터의 유출이 발생하는 외곽 경계조건
%> @param TOP_BOUNDARY_ELEV_COND    : 위 외곽 경계 고도 조건
%> @param topBndElev                : 외곽 위 경계에서의 고도 [m]
%> @param ithTimeStep               : i번째 단위 시간
% =========================================================================
function [bedrockElev,sedimentThick] = AdjustBoundary(Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,bedrockElev,sedimentThick,OUTER_BOUNDARY,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND,topBndElev,ithTimeStep,meanUpliftRateAtUpliftAxis)
%
% function AdjustBoundary
%

% 상수 정의
X_MID = round((X_MAX - X_INI) * 0.5);

% BOUNDARY_OUTFLOW_COND 태그
ONE_OUTLET_MID_BOTTOM = 0;
BOTTOM_BOUNDARY = 1;
TOP_BOTTOM_BOUNDARY = 2;
ONE_OUTLET_LEFT_EDGE = 3;
ALL_BOUNDARY = 4;

% BOUNDARY_ELEV_COND 태그
YEONGSEO_ELEV = 1;

% 1. 외곽 경계 퇴적층 두께 설정
sedimentThick(OUTER_BOUNDARY) = 0;

% 2. 외곽 경계 기반암 고도 설정

% 1) 유출구 또는 영역으로부터의 유출이 발생하는 외곽 경계 위치를 확인함
if BOUNDARY_OUTFLOW_COND == ONE_OUTLET_MID_BOTTOM
    
    % (1) 하나의 유출구를 가질 경우
    
    % A. 외곽 경계 고도 초기화
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. 유출구의 경계 고도 조건은 1)의 (1) 또는 (2)임
    bedrockElev(Y_BOTTOM_BND,X_MID) = 0; % mid bottom
    
elseif BOUNDARY_OUTFLOW_COND == ONE_OUTLET_LEFT_EDGE
    
    % (1) 하나의 유출구를 가질 경우
    
    % A. 외곽 경계 고도 초기화
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. 유출구의 경계 고도 조건은 1)의 (1) 또는 (2)임
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND) = 0; % edge bottom
    
elseif BOUNDARY_OUTFLOW_COND == BOTTOM_BOUNDARY
    
    % (2) 아래 경계면에서 유출이 발생할 경우
    
    % A. 외곽 경계 고도 초기화
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. 1)의 (1) 또는 (2) 조건임
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
    
elseif BOUNDARY_OUTFLOW_COND == TOP_BOTTOM_BOUNDARY
    
    % (3) 위, 아래 경계면에서 유출이 발생할 경우
    
    % A. 좌우 경계 초기화
    bedrockElev(Y_INI:Y_MAX,X_LEFT_BND) = inf;
    bedrockElev(Y_INI:Y_MAX,X_RIGHT_BND) = inf;
        
    % B.아래쪽 경계면은 1)의 (1) 또는 (2) 경우임
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
        
    % C. 위쪽 경계면 조건을 확인함
    if TOP_BOUNDARY_ELEV_COND ~= YEONGSEO_ELEV
        
        % A) 1)의 (1) 또는 (2) 경우
        bedrockElev(Y_TOP_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
                 
    else % TOP_BOUNDARY_ELEV_COND == YEONGSEO_ELEV
        
        % B) 경동성 요곡 지반융기운동을 모의할 경우
        % * 원리: 외곽 경계(유출구)의 고도를 DefineUpliftRateDistribution
        %   함수에서 정의한 대로 따름
        
        % (A) 위 경계면 고도 초기화
        bedrockElev(Y_TOP_BND,X_LEFT_BND:X_RIGHT_BND) = inf;
                
        % (B) 유출구 고도 정의
        bedrockElev(Y_TOP_BND,X_MID) = topBndElev(ithTimeStep);
    
    end
    
else % BOUNDARY_OUTFLOW_COND == ALL_BOUNDARY
    
    % (4) 모든 경계면에서 유출이 발생할 경우
    
    % A. 1)의 (1) 또는 (2) 경우
    bedrockElev(OUTER_BOUNDARY) ...
        = bedrockElev(OUTER_BOUNDARY) - meanUpliftRateAtUpliftAxis;
        
end

end % AdjustBoundary end