% =========================================================================
%> @section INTRO AdjustBoundary
%>
%> - ������ǿ� ���� �ܰ� ����� ��ݾ� ���� ������ �β��� �����ϴ� �Լ�
%>
%>  - ����: ���� ��迡���� ��ü���� ���������ۿ��� �߻����� ����. ������ ����
%>    ��� ������ ��� �� ������ �����ϴµ� �� �ʿ��� ���� �ܰ� ����� ���̸�
%>    ���⼭�� �̸� ������. �� �Լ��� ������ǿ� ���� ��(= ��ݾ� �� +
%>    ������ �β�)�� �����ϴµ�, ������ �β��� �׻� 0���� �����ϰ� ��ݾ� ����
%>    ������ǿ� ���� �޸� ������
%>
%>  - ����: �ܰ� ��������� 1) �ܰ� ���� ���� ���� ���� ���� ������������
%>    ���ų� ������ ���� 2) �ٸ� ���(��: �ܰ� ��迡 �������� ��ġ�ϴ� ���)��
%>    ũ�� �����Ͽ� ������ �� �� ����.\n
%>    1)�� ���� (1) ������� �ؼ����� �ϰ����� ���� �ϱ��κ����� ħ�� wave��
%>    �ܰ� ��迡 �����ϰ� �̰��� ����ϸ鼭 ħ�� ���ظ��� �ϰ��ϴ� ���,
%>    (2) ���� ������ �ܰ��� ���� ������ �̷�� ħ�� ���ظ��� �����Ǵ� ���,
%>    (3) ������� �ؼ����� ������� ���� �ϱ��� ���� ������ �����Ǿ� ħ��
%>    ���ظ��� ����ϴ� ���� ���� ���� �� ����.\n
%>    (2)�� ���� �ʱ� �������� ���� ���·��� �ߴ��� ������ �� ������ ���
%>    �����̶� ���� �����.\n
%>    (3)�� ���� �ؾȼ��� �� �ܰ��� ������ ���� ħ�� ���ظ��� �����ǳ�, ����
%>    ���ηα��� ������ ��� ħ�� ���ظ��� ����ϰ� �Ǵµ� ����μ��� ������ �� ����.\n
%>    2)�� ���� ���� ������ ��������� ���� ���� ��������� ��� ����
%>    �����Ǿ� ħ�� ���ظ��� �ϰ��ϴ� ��찡 ��ǥ���� ����.
%>
%>  - ����: ���������� 1)�� (1)�� (2)�� �����ϰ� ������. �ᱹ �ܰ� ��� ����
%>    ���� �� ���� ���� ��������� �������� ������. ������ �� ��쿡 ���� �Ⱓ
%>    ���� ������������ �ð��� ������ �ܰ� ���� ħ�� wave�� ������ ��������
%>    ���۵Ǹ� �̷� ���� �������� �� ��ȭ���� �ش���. �׸��� ���� �Ⱓ ������
%>    �� �������ⷮ�� ħ�� wave�� �ܰ� ��踦 ����ϸ鼭 ������ ���� ����Ŵ.
%>
%>  - �ֿ� ����:
%>   - BOUNDARY_OUTFLOW_COND: ���ⱸ �Ǵ� �������κ����� ������ �߻��ϴ� �ܰ� �������
%>    - 0: ONE_OUTLET, �ϳ��� ���ⱸ
%>    - 1: BOTTOM_BOUNDARY, �Ʒ� ���鿡�� ������ �߻���
%>    - 2: TOP_BOTTOM_BOUNDARY, ���� �Ʒ� ���鿡�� ������ �߻���
%>    - 4: ALL_BOUNDARY, ��� �鿡�� ������ �߻���
%>   - BOUNDARY_ELEV_COND: �ܰ� ��� �� ����
%>    - 0: CONSTANT_ELEV, 1)�� (1) �Ǵ� 2)
%>    - 1: YEONGSEO_ELEV, �浿�� ��� �������� � ���ǿ����� ������ �ܰ� ���
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev              : ��� ������ �ݿ��� ��ݾ� �� [m]
%> @retval sedimentThick            : ��� ������ �ݿ��� ������ �β� [m]
%>
%> @param Y_INI                     : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                     : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                     : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                     : ���� ���� X ������ ��ǥ��(=X+1)
%> @param Y_TOP_BND                 : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND              : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND               : ���� �ܰ� �� ��� X ��ǥ��
%> @param bedrockElev               : ��ݾ� �� [m]
%> @param sedimentThick             : ������ �β� [m]
%> @param OUTER_BOUNDARY            : ���� ���� �ܰ� ��� ����ũ
%> @param BOUNDARY_OUTFLOW_COND     : ���ⱸ �Ǵ� �������κ����� ������ �߻��ϴ� �ܰ� �������
%> @param TOP_BOUNDARY_ELEV_COND    : �� �ܰ� ��� �� ����
%> @param topBndElev                : �ܰ� �� ��迡���� �� [m]
%> @param ithTimeStep               : i��° ���� �ð�
% =========================================================================
function [bedrockElev,sedimentThick] = AdjustBoundary(Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,bedrockElev,sedimentThick,OUTER_BOUNDARY,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND,topBndElev,ithTimeStep,meanUpliftRateAtUpliftAxis)
%
% function AdjustBoundary
%

