% =========================================================================
%> @section INTRO DefineUpliftRateDistribution ���Լ�
%>
%> - �������� ������ �ð��� ������ �����ϴ� �Լ�
%>  - �� �Լ��� ���� �ð��������� ��������� �������⸦ ������. ���� �浿��
%>    ��� �������⵵ ���� ������
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval meanUpliftRateSpatialDistribution    : (���ǱⰣ ���) ���� �������� ������ ����
%> @retval upliftRateTemporalDistribution       : (���ǱⰣ) ���� �������� �ð��� ����
%> @retval meanUpliftRateAtUpliftAxis           : �������� (���ǱⰣ ���) ���� ������
%> @retval topBndElev                           : �ܰ� �� ��迡���� ��
%>
%> @param Y                                     : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                                     : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                                 : ���� ���� Y ���� ��ǥ��(=2)
%> @param X_INI                                 : ���� ���� X ���� ��ǥ��(=2)
%> @param Y_MAX                                 : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_MAX                                 : ���� ���� X ������ ��ǥ��(=X+1)
%> @param dX                                    : �� ũ�� [m]
%> @param TIME_STEPS_NO                         : �� ���� Ƚ��
%> @param TOTAL_ACCUMULATED_UPLIFT              : (�����࿡��) ���� �Ⱓ ������ ���� ���ⷮ [m]
%> @param dT                                    : �������� �����Ⱓ [year]
%> @param IS_TILTED_UPWARPING                   : �浿�� ��� �������� ��� ����
%> @param UPLIFT_AXIS_DISTANCE_FROM_COAST       : ���� �ؾȼ����κ��� ����������� �Ÿ� [m]
%> @param TOP_BOUNDARY_ELEV_COND                : �ܰ� �� ��� ����
%> @param Y_TOP_BND_FINAL_ELEV                  : �ܰ� �� ����� ���� �� [m]
%> @param RAMP_ANGLE_TO_TOP                     : (���� ���� ���ⷮ�� ����) �����࿡�� �� ������ �� [radian]
%> @param UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND: �������� �ð��� ���� ����
%> @param dUpliftRate                           : (������ ���� ���� ����) ��� ���� �������� �������� �ִ� �ּ� �������� ���� ����
%> @param acceleratedUpliftPhaseNo              : (������ ���� ���� ����) ���ǱⰣ ���� ���� �������� �߻��ϴ� ��
%> @param upliftRate0                           : (������ ����-���� ���� ����) ������ ��������� �ʱ� ������ [m/year]
%> @param waveArrivalTime                       : (�浿�� ��� �������� ����) ���� �ܰ� ��� ���� ���������� �ϰ��ϴ� ���� (���� �Ⱓ���� ����)
%> @param initUpliftRate                        : (�浿�� ��� �������� ����) ������ �ϰ� ���� ħ�� ���ظ� �ϰ��� [m/year]
% =========================================================================
function [meanUpliftRateSpatialDistribution,upliftRateTemporalDistribution,meanUpliftRateAtUpliftAxis,topBndElev] = DefineUpliftRateDistribution(Y,X,Y_INI,X_INI,Y_MAX,X_MAX,dX,TIME_STEPS_NO,TOTAL_ACCUMULATED_UPLIFT,dT,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST,TOP_BOUNDARY_ELEV_COND,Y_TOP_BND_FINAL_ELEV,RAMP_ANGLE_TO_TOP,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND,dUpliftRate,acceleratedUpliftPhaseNo,upliftRate0,waveArrivalTime,initUpliftRate)
%
% function DefineUpliftRateDistribution
%

% ��� ����
YEONGSEO_ELEV = 1;          % �浿�� ��� ���������� ������ �ܰ� ��� �� ����
CONSTANT_UPLIFTRATE = 1;    % ������ ����
INTERMITTENT_UPLIFT = 2;    % ������ ����
% DECAYING_UPLIFTRATE = 3;  % ������ ����

RAMP_ANGLE_TO_BOTTOM ...
    = TOTAL_ACCUMULATED_UPLIFT / UPLIFT_AXIS_DISTANCE_FROM_COAST;

% 1. �������� ������ ������ ������
if IS_TILTED_UPWARPING == true
    
    % 1) �浿�� ��� �������⸦ ������ ���
    
    % (1) ������������ ��ǥ ���ϱ�
    TOP_BOTTOM_DISTANCE = Y * dX;
    upliftAxisY ...
        = round((TOP_BOTTOM_DISTANCE - UPLIFT_AXIS_DISTANCE_FROM_COAST) / dX) ...
        + Y_INI;

    % (2) (���ǱⰣ ����) ���� �������� ������ ���� [m/TIME_STEPS_NO]
    totalAccumulatedUplift = zeros(Y+2,1);

    totalAccumulatedUplift(Y_INI:upliftAxisY) ...
        = TOTAL_ACCUMULATED_UPLIFT ...
        - RAMP_ANGLE_TO_TOP * ((upliftAxisY-Y_INI)*dX:-dX:0);

    totalAccumulatedUplift(upliftAxisY:Y_MAX) ...
        = TOTAL_ACCUMULATED_UPLIFT ...
        - RAMP_ANGLE_TO_BOTTOM * (0:dX:(Y_MAX-upliftAxisY)*dX);

    % (3) ���ǱⰣ ��� �������� ������ ���� [m/dT]
    meanUpliftRateSpatialDistribution = totalAccumulatedUplift / TIME_STEPS_NO;
    meanUpliftRateSpatialDistribution ... % 1���� -> 2����
        = repmat(meanUpliftRateSpatialDistribution,1,X+2);
    
    % (4) �������� (���ǱⰣ ���) ������ [m/dT]
    meanUpliftRateAtUpliftAxis ...
        = totalAccumulatedUplift(upliftAxisY) / TIME_STEPS_NO;
        
