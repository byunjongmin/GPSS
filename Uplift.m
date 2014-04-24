% =========================================================================
%> @section INTRO RockWeathering
%>
%> - �� ������ �������⸦ �ݿ��ϰ�, ����� ���� �� ��ȭ���� ���ϴ� �Լ�.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev                      : ������������ �ݿ��� ��ݾ� �� [m]
%>
%> @param Y_INI                             : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                             : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                             : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                             : ���� ���� X ������ ��ǥ��(=X+1)
%> @param bedrockElev                       : ��ݾ� �� [m]
%> @param ithTimeStepUpliftRate             : i ��° ���� �ð��� ��� ������
%> @param meanUpliftRateSpatialDistribution : ���� �Ⱓ ������ ��� ������ ����
%> @param meanUpliftRateAtUpliftAxis        : ���� �Ⱓ ���� �������� ��� ������
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