% ��� ����
X_MID = round((X_MAX - X_INI) * 0.5);

% BOUNDARY_OUTFLOW_COND �±�
ONE_OUTLET_MID_BOTTOM = 0;
BOTTOM_BOUNDARY = 1;
TOP_BOTTOM_BOUNDARY = 2;
ONE_OUTLET_LEFT_EDGE = 3;
ALL_BOUNDARY = 4;

% BOUNDARY_ELEV_COND �±�
YEONGSEO_ELEV = 1;

% 1. �ܰ� ��� ������ �β� ����
sedimentThick(OUTER_BOUNDARY) = 0;

% 2. �ܰ� ��� ��ݾ� �� ����

% 1) ���ⱸ �Ǵ� �������κ����� ������ �߻��ϴ� �ܰ� ��� ��ġ�� Ȯ����
if BOUNDARY_OUTFLOW_COND == ONE_OUTLET_MID_BOTTOM
    
    % (1) �ϳ��� ���ⱸ�� ���� ���
    
    % A. �ܰ� ��� �� �ʱ�ȭ
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. ���ⱸ�� ��� �� ������ 1)�� (1) �Ǵ� (2)��
    bedrockElev(Y_BOTTOM_BND,X_MID) = 0; % mid bottom
    
elseif BOUNDARY_OUTFLOW_COND == ONE_OUTLET_LEFT_EDGE
    
    % (1) �ϳ��� ���ⱸ�� ���� ���
    
    % A. �ܰ� ��� �� �ʱ�ȭ
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. ���ⱸ�� ��� �� ������ 1)�� (1) �Ǵ� (2)��
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND) = 0; % edge bottom
    
elseif BOUNDARY_OUTFLOW_COND == BOTTOM_BOUNDARY
    
    % (2) �Ʒ� ���鿡�� ������ �߻��� ���
    
    % A. �ܰ� ��� �� �ʱ�ȭ
    bedrockElev(OUTER_BOUNDARY) = inf;
    
    % B. 1)�� (1) �Ǵ� (2) ������
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
    
elseif BOUNDARY_OUTFLOW_COND == TOP_BOTTOM_BOUNDARY
    
    % (3) ��, �Ʒ� ���鿡�� ������ �߻��� ���
    
    % A. �¿� ��� �ʱ�ȭ
    bedrockElev(Y_INI:Y_MAX,X_LEFT_BND) = inf;
    bedrockElev(Y_INI:Y_MAX,X_RIGHT_BND) = inf;
        
    % B.�Ʒ��� ������ 1)�� (1) �Ǵ� (2) �����
    bedrockElev(Y_BOTTOM_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
        
    % C. ���� ���� ������ Ȯ����
    if TOP_BOUNDARY_ELEV_COND ~= YEONGSEO_ELEV
        
        % A) 1)�� (1) �Ǵ� (2) ���
        bedrockElev(Y_TOP_BND,X_LEFT_BND:X_RIGHT_BND) = 0;
                 
    else % TOP_BOUNDARY_ELEV_COND == YEONGSEO_ELEV
        
        % B) �浿�� ��� ���������� ������ ���
        % * ����: �ܰ� ���(���ⱸ)�� ���� DefineUpliftRateDistribution
        %   �Լ����� ������ ��� ����
        
        % (A) �� ���� �� �ʱ�ȭ
        bedrockElev(Y_TOP_BND,X_LEFT_BND:X_RIGHT_BND) = inf;
                
        % (B) ���ⱸ �� ����
        bedrockElev(Y_TOP_BND,X_MID) = topBndElev(ithTimeStep);
    
    end
    
else % BOUNDARY_OUTFLOW_COND == ALL_BOUNDARY
    
    % (4) ��� ���鿡�� ������ �߻��� ���
    
    % A. 1)�� (1) �Ǵ� (2) ���
    bedrockElev(OUTER_BOUNDARY) ...
        = bedrockElev(OUTER_BOUNDARY) - meanUpliftRateAtUpliftAxis;
        
end

end % AdjustBoundary end