else

    % 2) �������� ������ ������ �������� ���,
    
    % (1) (���ǱⰣ ���) �������� ������ ����
    meanUpliftRateSpatialDistribution = zeros(Y+2,X+2);
    meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = TOTAL_ACCUMULATED_UPLIFT / TIME_STEPS_NO;
    
    % (2) �������� (���ǱⰣ ���) ������ [m/dT]
    meanUpliftRateAtUpliftAxis ...
        = TOTAL_ACCUMULATED_UPLIFT / TIME_STEPS_NO;
    
end

% 2. ���ǱⰣ ���� ���� �������� �ð��� ����
t = 1:TIME_STEPS_NO;

if UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND == CONSTANT_UPLIFTRATE
    
    % 1) �������� ������ ���
    
    % (1) ������ ����: �������� (���ǱⰣ ���) �������� ������
    upliftRateTemporalDistribution ...
        = ones(TIME_STEPS_NO,1) * meanUpliftRateAtUpliftAxis;    
    
elseif UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND == INTERMITTENT_UPLIFT
    
    % 2) ���������� �������� ū ���
    % * ����: (���ǱⰣ ���) �������� �������� ���� ���� ��ŭ�� ���ϰų� ��
    acceleratedUpliftRate ...   % ���� �ñ��� ������ [m/dT]
        = meanUpliftRateAtUpliftAxis * (1 + dUpliftRate); 
    deceleratedUpliftRate ...   % ���� �ñ��� ������ [m/dT]
        = meanUpliftRateAtUpliftAxis * (1 - dUpliftRate);
    % ���� ������ �󵵿� ���� ���ǱⰣ ������ ������ �ֱ� ����
    w = acceleratedUpliftPhaseNo * (2 * pi) / TIME_STEPS_NO;    
    upliftRateTemporalDistribution = - sin(w * t);    
    upliftRateTemporalDistribution(upliftRateTemporalDistribution >= 0) ...
        = acceleratedUpliftRate;
    upliftRateTemporalDistribution(upliftRateTemporalDistribution < 0) ...
        = deceleratedUpliftRate;
    
else % upliftRateTemporalDistribution == DECAYING_UPLIFTRATE
    
    % 3) �������� �����ϴ� ���
    % * ����: t�� ���� ������(dU/dt)�� t�� ���� ������(U,upliftRate)��
    %   �����. �ʱ� �������� �־��� ���, �������� �������� �ð��� ������
    %   ������. ���⼭ ���ǱⰣ ������ ���� ������(integral of U)�� ��������
    %   ���� �������� ���ƾ� �Ѵ�.
    
    % (�ɺ��� ��ü�� �̿���) ������ K ���ϱ�
    syms time K;
    
    U = (upliftRate0 * dT) ...      % [m/dT] ������ȯ
        * exp(K*time);              % ������ ���� �Լ�
    integralU = int(U,'time',0,TIME_STEPS_NO); % (���� �Ⱓ) ���� �Լ� ���а�
    % �׵��: ���� �Լ� ���а� - ���� ���ⷮ = 0
    identicalEquation = integralU - TOTAL_ACCUMULATED_UPLIFT;
    solvedK = double(solve(identicalEquation,K)); % ���� ����� �����
    
    upliftRateTemporalDistribution = (upliftRate0 * dT) ... % [m/dT] ������ȯ
        * exp(solvedK*t);
    
end

% 3. �� �ܰ� ��� ��[m]�� �ð��� ����
if TOP_BOUNDARY_ELEV_COND == YEONGSEO_ELEV
    
    % 1) �浿�� ��� ���������� ������ ���
    
    % (1) ��(����) �ܰ� ��� ���� �ð��� ���� �ʱ�ȭ
    % * ����: �������� ħ�� ���ظ� �ϰ� �ñ� ������ �ܰ� ��� ���� ���� ���
    %   ������ ���� ���� ħ�� ���ظ� �ϰ����� �� ���� ��� ������
    % * ����: �ϱ� ���� ���� ���� ������ ������ ��ϳ�? ...
    topBndElev = cumsum(upliftRateTemporalDistribution) ...
        .* (meanUpliftRateSpatialDistribution(Y_INI,X_INI) ...
        ./ meanUpliftRateAtUpliftAxis) - initUpliftRate;
    
    % (2) ��� ��(ħ�ı��ظ�)�� ���������� �������� �������� ����
    %     ���ǱⰣ������ ��� ��
    
    % A. ħ�ı��ظ��� ������ �ϰ� ����
    waveArrivalTime = round(waveArrivalTime * TIME_STEPS_NO);
    if waveArrivalTime == 0
        waveArrivalTime = 1;
    end

    % B. ������ �ϰ��������� ���ǱⰣ �������� ������ ��ȭ��
    % * ����: �������� ħ�� ���ظ� �ϰ� �ñ��� ���������� (�̹� ���ǵ�) ����
    %   ħ�� ���ظ� ������ �ϰ���. ���� ���� �Ⱓ���� ���� ħ�� ���ظ�
    %   ������ �����ϴµ� �ʿ��� ���� �� ��ȭ���� ����
    dElevAfterWaveArrival = - (topBndElev(waveArrivalTime) - Y_TOP_BND_FINAL_ELEV) ...
        / (TIME_STEPS_NO - waveArrivalTime);
    
    % C. ��� ��
    topBndElev(waveArrivalTime + 1:TIME_STEPS_NO) ...
        = topBndElev(waveArrivalTime) ...
        + dElevAfterWaveArrival * (1:TIME_STEPS_NO - waveArrivalTime);
    
else
    
    topBndElev = 0;
    
end

end % DefineUpliftRateDistribution end