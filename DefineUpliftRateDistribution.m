% =========================================================================
%> @section INTRO DefineUpliftRateDistribution 부함수
%>
%> - 융기율의 공간적 시간적 분포를 정의하는 함수
%>  - 이 함수를 통해 시공간적으로 비균질적인 지반융기를 모의함. 현재 경동성
%>    요곡 지반융기도 모의 가능함
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval meanUpliftRateSpatialDistribution    : (모의기간 평균) 연간 융기율의 공간적 분포
%> @retval upliftRateTemporalDistribution       : (모의기간) 연간 융기율의 시간적 분포
%> @retval meanUpliftRateAtUpliftAxis           : 융기축의 (모의기간 평균) 연간 융기율
%> @retval topBndElev                           : 외곽 위 경계에서의 고도
%>
%> @param Y                                     : 외곽 경계를 제외한 Y축 크기
%> @param X                                     : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                                 : 모형 영역 Y 시작 좌표값(=2)
%> @param X_INI                                 : 모형 영역 X 시작 좌표값(=2)
%> @param Y_MAX                                 : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_MAX                                 : 모형 영역 X 마지막 좌표값(=X+1)
%> @param dX                                    : 셀 크기 [m]
%> @param TIME_STEPS_NO                         : 총 실행 횟수
%> @param TOTAL_ACCUMULATED_UPLIFT              : (융기축에서) 모의 기간 동안의 누적 융기량 [m]
%> @param dT                                    : 만수유량 재현기간 [year]
%> @param IS_TILTED_UPWARPING                   : 경동성 요곡 지반융기 운동을 결정
%> @param UPLIFT_AXIS_DISTANCE_FROM_COAST       : 영동 해안선으로부터 융기축까지의 거리 [m]
%> @param TOP_BOUNDARY_ELEV_COND                : 외곽 위 경계 조건
%> @param Y_TOP_BND_FINAL_ELEV                  : 외곽 위 경계의 최종 고도 [m]
%> @param RAMP_ANGLE_TO_TOP                     : (누적 지반 융기량을 기준) 융기축에서 위 경계로의 각 [radian]
%> @param UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND: 융기율의 시간적 분포 결정
%> @param dUpliftRate                           : (융기율 변동 분포 조건) 평균 연간 융기율을 기준으로 최대 최소 융기율의 차이 비율
%> @param acceleratedUpliftPhaseNo              : (융기율 변동 분포 조건) 모의기간 동안 높은 융기율이 발생하는 빈도
%> @param upliftRate0                           : (융기율 돌출-감쇠 분포 조건) 융기율 감쇠분포의 초기 융기율 [m/year]
%> @param waveArrivalTime                       : (경동성 요곡 지반융기 조건) 영서 외곽 경계 고도가 본격적으로 하강하는 시점 (모의 기간에서 비율)
%> @param initUpliftRate                        : (경동성 요곡 지반융기 조건) 본격적 하강 이전 침식 기준면 하강율 [m/year]
% =========================================================================
function [meanUpliftRateSpatialDistribution,upliftRateTemporalDistribution,meanUpliftRateAtUpliftAxis,topBndElev] = DefineUpliftRateDistribution(Y,X,Y_INI,X_INI,Y_MAX,X_MAX,dX,TIME_STEPS_NO,TOTAL_ACCUMULATED_UPLIFT,dT,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST,TOP_BOUNDARY_ELEV_COND,Y_TOP_BND_FINAL_ELEV,RAMP_ANGLE_TO_TOP,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND,dUpliftRate,acceleratedUpliftPhaseNo,upliftRate0,waveArrivalTime,initUpliftRate)
%
% function DefineUpliftRateDistribution
%

% 상수 정의
YEONGSEO_ELEV = 1;          % 경동성 요곡 지반융기운동의 영서쪽 외곽 경계 고도 조건
CONSTANT_UPLIFTRATE = 1;    % 융기율 일정
INTERMITTENT_UPLIFT = 2;    % 간헐적 융기
% DECAYING_UPLIFTRATE = 3;  % 융기율 감쇠

