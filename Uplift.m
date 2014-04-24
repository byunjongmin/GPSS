% =========================================================================
%> @section INTRO RockWeathering
%>
%> - 모델 영역에 지반융기를 반영하고, 융기로 인한 고도 변화율을 구하는 함수.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev                      : 지반융기율이 반영된 기반암 고도 [m]
%>
%> @param Y_INI                             : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                             : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                             : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                             : 모형 영역 X 마지막 좌표값(=X+1)
%> @param bedrockElev                       : 기반암 고도 [m]
%> @param ithTimeStepUpliftRate             : i 번째 단위 시간의 평균 융기율
%> @param meanUpliftRateSpatialDistribution : 모의 기간 동안의 평균 융기율 분포
%> @param meanUpliftRateAtUpliftAxis        : 모의 기간 동안 융기율의 평균 융기율
% =========================================================================
function bedrockElev = Uplift(Y_INI,Y_MAX,X_INI,X_MAX,bedrockElev,ithTimeStepUpliftRate,meanUpliftRateSpatialDistribution,meanUpliftRateAtUpliftAxis)
%
% function Uplift
%

bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
    + (meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
    ./ meanUpliftRateAtUpliftAxis) ...
    * ithTimeStepUpliftRate;

end % Uplift end