RAMP_ANGLE_TO_BOTTOM ...
    = TOTAL_ACCUMULATED_UPLIFT / UPLIFT_AXIS_DISTANCE_FROM_COAST;

% 1. 융기율의 공간적 분포를 정의함
if IS_TILTED_UPWARPING == true
    
    % 1) 경동성 요곡 지반융기를 모의할 경우
    
    % (1) 지반융기축의 좌표 구하기
    TOP_BOTTOM_DISTANCE = Y * dX;
    upliftAxisY ...
        = round((TOP_BOTTOM_DISTANCE - UPLIFT_AXIS_DISTANCE_FROM_COAST) / dX) ...
        + Y_INI;

    % (2) (모의기간 동안) 누적 융기율의 공간적 분포 [m/TIME_STEPS_NO]
    totalAccumulatedUplift = zeros(Y+2,1);

    totalAccumulatedUplift(Y_INI:upliftAxisY) ...
        = TOTAL_ACCUMULATED_UPLIFT ...
        - RAMP_ANGLE_TO_TOP * ((upliftAxisY-Y_INI)*dX:-dX:0);

    totalAccumulatedUplift(upliftAxisY:Y_MAX) ...
        = TOTAL_ACCUMULATED_UPLIFT ...
        - RAMP_ANGLE_TO_BOTTOM * (0:dX:(Y_MAX-upliftAxisY)*dX);

    % (3) 모의기간 평균 융기율의 공간적 분포 [m/dT]
    meanUpliftRateSpatialDistribution = totalAccumulatedUplift / TIME_STEPS_NO;
    meanUpliftRateSpatialDistribution ... % 1차원 -> 2차원
        = repmat(meanUpliftRateSpatialDistribution,1,X+2);
    
    % (4) 융기축의 (모의기간 평균) 융기율 [m/dT]
    meanUpliftRateAtUpliftAxis ...
        = totalAccumulatedUplift(upliftAxisY) / TIME_STEPS_NO;
        
else

    % 2) 융기율의 공간적 분포가 동질적인 경우,
    
    % (1) (모의기간 평균) 융기율의 공간적 분포
    meanUpliftRateSpatialDistribution = zeros(Y+2,X+2);
    meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = TOTAL_ACCUMULATED_UPLIFT / TIME_STEPS_NO;
    
    % (2) 융기축의 (모의기간 평균) 융기율 [m/dT]
    meanUpliftRateAtUpliftAxis ...
        = TOTAL_ACCUMULATED_UPLIFT / TIME_STEPS_NO;
    
end

% 2. 모의기간 동안 연간 융기율의 시간적 분포
t = 1:TIME_STEPS_NO;

if UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND == CONSTANT_UPLIFTRATE
    
    % 1) 융기율이 일정한 경우
    
    % (1) 융기율 분포: 융기축의 (모의기간 평균) 융기율을 대입함
    upliftRateTemporalDistribution ...
        = ones(TIME_STEPS_NO,1) * meanUpliftRateAtUpliftAxis;    
    
elseif UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND == INTERMITTENT_UPLIFT
    
    % 2) 간헐적으로 융기율이 큰 경우
    % * 원리: (모의기간 평균) 융기율을 기준으로 일정 비율 만큼을 더하거나 뺌
    acceleratedUpliftRate ...   % 높은 시기의 융기율 [m/dT]
        = meanUpliftRateAtUpliftAxis * (1 + dUpliftRate); 
    deceleratedUpliftRate ...   % 낮은 시기의 융기율 [m/dT]
        = meanUpliftRateAtUpliftAxis * (1 - dUpliftRate);
    % 높은 융기율 빈도에 따른 모의기간 동안의 융기율 주기 정의
    w = acceleratedUpliftPhaseNo * (2 * pi) / TIME_STEPS_NO;    
    upliftRateTemporalDistribution = - sin(w * t);    
    upliftRateTemporalDistribution(upliftRateTemporalDistribution >= 0) ...
        = acceleratedUpliftRate;
    upliftRateTemporalDistribution(upliftRateTemporalDistribution < 0) ...
        = deceleratedUpliftRate;
    
else % upliftRateTemporalDistribution == DECAYING_UPLIFTRATE
    
    % 3) 융기율이 감쇠하는 경우
    % * 원리: t일 때의 융기율(dU/dt)은 t일 때의 융기율(U,upliftRate)에
    %   비례함. 초기 융기율이 주어질 경우, 감쇠상수가 융기율의 시간적 분포를
    %   결정함. 여기서 모의기간 동안의 누적 융기율(integral of U)은 융기축의
    %   누적 융기율과 같아야 한다.
    
    % (심볼릭 객체를 이용한) 감쇠상수 K 구하기
    syms time K;
    
    U = (upliftRate0 * dT) ...      % [m/dT] 단위변환
        * exp(K*time);              % 융기율 감쇠 함수
    integralU = int(U,'time',0,TIME_STEPS_NO); % (모의 기간) 감쇠 함수 적분값
    % 항등식: 감쇠 함수 적분값 - 누적 융기량 = 0
    identicalEquation = integralU - TOTAL_ACCUMULATED_UPLIFT;
    solvedK = double(solve(identicalEquation,K)); % 감쇠 상수의 대수해
    
    upliftRateTemporalDistribution = (upliftRate0 * dT) ... % [m/dT] 단위변환
        * exp(solvedK*t);
    
end

% 3. 위 외곽 경계 고도[m]의 시간적 분포
if TOP_BOUNDARY_ELEV_COND == YEONGSEO_ELEV
    
    % 1) 경동성 요곡 지반융기운동을 모의할 경우
    
    % (1) 위(영서) 외곽 경계 고도의 시간적 분포 초기화
    % * 가정: 본격적인 침식 기준면 하강 시기 이전의 외곽 경계 고도는 영역 경계
    %   고도에서 모의 이전 침식 기준면 하강율을 뺀 고도를 계속 유지함
    % * 주의: 하구 고도가 만약 연접 셀보다 높으면 어떻하나? ...
    topBndElev = cumsum(upliftRateTemporalDistribution) ...
        .* (meanUpliftRateSpatialDistribution(Y_INI,X_INI) ...
        ./ meanUpliftRateAtUpliftAxis) - initUpliftRate;
    
    % (2) 경계 고도(침식기준면)가 본격적으로 내려가는 시점부터 최종
    %     모의기간까지의 경계 고도
    
    % A. 침식기준면의 본격적 하강 시점
    waveArrivalTime = round(waveArrivalTime * TIME_STEPS_NO);
    if waveArrivalTime == 0
        waveArrivalTime = 1;
    end

    % B. 본격적 하강시점부터 모의기간 끝까지의 경계고도의 변화율
    % * 원리: 본격적인 침식 기준면 하강 시기의 고도에서부터 (이미 정의된) 최종
    %   침식 기준면 고도까지 하강함. 따라서 남은 기간동안 최종 침식 기준면
    %   고도까지 도달하는데 필요한 연간 고도 변화율을 구함
    dElevAfterWaveArrival = - (topBndElev(waveArrivalTime) - Y_TOP_BND_FINAL_ELEV) ...
        / (TIME_STEPS_NO - waveArrivalTime);
    
    % C. 경계 고도
    topBndElev(waveArrivalTime + 1:TIME_STEPS_NO) ...
        = topBndElev(waveArrivalTime) ...
        + dElevAfterWaveArrival * (1:TIME_STEPS_NO - waveArrivalTime);
    
else
    
    topBndElev = 0;
    
end

end % DefineUpliftRateDistribution end